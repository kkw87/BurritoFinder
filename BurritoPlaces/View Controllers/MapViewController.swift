//
//  MapViewController.swift
//  BurritoPlaces
//
//  Created by Kevin Wang on 5/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let RoundedCornerRadius : CGFloat = 10
        static let MarkerImageName = "Pin"
        
        static let CameraZoomLevel : Float = 17
    }
    
    // MARK: - Model
    var restaurant : BurritoRestaurant? {
        didSet {
            setupUI()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var addressLabel: UILabel!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            containerView?.layer.cornerRadius = Constants.RoundedCornerRadius
            containerView?.clipsToBounds = true
        }
    }
    @IBOutlet private weak var mapView: GMSMapView! {
        didSet {
            let camera = GMSCameraPosition.camera(withLatitude: 1.285, longitude: 103.848, zoom: 12)
            mapView.camera = camera
            mapView.mapType = .normal
        }
    }
    
    
    // MARK: - Properties
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI Functions
    private func setupUI() {
        
        guard let burritoRestaurant = restaurant  else {
            return
        }
        
        //Set outlets
        navigationItem.title = burritoRestaurant.restaurantName
        addressLabel?.text = burritoRestaurant.restaurantAddress
        descriptionLabel?.text = burritoRestaurant.restaurantDescription
        
        //Setup the location pin marker for the map
        let mapMarker = GMSMarker()
        mapMarker.icon = UIImage(named: Constants.MarkerImageName)
        mapMarker.position = burritoRestaurant.restaurantCoordinates
        mapMarker.map = mapView
        
        //Update the position of the map to display the restaurant location
        let newPinLocation = GMSCameraPosition.camera(withTarget: burritoRestaurant.restaurantCoordinates, zoom: Constants.CameraZoomLevel)
        mapView?.camera = newPinLocation
        
    }
    
}
