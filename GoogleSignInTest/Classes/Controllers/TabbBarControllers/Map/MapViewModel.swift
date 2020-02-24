//
//  MapViewModel.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 24.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import MapKit


class MapViewModel: NSObject {
    
    let locationManager = CLLocationManager()
    var locationAuthorizationStatusChanged: Completion?
    
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
