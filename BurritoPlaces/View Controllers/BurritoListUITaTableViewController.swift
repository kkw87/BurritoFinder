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
        
        static let GooglePlacesTypeSearchTerms = "restaurant+food"
        static let GooglePlacesKeywordSearchTerms = "mexican+burrito"

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
        locationManager.requestWhenInUseAuthorization()
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
            
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestLocation()
        
    }
    
    private func queryForRestaurants(aroundLocation userCoordinate : CLLocationCoordinate2D) {
        
        let userLocationLatitude = "\(userCoordinate.latitude)"
        let userLocationLongitude = "\(userCoordinate.longitude)"
        
        guard let queryURL = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userLocationLatitude),\(userLocationLongitude)&radius=1500&type=\(StringConstants.GooglePlacesTypeSearchTerms)&keyword=\(StringConstants.GooglePlacesKeywordSearchTerms)&key=\(AppDelegate.GooglePlacesAPIInfo.CurrentAPIKey)") else {
            return
        }
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.allowsCellularAccess = true
        
        let urlSession = URLSession(configuration: urlSessionConfig)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dataTask = urlSession.dataTask(with: queryURL, completionHandler: { (formData, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableviewRefreshControl.endRefreshing()
            }

            guard error == nil else {
                print("Error fetching locations: \(error!.localizedDescription) \n")
                return
            }
            
            guard let placesData = formData else {
                return
            }
            
            guard let googleJSON = try? JSONDecoder().decode(GooglePlacesResponse.self, from: placesData) else {
                return
            }
            DispatchQueue.main.async {
                self.nearbyRestaurants = googleJSON.results.map {
                    BurritoRestaurant(googlePlace: $0)
                }
                self.tableView.reloadData()
            }
            
        })
        
        DispatchQueue.global(qos: .userInitiated).async {
            dataTask.resume()
        }
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
            locationManager.requestLocation()
        default :
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get current location!
        guard let currentUsersLocation = locations.first?.coordinate else {
            return
        }
        queryForRestaurants(aroundLocation: currentUsersLocation)
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

// MARK: - UIViewConroller Extensions

extension UIViewController {
    var contentViewController : UIViewController {
        return self.navigationController?.visibleViewController ?? self
    }
}

