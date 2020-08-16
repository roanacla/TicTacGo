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

public class ViewModel : ObservableObject {
  //MARK: - Properties
  private var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  private var cancellable: AnyCancellable?
  private var memoryLapTime = LapTime()
  private var memoryLoops: Double = 1
  private var soundsData: [String: SystemSoundID]
  
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
  
  //MARK: - Functions
  
  func startTimer(completion: (()->())?) {
    let allowToStart = (lapTime.exerciseMinutes+lapTime.exerciseSeconds+lapTime.restMinutes+lapTime.restSeconds) > 0 ? true : false
    var counter = 0
    if allowToStart {
      memoryLapTime = lapTime
      memoryLoops = loops
      self.loadSoundEffects()
      self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      self.playSoundEffect(soundName: "start.caf")
      self.cancellable = currentTimePublisher?.sink { _ in
        counter += 1
        if counter >= 5 {
          self.countDownByOne()
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
  }
  
  func finishTimer() {
    self.playSoundEffect(soundName: "end.caf") { //First play end sound
      self.unloadAllSoundEffects() //then it unloads all the sounds. 
    }
    self.currentTimePublisher?.upstream.connect().cancel()
    self.lapTime = self.memoryLapTime
    self.loops = self.memoryLoops
  }
  
  private func countDownByOne() {
    if self.lapTime.exerciseSeconds != 0 {
      self.lapTime.exerciseSeconds -= 1
    } else if self.lapTime.exerciseMinutes > 0 {
      self.lapTime.exerciseMinutes -= 1
      self.lapTime.exerciseSeconds = 59
    } else if self.lapTime.restSeconds != 0 && loops > 1 {
      if memoryLapTime.restSeconds == self.lapTime.restSeconds {
        self.playSoundEffect(soundName: "rest.caf")
      }
      if self.lapTime.restSeconds == 5 {
        self.playSoundEffect(soundName: "start.caf")
      }
      self.lapTime.restSeconds -= 1 //Goes after if statement
    } else if self.lapTime.restMinutes > 0 && loops > 1 {
      self.lapTime.restMinutes -= 1
      self.lapTime.restSeconds = 59
    } else {
      print("🔴 BRRRR BRRR BRRRR Finish loop")
      self.loops -= 1
      self.lapTime = memoryLapTime
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
