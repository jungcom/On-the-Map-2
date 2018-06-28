//
//  ParseClient.swift
//  On the Map
//
//  Created by Anthony Lee on 6/27/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

class ParseClient :NSObject{
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    var sessionID: String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
