import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

import HealthKit


class ViewController: UIViewController,GIDSignInUIDelegate  {
  var ref: DatabaseReference!
  var db: Firestore!
  
  let healthManager:HealthManager = HealthManager()
  let healthKitStore:HKHealthStore = HKHealthStore()
  var hearRateSamples = [HKQuantitySample]()
  var stepSamples = [HKQuantitySample]()
  var nrgSamples = [HKQuantitySample]()
  
  var startDate = Date().addingTimeInterval(-80*24*60*60)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signIn()
    ref = Database.database().reference()
    db = Firestore.firestore()
    
    //valid_accounts
    self.ref.child("valid_accounts").child("heartRate").setValue(["username": "mchirico@gmail.com"])
    
   
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func buttonUpload(_ sender: UIButton) {
    
      self.requestAccessToHealthKit()
    
    let utility = Utility()
    utility.writeFile(fileName: "HeartRates.csv", writeString: prHeartRates())
    
    if let url = utility.getURL() {
      
      utility.pushToFirebase(localFile: url,
                             remoteFile: "HeartRate.csv")
    }
  }
  
  
  
  private func requestAccessToHealthKit() {
    let healthStore = HKHealthStore()
    
    let allShare = Set([HKObjectType.workoutType(),
                        
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
                        
                        
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
    
    
    let allRead = Set([HKObjectType.workoutType(),
                       
                       
                       
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
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
    
    healthStore.requestAuthorization(toShare: allShare, read: allRead) { (success, error) in
      if !success {
        print( error)
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
      s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(source),\(diff),\(count),\(rate)\n"
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
      
      print("\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(count)")
      s = s + "\(dfmt.string(from: sd )),\(dfmt.string(from: ed )),\(source),\(diff),\(Int(count)),\(rate)\n"
    }
    return s
  }
  
  
  
  // MARK: prHeartRates()
  func prHeartRates() -> (String){
    var s = ""
    let dfmt = DateFormatter()
    dfmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    for r in hearRateSamples {
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
  
  
  
  
  func readHeartRates() {
    
    //hstatus=0
    //println("hearRateSamples: \(hearRateSamples)")
    
    let endDate = Date()
    //let startDate = endDate.addingTimeInterval(-360*24*500)
    
    
    
    let heartRateSampleType = HKSampleType.quantityType( forIdentifier: HKQuantityTypeIdentifier.heartRate)
    
    // HKQuery.predicate(forActivitySummariesBetweenStart: startDate, end: <#T##DateComponents#>)
    let predicate2 = HKQuery.predicateForSamples(withStart: startDate,
                                                 end: endDate)
    
    let query = HKSampleQuery(sampleType: heartRateSampleType!, predicate: predicate2,
                              limit: 0, sortDescriptors: nil, resultsHandler: {
                                (query, results, error) in
                                
                                DispatchQueue.main.async {
                                  self.hearRateSamples = results as! [HKQuantitySample]
                                  
                                }
    })
    healthKitStore.execute(query)
  }
  
  
  
  
  
  
  
  
}
