//
//  BurritoListUITaTableViewController.swift
//  BurritoPlaces
//
//  Created by Kevin Wang on 5/22/18.
//  Copyright © 2018 Kevin Wang. All rights reserved.
//

import UIKit
import GooglePlaces


class BurritoListUITaTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // MARK: - Constants
    
    private struct Constants {
        static let DefaultCellHeight : CGFloat = 120
    }
    
    private struct Storyboard {
        //Segue Identifiers
        static let BurritoTableViewCellReuseIdentifier = "Burrito Cell Identifier"
        static let BurritoTableViewCellSegueIdentifier = "Burrito Place Segue"
    }
    
    private struct StringConstants {
        
        //Text for Alert titles/buttons
        static let LocationAuthorizationAlertTitle = "Location services are disabled"
        static let LocationAuthorizationAlertBody = "Please enable location services so we can find you burritos!"
        static let LocationAuthorizationAlertSettingsButtonTitle = "Settings"
        static let LocationAuthorizationAlertCancelButtonTitle = "Cancel"
        
        static let UnableToFindBurritosAlertTitle = "We were unable to find any burritos near you"
        static let UnableToFindBurritosAlertBody = "You will have to look elsewhere for burritos"
        static let UnableToFindBurritosAlertButton = "Got it"
        
        static let LocationSearchKeyword = "burrito"
    }
    
    
    private struct GMSPlaceTypes {
        static let Restaurants = "restaurant"
        static let Cafes = "cafe"
        static let Takeout = "meal_takeaway"
        static let Delivery = "meal_delivery"
        static let Bar = "bar"
        static let Bakery = "bakery"
        static let Food = "food"
    }
    
    
    // MARK: - Model
    var nearbyRestaurants : [BurritoRestaurant] = []
    
    // MARK: - Properties
    private var placesClient : GMSPlacesClient!
    
    private lazy var tableviewRefreshControl : UIRefreshControl = {
        
        let pulldownRefresh = UIRefreshControl()
        
        pulldownRefresh.addTarget(self, action: #selector(getNewLocations), for: .valueChanged)
        
        pulldownRefresh.tintColor = UIColor.purple
        return pulldownRefresh
    }()
    
    private lazy var locationManager : CLLocationManager = {
       let locManager = CLLocationManager()
        locManager.delegate = self
        return locManager
    }()
    
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup GMSPlacesClien
        placesClient = GMSPlacesClient.shared()
        
        //Add pulldown to refresh to tableview controller
        tableView.refreshControl = tableviewRefreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewLocations()
    }
    
    // MARK: - Network call functions
    @objc private func getNewLocations() {
        
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        //Check authorization status
        switch locationAuthorizationStatus {
        case .denied:
            fallthrough
        case .restricted :
            
            let alert = UIAlertController(title: StringConstants.LocationAuthorizationAlertTitle, message: StringConstants.LocationAuthorizationAlertBody, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: StringConstants.LocationAuthorizationAlertSettingsButtonTitle, style: .default, handler: { (action) in
                
                guard let appSettingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(appSettingsURL) {
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: StringConstants.LocationAuthorizationAlertCancelButtonTitle, style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
        
        //Pull locations based on users location
        getLocations()
        
    }
    
    private func getLocations() {
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        placesClient.currentPlace { [weak self] (places, error) in
            
            self?.nearbyRestaurants = []
            self?.tableView.refreshControl?.endRefreshing()
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            //Attempt to pull nearby places matching "types" along with a search keyword
            guard let nearbyPlaces = self?.pullPlaces(fromLikelihoods: places, withTypesToFind: [GMSPlaceTypes.Cafes, GMSPlaceTypes.Restaurants, GMSPlaceTypes.Bakery, GMSPlaceTypes.Bar, GMSPlaceTypes.Delivery, GMSPlaceTypes.Food], withSearchTerm: StringConstants.LocationSearchKeyword) else {
                
                //If there are no locations, alert the user
                let noBurritosAlert = UIAlertController(title: StringConstants.UnableToFindBurritosAlertTitle, message: StringConstants.UnableToFindBurritosAlertBody, preferredStyle: .alert)
                noBurritosAlert.addAction(UIAlertAction(title: StringConstants.UnableToFindBurritosAlertButton, style: .cancel, handler: nil))
                
                self?.present(noBurritosAlert, animated: true, completion: nil)
                return
            }
            
            
            for burritoRestaurant in nearbyPlaces {
                
                let newBurritoRestaurant = BurritoRestaurant(googlePlace: burritoRestaurant)
                
                self?.nearbyRestaurants.append(newBurritoRestaurant)
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: - Google places convenience functions
    
    private func pullPlaces(fromLikelihoods : GMSPlaceLikelihoodList?, withTypesToFind userTypes : [String], withSearchTerm searchTerm : String?) -> [GMSPlace]? {
        
        guard let likelihoodList = fromLikelihoods else {
            return nil
        }

        //Pull out places from likelihoods, then find only the types user requested
        var gmsPlaces = likelihoodList.likelihoods.compactMap {
            $0.place
            }.filter {
                for type in userTypes {
                    if $0.types.contains(type) {
                        return true
                    }
                }
                return false
        }
        
        //Pull out only places that contain the entered keyword if it exists
        if let keyword = searchTerm {
            gmsPlaces = gmsPlaces.filter {
                if $0.name.lowercased().contains(keyword.lowercased()) {
                    return true
                }
                return false
            }
        }
        
        return !gmsPlaces.isEmpty ? gmsPlaces : nil
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return nearbyRestaurants.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let burritoCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BurritoTableViewCellReuseIdentifier, for: indexPath) as! BurritoTableViewCell
        
        burritoCell.currentRestaurant = nearbyRestaurants[indexPath.section]
        return burritoCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.DefaultCellHeight
    }
    
    // MARK: - CLLocationManager delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways :
            fallthrough
        case .authorizedWhenInUse :
            getLocations()
        default :
            break
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
            
        case Storyboard.BurritoTableViewCellSegueIdentifier:
            
            guard let destinationVC = segue.destination.contentViewController as? MapViewController,
                let sendingCell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: sendingCell) else {
                    break
            }
            
            destinationVC.restaurant = nearbyRestaurants[indexPath.section]
            
        default:
            break
        }
        
    }
}



extension UIViewController {
    var contentViewController : UIViewController {
        return self.navigationController?.visibleViewController ?? self
    }
}

