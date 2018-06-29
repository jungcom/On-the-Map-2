//
//  UdacityClient.swift
//  On the Map
//
//  Created by Anthony Lee on 6/28/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

class UdacityClient :NSObject{
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
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
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
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


