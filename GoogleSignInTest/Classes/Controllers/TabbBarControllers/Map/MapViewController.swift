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

        setupClusterManager()
        bindViewModel()
        mapView.delegate = self
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
        viewModel.observeReference()
        
        viewModel.locationAuthorizationStatusChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.mapView.isMyLocationEnabled = true
                self?.moveToCurrentLocation()
            }
        }
        
        viewModel.placeReceived = { [weak self] place in
            DispatchQueue.main.async {
                self?.addPlaceMarker(place)
            }
        }
        
        viewModel.placeRemoved = { [weak self] place in
            self?.removePlaceMarker(place)
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
    
    fileprivate func centrateMarker(_ marker: Place) {
        let mapZoom = mapView.camera.zoom > Constants.maxClusterZoom ? mapView.camera.zoom : Constants.maxClusterZoom + 1
        mapView.camera = GMSCameraPosition(target: marker.position,
                                           zoom: mapZoom,
                                           bearing: 0,
                                           viewingAngle: 0)
    }
    

    private func addPlaceMarker(_ place: Place) {
        let marker = GMSMarker(position: place.position)
        marker.icon = place.icon
        marker.title = place.name
        marker.snippet = "What is snippet?"
        marker.map = mapView
        
//        clusterManager.add(place)
//        clusterManager.cluster()
    }
    
    
    private func removePlaceMarker(_ place: Place) {
        clusterManager.remove(place)
        clusterManager.cluster()
    }
    
    private func addNewPlace(with coordinate: CLLocationCoordinate2D) {
        AlertsManager.showAlertAddNewPlace(to: self, okCompletion: { [weak self] placeName in
            var name = placeName
            if placeName.isEmpty {
                let count = (self?.viewModel.places.count ?? 0) + 1
                name = "Place \(count)"
            }
            
            let newPlace = Place(name: name, coordinates: coordinate)
            self?.viewModel.addNewPlace(newPlace)
        })
    }
    
}

extension MapViewController {
    private struct Constants {
        static let initialCoordinate = CLLocationCoordinate2DMake(50.450648, 30.523117)
        static let mapViewDefaultZoom: Float = 6
        static let maxRadius = 30_000
        static let maxClusterZoom: Float = 1
    }
}

// MARK: - —GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if mapView.selectedMarker == marker {
            mapView.selectedMarker = nil
        } else {
            mapView.selectedMarker = marker
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = nil
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        addNewPlace(with: coordinate)
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
