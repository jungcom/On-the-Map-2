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
    
    let client = ParseClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "On The Map"
        
        // Download Student locations
        downloadStudentLocation()
    }
    
    func downloadStudentLocation(){
        
        //create parameters
        
        let parameter = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        var request = URLRequest(url: client.parseURLFromParameters(parameter))
        request.addValue(ParseConstants.ParseParameterKeys.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ParseParameterKeys.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            //Print error method
            func sendError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data*/
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult[ParseConstants.ParseResponseKeys.results] as? [[String: AnyObject]] else {
                sendError("cannot parse")
                return
            }
            
            //handle data
            let studentLocations = StudentInformation.studentLocationsFromResults(results)
            // save studentLoactions as a global variable
            self.client.sharedStudentLocations = studentLocations
            self.placePins(studentLocations)
        }
        task.resume()
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
