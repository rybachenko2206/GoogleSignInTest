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
    
    private var selectedItem: PlaceClusterItem?
    
    // Used when places is not received from Firebase
    // but it's selected on Places list
    private var selectedPlace: Place?
    
    
    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        setupClusterManager()
        bindViewModel()

        setInitialLocation()
    }
    
    
    // MARK: - Actions
    @IBAction func currentLocationButtonTapped(_ sender: UIButton) {
        moveToCurrentLocation()
    }
    
    
    // MARK: - Public funcs
    func showPlace(_ place: Place) {
        if let clusterItem = viewModel.placeItems.first(where: { $0.place.id == place.id }) {
            selectedItem = clusterItem
            let mapZoom = mapView.camera.zoom > Constants.maxClusterZoom ? mapView.camera.zoom : Constants.maxClusterZoom + 1
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.selectedMarkerDelay , execute: {
                self.mapView.camera = GMSCameraPosition(target: place.position,
                                                        zoom: mapZoom,
                                                        bearing: 0,
                                                        viewingAngle: 0)
            })
            
        } else {
            selectedPlace = place
        }
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
        
        viewModel.placeReceived = { [weak self] clusterItem in
            DispatchQueue.main.async {
                if clusterItem.place.id == self?.selectedPlace?.id {
                    self?.selectedItem = clusterItem
                    self?.selectedPlace = nil
                }
                self?.addPlaceItem(clusterItem)
            }
        }
        
        viewModel.placeRemoved = { [weak self] marker in
            self?.removePlaceItem(marker)
        }
    }
    
    private func moveToCurrentLocation() {
        guard let coordinate = viewModel.locationManager.location?.coordinate else { return }
        let camera = GMSCameraPosition(target: coordinate,
                                       zoom: mapView.camera.zoom,
                                       bearing: 0,
                                       viewingAngle: 0)
        mapView.camera = camera
    }
    
    private func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    private func setInitialLocation() {
        var coordinate = viewModel.locationManager.location?.coordinate ?? Constants.initialCoordinate
        var zoom = Constants.mapViewDefaultZoom
        
        if let place = selectedPlace {
            coordinate = place.position
            zoom = Constants.maxClusterZoom + 1
        }
        
        if CLLocationManager.locationServicesEnabled()  {
            mapView.isMyLocationEnabled = true
        } else {
            viewModel.locationManager.requestWhenInUseAuthorization()
        }
        let cameraPos = GMSCameraPosition(target: coordinate,
                                          zoom: zoom,
                                          bearing: 0,
                                          viewingAngle: 0)
        mapView.camera = cameraPos
    }
    

    private func addPlaceItem(_ placeItem: PlaceClusterItem) {
        DispatchQueue.main.async { [weak self] in
            self?.clusterManager.add(placeItem)
            self?.clusterManager.cluster()
        }
    }
    
    
    private func removePlaceItem(_ placeItem: PlaceClusterItem) {
        DispatchQueue.main.async { [weak self] in
            self?.clusterManager.remove(placeItem)
            self?.clusterManager.cluster()
        }
    }
    
    private func addNewPlace(with coordinate: CLLocationCoordinate2D) {
        AlertsManager.showAlertAddNewPlace(to: self, okCompletion: { [weak self] placeName in
            var name = placeName
            if placeName.isEmpty {
                let count = (self?.viewModel.placeItems.count ?? 0) + 1
                name = "Place \(count)"
            }
            
            let newPlace = Place(name: name, coordinates: coordinate)
            self?.viewModel.addNewPlace(newPlace)
        })
    }
    
    private func setSelectedMarker(_ marker: GMSMarker, delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
            self?.mapView.selectedMarker = marker
        })
    }
    
}

extension MapViewController {
    struct Constants {
        static let initialCoordinate = CLLocationCoordinate2DMake(50.450648, 30.523117)
        static let mapViewDefaultZoom: Float = 6
        static let maxRadius = 30_000
        static let maxClusterZoom: Float = 10
        static let selectedMarkerDelay: TimeInterval = 0.5
    }
}

// MARK: - —GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if mapView.selectedMarker == marker {
            mapView.selectedMarker = nil
            selectedItem = nil
        } else {
            mapView.selectedMarker = marker
        }

        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = nil
        selectedItem = nil
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


extension MapViewController: GMUClusterRendererDelegate {
    
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        switch object {
        case let clusterItem as PlaceClusterItem:
            let marker = PlaceMarker(clusterItem.place)
            if clusterItem.place.id == selectedItem?.place.id {
                setSelectedMarker(marker, delay: Constants.selectedMarkerDelay)
            }
            return marker
            
        default:
            return nil
        }
    }
    
}
