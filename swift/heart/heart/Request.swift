//
//  Request.swift
//  heart
//
//  Created by Michael Chirico on 7/2/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation

class Request{
  
  var contents = ""
  
  func post(url: String, _ locationFile: String, data: Data) {
    
    
    let TOKEN="abc"
    
    let size=data.count
    let request = NSMutableURLRequest(url: URL(string: url)!)
    
    request.httpMethod = "POST"
    
    request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
    
    request.setValue("{\"path\": \"\(locationFile)\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false}", forHTTPHeaderField: "Dropbox-API-Arg")
    
    request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
    request.setValue("\(size)", forHTTPHeaderField: "Content-Length")
    request.setValue("100-continue", forHTTPHeaderField: "Expect")
    request.httpBody = data
    
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
      data, response, error in
      
      if error != nil {
        let defaultMessage = "error: URLSession.shared.dataTask"
        print("error=\(error ?? defaultMessage as! Error)")
        return
      }
      
      print("response = \(String(describing: response))")
      
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(String(describing: responseString))")
    })
    task.resume()
    
  }
  
  
  func getURL(url: String){
    if let url = URL(string: url) {
      do {
        contents = try String(contentsOf: url)
      } catch {
        print("Contents could not be loaded")
      }
    } else {
      print("The URL was bad")
    }
  }
  
}
