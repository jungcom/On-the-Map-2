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
    
    @IBOutlet weak var addLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // Cancel adding location
    @IBAction func cancelButton(sender:AnyObject){
        dismiss(animated: true, completion: nil)
    }
    
    // Post a location to Parse API
    @IBAction func addLocationButton(sender:AnyObject){
        let currentString = locationTextField.text
        let coordinates = findLatLong(location: currentString!)
        
    }
    
    // Find the latitude and longitude of a given location String
    func findLatLong(location:String) -> [Double]{
        var coordinates: [Double] = [Double]()
        
        if let address = locationTextField.text {
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
                print("lat : \(lat) and long : \(lon)")
                coordinates.append(lat)
                coordinates.append(lon)
                return
            }
            
        } else {
            print("empty text")
        }
        
        return coordinates
    }

}
