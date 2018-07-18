import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

import HealthKit

import CoreLocation

class ViewController: UIViewController,GIDSignInUIDelegate  {
  
  @IBOutlet weak var textView0: UITextView!
  
  
  
  var ref: DatabaseReference!
  var db: Firestore!
  
  var startDate = Date().addingTimeInterval(-2*24*60*60)
  var distance = 0.0
  
  let healthManager:HealthManager = HealthManager()
  let healthKitStore:HKHealthStore = HKHealthStore()
  var heartRateSamples = [HKQuantitySample]()
  var heartRateVaribility = [HKQuantitySample]()
  var workoutSamples = [HKQuantitySample]()
  var workoutSamples2 = [HKSample]()  // This is for route data
  var restingHearRateSamples = [HKQuantitySample]()
  var flightsClimbed = [HKQuantitySample]()
  var appleExerciseTime = [HKQuantitySample]()
  var distanceWalkingRunning = [HKQuantitySample]()
  var stepSamples = [HKQuantitySample]()
  var nrgSamples = [HKQuantitySample]()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signIn()
    ref = Database.database().reference()
    db = Firestore.firestore()
    
    //valid_accounts
    self.ref.child("valid_accounts").child("heartRate").setValue(["username": "mchirico@gmail.com"])
    

    self.ref.child("access_token").child("stravaTest").setValue("0d936348d557c5fab74e1075c8fa1d165f84294d")
    
    
    
    
    
    ref.child("access_token").child("stravaTest").observeSingleEvent(of: .value, with: { (snapshot) in
      
      let ACCESS_TOKEN = snapshot.value as? String ?? ""
      print("ACCESS_TOKEN  \(ACCESS_TOKEN)")
      strava.ACCESS_TOKEN = ACCESS_TOKEN
      
      
      
    }) { (error) in
      print(error.localizedDescription)
      self.stravaPopUp()
    }
    
    
    
    
    
