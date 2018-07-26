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
  
  
  
  var startDate = Date().addingTimeInterval(-2*24*60*60)
  var distance = 0.0
  
  
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
      
      //Uncomment, if you want to print
      
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
  
  
  
  
  
  
  
  
  
}




