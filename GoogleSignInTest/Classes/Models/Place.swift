//
//  Place.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 23.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation


struct Place {
    
    // MARK: - Properties
    let placeId: String
    let ref: DatabaseReference?
    let name: String
    let coordinates: CLLocationCoordinate2D
    
    
    // MARK: - Init funcs
    init(name: String, coordinates: CLLocationCoordinate2D) {
        self.placeId = UUID().uuidString
        self.name = name
        self.coordinates = coordinates
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
            let id = value[Keys.kPlaceId] as? String,
            let name = value[Keys.kName] as? String,
            let lat = value[Keys.kLatitude] as? Double,
            let lon = value[Keys.kLongitude] as? Double
            else { return nil }
        
        self.placeId = id
        self.name = name
        self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.ref = snapshot.ref
    }
}


extension Place {
    private struct Keys {
        static let kPlaceId = "placeId"
        static let kName = "name"
        static let kLatitude = "latitude"
        static let kLongitude = "longitude"
    }
}