    requestAccessToHealthKit()
  }
  
  
  func stravaPopUp(){
    ref.child("valid_accounts").child("StravaAppToken").observeSingleEvent(of: .value, with: { (snapshot) in
      
      let TOKEN = snapshot.value as? String ?? ""
      print("TOKEN  \(TOKEN)")
      strava.CLIENT_SECRET = TOKEN
      
      strava.stravaSignIn()
      
    }) { (error) in
      print(error.localizedDescription)
    }
  }
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func buttonHR(_ sender: UIButton) {
    self.requestAccessToHealthKit()
    
    let utility = Utility()
    utility.writeFile(fileName: "HeartRates.csv", writeString: prHeartRates())
    if let url = utility.getURL() {
      
      utility.pushToFirebase(localFile: url,
                             remoteFile: "HeartRate.csv")
    }
    
    
  }
  
  @IBAction func buttonUpload(_ sender: UIButton) {
     strava.test()
  }
  
  @IBAction func buttonStat(_ sender: UIButton) {
    
  }
  
  
  
  
  
  // MARK: Test Button
  @IBAction func test(_ sender: UIButton) {
    self.requestAccessToHealthKit()
    
    //    print("pr steps")
    //    readSteps()
    
    // Works but comment
    //readActiveNRGBurned()
    //readFlightClimbed()
    //readAppleExerciseTime()
    //readWalkingRunning()
    
    // writeDatabase()
    
    
    // readHRV()
    
    //readAndWriteHeartRates()
    
    readWorkoutLocations()
    
    //readWalkingRunning()
    
    
    let url = URL(string: "https://example.com/post")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
   
   
  }
  
  
  
  
  
  
  func urlThing(){
    let r = Request()
    r.getURL(url: "https://s3.amazonaws.com/swiftbook/menudata.csv")
    
    
    let someString = "this is a test\n\n"
    let data = Data(someString.utf8)
    r.post(url: "https://httpbin.org/post","test", data: data)
  }
  
  
  func writeDatabase() {
    let sb = SqliteBroker()
    sb.myStart()
    sb.close()
    let url = sb.getDatabaseFileURL()
    
    let utility = Utility()
    utility.pushToFirebase(localFile: url,
                           remoteFile: "test.sqlite")
    
  }
  
  
  
  private func requestAccessToHealthKit() {
    let healthStore = HKHealthStore()
    
    let allShare = Set([HKObjectType.workoutType(),HKSeriesType.workoutRoute(),
                        
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                        
                        
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
    
    
    let allRead = Set([HKObjectType.workoutType(),HKSeriesType.workoutRoute(),
                       
                       
                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
                       
                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.fitzpatrickSkinType)!,
                       
                       HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.wheelchairUse)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                       
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
    
    healthStore.requestAuthorization(toShare: allShare, read: allRead) { (success, error) in
      if !success {
        print( error ?? "requestAuthorizaition error")
      } else {
        print("\n*************************\nAccess is granted\n\n\n")
        print("\(self.readProfile())")
        //self.savePushUps() // My Test (This works!)
        self.readHeartRates()
      }
    }
  }
  
  
  
  func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?
    , bloodtype:HKBloodTypeObject?)
  {
    
    var age:Int?
    age = 0
    //let birthDay: NSDate?
    var biologicalSex :HKBiologicalSexObject? = nil
    var bloodType:HKBloodTypeObject? = nil
    
    // 1. Request birthday and calculate age
    
    do {
      // this was the problem ///////////////
      //try birthDay = healthKitStore.dateOfBirth() as NSDate?
      
      let birthDayComponent = try healthKitStore.dateOfBirthComponents()
      
      
      
      // This changed in Swift 3
      let dfmt = DateFormatter()
      dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
      if let birthDay = birthDayComponent.date {
        let dateString = dfmt.string(from: birthDay )
        print("birthDay = \(dateString)")
      }
      
    } catch {
      
      print("Failure to save context: \(error)")
    }
    
    
    do {
      biologicalSex = try healthKitStore.biologicalSex()
      for _ in 0...30 {
        print("*+")
      }
      // Maybe guard?
      // https://www.natashatherobot.com/healthkit-asking-for-identifying-information/
      switch ((biologicalSex?.biologicalSex.rawValue)! as Int)  {
        
      case 1 :
        print("Female")
      case 2 :
        print("Male")
      case 4  :
        print ("Other")
      default:
        print("default")
      }
      
      
      
    }
    catch {
      print("Error handling Biological Sex")
    }
    
    do {
      bloodType = try healthKitStore.bloodType()
    }
    catch {
      print("Error handling bloodType")
    }
    
    //return (age,nil,nil)
    
    // Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  
  
  
  // MARK: prNRG()
  func prNRG() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in nrgSamples {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit.joule())
      
      
      
      let sd = result.startDate
      let ed = result.endDate
      let diff = ed.timeIntervalSince(sd)
      
      let rate = count / diff
      //let source = result.source
      
      let source = result.sourceRevision.source.name
      
      print("\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(source),\(diff),\(count),\(rate)\n")
      s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(diff),\(count),\(rate)\n"
    }
    return s
  }
  
  
  
  // MARK: prSteps()
  func prSteps() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in stepSamples {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit(from: "count"))
      
      
      
      let sd = result.startDate
      let ed = result.endDate
      let diff = ed.timeIntervalSince(sd)
      
      let rate = count / diff
      //let source = result.source
      
      let source = result.sourceRevision.source.name
      print("source: \(source)")
      
      print("\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(count),\(rate)")
      s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(Int(count)),\(rate)\n"
      // Keep this
      // s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(source),\(diff),\(Int(count)),\(rate)\n"
    }
    return s
  }
  
  
  
  // MARK: prHeartRates()
  func prHeartRates() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in heartRateSamples {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit(from: "count/min"))
      let sd = result.startDate
      
      //Uncomment, if you want to print
      
      print("\(dfmt.string(from: sd )),\(count)")
      s = s + "\(dfmt.string(from: sd )),\(count)\n"
      
      
    }
    return s
  }
  
  // MARK: prFlightsClimbed()
  func prFlightsClimbed() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in flightsClimbed {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit(from: "count"))
      let sd = result.startDate
      
      //Uncomment, if you want to print
      
      print("\(dfmt.string(from: sd )),\(count)")
      s = s + "\(dfmt.string(from: sd )),\(count)\n"
      
      
    }
    return s
  }
  
  
  func prAppleExerciseTime() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in appleExerciseTime {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit.minute())
      
      
      let sd = result.startDate
      
      //Uncomment, if you want to print
      
      print("\(dfmt.string(from: sd )),\(count)")
      s = s + "\(dfmt.string(from: sd )),\(count)\n"
      
      
    }
    return s
  }
  
  
  func prDistanceWalkingRunning() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    for r in distanceWalkingRunning {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit.meter())
      
      //      if count < 0.2 {
      //        continue
      //      }
      //let sd = result.startDate
      let ed = result.endDate
      
      myArray.append("\(dfmt.string(from: ed )),\(count)")
      
    }
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  func prHRV() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    for r in heartRateVaribility {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
      
      
      let sd = result.startDate
      
      myArray.append("\(dfmt.string(from: sd )),\(count)")
      
    }
    
    print("HRV:    **************************\n\n")
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  
  func prWorkout() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    for r in workoutSamples {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit.mile())
      
      if count < 1.5 {
        continue
      }
      let sd = result.startDate
      
      myArray.append("\(dfmt.string(from: sd )),\(count)")
      
    }
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  
  func readWorkoutLocations() {
    
    let endDate = Date()
    let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
    let timePredicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate)
    let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,
                                                                       timePredicate])
    
    
    
    
    
    let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                
                                
                                DispatchQueue.main.async {
                                  print("\n\n  *****  Here is samples  *****\n")
                                  for r in results! {
                                    print("Sample Type: \(r.sampleType)")
                                    print("startDate: \(r.startDate)")
                                    print("endDate: \(r.endDate)")
                                    print("description: \(r.description)")
                                    print("device: \(String(describing: r.device))")
                                    print("uuid: \(r.uuid)")
                                    
                                  }
                                  
                                  print("\n  ****  **** ***** \n\n\n")
                                  self.workoutSamples2 = results!
                                  //self.prWorkoutRoute()
                                  
                                }
    })
    healthKitStore.execute(query)
    
  }
  
  
  
  
  
  
  func prWorkoutRoute(){
    
    if workoutSamples2.count < 1 {
      return
    }
    
    
    
    // let runningPredicate = HKQuery.predicateForObject(with: workoutSamples2[0].uuid)
    
    let endDate = Date()
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate2, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
      
      guard error == nil else {
        fatalError("The initial query failed.\(error)")
      }
      
      // Nill
      print("*******    Data ********* \n")
      print(samples)
      print("End Data\n\n\n")
      
      
      self.distance = 0.0
      self.getRouteData(samples: samples,index: 0)
      
      
      
    }
    self.healthKitStore.execute(routeQuery)
    
    
  }
  
  
  
  func getRouteData(samples:[HKSample]?,index:Int ) {
    // Separate this
    
    
    
    
    
    
    let query = HKWorkoutRouteQuery(route: samples![index] as! HKWorkoutRoute) { (query, locationsOrNill, done, errorOrNil) in
      
      
      if errorOrNil != nil {
        // Handle any errors here.
        return
      }
      
      guard let locations = locationsOrNill else {
        fatalError("*** Invalid State: This can only fail if there was an error. ***")
      }
      
      let r = locationsOrNill![0]
      var mcc = CLLocationCoordinate2D(latitude: r.coordinate.latitude,
                                       longitude: r.coordinate.longitude)
      
      var myLocation = CLLocation(coordinate: mcc, altitude: r.altitude, horizontalAccuracy: r.horizontalAccuracy, verticalAccuracy: r.verticalAccuracy, timestamp: r.timestamp)
      
      
      
      for r in locationsOrNill! {
        print("Locations time: \(r.timestamp)")
        print("Locations lat,lon: \(r.coordinate.latitude),\(r.coordinate.longitude)")
        
        let lat = Double(r.coordinate.latitude).roundTo(places: 10)
        print("lat: \(lat)")
        
        
        print("Altitude: \(r.altitude)")
        print("Speed: \(r.speed)")
        
        
        
        self.distance += r.distance(from: myLocation)
        
        
        
        print("Distance: \(self.distance),     \(r.distance(from: myLocation))")
        
        mcc = CLLocationCoordinate2D(latitude: r.coordinate.latitude,
                                     longitude: r.coordinate.longitude)
        
        
        myLocation = CLLocation(coordinate: mcc, altitude: r.altitude, horizontalAccuracy: r.horizontalAccuracy, verticalAccuracy: r.verticalAccuracy, course: r.course, speed: r.speed, timestamp: r.timestamp)
        
        //        myLocation = CLLocation(coordinate: mcc, altitude: r.altitude, horizontalAccuracy: r.horizontalAccuracy, verticalAccuracy: r.verticalAccuracy, timestamp: r.timestamp)
        //
        
        
        
        
      }
      
      
      if done {
        // The query returned all the location data associated with the route.
        // Do something with the complete data set.
        print("done... Distance: \(self.distance)")
      }
    }
    self.healthKitStore.execute(query)
    
  }
  
  
  
  
  
  func readAndWriteHeartRates() {
    
    let endDate = Date()
    
    let heartRateSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.heartRate)
    
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: heartRateSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  
                                  
                                  self.heartRateSamples = results as! [HKQuantitySample]
                                  
                                  
                                  let sb = SqliteBroker()
                                  sb.exFileSQL(file: "hr.sqlite", sql: "drop table if exists hr;")
                                  sb.heartAdd(heartRateSamples: self.heartRateSamples)
                                  sb.close()
                                  
                                  let url = sb.getDatabaseFileURL(database: "hr.sqlite")
                                  
                                  let utility = Utility()
                                  utility.pushToFirebase(localFile: url,
                                                         remoteFile: "hr.sqlite")
                                  
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
  func readHeartRates() {
    
    let endDate = Date()
    
    let heartRateSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.heartRate)
    
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: heartRateSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.heartRateSamples = results as! [HKQuantitySample]
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
  
  func readSteps() {
    let endDate = Date()
    
    let stepSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.stepCount)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: stepSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.stepSamples = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  self.textView0.text = self.prSteps()
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  func readActiveNRGBurned() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.nrgSamples = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  
                                  let utility = Utility()
                                  utility.writeFile(fileName: "ActiveEnergyBurned.csv", writeString: self.prNRG())
                                  if let url = utility.getURL() {
                                    
                                    utility.pushToFirebase(localFile: url,
                                                           remoteFile: "ActiveEnergyBurned.csv")
                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  func readFlightClimbed() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.flightsClimbed = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  
                                  let utility = Utility()
                                  utility.writeFile(fileName: "FlightsClimbed.csv", writeString: self.prFlightsClimbed())
                                  if let url = utility.getURL() {
                                    
                                    utility.pushToFirebase(localFile: url,
                                                           remoteFile: "FlightsClimbed.csv")
                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
  func readAppleExerciseTime() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.appleExerciseTime = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  let utility = Utility()
                                  utility.writeFile(fileName: "AppleExerciseTime.csv", writeString: self.prAppleExerciseTime())
                                  if let url = utility.getURL() {
                                    
                                    utility.pushToFirebase(localFile: url,
                                                           remoteFile: "AppleExerciseTime.csv")
                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  func readWalkingRunning() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.distanceWalkingRunning = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  let utility = Utility()
                                  utility.writeFile(fileName: "DistanceWalkingRunning.csv", writeString: self.prDistanceWalkingRunning())
                                  if let url = utility.getURL() {
                                    
                                    utility.pushToFirebase(localFile: url,
                                                           remoteFile: "DistanceWalkingRunning.csv")
                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  func readHRV() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.heartRateVaribility = results as! [HKQuantitySample]
                                  
                                  print("HERE test")
                                  print(self.heartRateVaribility )
                                  
                                  // This is unique to View
                                  let utility = Utility()
                                  utility.writeFile(fileName: "heartRateVaribility.csv", writeString: self.prHRV())
                                  if let url = utility.getURL() {
                                    
                                    utility.pushToFirebase(localFile: url,
                                                           remoteFile: "heartRateVaribility.csv")
                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
}





extension Double {
  // Rounds the double to 'places' significant digits
  func roundTo(places:Int) -> Double {
    guard self != 0.0 else {
      return 0
    }
    let divisor = pow(10.0, Double(places) - ceil(log10(fabs(self))))
    return (self * divisor).rounded() / divisor
  }
}
