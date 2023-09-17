//
//  LocationData.swift
//  MapKitSwiftUI
//
//  Created by Enrique Poyato Ortiz on 17/9/23.
//

import MapKit

extension CLLocationCoordinate2D {
    static var mylocation: CLLocationCoordinate2D {
        return .init(latitude: 37.88842132549173,  longitude: -4.776932914940615)
    }
}
extension MKCoordinateRegion {
    static var myRegion: MKCoordinateRegion {
        return .init(center: .mylocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}
