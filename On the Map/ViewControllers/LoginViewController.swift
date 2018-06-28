//
//  ViewController.swift
//  On the Map
//
//  Created by Anthony Lee on 6/22/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    var parseClient: ParseClient!
    var keyboardOnScreen = false
    var webView: WKWebView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cannotLoginTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }

    @IBAction func loginPressed(){
        if userEmailTextField.text!.isEmpty || userPasswordTextField.text!.isEmpty {
            cannotLoginTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            let userEmail = userEmailTextField.text!
            let userPassword = userPasswordTextField.text!
            authenticateUser(userEmail: userEmail, userPassword: userPassword)
        }
    }
    
    @IBAction func signUpPressed(){
        let controller = storyboard!.instantiateViewController(withIdentifier: "WebViewController") 
        present(controller, animated: true, completion: nil)
    }
    
    @objc func cancelSignUp() {
        dismiss(animated: true, completion: nil)
    }
    
    func authenticateUser(userEmail: String, userPassword: String){
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
                performUIUpdatesOnMain {
                    self.cannotLoginTextLabel.text = error
                    self.setUIEnabled(true)
                }
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
                print("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            if let _ = parsedResult[UdacityConstants.UdacityResponseKeys.StatusCode] as? Int {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            guard let _ = parsedResult[UdacityConstants.UdacityResponseKeys.Account] as? [String: AnyObject], let session = parsedResult[UdacityConstants.UdacityResponseKeys.Session] as? [String: AnyObject] else {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            guard let sessionID = session[UdacityConstants.UdacityResponseKeys.SessionID] as? String else {
                sendError(UdacityConstants.UdacityErrors.noUsernameOrPassword)
                return
            }
            
            print(sessionID)
            // MARK: TODO Change for Client
            // self.appDelegate.sessionID = sessionID
            self.completeLogin()
        }
        task.resume()
    }
    
    // MARK: function to complete login and open Movietab controller
    func completeLogin() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "LocationTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}

//MARK: UI Updates
private extension LoginViewController{
    func setUIEnabled(_ enabled: Bool) {
        userEmailTextField.isEnabled = enabled
        userPasswordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= (keyboardHeight(notification)/2)
            //movieImageView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += (keyboardHeight(notification)/2)
            //movieImageView.isHidden = false
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    /*@IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }*/
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
