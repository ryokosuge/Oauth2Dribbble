//
//  OauthDribbble.swift
//  Oauth2Dribbble
//
//  Created by nagisa-kosuge on 2015/05/14.
//  Copyright (c) 2015年 RyoKosuge. All rights reserved.
//

import Foundation

let DidOauthLoginSuccessNotification    = "DidOauthLoginSuccessNotification"
let DidOauthLoginFailureNotification    = "DidOauthLoginFailureNotification"
let ErrorDomain                         = "Oauth2DribbbleErrorDomain"

class Oauth2Dribbble {
    
    static let sharedInstance = Oauth2Dribbble()
    
    private var clientID: String? = nil
    private var clientSecret: String? = nil
    private var redirectURI: String? = nil
    
    private var accessToken: String? = nil
    private var failureError: NSError? = nil
    
    private init() {
    }
    
    func setClientInfo(#id: String, secret: String, redirectURI: String) {
        self.clientID = id
        self.clientSecret = secret
        self.redirectURI = redirectURI
    }
    
    func authorizeURL(scope: String = "public", state: String = "DRIBBBLE") -> NSURL? {
        
        if let id = self.clientID, redirect = self.redirectURI {
            let authorizeURL = "https://dribbble.com/oauth/authorize?client_id=\(id)&redirect_uri=\(redirect)&scope=\(scope)&state=\(state)"
            return NSURL(string: authorizeURL)
        }
        
        return nil
    }
    
    func handleURL(url: NSURL) {
        println(__FUNCTION__)
        if let urlQuery = url.query {
            let query = splitQuery(urlQuery)
            if let code: String = query["code"] as? String {
                postOauth(code: code)
            } else {
                notifyFailure()
            }
        } else {
            notifyFailure()
        }
    }
    
}

// MARK : - post auth.

extension Oauth2Dribbble {
    
    private func postOauth(#code: String) {
        var parameters: [String: String] = [:]
        if let id = clientID, secret = clientSecret, redirect = redirectURI {
            parameters["client_id"] = id
            parameters["client_secret"] = secret
            parameters["code"] = code
            parameters["redirect_uri"] = redirect
        }
        
        if let re = request(parameters) {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(re, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if let e = error {
                    self.failureError = error
                    self.notifyFailure()
                    return
                }
                
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode ?? 0
                if !contains(200..<300, statusCode) {
                    let userInfo = [NSLocalizedDescriptionKey: "received status code that represents error."]
                    let error = NSError(domain: ErrorDomain, code: statusCode, userInfo: userInfo)
                    self.failureError = error
                    self.notifyFailure()
                    return
                }
                
                var jsonError: NSError? = nil
                if let rawValue = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as? [String: String] {
                    self.accessToken = rawValue["access_token"]
                    self.notifySuccess()
                    return
                }
            })
            task.resume()
        }
        
    }
    
    private func request(parameter: [String: String]) -> NSURLRequest? {
        if let componets = NSURLComponents(URL: NSURL(string: "https://dribbble.com/oauth/token")!, resolvingAgainstBaseURL: true) {
            let request = NSMutableURLRequest()
            request.HTTPMethod = "POST"
            
            let contentType = "application/x-www-form-urlencoded"
            if let params = dataFromObject(parameter) {
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                request.HTTPBody = params
            }
            
            request.URL = componets.URL
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return request
        }
        
        return nil
    }
    
    private func dataFromObject(object: [String:String]) -> NSData? {
        let string = stringFromObject(object)
        return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    private func stringFromObject(object: [String:String]) -> String {
        println(__FUNCTION__)
        var pairs = [String]()
        for (key, value) in object {
            let pair = "\(key)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)"
            pairs.append(pair)
        }
        
        return join("&", pairs)
    }
    
}

// MARK : - notification method.

extension Oauth2Dribbble {
    
    private func notifyFailure() {
        println(__FUNCTION__)
        NSNotificationCenter.defaultCenter().postNotificationName(DidOauthLoginFailureNotification, object: nil, userInfo: nil)
    }
    
    private func notifySuccess() {
        println(__FUNCTION__)
        NSNotificationCenter.defaultCenter().postNotificationName(DidOauthLoginSuccessNotification, object: nil, userInfo: nil)
    }
}

// MARK: - helper method.

extension Oauth2Dribbble {
    
    private func splitQuery(query: String) -> [String: AnyObject] {
        var q: [String: AnyObject] = [:]
        
        for queryStr in split(query, maxSplit: 0, allowEmptySlices: false, isSeparator: { $0 == "&"}) {
            var sq = split(queryStr, maxSplit: 2, allowEmptySlices: false, isSeparator: { $0 == "="})
            var key = sq.first!
            var value = sq.last!
            q[key] = value
        }
        return q
    }
    
}