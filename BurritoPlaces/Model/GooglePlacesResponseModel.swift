//
//  GooglePlacesResponseModel.swift
//  BurritoPlaces
//
//  Created by Kevin Wang on 5/24/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import Foundation

struct GooglePlacesResponse : Codable {
    let results : [GooglePlace]
    enum CodingKeys : String, CodingKey {
        case results = "results"
    }
}

struct GooglePlace : Codable {
    
    let geometry : Location
    let name : String
    let address : String
    let rating : Double
    let price : Int?
    
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case name = "name"
        case address = "vicinity"
        case rating = "rating"
        case price = "price_level"
    }
    
    struct Location : Codable {
        
        let location : LatLong
        
        enum CodingKeys : String, CodingKey {
            case location = "location"
        }
        
        struct LatLong : Codable {
            
            let latitude : Double
            let longitude : Double
            
            enum CodingKeys : String, CodingKey {
                case latitude = "lat"
                case longitude = "lng"
            }
        }
    }

}

//struct GooglePlacesResponse : Codable {
//
//    let results : [GooglePlace]
//
//    enum CodingKeys: String, CodingKey {
//        case results = "results"
//    }
//
//}
//
//struct GooglePlace : Codable {
//    let geometry : Location
//    let name : String
//    let price : Int
//    let rating : String
//    let address : String
//    let openingHours : OpenNow?
//    let types : [String]
//    let photos : [PhotoInfo]
//
//    enum CodingKeys : String, CodingKey {
//        case geometry = "geometry"
//        case name = "name"
//        case price = "price_level"
//        case rating = "rating"
//        case address = "vicinity"
//        case openingHours = "opening_hours"
//        case photos = "photos"
//        case types = "types"
//    }
//
//    struct Location : Codable {
//
//        let location : LatLong
//
//        enum CodingKeys: String, CodingKey {
//            case location = "location"
//        }
//
//
//        struct LatLong: Codable {
//            let latitude : Double
//            let longitude : Double
//
//            enum CodingKeys : String, CodingKey {
//                case latitude = "lat"
//                case longitude = "lng"
//            }
//        }
//    }
//
//    struct OpenNow : Codable {
//
//        let isOpen : Bool
//
//        enum CodingKeys : String, CodingKey {
//            case isOpen = "open_now"
//        }
//    }
//
//    struct PhotoInfo : Codable {
//
//        let height : Int
//        let width : Int
//        let photoReference : String
//
//        enum CodingKeys : String, CodingKey {
//            case height = "height"
//            case width = "width"
//            case photoReference = "photo_reference"
//        }
//    }
//
//}
