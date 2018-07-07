//
//  UserTableViewController.swift
//  On the Map
//
//  Created by Anthony Lee on 6/26/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController {

    var studentLocations : [StudentInformation]?
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentLocations = ParseClient.sharedInstance().sharedStudentLocations
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.title = "On The Map"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh data
        studentLocations = ParseClient.sharedInstance().sharedStudentLocations
        tableView.reloadData()
    }
    
    // Refresh button
    @IBAction func refresh(sender:AnyObject){
        // Download 100 Student locations
        
        let parameter = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        download100StudentLocations(parameter: parameter)
        
        self.studentLocations = ParseClient.sharedInstance().sharedStudentLocations
        tableView.reloadData()
    }
    
    //download Student Locations
    func download100StudentLocations(parameter: [String:AnyObject], withPathExtension:String? = nil){
        let sv = UIViewController.displaySpinner(onView: self.view)
        // Create request using parseClient
        ParseClient.sharedInstance().downloadStudentLocations(parameters: parameter, completionHandlerForDownload: {(results, success) in
            if success {
                // handle data
                let studentLocations = StudentInformation.studentLocationsFromResults(results!)
                
                // save studentLoactions as a global variable
                ParseClient.sharedInstance().sharedStudentLocations = studentLocations
                UIViewController.removeSpinner(spinner: sv)
                print("Download Successful")
            } else {
                print("Download Failed")
            }
        })
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
    
    //Logout
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentLocations?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let student = self.studentLocations?[(indexPath as NSIndexPath).row]
        // Configure the cell...
        cell.imageView?.image = UIImageView(image: UIImage(named: "icon_pin")!).image
        cell.textLabel?.text = "\(student?.firstName ?? "")  \(student?.lastName ??  "")"
        cell.detailTextLabel?.text = student?.mediaURL

        return cell
    }
    
    //When Cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = self.studentLocations?[(indexPath as NSIndexPath).row]
        let app = UIApplication.shared
        if let url = student?.mediaURL {
            app.open(URL(string: url)!, options: [:], completionHandler: nil)
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
