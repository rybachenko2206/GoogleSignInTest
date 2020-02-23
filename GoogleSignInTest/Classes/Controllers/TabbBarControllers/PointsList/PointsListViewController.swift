//
//  PointsListViewController.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 21.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit


class PointsListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyResponseView: UIView!
    
    
    // MARK: - Properties
    let viewModel = PointsListViewModel()

    
    // MARK: - Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupTableView()
        bindViModel()
    }
    

    // MARK: - Private funcs
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        
        tableView.registerCell(PlaceCell.self)
    }
    
    private func bindViModel() {
        viewModel.placesReceived = { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlacesReceived()
            }
        }
        
        viewModel.errorReceived = { [weak self] error in
            DispatchQueue.main.async {
                self?.handleReceivedError(error)
            }
        }
    }
    
    private func handlePlacesReceived() {
        tableView.reloadData()
        emptyResponseView.isHidden = viewModel.places.count > 0
    }
    
    private func handleReceivedError(_ error: Error) {
        AlertsManager.showServerErrorAlert(with: error, to: self)
        emptyResponseView.isHidden = true
    }
    
}


// MARK: - UITableViewDataSource
extension PointsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let place = viewModel.places[safe: indexPath.row] else { return UITableViewCell () }
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: PlaceCell.self)
        cell.nameLabel.text = place.name
        cell.latitudeLabel.text = place.coordinates.latitude.description
        cell.longitudeLabel.text = place.coordinates.longitude.description
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension PointsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: move to mapView at location..
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaceCell.height
    }
    
}


