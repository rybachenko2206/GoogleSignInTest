//
//  PointsListViewModel.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 23.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

typealias Completion = () -> Void
typealias FailureHandler = (Error) -> Void

class PointsListViewModel {
    
    // MARK: - Properties
    private (set) var places: [Place] = []
    private var ref: DatabaseReference?
    
    var placesReceived: Completion?
    var errorReceived: FailureHandler?
    
    
    // MARK: - Init
    init() {
        self.ref = Database.database().reference(withPath: Place.entityName)
        self.observeReference()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            let new = Place(name: "Test Place 1", coordinates: CLLocationCoordinate2D(latitude: 1.1111, longitude: 1.1111))
            self?.addPlace(new)

        })
    }
    
    
    // MARK: - Public funcs
    func removePlace(at index: Int) {
        guard let item = places[safe: index] else { return }
        item.ref?.removeValue()
        places.remove(at: index)
    }
    
    func addPlace(_ place: Place) {
        let newRef = ref?.child(place.id)
        newRef?.setValue(place.toAny(),
                         withCompletionBlock: { [weak self] (error, _) in
                            if let error = error {
                                self?.errorReceived?(error)
                            } else {
                                self?.places.append(place)
                            }
        })
    }
    
    
    // MARK: - Private funcs
    private func observeReference() {
        //        ref?.observe(.childAdded, with: { value in
        //            pl(".childAdded snapshot in \n\(value)")
        ////            DispatchQueue.main.async { [weak self] in
        ////                if let newPlace = value as? Place {
        ////                    self?.places.append(newPlace)
        ////                }
        ////
        ////            }
        //        }, withCancel: { error in
        //            pl(".childAdded event error:\n\(error)")
        //        })
        //
        //        ref?.observe(.childRemoved, with: { [weak self] snapshot in
        //            pl(".childRemoved snapshot in \n\(snapshot)")
        //
        //            }, withCancel: { error in
        //                pl(".childRemoved event error:\n\(error)")
        //        })
        
        ref?.observe(.value, with: { [weak self] snapshot in
            pl(snapshot)
            var newItems: [Place] = []
            
            for child in snapshot.children {
                if let dataSnapshot = child as? DataSnapshot,
                    let place = Place(snapshot: dataSnapshot)
                {
                    newItems.append(place)
                }
            }
            
            self?.places = newItems.sorted(by: { $0.name > $1.name })
            self?.placesReceived?()
            
            }, withCancel: { [weak self] error in
                DispatchQueue.main.async {
                    self?.errorReceived?(error)
                }
        })
    }
    
}

