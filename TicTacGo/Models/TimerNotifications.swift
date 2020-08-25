//
//  TimerNotifications.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/24/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation
import UserNotifications


class TimerNotifications: CustomStringConvertible, NotificationScheduler {
  
  var startTime: Date = Date()
  var endTime: Date = Date()
  var restTimes: [Date] = []
  var endOfRestTimes: [Date] = []
  
  func reset() {
    startTime = Date()
    endTime = Date()
    restTimes = []
    endOfRestTimes = []
  }
  
  func createNotification(at date: Date, title: String, soundName: SoundName) {
    var components = DateComponents()
    let calendar = Calendar.current
    
    components.second = calendar.component(.second, from: date)
    components.minute = calendar.component(.minute, from: date)
    components.hour = calendar.component(.hour, from: date)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    scheduleNotification(
      title: title,
      trigger: trigger,
      sound: true,
      soundName: soundName.rawValue,
      badge: nil)
  }
  
  func createNotifications() {
    createNotification(at: startTime, title: "Start", soundName: .start)
    createNotification(at: endTime, title: "End of workout", soundName: .end)
    for startRest in restTimes {
      createNotification(at: startRest, title: "Time to rest", soundName: .rest)
    }
    
    for endRest in endOfRestTimes {
      createNotification(at: endRest, title: "Time to start again", soundName: .start)
    }
  }
  
  var description: String {
    let startTimeDescription = "🟢The exercise will start at \(startTime)\n"
    let endTimeDescription = "🔴The exercise will end at \(endTime)\n"
    
    var restTimesDescription = ""
    var endOfRestTimesDescription = ""
    var index = 1
    for restTime in restTimes {
      restTimesDescription += "☀️The timer \(index) will start at: \(restTime)\n"
      index += 1
    }
    
    index = 1
    for endRestTime in endOfRestTimes {
      endOfRestTimesDescription += "🌑The end of Timer \(index) will be at \(endRestTime)\n"
      index += 1
    }
    
    return startTimeDescription + endTimeDescription + restTimesDescription + endOfRestTimesDescription
  }
}
