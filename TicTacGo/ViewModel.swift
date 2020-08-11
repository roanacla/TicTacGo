//
//  ViewModel.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation
import Combine

public struct LapTime: CustomStringConvertible {
  var exerciseMinutes = 0
  var exerciseSeconds = 0
  var restMinutes = 0
  var restSeconds = 0
  
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
  var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  var cancellable: AnyCancellable?
  @Published var lapTime = LapTime()
  
  func startTimer(completion: (()->())?) {
    let allowToStart = (lapTime.exerciseMinutes+lapTime.exerciseSeconds+lapTime.restMinutes+lapTime.restSeconds) > 0 ? true : false
    if allowToStart {
      var totalTime = lapTime.exerciseMinutes*60+lapTime.exerciseSeconds+lapTime.restMinutes*60+lapTime.restSeconds
      self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      self.cancellable = currentTimePublisher?.sink { _ in
        self.countDownByOne()
        totalTime -= 1
        if totalTime == 0 {
          completion?()
          //Play sound here
        }
      }
    }
  }
  
  func stopTimer() {
    self.currentTimePublisher?.upstream.connect().cancel()
    self.lapTime.reset()
  }
  
  func countDownByOne() {
    if self.lapTime.exerciseSeconds != 0 {
      self.lapTime.exerciseSeconds -= 1
    } else if self.lapTime.exerciseMinutes > 0 {
      self.lapTime.exerciseMinutes -= 1
      self.lapTime.exerciseSeconds = 59
    } else if self.lapTime.restSeconds != 0 {
      self.lapTime.restSeconds -= 1
    } else if self.lapTime.restMinutes > 0 {
      self.lapTime.restMinutes -= 1
      self.lapTime.restSeconds = 59
    } else {
      print("🔴BRRRR BRRR BRRRR")
      print(self.lapTime.description)
      self.stopTimer()
    }
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
