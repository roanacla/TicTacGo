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
  private var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  private var cancellable: AnyCancellable?
  private var memoryLapTime = LapTime()
  private var memoryLoops: Double = 1
  
  @Published var lapTime = LapTime()
  @Published var loops: Double = 1
  
  func startTimer(completion: (()->())?) {
    let allowToStart = (lapTime.exerciseMinutes+lapTime.exerciseSeconds+lapTime.restMinutes+lapTime.restSeconds) > 0 ? true : false
    memoryLapTime = lapTime
    memoryLoops = loops
    if allowToStart {
      loadSoundEffect("out.caf")
      self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      self.cancellable = currentTimePublisher?.sink { _ in
        self.countDownByOne()
        if self.loops == 0 {
          self.stopTimer()
          completion?()
        }
      }
    }
  }
  
  func stopTimer() {
    self.currentTimePublisher?.upstream.connect().cancel()
    self.cancelTimer()
  }
  
  private func cancelTimer() {
    self.lapTime = self.memoryLapTime
    self.loops = self.memoryLoops
  }
  
  func countDownByOne() {
    if self.lapTime.exerciseSeconds != 0 {
      self.lapTime.exerciseSeconds -= 1
    } else if self.lapTime.exerciseMinutes > 0 {
      self.lapTime.exerciseMinutes -= 1
      self.lapTime.exerciseSeconds = 59
    } else if self.lapTime.restSeconds != 0 {
      if self.lapTime.restSeconds == 10 {
        playSoundEffect()
      }
      self.lapTime.restSeconds -= 1
    } else if self.lapTime.restMinutes > 0 {
      self.lapTime.restMinutes -= 1
      self.lapTime.restSeconds = 59
    } else {
      print("🔴 BRRRR BRRR BRRRR Finish loop")
      self.loops -= 1
      self.lapTime = memoryLapTime
    }
  }
  
  var soundID: SystemSoundID = 0
  
  func loadSoundEffect(_ name: String) {
    if let path = Bundle.main.path(forResource: name, ofType: nil) {
      let fileURL = URL(fileURLWithPath: path, isDirectory: false)
      let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
      if error != kAudioServicesNoError {
        print("Error code \(error) loading sound: \(path)")
      }
    }
  }
  
  func unloadSoundEffect() {
    AudioServicesDisposeSystemSoundID(soundID)
    soundID = 0
  }
  
  func playSoundEffect() {
    AudioServicesPlaySystemSound(soundID)
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
