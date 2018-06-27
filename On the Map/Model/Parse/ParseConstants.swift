//
//  ParseConstants.swift
//  On the Map
//
//  Created by Anthony Lee on 6/25/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

struct ParseConstants{
    
    //Response Keys
    struct ParseResponseKeys{
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let results = "results"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    //Parse Methods
    struct ParseMethods{
        static let getStudentLocationMethod = "https://parse.udacity.com/parse/classes/StudentLocation?limit=10"
    }
    
    //Parse Parameter Keys
    struct ParseParameterKeys{
        static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let restAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
    }
}
