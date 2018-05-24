//
//  BurritoTableViewCell.swift
//  BurritoPlaces
//
//  Created by Kevin Wang on 5/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit

class BurritoTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    private struct Constants {
        static let RoundedCornerRadius : CGFloat = 10
    }
    
    // MARK: - Model
    var currentRestaurant : BurritoRestaurant? {
        didSet {
            setupUI()
        }
    }
    
    // MARK: - Outlets
    // Restaurant Name Label
    @IBOutlet private weak var titleLabel: UILabel!
    
    // Restaurant Address Label
    @IBOutlet private weak var addressLabel: UILabel!
    
    // Restaurant Description Label
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    // MARK: - UI Setup functions
    private func setupUI() {
        
        //Make sure a restaurant is set
        guard let restaurant = currentRestaurant else {
            return
        }
        
        titleLabel.text = restaurant.restaurantName
        addressLabel.text = restaurant.restaurantAddress
        descriptionLabel.text = restaurant.restaurantDescription
        
    }
    
    private func setupCell() {
        self.layer.cornerRadius = Constants.RoundedCornerRadius
        self.clipsToBounds = true
        
    }
    
    // MARK: - Layout functions
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
        
    }
    
    
}
