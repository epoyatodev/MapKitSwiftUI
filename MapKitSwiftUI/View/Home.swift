//
//  Home.swift
//  MapKitSwiftUI
//
//  Created by Enrique Poyato Ortiz on 17/9/23.
//

import SwiftUI
import MapKit

struct Home: View {
    /// Map Properties
    @State private var cameraPosition: MapCameraPosition = .region(.myRegion)
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationScope
    @State private var viewinRegion: MKCoordinateRegion?
    /// Search Properties
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchResults: [MKMapItem] = []
    /// Map Selection Detail Properties
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    /// Route Properties
    @State private var routeDisplaying: Bool = false
    @State private var route : MKRoute?
    @State private var routeDestination: MKMapItem?
    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection , scope: locationScope) {
                Marker("Córdoba", systemImage: "person.fill" , coordinate: .mylocation)
                    .tint(.black)
                    .annotationTitles(.hidden)
                
                ForEach(searchResults, id: \.self) { mapItem in
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                    } else {
                        let placemark = mapItem.placemark
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                            .tint(.blue)
                    }
                }
                
                /// Display Route usign PolyLine
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                
                
                UserAnnotation()
            }
            .onMapCameraChange ({ ctx in
                viewinRegion = ctx.region
            })
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 15) {
                    MapCompass(scope: locationScope)
                    MapPitchToggle(scope: locationScope)
                    MapUserLocationButton(scope: locationScope)
                    
                }
                .buttonBorderShape(.circle)
                .padding()
            }
            .mapScope(locationScope)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, isPresented: $showSearch)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            /// When Route Displaying Hiding Top And Bottom bar
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .sheet(isPresented: $showDetails, content: {
                MapDetailView(lookAroundScene: $lookAroundScene, showDetails: $showDetails, mapSelection: $mapSelection, fetchRoute: fetchRoute)
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            })
            .safeAreaInset(edge: .bottom) {
                if routeDisplaying {
                    Button("End Route"){
                        withAnimation(.snappy){
                            routeDisplaying = false
                            showDetails = true
                            mapSelection = routeDestination
                            routeDestination = nil
                            route = nil
                            cameraPosition = .region(.myRegion)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.red.gradient, in: .rect(cornerRadius: 15))
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
        }
        .onSubmit(of: .search) {
            Task{
                guard !searchText.isEmpty else { return }
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                searchResults.removeAll(keepingCapacity: false)
                showDetails = false
                /// Zooming Out to User Region when Search Cancelled
                withAnimation(.snappy) {
                    cameraPosition = .region(.myRegion)
                }
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
            /// Fetching Look Around previews
            fetchLookAroundPreview()
        }
        
    }
    
    /// Search Places
    
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = viewinRegion ?? .myRegion
        
        let results = try? await MKLocalSearch(request: request).start()
        searchResults = results?.mapItems ?? []
    }
    
    /// Fetching Location Previews
    
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    /// Fetching Route
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = .init(placemark: .init(coordinate: .mylocation))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    /// Zooming
                    if let boundingRect = route?.polyline.boundingMapRect {
                        cameraPosition = .rect(boundingRect)
                    }
                }
                
            }
        }
        
    }
}

#Preview {
    Home()
}
