//
//  Workout.swift
//  heart
//
//  Created by Michael Chirico on 12/4/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation
import HealthKit

class Workout {
  
  var sampleType: HKSampleType?
  var startDate: Date?
  var endDate: Date?
  var description: String?
  var uuid: UUID?
  
}

class Workouts {
  var records: [UUID: Workout] = [:]
  var startDate: [Date: UUID] = [:]
  var dateArray: [Date] = []
  
  func add(workout: Workout) {
    if let uuid = workout.uuid {
      records[uuid] = workout
      if let start = workout.startDate {
        startDate[start] = uuid
      }
      if let date = workout.startDate {
        dateArray.append(date)
      }
    }
  }
  
  func add(sampleType: HKSampleType, startDate: Date, endDate: Date,
           description: String, uuid: UUID) {
    let workout = Workout()
    workout.sampleType = sampleType
    workout.startDate = startDate
    workout.endDate = endDate
    workout.uuid = uuid
    add(workout: workout)
    
  }
  
}
