/*
 Will need to add documentation
 
 
 
 
 
 
 
 
 */


import UIKit

import Foundation
import HealthKit

import CoreLocation

protocol ZZ {
  init(sampleType: HKSampleType, predicate: NSPredicate?, limit: Int, sortDescriptors: [NSSortDescriptor]?, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Swift.Void)
}



class HKSQuery:HKQuery {
  
  
  public func queryinit(sampleType: HKSampleType, predicate: NSPredicate?, limit: Int, sortDescriptors: [NSSortDescriptor]?, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Swift.Void) ->  HKSampleQuery {
    
    return HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors, resultsHandler: resultsHandler)
  }
}



class HealthKitManager {
  
  var textView0: UITextView!
  
  var startDate = Date().addingTimeInterval(-10*60*60)
  var endDate = Date().addingTimeInterval(-10*60*60)
  var distance = 0.0
  
  var vo2Max = [HKQuantitySample]()
  
  
  var healthKitStore:HKHealthStore
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
  
  var workouts = Workouts()
  
  
  
  init(){
    healthKitStore = HKHealthStore()
    
  }
  
  
  func requestAccessToHealthKit() {
    
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
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
                       
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.vo2Max)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
    
    
    requestAccess(toShare: allShare, read: allRead)
    
  }
  
  private func requestAccess(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?){
    
    
    healthKitStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
      if !success {
        print( error ?? "requestAuthorizaition error")
      } else {
        print("\n*************************\nAccess is granted\n\n\n")
        print("\(self.readProfile())")
        
        // My Tests
        //  self.savePushUps() // My Test (This works!)
        //  self.readHeartRates()
        
      }
    }
  }
  
  
  
  
  func readProfile() -> ( age:Int?,  biologicalsex:String
    , bloodtype:HKBloodTypeObject?)
  {
    
    var age:Int?
    var sex=""
    
    //let birthDay: NSDate?
    var biologicalSex :HKBiologicalSexObject? = nil
    var bloodType:HKBloodTypeObject? = nil
    
    // 1. Request birthday and calculate age
    do {
      
      let birthDayComponent = try healthKitStore.dateOfBirthComponents()
      
      let dfmt = DateFormatter()
      dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
      if let birthDay = birthDayComponent.date {
        age = Calendar.current.dateComponents([.year], from: birthDay, to: Date()).year
        let dateString = dfmt.string(from: birthDay )
        print("birthDay = \(dateString)")
        print("Age: \(String(describing: age ?? 0))")
        
      }
      
    } catch {
      
      print("Failure to save context: \(error)")
    }
    
    do {
      biologicalSex = try healthKitStore.biologicalSex()
      for _ in 0...3 {
        print("\n*+")
      }
      // Maybe guard?
      // https://www.natashatherobot.com/healthkit-asking-for-identifying-information/
      switch ((biologicalSex?.biologicalSex.rawValue)! as Int)  {
        
      case 1 :
        sex = "Female"
      case 2 :
        sex = "Male"
      case 4  :
        sex = "Other"
      default:
        sex = "default"
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
    return (age, sex,bloodType)
  }
  
  
  func savePushUps() {
    //FunctionalStrengthTraining
    
    let end = Date()
    let start = Calendar.current.date(byAdding: .minute, value: -20, to: Date())!
    
    let energyBurned = HKQuantity(unit: HKUnit.kilocalorie(),
                                  doubleValue: 425.0)
    
    let distance = HKQuantity(unit: HKUnit.mile(),
                              doubleValue: 0)
    
    let status = "felt okay...could have done more"
    let push_ups = 40
    let sit_ups = 50
    let jumping_jacks = 50
    let abdominal_lifts = 40
    let psychology = 75   // scale 1 to 100
    
    //let separated = split("Split Me!", {$0==" "}, allowEmptySlices: false)
    
    let meta = ["push_ups": push_ups,
                "sit_ups": sit_ups,
                "notes": status,
                "tag": "Entry from Heart",
                "jumping_jacks": jumping_jacks,
                "abdominal_lifts": abdominal_lifts,
                "psychology": psychology,
                HKMetadataKeyIndoorWorkout:true
      ] as NSDictionary
    
    // Example of adding metadata....
    let wrkOut = HKWorkout(activityType: HKWorkoutActivityType.functionalStrengthTraining,
                           start: start, end: end, duration: 0,
                           totalEnergyBurned: energyBurned, totalDistance: distance, metadata: (meta as [NSObject : AnyObject] as! [String : Any]))
    
    // Save the workout before adding detailed samples.
    healthKitStore.save(wrkOut) { (success, error) -> Void in
      if !success {
        // Perform proper error handling here...
        print("*** An error occurred while saving the " +
          "workout: \(String(describing: error?.localizedDescription))")
        
        abort()
      }
      
      // Add optional, detailed information for each time interval
      var samples: [HKQuantitySample] = []
      
      let distanceType =
        HKObjectType.quantityType(
          forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
      
      let distancePerInterval = HKQuantity(unit: HKUnit.foot(),
                                           doubleValue: 165.0)
      
      let distancePerIntervalSample =
        HKQuantitySample(type: distanceType!, quantity: distancePerInterval,
                         start: start, end: end)
      
      samples.append(distancePerIntervalSample)
      
      let meta = HKQuantity(unit: HKUnit.count(),
                            doubleValue: 40.0)
      
      let pType =
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)
      
      
      
      let energyBurnedType =
        HKObjectType.quantityType(
          forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
      
      let energyBurnedPerInterval = HKQuantity(unit: HKUnit.kilocalorie(),
                                               doubleValue: 15.5)
      
      let energyBurnedPerIntervalSample =
        HKQuantitySample(type: energyBurnedType!, quantity: energyBurnedPerInterval,
                         start: start, end: end)
      
      samples.append(energyBurnedPerIntervalSample)
      
      let heartRateType =
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
      
      let heartRateForInterval = HKQuantity(unit: HKUnit(from: "count/min"),
                                            doubleValue: 95.0)
      
      let heartRateForIntervalSample =
        HKQuantitySample(type: heartRateType!, quantity: heartRateForInterval,
                         start: start, end: end)
      
      
      
      // Works...but don't screw up real data
      // samples.append(heartRateForIntervalSample)
      
      // Continue adding detailed samples...
      // Add all the samples to the workout.
      self.healthKitStore.add(samples,
                              to: wrkOut) { (success, error) -> Void in
                                if !success {
                                  // Perform proper error handling here...
                                  print("*** An error occurred while adding a " +
                                    "sample to the workout: \(String(describing: error?.localizedDescription))")
                                  abort()
                                } else {
                                  print("okay...sample added")
                                }
      }
    }
    
    
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
      
      // Uncomment, if you want to print
      
      print("\(dfmt.string(from: sd )),\(count)")
      s = s + "\(dfmt.string(from: sd )),\(count)\n"
      
      
    }
    return s
  }
  
  
  
  func readAppleExerciseTime() {
    let endDate = Date()
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    
    
    // HKSQuery
    // HKSampleQuery
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                
                                
                                DispatchQueue.main.async {
                                  self.appleExerciseTime = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
//                                  let utility = Utility()
//                                  utility.writeFile(fileName: "AppleExerciseTime.csv", writeString: self.prAppleExerciseTime())
//                                  if let url = utility.getURL() {
//
//                                    utility.pushToFirebase(localFile: url,
//                                                           remoteFile: "AppleExerciseTime.csv")
//                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
  // MARK: Steps
  
  func prSteps() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    let dfmtZ = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dfmtZ.timeZone = TimeZone(secondsFromGMT: 0)
    dfmtZ.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    for r in stepSamples {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit(from: "count"))
      
      
      
      let sd = result.startDate
      let ed = result.endDate
      let diff = ed.timeIntervalSince(sd)
      
      
      
      let rate = count / diff
      //let source = result.source
      
      
      
      //        let source = result.sourceRevision.source.name
      //        print("source: \(source)")
      
      
      
      
      //      print( " \(dfmt.string(from: sd )), " +
      //        " \(dfmt.string(from: ed ) ), \(dfmtZ.string(from: ed)) " +
      //      " \(count),\(rate * 60),\(rate), \(diff)" )
      
      print( " \(dfmt.string(from: sd )), " +
        " \(dfmt.string(from: ed ) ), \(rate * 60)")
      
      
      
      s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(Int(count)),\(rate)\n"
      // Keep this
      // s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(source),\(diff),\(Int(count)),\(rate)\n"
    }
    return s
  }
  
  
  
  
  func readSteps(withStart: Date,
                 endDate:Date = Date()) {
    
    
    let stepSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.stepCount)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: stepSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.stepSamples = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
                                  self.prSteps()
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  // MARK: Running -- what the watch says
  
  
  func walkingRunningWatchDistance(withStart:Date, end: Date) {
    
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
    let predicate2 = HKQuery.predicateForSamples(withStart: withStart,
                                                 end: end)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.distanceWalkingRunning = results as! [HKQuantitySample]
                                  
                                  // This is unique to View
//                                  let utility = Utility()
//                                  utility.writeFile(fileName: "DistanceWalkingRunning2.csv", writeString: self.prDistanceWalkingRunning())
//                                  if let url = utility.getURL() {
//
//                                    utility.pushToFirebase(localFile: url,
//                                                           remoteFile: "DistanceWalkingRunning2.csv")
//                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
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
  
  
  // Workout Date Times
  
  
  func WorkOutData(withStart:Date, endDate: Date) {
    
    print("withStart \(withStart)\n")
    print("withEnd \(endDate)\n")
    
    let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
    
    
    let uuidPredicate = HKQuery.predicateForObject(with: UUID(uuidString: "7C85ED07-1D0E-4CDA-9813-7217463490EB")!)
    
    
    
    // I don't think you can query by time range for workouts -- samples only?
    
    // let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,timePredicate])
    
    let timePredicate = HKQuery.predicateForSamples(withStart: withStart,
                                                    end: endDate)
    // let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,
    //                                                                   timePredicate])
    
    
    var compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,uuidPredicate])
    
    if 1 == 1 {
      compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate])
      
    }
    
    // Can we add time?
    // compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,uuidPredicate,timePredicate])
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                          ascending: false)
    
    // HKObjectQueryNoLimit
    let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound,
                              limit: 1, sortDescriptors: [sortDescriptor], resultsHandler: {
                                (query, results, error) in
                                
                                
                                DispatchQueue.main.async {
                                  print("\n\n  *****  Here is samples  *****\n")
                                  print("\n error: \(error)")
                                  
                                  print("\n count: \(results!.count)\n")
                                  
                                  
                                  
                                  for r in results! {
                                    
                                    
                                    self.textView0.text = "Good"
                                    
                                    
                                    self.startDate = r.startDate
                                    self.endDate = r.endDate
                                    
                                    print("Sample Type: \(r.sampleType)")
                                    print("startDate: \(r.startDate)")
                                    print("endDate: \(r.endDate)")
                                    print("description: \(r.description)")
                                    
                                    let dateFormatter = DateFormatter()
                                    
                                    
                                    
                                    if let meta = r.metadata {
                                      print("\nMeta:")
                                      for m in meta {
                                        if m.key == "HKTimeZone" {
                                          dateFormatter.timeZone = TimeZone(identifier: m.value as! String)
                                          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                          print("start: \(dateFormatter.string(from: r.startDate))")
                                          
                                          let ti = Int(r.endDate.timeIntervalSince(r.startDate))
                                          let seconds = ti % 60
                                          let minutes = (ti / 60) % 60
                                          let hours = (ti / 3600)
                                          print("Minutes: \(minutes)")
                                          print("Hours: \(hours)")
                                          print("Seconds: \(seconds)")
                                          
                                          
                                          
                                        }
                                        print("key: \(m.key), value: \(m.value)")
                                      }
                                    }
                                    print("metadata: \(String(describing: r.metadata))")
                                    
                                    print("device: \(String(describing: r.device))")
                                    print("uuid: \(r.uuid)")
                                    
                                  }
                                  
                                  print("\n  ****  **** ***** \n\n\n")
                                  self.workoutSamples2 = results!
                                  // Works below, but prints a lot of data
                                  self.prWorkoutRoute(startDate: self.startDate, endDate: self.endDate)
                                  
                                  // True distance?
                                  self.walkingRunningWatchDistance(withStart: self.startDate, end: self.endDate)
                                  
                                }
    })
    healthKitStore.execute(query)
    
  }
  
  
  
  
  
  
  func prWorkoutRoute(startDate: Date, endDate: Date){
    
    if workoutSamples2.count < 1 {
      return
    }
    
    
    
    // let runningPredicate = HKQuery.predicateForObject(with: workoutSamples2[0].uuid)
    
    let endDate = Date()
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: predicate2, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
      
      guard error == nil else {
        fatalError("The initial query failed.\(error!)")
      }
      
      // Nill
      print("*******    Data(22) ********* \n")
      print("startDate: \(self.startDate)\n")
      
      print("\n ---  samples --- \n")
      print(samples)
      print("End Data\n\n\n")
      
      
      if samples?.count == 0 {
        return
      }
      
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
       
        print("lat: \(r.coordinate.latitude)")
        
        
        print("Altitude: \(r.altitude)")
        print("Speed: \(r.speed)")
        
        
        self.distance += r.distance(from: myLocation)
        
        
        
        print("Distance: \(self.distance), \(self.distance * 0.000621371) miles,  \(r.distance(from: myLocation)) \(r.distance(from: myLocation)*3.28084) feet")
        
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
  
  /*
   
   let dateFormatter = DateFormatter()
   dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
   guard let sd = dateFormatter.date(from: "2018-08-12 12:24:52 +0000") else {
   fatalError(" Cannot create start date **")
   }
   guard let ed = dateFormatter.date(from: "2018-08-29 12:24:52 +0000") else {
   fatalError(" Cannot create end date **")
   }
   
   h.fetchTotalJoulesConsumedWithCompletionHandler(
   startDate: sd,endDate: ed) {total,err in
   print("\n\nfetchTotalJoulesConsumedWithCompletionHandler: \(total)")
   
   }
   
   Ref: https://mchirico.github.io/python/2018/07/18/swift4.html#read-more
   
   */
  
  // Apple's example ... does this work?
  func fetchTotalJoulesConsumedWithCompletionHandler(
    startDate:Date, endDate:Date,
    completionHandler:@escaping (Double?, Error?)->()) {
    
    let sampleType = HKQuantityType.quantityType(
      forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
    
    
    let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                end: endDate, options: .strictStartDate)
    
    
    
    let query = HKStatisticsQuery(quantityType: sampleType!,
                                  quantitySamplePredicate: predicate,
                                  options: .cumulativeSum) { query, result, error in
                                    
                                    if result == nil {
                                      completionHandler(nil, error )
                                      return
                                    }
                                    
                                    var totalCalories = 0.0
                                    
                                    if let quantity = result?.sumQuantity() {
                                      let unit = HKUnit.count()
                                      totalCalories = quantity.doubleValue(for: unit)
                                    }
                                    
                                    print("startDate: \(startDate)\n")
                                    print("endDate: \(endDate)\n")
                                    
                                    completionHandler(totalCalories,error)
    }
    
    healthKitStore.execute(query)
  }
  
  
  func readVO2Max(startDate: Date) {
    let endDate = Date()
    
    
    //  let hSampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.vo2Max)
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.vo2Max)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  if results == nil {
                                    return
                                  }
                                  
                                  self.vo2Max = results as! [HKQuantitySample]
                                  
                                  print("HERE test")
                                  print(self.vo2Max )
                                  
                                  // This is unique to View
//                                  let utility = Utility()
//                                  utility.writeFile(fileName: "vo2Max.csv", writeString: self.prVo2Max())
//                                  if let url = utility.getURL() {
//
//                                    utility.pushToFirebase(localFile: url,
//                                                           remoteFile: "vo2Max.csv")
//                                  }
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  func prVo2Max() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    for r in vo2Max {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for:  HKUnit(from: "ml/kg*min"))
      
      
      let sd = result.startDate
      
      myArray.append("\(dfmt.string(from: sd )),\(count)")
      
    }
    
    print("Vo2Max:    **************************\n\n")
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  
  // Ref: https://www.devfright.com/healthkit-tutorial-fetch-weight-data-swift/
  func readWeight() {
    let quantityType : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
    
    let startDate = Date.init(timeIntervalSinceNow: -7*24*60*60)
    let endDate = Date()
    
    let predicate = HKQuery.predicateForSamples(withStart: startDate,
                                                end: endDate,
                                                options: .strictStartDate)
    
    let query = HKSampleQuery.init(sampleType: quantityType.first!,
                                   predicate: predicate,
                                   limit: HKObjectQueryNoLimit,
                                   sortDescriptors: nil,
                                   resultsHandler: { (query, results, error) in
                                    
                                    DispatchQueue.main.async {
                                      if results == nil {
                                        return
                                      }
                                      
                                      var weight = results as! [HKQuantitySample]
                                      
                                      print("HERE test")
                                      //print(weight )
                                      self.prWeight(weight: weight)
                                      
                                    }
                                    
                                    
    })
    healthKitStore.execute(query)
  }
  
  
  func prWeight(weight: [HKQuantitySample]) -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    for r in weight {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let count = quantity.doubleValue(for: HKUnit(from: .pound))
      
      
      let sd = result.startDate
      
      myArray.append("\(dfmt.string(from: sd )),\(count)")
      
    }
    
    print("Weight:    **************************\n\n")
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  
  func QueryToWorkout(query : HKSampleQuery,
                      results: [HKSample]?,
                      error: Error?,
                      workouts: Workouts) {
    
    
    guard let results = results else { /* Handle nil case */ return }
    
    for r in results {
      workouts.add(sampleType: r.sampleType,
                   startDate: r.startDate,
                   endDate: r.endDate,
                   description: r.description,
                   uuid: r.uuid)
    }
    
  }
  
  
  
  /*
   Basic information about out run:
   startDate
   endDate
   Temp, Humid
   UUID (Can I use this uuid)?
   */
  
  // MARK: readWorkoutLocations
  func readRunWorkouts(startDate: Date, endDate: Date) {
    
    
    
    
    
    let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
    let timePredicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate)
    let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,
                                                                       timePredicate])
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                          ascending: false)
    
    let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound,
                              limit: 0, sortDescriptors: [sortDescriptor], resultsHandler: {
                                (query, results, error) in
                                
                                self.QueryToWorkout(query: query, results: results, error: error,workouts: self.workouts)
                                
                                DispatchQueue.main.async {
                                  
                                  print("\n\n  *****  Here is samples  *****\n")
                                  for r in results! {
                                    
                                    
                                    print("Sample Type: \(r.sampleType)")
                                    print("startDate: \(r.startDate)")
                                    print("endDate: \(r.endDate)")
                                    print("description: \(r.description)")
                                    
                                    let dateFormatter = DateFormatter()
                                    
                                    if let meta = r.metadata {
                                      print("\nMeta:")
                                      for m in meta {
                                        if m.key == "HKTimeZone" {
                                          dateFormatter.timeZone = TimeZone(identifier: m.value as! String)
                                          dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                          print("start: \(dateFormatter.string(from: r.startDate))")
                                          print("end: \(dateFormatter.string(from: r.endDate))")
                                          print("uuid: \(r.uuid)")
                                          
                                          if let temp = r.metadata?["HKWeatherTemperature"] {
                                            print("temp: \(temp)")
                                          }
                                          if let humidity = r.metadata?["HKWeatherHumidity"] {
                                            print("humidity: \(humidity)")
                                          }
                                          
                                          let ti = Int(r.endDate.timeIntervalSince(r.startDate))
                                          let seconds = ti % 60
                                          let minutes = (ti / 60) % 60
                                          let hours = (ti / 3600)
                                          print("Minutes: \(minutes)")
                                          print("Hours: \(hours)")
                                          print("Seconds: \(seconds)")
                                          
                                        }
                                        print("key: \(m.key), value: \(m.value)")
                                      }
                                    }
                                    print("metadata: \(String(describing: r.metadata))")
                                    print("device: \(String(describing: r.device))")
                                    print("uuid: \(r.uuid)")
                                  }
                                  print("\n  ****  **** ***** \n\n\n")
                                }
    })
    healthKitStore.execute(query)
    print("here")
  }
  
  
  func getRunWorkouts(startDate: Date, endDate: Date,
                      completion: @escaping (_ resultW: Workouts ) -> String)  {
    
    let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
    let timePredicate = HKQuery.predicateForSamples(withStart: startDate,
                                                    end: endDate)
    let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,
                                                                       timePredicate])
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                          ascending: false)
    
    let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound,
                              limit: 0, sortDescriptors: [sortDescriptor], resultsHandler: {
                                
                                (query, results, error) in
                                
                                self.QueryToWorkout(query: query,
                                                    results: results,
                                                    error: error,
                                                    workouts: self.workouts)
                                
                                let future = completion(self.workouts)
                                print("future: \(future)")
                                
    })
    healthKitStore.execute(query)
  }
  
  
  func getWatchDistance(withStart:Date, endDate: Date,
                        completion: @escaping (_ resultW: String ) -> String) {
    
    
    let hSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
    let predicate2 = HKQuery.predicateForSamples(withStart: withStart,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: hSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                completion(self.mWalkingRunning(results: results,endDate: endDate))
                                
    })
    healthKitStore.execute(query)
  }
  
  
  func mWalkingRunning(results: [HKSample]?, endDate: Date) -> (String) {
    
    let distanceWalkingRunning = results as! [HKQuantitySample]
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var myArray = [String]()
    var totalDistanceMile = 0.0
    var totalDistanceMeter = 0.0
    
    for r in distanceWalkingRunning {
      let result = r as HKQuantitySample
      let quantity = result.quantity
      let dMile = quantity.doubleValue(for: HKUnit.mile())
      let dMeter = quantity.doubleValue(for: HKUnit.meter())
      
      totalDistanceMile += dMile
      totalDistanceMeter += dMeter
      
      let st = result.startDate
      let ed = result.endDate
      
      let rate = (ed.timeIntervalSince(st)/dMile)/60
      
      if endDate >= ed {
        myArray.append("\(dfmt.string(from: ed )),\(totalDistanceMile),\(rate)")
      }
      
    }
    let mySet = Array(Set(myArray))
    for i in mySet.sorted() {
      print(i)
      s = s + "\(i)\n"
    }
    return s
  }
  
  
  
}






