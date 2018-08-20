
//
//  AppDelegate.swift
//  evilDuck
//
//  Created by Michael Chirico on 2/19/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
  
  var window: UIWindow?
  
  
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    return true
  }
  
  
  @available(iOS 9.0, *)
  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
      
      print("****************\n\n\n\n**************\n\n\(url)\n\n\n")
      print("will need to pass back")
      
      var array = "\(url)".split(separator: "&")
      print(array)
      let filtered = array.filter { $0.range(of: "code=.*", options: .regularExpression) != nil  }
      if filtered.count == 1 {
        let s = filtered[0]
        strava.CODE = String(s.suffix(from: s.index(s.startIndex, offsetBy: 5)))
        print("strava.CODE: \(strava.CODE)")
        strava.tokenExchange()
      }
      print("filtered=\(filtered) length= \(filtered.count)")
      

      
      return GIDSignIn.sharedInstance().handle(url,
                                               sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                               annotation: [:])
  }
  
  
  // [START headless_google_auth]
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    // [START_EXCLUDE]
    
    
    
    
    guard (GIDSignIn.sharedInstance().uiDelegate as? ViewController) != nil else { return }
    // [END_EXCLUDE]
    if error != nil {
      // [START_EXCLUDE]
      print("error on sign in")
      // [END_EXCLUDE]
      return
    }
    
    // [START google_credential]
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    
    // Mike: You need the following below to get users signed in
    
    
    Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
      if error != nil {
        // ...
        print("Error with sign-in")
        
        return
      }
      // User is signed in
      print("User is signed in")
      
      
      // ...
    }
    
    // [END google_credential]
    // [START_EXCLUDE]
    // odd_not_working   controller.firebaseLogin(credential)
    // [END_EXCLUDE]
  }
  // [END headless_google_auth]
  
  
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    
    var token = ""
    
    for i in 0..<deviceToken.count {
      token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
    }
    
    print("Registration succeeded!")
    print("Special Hex Token: ", token,"\n\n")
    print("\n**********************************\n\n")
    print("Current User \(String(describing: Auth.auth().currentUser))")
    
    
    Analytics.logEvent("HexToken", parameters: [
      "currentUser": "\(String(describing: Auth.auth().currentUser))" as NSObject,
      "test": "Got Token" as NSObject
      ])
    
    
    
  }
  
  
  @objc func tokenRefreshNotification(notification: NSNotification) {
    print("Token\n\n")
    
    
    InstanceID.instanceID().instanceID { (result, error) in
      if let error = error {
        print("Error fetching remote instange ID: \(error)")
      } else if let result = result {
        
        // I'd like to pass this along
        let defaults = UserDefaults(suiteName: "group.pigshareData")!
        defaults.set(result, forKey: "FAuthDataToken")
        defaults.synchronize()
        
        print("Remote instance ID token: \(result.token)")
      }
    }
    
    
    
  }
  
  
}

