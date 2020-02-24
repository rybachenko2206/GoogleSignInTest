//
//  PlaceCell.swift
//  GoogleSignInTest
//
//  Created by Roman Rybachenko on 23.02.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//

import UIKit


protocol PlaceCellDelegate: class {
    func longTap(in cell: PlaceCell)
}


class PlaceCell: UITableViewCell, ReusableCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    
    // MARK: - Properties
    weak var delegate: PlaceCellDelegate?
    
    static var height: CGFloat {
        return 77
    }
    
    // MARK: - Overriden funcs
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addLongTapGesture()
    }
    
    // MARK: - Actions
    @objc func longTap(_ sender: UILongPressGestureRecognizer) {
        delegate?.longTap(in: self)
    }
    
    
    // MARK: - Private funcs
    private func addLongTapGesture() {
        let longTapGR = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        longTapGR.minimumPressDuration = 1.0
        self.addGestureRecognizer(longTapGR)
    }
    
    
    

}
