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
    }
    
    
    // MARK: - Public funcs
    func removePlace(at index: Int) {
        guard let item = places[safe: index] else { return }
        item.ref?.removeValue()
        places.remove(at: index)
    }
    
    
    // MARK: - Private funcs
    private func observeReference() {
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
            
            self?.places = newItems.sorted(by: { $0.name < $1.name })
            self?.placesReceived?()
            
            }, withCancel: { [weak self] error in
                DispatchQueue.main.async {
                    self?.errorReceived?(error)
                }
        })
    }
    
}

