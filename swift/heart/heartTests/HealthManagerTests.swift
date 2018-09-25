import XCTest
import UIKit

@testable import heart

import HealthKit

//: HKQuery
//HKSampleQuery
class HKSampleQueryMock:HKQuery {
  
  
  
  public func queryinit(sampleType: HKSampleType, predicate: NSPredicate?, limit: Int, sortDescriptors: [NSSortDescriptor]?, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Swift.Void) ->  HKQuery {
    
    return self
  }
  
  /*
  private let resultsHandler:(HKSampleQuery, [HKSample]?, Error?) -> Void
   
  override public init(sampleType: HKSampleType, predicate: NSPredicate?, limit: Int, sortDescriptors: [NSSortDescriptor]?, resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Swift.Void) {
    
    self.resultsHandler = resultsHandler
    
    super.init(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors,
               resultsHandler: resultsHandler)
    
 
    
    print("\n\n\n ------------------ HKSampleQueryMock:HKSampleQuery  --\n\n\n" )
   
   }
    */
    
  
  
  
}


class HKHealthStoreMock:HKHealthStore {
  
  
  
  
  var expectedAge:Int?
  
  
  override func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void) {
    
    print("\n\nMock Authorization\n\n")
  }
  
  
  override func execute(_ query: HKQuery) {
    print("***\n\n**************  Execute Overide Test ******** \n\n")
    print("query.predicate: ...\(String(describing: query.predicate))\n\n ")
    
    debugPrint("query:",query)

    
    print("sampleType type: \(String(describing: query.objectType))")
    
    
  }
  
  override func biologicalSex() throws -> HKBiologicalSexObject {
    class HKBiologicalSexObjectMock: HKBiologicalSexObject {
      override var biologicalSex: HKBiologicalSex  { get { return HKBiologicalSex(rawValue: 2)! } }
    }
    return HKBiologicalSexObjectMock()
  }
  
  override func bloodType() throws -> HKBloodTypeObject {
    class HKBloodTypeObjectMock: HKBloodTypeObject {
      override var  bloodType: HKBloodType  { get { return HKBloodType(rawValue: 2)! } }
    }
    return HKBloodTypeObjectMock()
  }
  
  
  func ExpectedAge() -> Int? {
    return expectedAge
  }
  
  override func dateOfBirthComponents() throws -> DateComponents {
    let calendar = NSCalendar.current
    let t = DateComponents(calendar: calendar, year: 1963, month: 1, day: 12)
    expectedAge = Calendar.current.dateComponents([.year], from: t.date!, to: Date()).year!
    return t
  }
  
  
  
  
}

// http://www.mokacoding.com/blog/dependency-injection-for-classes-in-swift/
class HealthKitManagerMock: HealthKitManager {
  
  
  override init() {
    super.init()
    
    healthKitStore = HKHealthStoreMock()
  }
  
  func ExpectedAge() -> Int {
    let h = HKHealthStoreMock()
    try! print(h.dateOfBirthComponents())
    return h.ExpectedAge()!
  }
  
  
}

class HealthManagerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  
  func testHealthRequest(){
    let h = HealthKitManagerMock()
    h.requestAccessToHealthKit()
    
    let (age,sex,blood) = h.readProfile()
    XCTAssert(age == h.ExpectedAge())
    XCTAssert(sex == "Male")
    XCTAssert(blood!.bloodType == HKBloodType.aNegative )
    
  }
  
  func testHealthQuery(){
    let h = HealthKitManagerMock()
    h.requestAccessToHealthKit()
    h.readAppleExerciseTime()
    
    
  }
  
  
  func testFetch(){
    let h = HealthKitManagerMock()
    h.requestAccessToHealthKit()
    
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
    
    
  }
  
  
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  
  
  func testWithInnerClass(){
    // let h = HealthKitManager()
    // h.requestAuthorization(completion: <#T##(Bool, Error?) -> Void#>)
    
  }
  
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
