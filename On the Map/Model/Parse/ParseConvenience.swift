//
//  ParseConvenience.swift
//  On the Map
//
//  Created by Anthony Lee on 6/28/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient{
    
    // Get method
    /*
    func getStudentLocations(completionHandlerForStudentInfo: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseConstants.ParseParameterKeys.limit: 100] as [String:AnyObject]
        
        /* 2. Make the request */
        let _ = taskForGETMethod("", parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentInfo(nil, error)
            } else {
                
                if let results = results?[ParseConstants.ParseResponseKeys.results] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForFavMovies(movies, nil)
                } else {
                    completionHandlerForFavMovies(nil, NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
                }
            }
        }
    }*/
}
