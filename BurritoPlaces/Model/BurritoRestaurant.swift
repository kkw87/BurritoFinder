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
    
    // MARK: - Properties
    let restaurantName : String
    let restaurantAddress : String
    let restaurantDescription : String
    
    let restaurantCoordinates : CLLocationCoordinate2D
    
    
    // MARK: - Init functions
    init(googlePlace : GooglePlace) {
        
        //Format address just to have the street name
        let addressString = googlePlace.address.components(separatedBy: ", ").first ?? ""
        
        //Setup description that combines dollar sign amounts as well as the place description
        
        var ratingSigns : String {
            switch Int(googlePlace.rating) {
            case 1 :
                return "★"
            case 2 :
                return "★★"
            case 3 :
                return "★★★"
            case 4:
                return "★★★★"
            case 5:
                return "★★★★★"
            default:
                return "No reviews"
            }
        }
        
        var dollarSigns : String {
            
            switch googlePlace.price {
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
        
        
        
        let placeDescription = "\(dollarSigns) • \(ratingSigns)"
        
        restaurantName = googlePlace.name
        restaurantAddress = addressString
        restaurantDescription = placeDescription
        
        let lat = googlePlace.geometry.location.latitude
        let lng = googlePlace.geometry.location.longitude
        restaurantCoordinates = CLLocationCoordinate2DMake(lat, lng)
    }
}

