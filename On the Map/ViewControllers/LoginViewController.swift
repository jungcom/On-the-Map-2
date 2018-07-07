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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set textfields empty
        userEmailTextField.text = ""
        userPasswordTextField.text = ""
        cannotLoginTextLabel.text = ""
    }

    @IBAction func loginPressed(){
        if userEmailTextField.text!.isEmpty || userPasswordTextField.text!.isEmpty {
            cannotLoginTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            authenticate()
            
        }
    }
    
    func authenticate(){
        let userEmail = userEmailTextField.text!
        let userPassword = userPasswordTextField.text!
        UdacityClient.sharedInstance().authenticateUser(userEmail: userEmail, userPassword: userPassword, completionHandlerForAuthenticating: { ( success, error) in
            if success{
                self.completeLogin()
            } else {
                performUIUpdatesOnMain {
                    self.cannotLoginTextLabel.text = error
                    self.setUIEnabled(true)
                }
            }
        })
    }
    
    @IBAction func signUpPressed(){
        let controller = storyboard!.instantiateViewController(withIdentifier: "WebViewController") 
        present(controller, animated: true, completion: nil)
    }
    
    // function to complete login and open Movietab controller
    func completeLogin() {
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "LocationTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}

// UI Updates
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
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Show/Hide Keyboard
    
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

// LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
