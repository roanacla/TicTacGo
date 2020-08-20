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

public struct LapTime: CustomStringConvertible {
  var exerciseMinutes = 0
  var exerciseSeconds = 0
  var restMinutes = 0
  var restSeconds = 0
  
  var totalSeconds: Int {
    return exerciseMinutes*60 + exerciseSeconds + restMinutes*60 + restSeconds
  }
  
  var totalExerciseMinutes: Int {
    return exerciseMinutes * 60 + exerciseSeconds
  }
  var isZero: Bool {
    return (exerciseMinutes + exerciseSeconds + restMinutes + restSeconds) == 0 ? true : false
  }
  
  mutating func reset() {
    exerciseMinutes = 0
    exerciseSeconds = 0
    restMinutes = 0
    restSeconds = 0
  }
  
  public var description: String {
    return """
    Exercise Minutes: \(exerciseMinutes)
    Exercise Seconds: \(exerciseSeconds)
    Rest Minutes: \(restMinutes)
    Rest Seconds: \(restSeconds)
    """
  }
}

struct NotificationTimes: CustomStringConvertible {
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
  
  var startTime: Date = Date()
  var endTime: Date = Date()
  var restTimes: [Date] = []
  var endOfRestTimes: [Date] = []
  
  mutating func reset() {
    startTime = Date()
    endTime = Date()
    restTimes = []
    endOfRestTimes = []
  }
}

public class ViewModel : ObservableObject {
  //MARK: - Properties
  private var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  private var cancellable: AnyCancellable?
  private var memoryLapTime = LapTime()
  private var memoryLoops: Double = 1
  private var soundsData: [String: SystemSoundID]
  var notificationTimes = NotificationTimes()
  
  @Published var lapTime = LapTime()
  @Published var loops: Double = 1
  
  //MARK: - Initializer
  init() {
    let startSoundID: SystemSoundID = 0
    let middleSoundID: SystemSoundID = 0
    let endSoundID: SystemSoundID = 0
    soundsData = ["start.caf": startSoundID,
                  "rest.caf": middleSoundID,
                  "end.caf": endSoundID]
  }
  
  //MARK: - Functions
  func startTimer(completion: (()->())?) {
    let allowToStart = (lapTime.exerciseMinutes+lapTime.exerciseSeconds+lapTime.restMinutes+lapTime.restSeconds) > 0 ? true : false
    var counter = 0
    if allowToStart {
      memoryLapTime = lapTime
      memoryLoops = loops
      self.loadSoundEffects()
      self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      self.playSoundEffect(soundName: "start.caf")
      self.calculateWhenToPlaySounds()
      print(self.notificationTimes.description)
      self.cancellable = currentTimePublisher?.sink { _ in
        counter += 1
        if counter >= 5 {
          self.countDownByOne()
          if self.lapTime.isZero || (self.loops == 1 && self.lapTime.exerciseMinutes + self.lapTime.exerciseSeconds == 0)  {
            print("🔴 BRRRR BRRR BRRRR Finish loop \(Date())")
            self.loops -= 1
            self.lapTime = self.memoryLapTime
          }
          if self.loops == 0 {
            self.finishTimer()
            completion?()
          }
        }
      }
    }
  }
  
  func stopTimer() {
    self.currentTimePublisher?.upstream.connect().cancel()
    self.unloadAllSoundEffects()
    self.lapTime = self.memoryLapTime
    self.loops = self.memoryLoops
    self.notificationTimes.reset()
  }
  
  func finishTimer() {
    print("⏰ Finished \(Date())")
    self.playSoundEffect(soundName: "end.caf") { //First play end sound
      self.unloadAllSoundEffects() //then it unloads all the sounds.
    }
    self.currentTimePublisher?.upstream.connect().cancel()
    self.lapTime = self.memoryLapTime
    self.loops = self.memoryLoops
    self.notificationTimes.reset()
  }
  
  private func countDownByOne() {
    if self.lapTime.exerciseSeconds != 0 {
      self.lapTime.exerciseSeconds -= 1
    } else if self.lapTime.exerciseMinutes > 0 {
      self.lapTime.exerciseMinutes -= 1
      self.lapTime.exerciseSeconds = 59
    } else if self.lapTime.restSeconds != 0 && loops > 1 {
      self.lapTime.restSeconds -= 1
    } else if self.lapTime.restMinutes > 0 && loops > 1 {
      self.lapTime.restMinutes -= 1
      self.lapTime.restSeconds = 59
    }
  }
  
  private func calculateWhenToPlaySounds() {
    var isFirstLoop = false
    
    //Create immediate push notification
    self.notificationTimes.startTime = Date()
    print(Date())
    
    //Create end notification
    let startEndExerciseAfter = 4 + (lapTime.totalSeconds * Int(self.loops)) - (lapTime.restMinutes * 60 + lapTime.restSeconds)
    self.notificationTimes.endTime = Date().addingTimeInterval(Double(startEndExerciseAfter))
    
    var startRestAfter = 0
    for _ in 0..<Int(self.loops) {
      //Create all start-rest notifications
      if !isFirstLoop {
        startRestAfter = 4 + (lapTime.exerciseMinutes * 60 + lapTime.exerciseSeconds)
        isFirstLoop = true
      } else {
        startRestAfter += lapTime.totalSeconds
      }
      self.notificationTimes.restTimes.append(Date().addingTimeInterval(Double(startRestAfter)))
      //Create all end-rest notifications
      let startEndRestAfter = startRestAfter + lapTime.restMinutes * 60 + lapTime.restSeconds
      self.notificationTimes.endOfRestTimes.append(Date().addingTimeInterval(Double(startEndRestAfter)))
    }
    if self.notificationTimes.endOfRestTimes.count > 0 {
      self.notificationTimes.endOfRestTimes.removeLast()
    }
  }
  
  //MARK: - Sound Functions
  private func loadSoundEffects() {
    for soundID in soundsData {
      if let path = Bundle.main.path(forResource: soundID.key, ofType: nil) {
        let fileURL = URL(fileURLWithPath: path, isDirectory: false)
        let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundsData[soundID.key]!)
        if error != kAudioServicesNoError {
          print("Error code \(error) loading sound: \(path)")
        }
      }
    }
  }
  
  private func unloadAllSoundEffects() {
    for sound in soundsData {
      AudioServicesDisposeSystemSoundID(sound.value)
    }
  }
  
  private func playSoundEffect(soundName: String, completion: (()->())? = nil) {
    if let soundID = soundsData[soundName] {
      if let completionBlock = completion {
        AudioServicesPlaySystemSoundWithCompletion(soundID) {
          completionBlock()
        }
      } else {
        AudioServicesPlaySystemSound(soundID)
      }
    }
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
