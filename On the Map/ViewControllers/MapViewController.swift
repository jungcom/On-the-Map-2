//
//  MapViewController.swift
//  On the Map
//
//  Created by Anthony Lee on 6/26/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "On The Map"
        
        // Download 100 Student locations
        
        let parameter = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        download100StudentLocations(parameter: parameter)
        
        // Download User Location
        let udacityClient = UdacityClient.sharedInstance()
        
        // MARK: TO DO - MUST USE ESCAPED FORM
        let param = ["where" : "{\"uniqueKey\":\"\(udacityClient.uniqueKey)\"}"] as [String : AnyObject]
        downloadUserLocation(parameters: param)
    }
    
    //Refresh Button
    @IBAction func refreshData(sender: AnyObject){
        let parameter = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        download100StudentLocations(parameter: parameter)
        mapView.reloadInputViews()
    }
    
    // Logout using Udacity's DELETE method
    @IBAction func logout(sender: AnyObject){
        UdacityClient.sharedInstance().logout{ (success) in
            if success {
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("logout failed")
            }
        }
    }
    
    // Add Location Button
    @IBAction func addLocation(sender: AnyObject){
        let parseClient = ParseClient.sharedInstance()
        if parseClient.hasPostedBefore {
            let alert = UIAlertController(title: "Override?", message: "Would you like to override your current location?", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InformationPostingViewController") as? InformationPostingViewController {
                    self.present(mvc, animated: true, completion: nil)
                }
            })
            alert.addAction(closeAction)
            alert.addAction(continueAction)
            self.present(alert, animated: true)
            
        } else {
            if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InformationPostingViewController") as? InformationPostingViewController {
                self.present(mvc, animated: true, completion: nil)
            }
        }
 
    }
    
    //download current user location
    func downloadUserLocation(parameters: [String:AnyObject]){
        let parseClient = ParseClient.sharedInstance()
        
        parseClient.downloadStudentLocations(parameters: parameters, completionHandlerForDownload: { (userLocation, success) in
            if success{
                //Use parsed Data
                guard let recentUserLocation = userLocation![0] as? [String : AnyObject] else {
                    print("no object for user location found")
                    return
                }
                
                guard let objectID = recentUserLocation[ParseConstants.ParseResponseKeys.objectID] as? String else {
                    print("No objectID found")
                    return
                }
                
                //MARK: TO DO - MUST USE recentUserLocation to save its user data into Udacity Client (make the app useable by other udacity students, not just me)
                parseClient.objectID = objectID
                parseClient.hasPostedBefore = true
                print("objectID found")
                
            } else {
                print("unsuccessful in downloading user location")
            }
            })

    }
    
    //download 100 student locations
    func download100StudentLocations(parameter: [String:AnyObject], withPathExtension:String? = nil){
        
        // Create request using parseClient
        ParseClient.sharedInstance().downloadStudentLocations(parameters: parameter, completionHandlerForDownload: {(results, success) in
            if success {
                // handle data
                let studentLocations = StudentInformation.studentLocationsFromResults(results!)
                
                // save studentLoactions as a global variable
                ParseClient.sharedInstance().sharedStudentLocations = studentLocations
                
                // Place pins on map
                print("Download Successful")
                self.placePins(studentLocations)
            } else {
                print("Download Failed")
            }
        })
    }
    
    // Place Pins on Map
    func placePins(_ studentLocations: [StudentInformation]){
        var annotations = [MKPointAnnotation]()
        for studentInfo in studentLocations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(studentInfo.latitude)
            let long = CLLocationDegrees(studentInfo.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInfo.firstName
            let last = studentInfo.lastName
            let mediaURL = studentInfo.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
