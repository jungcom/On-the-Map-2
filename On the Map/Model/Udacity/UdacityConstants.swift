//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Anthony Lee on 6/25/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: Udacity
    struct UdacityMethod {
        static let authenticateMethod = "https://www.udacity.com/api/session"
        static let userGetMethod = "https://www.udacity.com/api/users/"
    }
    
    // MARK: Udacity Response Keys
    struct UdacityResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "Key"
        static let Session = "session"
        static let SessionID = "id"
        static let Expiration = "expiration"
        static let StatusCode = "status"
    }
    
    struct UdacityErrors{
        static let noUsernameOrPassword = "Email or Password was not found. Please try again"
    }
}
