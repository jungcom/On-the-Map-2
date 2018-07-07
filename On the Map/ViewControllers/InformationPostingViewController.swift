//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Anthony Lee on 6/28/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    @IBOutlet weak var addLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Cancel adding location
    @IBAction func cancelButton(sender:AnyObject){
        dismiss(animated: true, completion: nil)
    }
    
    // POST a location to Parse API
    @IBAction func addLocationButton(sender:AnyObject){
        self.createUserLocationObject{(user, success) in
            // If creating user location object was successful
            if success {
                // If User has posted before, use the update method
                if ParseClient.sharedInstance().hasPostedBefore{
                    self.putCurrentUserLocation(user)
                } else {
                    //Post New User Location
                    self.postNewUserLocation(user)
                }
            } else {
                print("User Location Object creation failed")
            }
        }
        
    }
    
    //PUT Current User Location (Update)
    func putCurrentUserLocation(_ userInfo:StudentInformation){
        ParseClient.sharedInstance().updateUserLocation(userLocationInfo: userInfo, completionHandlerForUpdating: { (success) in
                if success{
                    print("puting data successful")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Updating User Location failed")
                }
            })
    }
    //Post New User Location
    func postNewUserLocation(_ userInfo:StudentInformation){
        ParseClient.sharedInstance().postNewUserLocation(userLocationInfo: userInfo, completionHandlerForPostingLocation:{ (success) in
            // If posting a new location was successful
            if success {
                print("posting data successful")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Adding New Location failed")
            }
        })
    }
    
    // Create a StudentInformation Object
    func createUserLocationObject(completionHandler:  @escaping (_ userInfo:StudentInformation, _ success:Bool) -> Void) {
        findLatLong(location: self.locationTextField.text!, completionHandlerForDownloadingLatLong: { (coordinates, success) in
            if success{
                let client = UdacityClient.sharedInstance()
                let user = StudentInformation(firstname: ParseConstants.UserInfo.firstName, lastName: ParseConstants.UserInfo.lastname, mapString: self.locationTextField.text!, mediaURL: self.mediaURLTextField.text!, latitude: coordinates[0], longitude: coordinates[1], uniqueKey: client.uniqueKey)
                completionHandler(user, true)
            } else {
                print("latitude and longitude not successfully downloaded")
            }
            
        })
        
    }
    
    // Find the latitude and longitude of a given location String
    func findLatLong(location:String, completionHandlerForDownloadingLatLong: @escaping (_ coordinates: [Double], _ success:Bool) -> Void){
        var coordinatesCopy = [Double]()
            if let address = self.locationTextField.text {
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard let placemarks = placemarks?.first,
                        let lat = placemarks.location?.coordinate.latitude,
                        let lon = placemarks.location?.coordinate.longitude
                        else {
                            // handle no location found
                            print("empty text")
                            return
                    }
                    
                    // Use your location
                    coordinatesCopy.append(lat)
                    coordinatesCopy.append(lon)
                    completionHandlerForDownloadingLatLong(coordinatesCopy ,true)
                }
            }
    }

}
