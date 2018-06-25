



import Foundation



import HealthKit


class HealthKitManager: NSObject {
  
  private let healthStore = HKHealthStore()
  
  func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
    var shareTypes = Set<HKSampleType>()
    var readTypes = Set<HKSampleType>()
    
    // Add Workout Type
    shareTypes.insert(HKSampleType.workoutType())
    readTypes.insert(HKSampleType.workoutType())
    
    // Request Authorization
    healthStore.requestAuthorization(toShare: shareTypes, read: readTypes, completion: completion)
  }
  
}




class HealthManager {
  let healthKitStore:HKHealthStore = HKHealthStore()
  let store:HKHealthStore = HKHealthStore()
  
  var hearRateSamples = [HKQuantitySample]()
  var hstatus=0
  
  
  
  
  func authorizeHealthKit(completion: ((_ success:Bool, _ error:NSError?) -> Void)!)
  {
    
    let healthKitTypesToRead = Set(
      arrayLiteral:
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!,
      
      
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
      
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.numberOfTimesFallen)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!,
      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
      HKObjectType.workoutType()
      
    )
    
    let healthKitTypesToWrite = Set(
      arrayLiteral:
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMassIndex)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.numberOfTimesFallen)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)!,
      HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
      HKQuantityType.workoutType()
      
    )
    
    
    
    let _: ((Bool, NSError?) -> Void) = {
      (success, error) -> Void in
      
      if !success {
        print("You didn't allow HealthKit to access these write data types.\nThe error was:\n \(error!.description).")
        
        return
      }
    }
    
    
    
    healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
      if !success {
        print(error ?? "Error on requestAuthorization" )
      }
    }
    
    
    
    
    
  }
  
  
  
}
