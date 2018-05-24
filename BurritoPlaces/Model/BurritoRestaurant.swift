//
//  BurritoRestaurant.swift
//  BurritoPlaces
//
//  Created by Kevin Wang on 5/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation
import CoreLocation
import GooglePlaces

struct BurritoRestaurant {
    
    // MARK: - Constants
    private struct Constants {
        static let DefaultDescriptionText = "-"
    }
    
    // MARK: - Properties
    let restaurantName : String
    let restaurantAddress : String
    let restaurantDescription : String
    
    let restaurantCoordinates : CLLocationCoordinate2D
    
    
    // MARK: - Init functions
    init(googlePlace : GMSPlace) {
        
        //Format address just to have the street name
        let addressString = googlePlace.formattedAddress?.components(separatedBy: ", ").first ?? ""
        
        //Setup description that combines dollar sign amounts as well as the place description
        let placeDescription = "\(googlePlace.dollarSigns) • \(googlePlace.ratingSigns)"
        
        restaurantName = googlePlace.name
        restaurantAddress = addressString
        restaurantDescription = placeDescription
        restaurantCoordinates = googlePlace.coordinate
    }
}

// MARK: - GMSPlace extensions

extension GMSPlace {
    
    var ratingSigns : String {
        switch rating {
        case 1.0:
            return "★"
        case 2.0 :
            return "★★"
        case 3.0 :
            return "★★★"
        case 4.0:
            return "★★★★"
        case 5.0:
            return "★★★★★"
        default:
            return "No reviews"
        }
    }
    
    var dollarSigns : String {
        
        switch priceLevel.rawValue {
        case 1:
            return "$$"
        case 2:
            return "$$$"
        case 3:
            return "$$$$"
        case 4:
            return "$$$$$"
        default:
            return "$"
        }
    }
}
