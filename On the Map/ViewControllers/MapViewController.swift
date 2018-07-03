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
        
        var parameter = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        downloadStudentLocation(parameter: parameter)
        
        //MARK: TO DO - downloading the users location gives an error (When commenting the top code that downloads 100 Student locations)
        let uniqueKey = UdacityClient.sharedInstance().uniqueKey
        print(uniqueKey!)
        parameter = [ParseConstants.ParseParameterKeys.wherePar: "{\"uniqueKey\":\"\(uniqueKey!)\"}"] as [String:AnyObject]
        downloadStudentLocation(parameter: parameter)
    }
    
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
    
    func downloadStudentLocation(parameter: [String:AnyObject], withPathExtension:String? = nil){
        
        //create parameters and URL
        
        let parseClient = ParseClient.sharedInstance()
        let parseURL: URL
        if let withPathExtension = withPathExtension {
            parseURL = parseClient.parseURLFromParameters(parameter, withPathExtension: withPathExtension)
        } else {
            parseURL = parseClient.parseURLFromParameters(parameter)
        }
        
        // Create request
        parseClient.downloadStudentLocations(url: parseURL, parameters: parameter, completionHandlerForDownload: {(results, success) in
            if success {
                // handle data
                let studentLocations = StudentInformation.studentLocationsFromResults(results!)
                
                // save studentLoactions as a global variable
                parseClient.sharedStudentLocations = studentLocations
                
                // Place pins on map
                self.placePins(studentLocations)
            } else {
                print("Download Failed")
            }
        })
    }
    
    //Place Pins
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
