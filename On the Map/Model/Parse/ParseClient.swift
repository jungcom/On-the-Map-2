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
    
    // shared STUDENT LOCATION data
    var sharedStudentLocations: [StudentInformation]?
    
    // shared user objectID
    var objectID: String? = nil
    
    // shared var whether the user has already posted a location or not
    var hasPostedBefore: Bool = false
    
    // Download Student Location with get method
    
    func downloadStudentLocations(parameters: [String:AnyObject], completionHandlerForDownload: @escaping (_ results: [[String:AnyObject]]?, _ success: Bool) -> Void){
        
        //create Parse client and request
        let client = ParseClient.sharedInstance()
        var request = URLRequest(url: client.parseURLFromParameters(parameters))
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
            
            /* Parse Json Data */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (parsedResult, error) in
                if error == nil{
                    guard let results = parsedResult![ParseConstants.ParseResponseKeys.results] as? [[String: AnyObject]] else {
                        sendError("cannot parse results")
                        print(parsedResult)
                        return
                    }
                     
                    completionHandlerForDownload(results, true)
                    
                } else {
                    sendError("Convertion JSON failed")
                }
            })
            
        }
        task.resume()
    }
    
    // MARK: - Post User's Location
    func postNewUserLocation(userLocationInfo: StudentInformation, completionHandlerForPostingLocation: @escaping (_ success: Bool) -> Void){
        var request = URLRequest(url: URL(string: ParseConstants.ParseMethods.getStudentLocationMethod)!)
        request.httpMethod = "POST"
        request.addValue(ParseConstants.ParseParameterKeys.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ParseParameterKeys.restAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(userLocationInfo.uniqueKey ?? "")\", \"firstName\": \"\(userLocationInfo.firstName)\", \"lastName\": \"\(userLocationInfo.lastName)\",\"mapString\": \"\(userLocationInfo.mapString)\", \"mediaURL\": \"\(userLocationInfo.mediaURL)\",\"latitude\": \(userLocationInfo.latitude), \"longitude\": \(userLocationInfo.longitude)}".data(using: .utf8)
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
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                if error == nil {
                    guard let objectId = result![ParseConstants.ParseResponseKeys.objectID] as! String? else{
                        print("empty objectID")
                        return
                    }
                    
                    self.objectID = objectId
                    completionHandlerForPostingLocation(true)
                } else {
                    print("Data conversion failed")
                }
                })
        }
        task.resume()
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
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
    
    // Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
