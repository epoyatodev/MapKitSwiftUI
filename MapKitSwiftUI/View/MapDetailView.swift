//
//  MapDetailView.swift
//  MapKitSwiftUI
//
//  Created by Enrique Poyato Ortiz on 17/9/23.
//

import SwiftUI
import MapKit

struct MapDetailView: View {
    @Binding var lookAroundScene: MKLookAroundScene?
    @Binding var showDetails: Bool
    @Binding var mapSelection: MKMapItem?
    var fetchRoute: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                if lookAroundScene == nil {
                    ContentUnavailableView("No Preview Available", systemImage: "eye.slsh")
                } else {
                    LookAroundPreview(scene: $lookAroundScene)
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    showDetails = false
                    withAnimation(.snappy) {
                        mapSelection = nil
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.black)
                        .background(.white, in: .circle)
                })
                .padding(10)
            }
            
            Button("Get Directions", action: fetchRoute)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
        }
        .padding(15)
    }
}
