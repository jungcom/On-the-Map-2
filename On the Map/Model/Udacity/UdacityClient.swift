//
//  UdacityClient.swift
//  On the Map
//
//  Created by Anthony Lee on 6/28/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

class UdacityClient :NSObject{
    // Properties
    var uniqueKey: String!
    // shared session
    var session = URLSession.shared
    
    // Authenticate User
    func authenticateUser(userEmail: String, userPassword: String, completionHandlerForAuthenticating: @escaping (_ success:Bool, _ error:String? ) -> Void){
        // Start a request
        var request = URLRequest(url: URL(string: UdacityConstants.UdacityMethod.authenticateMethod)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(userEmail)\", \"password\": \"\(userPassword)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            //Print error method
            func sendError(_ error: String) {
                print(error)
                completionHandlerForAuthenticating(false, error)
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
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            /* 5. Parse the data*/
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                sendError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            if let _ = parsedResult[UdacityConstants.UdacityResponseKeys.StatusCode] as? Int {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            guard let account = parsedResult[UdacityConstants.UdacityResponseKeys.Account] as? [String: AnyObject], let session = parsedResult[UdacityConstants.UdacityResponseKeys.Session] as? [String: AnyObject] else {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            guard let sessionID = session[UdacityConstants.UdacityResponseKeys.SessionID] as? String, let uniqueKey = account[UdacityConstants.UdacityResponseKeys.Key] as? String else {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            print("SessionID: " + sessionID)
            print ("Unique Key : " + uniqueKey)
            self.uniqueKey = uniqueKey
            completionHandlerForAuthenticating(true, nil)
        }
        task.resume()
    }
    
    // LogOut
    func logout(completionHandlerForLogout: @escaping (_ error: Bool) -> Void){
        
        var request = URLRequest(url: URL(string: UdacityConstants.UdacityMethod.authenticateMethod)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            completionHandlerForLogout(true)
        }
        task.resume()
    }
    
    //shared instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}


