//
//  ViewController.swift
//  Oauth2Dribbble
//
//  Created by nagisa-kosuge on 2015/05/14.
//  Copyright (c) 2015年 RyoKosuge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let DribbbleClientID = "xxxxxxxx"
    private let DribbbleClientSecret = "xxxxxxxx"
    private let DribbbleRedirectURI = "xxxxxxxx"
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupOauthDribbble()
        setupLoginButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

// MARK : setup btn

extension ViewController {
    
    private func setupLoginButton() {
        loginButton.layer.borderColor = UIColor.blackColor().CGColor
        loginButton.layer.borderWidth = 2
        loginButton.addTarget(self, action: "touchUpLoginBtn:", forControlEvents: .TouchUpInside)
    }
    
    func touchUpLoginBtn(sender: UIButton) {
        println(__FUNCTION__)
        if let authorizeURL = Oauth2Dribbble.sharedInstance.authorizeURL() {
            println(authorizeURL)
            UIApplication.sharedApplication().openURL(authorizeURL)
        }
    }
    
}

// MARK : setup oauth dribbble

extension ViewController {
    
    private func setupOauthDribbble() {
        let oauth = Oauth2Dribbble.sharedInstance
        oauth.setClientInfo(id: DribbbleClientID, secret: DribbbleClientSecret, redirectURI: DribbbleRedirectURI)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "oauthLoginSuccess:", name: DidOauthLoginSuccessNotification, object: nil)
        notificationCenter.addObserver(self, selector: "oauthLoginFailure:", name: DidOauthLoginFailureNotification, object: nil)
    }
    
}

// MARK : notify oauth login

extension ViewController {
    
    func oauthLoginSuccess(notification: NSNotification) {
        println(__FUNCTION__)
    }
    
    func oauthLoginFailure(notification: NSNotification) {
        println(__FUNCTION__)
    }
}