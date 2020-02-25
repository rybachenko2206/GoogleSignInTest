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


class Place {
    
    // MARK: - Properties
    let id: String
    let ref: DatabaseReference?
    let name: String
    let position: CLLocationCoordinate2D
    
    let icon: UIImage?
    
    static let entityName = String(describing: Place.self)
    
    
    // MARK: - Init funcs
    init(name: String, coordinates: CLLocationCoordinate2D) {
        self.id = UUID().uuidString
        self.name = name
        self.position = coordinates
        self.ref = nil
        
        self.icon = Place.randMarkerIcon()
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
        self.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.ref = snapshot.ref
        self.icon = Place.randMarkerIcon()
    }
    
    
    // MARK: - Public funcs
    func toAny() -> Any {
        return [
            Keys.kPlaceId: id,
            Keys.kName: name,
            Keys.kLatitude: NSNumber(floatLiteral: position.latitude),
            Keys.kLongitude: NSNumber(floatLiteral: position.longitude)
        ]
    }
    
    private class func randMarkerIcon() -> UIImage? {
        let iconNames = ["markerRed", "markerGreen", "markerCyan", "markerOrange", "markerPurple", "markerBrown"]
        let randIndex = Int.random(in: 0..<iconNames.count)
        let iName = iconNames[randIndex]
        return UIImage(named: iName)
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


class PlaceMarker: GMSMarker {
    let place: Place
    
    init(_ place: Place) {
        self.place = place
        super.init()
        self.position = place.position
        self.icon = place.icon
        self.title = place.name
    }
    
}
