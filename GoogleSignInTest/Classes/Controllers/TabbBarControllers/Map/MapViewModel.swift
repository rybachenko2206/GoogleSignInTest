//
//  MapViewModel.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 24.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import MapKit
import Firebase


class MapViewModel: NSObject {
    
    let locationManager = CLLocationManager()
    var locationAuthorizationStatusChanged: Completion?
    
    private (set) var places: Set<Place> = []
    private var ref: DatabaseReference?
    
    var placeReceived: ((Place) -> Void)?
    var placeRemoved: ((Place) -> Void)?
    var errorReceived: FailureHandler?
    
    override init() {
        super.init()
        
        self.ref = Database.database().reference(withPath: Place.entityName)
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func addNewPlace(_ place: Place) {
        let newRef = ref?.child(place.id)
        newRef?.setValue(place.toAny(),
                         withCompletionBlock: { [weak self] (error, _) in
                            if let error = error {
                                self?.errorReceived?(error)
                            }
        })
    }
    
    func observeReference() {
        ref?.observe(.childAdded, with: { [weak self] snapshot in
            if let newPlace = Place(snapshot: snapshot),
                self?.places.contains(newPlace) == false
            {
                self?.places.insert(newPlace)
                self?.placeReceived?(newPlace)
            }
        })
        
        ref?.observe(.childRemoved, with: { [weak self] snapshot in
            if let removedPlace = Place(snapshot: snapshot),
                self?.places.contains(removedPlace) == true
            {
                self?.places.remove(removedPlace)
                self?.placeRemoved?(removedPlace)
            }
        })
    }
}


// MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        locationAuthorizationStatusChanged?()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pl("locationManager: didFailWithError: \(error)")
    }
}
