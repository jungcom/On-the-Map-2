//
//  StudentInformation.swift
//  On the Map
//
//  Created by Anthony Lee on 6/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    //MARK: Properties
    let objectId : String
    let uniqueKey : String?
    let firstName : String
    let lastName : String
    let mapString : String
    let mediaURL : String
    let latitude : Double
    let longitude : Double
    let createdAt : String
    let updatedAt : String
    
    init?(dictionary: [String:Any]) {
        self.firstName = dictionary[ParseConstants.ParseResponseKeys.firstName] as? String ?? ""
        self.lastName = dictionary[ParseConstants.ParseResponseKeys.lastName] as? String ?? ""
        self.uniqueKey = dictionary[ParseConstants.ParseResponseKeys.uniqueKey] as? String ?? ""
        self.objectId = dictionary[ParseConstants.ParseResponseKeys.objectID] as? String ?? ""
        self.mapString = dictionary[ParseConstants.ParseResponseKeys.mapString] as? String ?? ""
        self.mediaURL = dictionary[ParseConstants.ParseResponseKeys.mediaURL] as? String ?? ""
        self.latitude = dictionary[ParseConstants.ParseResponseKeys.latitude] as? Double ?? 0.0
        self.longitude = dictionary[ParseConstants.ParseResponseKeys.longitude] as? Double ?? 0.0
        self.createdAt = dictionary[ParseConstants.ParseResponseKeys.createdAt] as? String ?? ""
        self.updatedAt = dictionary[ParseConstants.ParseResponseKeys.updatedAt] as? String ?? ""
    }
    
    init(firstname: String, lastName: String, mapString : String, mediaURL : String, latitude : Double, longitude : Double, uniqueKey: String? = nil, objectID : String? = nil) {
        self.firstName = firstname
        self.lastName = lastName
        self.mapString = mapString
        self.latitude = latitude
        self.longitude = longitude
        self.uniqueKey = uniqueKey
        self.objectId = objectID ?? ""
        self.mediaURL = mediaURL
        self.createdAt = ""
        self.updatedAt = ""
    }
    
    static func studentLocationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentLocations = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            studentLocations.append(StudentInformation(dictionary: result)!)
        }
        
        return studentLocations
    }
    
}
