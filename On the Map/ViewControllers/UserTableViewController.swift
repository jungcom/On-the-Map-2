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
        tableView.reloadData()
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
