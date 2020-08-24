//
//  SetTime.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/24/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation

struct Exercise {
  var minutes = 0
  var seconds = 0
}

struct Rest {
  var minutes = 0
  var seconds = 0
}

public struct SetTime: CustomStringConvertible {
  var exercise = Exercise()
  var rest = Rest()
  
  var totalSeconds: Int {
    return exercise.minutes * 60 + exercise.seconds + rest.minutes * 60 + rest.seconds
  }
  
  var totalExercise: Int {
    return exercise.minutes * 60 + exercise.seconds
  }
  
  var isZero: Bool {
    return (exercise.minutes + exercise.seconds + rest.minutes + rest.seconds) == 0 ? true : false
  }
  
  mutating func reset() {
    exercise.minutes = 0
    exercise.seconds = 0
    rest.minutes = 0
    rest.seconds = 0
  }
  
  public var description: String {
    return """
    Exercise Minutes: \(exercise.minutes)
    Exercise Seconds: \(exercise.seconds)
    Rest Minutes: \(rest.minutes)
    Rest Seconds: \(rest.seconds)
    """
  }
}
