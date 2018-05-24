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
        
        //Description in spec sheet is not available in the places API, we currently set it to the locations website or a default text if it doesnt exist
        let websiteString = googlePlace.website != nil ? "\(googlePlace.website!)" : Constants.DefaultDescriptionText
        
        //Setup description that combines dollar sign amounts as well as the place description
        let placeDescription = "\(googlePlace.dollarSigns) • \(websiteString)"
        
        restaurantName = googlePlace.name
        restaurantAddress = addressString
        restaurantDescription = placeDescription
        restaurantCoordinates = googlePlace.coordinate
    }
}
