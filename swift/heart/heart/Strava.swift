//
//  Strava.swift
//  heart
//
//  Created by Michael Chirico on 7/16/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

/*
 How to export:
 
 https://www.strava.com/activities/1860986144/export_tcx
 
 
 */


import UIKit

// FIXME:  Global -- hmm
let strava = Strava()

class Strava {
  
  var CLIENT_SECRET = ""
  var CODE = ""
  var ACCESS_TOKEN = ""
  
  
  enum SampleData {
    static let runningWorkout = "https://storage.googleapis.com/montco-stats/7_RE155_Fitness_51_Fatigue_83_Form_32_PiR_20.tcx"
    
  }
  
  
  
  static func getPostString(params:[String:Any]) -> String
  {
    var data = [String]()
    for(key, value) in params
    {
      data.append(key + "=\(value)")
    }
    return data.map { String($0) }.joined(separator: "&")
  }
  
  
  func stravaSignIn(){
    let url = URL(string: "https://www.strava.com/api/v3/oauth/authorize?" +
      "client_id=7704&redirect_uri=com.googleusercontent.apps.95443717815-7e2p08srbqhll631rjeken2f800qski3://127.0.0.1&response_type=" +
      "code&approval_prompt=auto&scope=view_private,write&state=3StravaApp")
    
    
    UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { (success) in
      print("Open url : \(success)")
    })
    
    return
    
  }
  
  func upload(runData: String) {
    let url = URL(string: "https://www.strava.com/api/v3/uploads")
    //let url = URL(string: "https://httpbin.org/post")
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    
    request.setValue("Bearer \(ACCESS_TOKEN)", forHTTPHeaderField: "Authorization")
    
    let boundary = generateBoundaryString()
    
    let param = [
      "activity_type"  : "run",
      "data_type"    : "tcx"
      
    ]
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody =  createBodyWithParameters(parameters: param,
                                                 filePathKey: "file",data: runData,  boundary: boundary)
    
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {
      data, response, error in
      
      if error != nil {
        print("error=\(String(describing: error))")
        return
      }
      
      print("response = \(String(describing: response))")
      
      
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(String(describing: responseString))")
    })
    task.resume()
    
    
    
  }
  
  
  func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?,data: String, boundary: String) -> Data {
    
    let body = NSMutableData();
    
    
    if parameters != nil {
      for (key, value) in parameters! {
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
      }
    }
    
    let filename = "data.gpx"
    let mimetype = "application/gpx+xml"
    
    
    
    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append(data.data(using: String.Encoding.utf8)!)
    body.append("\r\n".data(using: String.Encoding.utf8)!)
    
    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
    
    return body as Data
  }
  
  
  
  
  
  func generateBoundaryString() -> String
  {
    return "Boundary-\(NSUUID().uuidString)"
  }
  
  
  
  
  func tokenExchange() {
    
    let url = URL(string: "https://www.strava.com/oauth/token")
    let client_id = "7704"
    
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    
    //request.setValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
    
    let parameters:[String:String] = ["client_id": client_id,
                                      "client_secret": self.CLIENT_SECRET, "code": self.CODE]
    
    
    let postString = Strava.getPostString(params: parameters)
    request.httpBody = postString.data(using: .utf8)
    
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {
      data, response, error in
      
      if error != nil {
        print("error=\(String(describing: error))")
        return
      }
      
      print("response = \(String(describing: response))")
      
      
      guard let dataResponse = data,
        error == nil else {
          print(error?.localizedDescription ?? "Response Error")
          return }
      do{
        //here dataResponse received from a network request
        let jsonResponse = try JSONSerialization.jsonObject(with:
          dataResponse, options: [])
        
        guard let jsonArray = jsonResponse as? [String: Any] else {
          return
        }
        print(jsonArray)
        //Now get title value
        guard let access_token = jsonArray["access_token"] as? String else { return }
        print("\nAccess_token:  \(access_token)\n\n")
        
        self.ACCESS_TOKEN = access_token
        
      } catch let parsingError {
        print("Error", parsingError)
      }
      
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(responseString)")
    })
    task.resume()
  }
  
  func test() {
    let r = Request()
    r.getURL(url: SampleData.runningWorkout)
    upload(runData: r.contents)
    
  }
  
  
}






// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
