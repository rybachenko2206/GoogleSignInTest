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
    let id: String
    let ref: DatabaseReference?
    let name: String
    let coordinates: CLLocationCoordinate2D
    
    static let entityName = String(describing: Place.self)
    
    
    // MARK: - Init funcs
    init(name: String, coordinates: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
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
        
        self.id = id
        self.name = name
        self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.ref = snapshot.ref
    }
    
    
    // MARK: - Public funcs
    func toAny() -> Any {
        return [
            Keys.kPlaceId: id,
            Keys.kName: name,
            Keys.kLatitude: NSNumber(floatLiteral: coordinates.latitude),
            Keys.kLongitude: NSNumber(floatLiteral: coordinates.longitude)
        ]
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
