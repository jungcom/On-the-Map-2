//
//  WebViewController.swift
//  On the Map
//
//  Created by Anthony Lee on 6/25/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate{
    
    @IBOutlet weak var webView : WKWebView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let webUrl = URL (string: "https://auth.udacity.com/sign-up?next=nil")
        let request = URLRequest(url: webUrl!)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSignUp))
    }
    
    override func loadView() {
        navigationItem.title = "Udacity Sign Up"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSignUp))
        webView = WKWebView()
        webView.navigationDelegate = self
        
        // must be changed
        view = webView
    }

    @objc func cancelSignUp() {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
