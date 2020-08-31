//
//  ViewModel.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation
import Combine
import AudioToolbox
import UserNotifications

class ViewModel : ObservableObject{
  
  //MARK: - Properties
  private var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  private var cancellable: AnyCancellable?
  private var memoryLapTime = SetTime()
  private var memoryLoops: Double = 1
  
  var notificationTimes = TimerNotifications()
  
  @Published var setTime = SetTime()
  @Published var loops: Double = 1
  
  //MARK: - Initializer
  init() {
    SystemSounds.loadSoundEffects()
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("All set!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
  }
  
  //MARK: - Functions
  func startTimer(completion: (()->())?) {
    let allowToStart = (setTime.exercise.minutes+setTime.exercise.seconds+setTime.rest.minutes+setTime.rest.seconds) > 0 ? true : false
    var counter = 0
    if allowToStart {
      memoryLapTime = setTime
      memoryLoops = loops
      self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      self.cancellable = currentTimePublisher?.sink { value in
        if counter == 0 {
          self.createLocalNotifications(date: value)
        }
        if counter >= 5 {
          self.countDownByOne()
          if self.setTime.isZero || (self.loops == 1 && self.setTime.exercise.minutes + self.setTime.exercise.seconds == 0)  {
            print("🔴 BRRRR BRRR BRRRR Finish loop \(Date())")
            self.loops -= 1
            self.setTime = self.memoryLapTime
          }
          if self.loops == 0 {
            self.finishTimer()
            completion?()
          }
        }
        counter += 1
      }
    }
  }
  
  func stopTimer() {
    self.currentTimePublisher?.upstream.connect().cancel()
//    self.unloadAllSoundEffects()
    self.setTime = self.memoryLapTime
    self.loops = self.memoryLoops
    self.notificationTimes.reset()
  }
  
  func finishTimer() {
    print("⏰ Finished \(Date())")
//    self.playSoundEffect(soundName: "end.caf") { //First play end sound
//      self.unloadAllSoundEffects() //then it unloads all the sounds.
//    }
    self.currentTimePublisher?.upstream.connect().cancel()
    self.setTime = self.memoryLapTime
    self.loops = self.memoryLoops
    self.notificationTimes.reset()
  }
  
  private func countDownByOne() {
    if self.setTime.exercise.seconds != 0 {
      self.setTime.exercise.seconds -= 1
    } else if self.setTime.exercise.minutes > 0 {
      self.setTime.exercise.minutes -= 1
      self.setTime.exercise.seconds = 59
    } else if self.setTime.rest.seconds != 0 && loops > 1 {
      self.setTime.rest.seconds -= 1
    } else if self.setTime.rest.minutes > 0 && loops > 1 {
      self.setTime.rest.minutes -= 1
      self.setTime.rest.seconds = 59
    }
  }
  
  private func createLocalNotifications(date: Date) {
    var isFirstLoop = false
    
    //Create immediate push notification
    self.notificationTimes.startTime = date.addingTimeInterval(1)
    
    //Create end notification
    let startEndExerciseAfter = 3 + (setTime.totalSeconds * Int(self.loops)) - (setTime.rest.minutes * 60 + setTime.rest.seconds)
    self.notificationTimes.endTime = self.notificationTimes.startTime.addingTimeInterval(Double(startEndExerciseAfter))
    
    var startRestAfter = 0
    for _ in 1..<Int(self.loops) {
      //Create all start-rest notifications
      if !isFirstLoop {
        startRestAfter = 3 + (setTime.exercise.minutes * 60 + setTime.exercise.seconds)
        isFirstLoop = true
      } else {
        startRestAfter += setTime.totalSeconds
      }
      self.notificationTimes.restTimes.append(self.notificationTimes.startTime.addingTimeInterval(Double(startRestAfter)))
      //Create all end-rest notifications
      let startEndRestAfter = startRestAfter + setTime.rest.minutes * 60 + setTime.rest.seconds - 4
      self.notificationTimes.endOfRestTimes.append(self.notificationTimes.startTime.addingTimeInterval(Double(startEndRestAfter)))
    }
    self.notificationTimes.createNotifications()
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}

extension TimerNotifications {
  
}
