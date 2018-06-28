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
    
    // create a URL from parameters
    func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = ParseConstants.URLs.apiScheme
        components.host = ParseConstants.URLs.apiHost
        components.path = ParseConstants.URLs.apiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        guard let _ = components.url else {
            fatalError("Failed to create URL")
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
