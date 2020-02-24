//
//  MapViewController.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit
import GoogleMaps


class MapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = MapViewModel()
    
    private var clusterManager: GMUClusterManager!
    
    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkLocationStatus()
    }
    
    
    // MARK: - Actions
    
    @IBAction func currentLocationButtonTapped(_ sender: UIButton) {
        moveToCurrentLocation()
    }
    
    
    // MARK: - Private funcs
    
    private func bindViewModel() {
        viewModel.locationAuthorizationStatusChanged = { [weak self] in
            self?.mapView.isMyLocationEnabled = true
            self?.moveToCurrentLocation()
        }
    }
    
    private func moveToCurrentLocation() {
        guard let coordinate = viewModel.locationManager.location?.coordinate else { return }
        let camera = GMSCameraPosition(target: coordinate,
                                       zoom: Constants.mapViewDefaultZoom,
                                       bearing: 0,
                                       viewingAngle: 0)
        mapView.camera = camera
    }
    
    private func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let defRenderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: defRenderer)
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    private func checkLocationStatus() {
        var showCoord = Constants.initialCoordinate
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let loc = viewModel.locationManager.location {
                showCoord = loc.coordinate
            }
            mapView.isMyLocationEnabled = true
        } else {
            viewModel.locationManager.requestWhenInUseAuthorization()
        }
        mapView.camera = GMSCameraPosition(target: showCoord,
                                           zoom: Constants.mapViewDefaultZoom,
                                           bearing: 0,
                                           viewingAngle: 0)
    }
    
//    fileprivate func centrateMarker(_ marker: Place) {
//        let mapZoom = mapView.camera.zoom > maxClusterZoom ? mapView.camera.zoom : maxClusterZoom + 1
//        mapView.camera = GMSCameraPosition(target: marker.position,
//                                           zoom: mapZoom,
//                                           bearing: 0,
//                                           viewingAngle: 0)
//    }
    
//    private func addPlaceMarkers(_ places: [Place]) {
//        clusterManager.clearItems()
//        clusterManager.add(places)
//        allPlaces.removeAll()
//        allPlaces = Set(places)
//    }
//
//    private func addPlaceMarker(for place: Place) -> Place {
//        if let item = allPlaces.first(where: {$0.id == terminal.id}) {
//            allPlaces.remove(item)
//            allPlaces.insert(terminal)
//        } else {
//            allPlaces.insert(place)
//            clusterManager.add(place)
//        }
//
//        return terminal
//    }
    
    
}

extension MapViewController {
    private struct Constants {
        static let initialCoordinate = CLLocationCoordinate2DMake(50.450648, 30.523117)
        static let mapViewDefaultZoom: Float = 6
        static let maxRadius = 5000
        static let maxClusterZoom: Float = 13
    }
}

// MARK: - —GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }

}

// MARK: - GMUClusterManagerDelegate
extension MapViewController: GMUClusterManagerDelegate {
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return true
    }
    
}
