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
  public var description: String {
    return """
    Exercise Minutes: \(exerciseMinutes)
    Exercise Seconds: \(exerciseSeconds)
    Rest Minutes: \(restMinutes)
    Rest Seconds: \(restSeconds)
    """
  }
  
  var exerciseMinutes = 0
  var exerciseSeconds = 0
  var restMinutes = 0
  var restSeconds = 0
  
  
}

public class ViewModel {
  var currentTimePublisher: Publishers.Autoconnect<Timer.TimerPublisher>?
  var cancellable: AnyCancellable?
  var lapTime: LapTime?
  
  func startTimer(lapTime: LapTime) {
    print(lapTime.description)
    self.currentTimePublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    self.cancellable = currentTimePublisher?.sink(receiveValue: {value in print(value)})
  }
  
  func stopTimer() {
    self.currentTimePublisher?.upstream.connect().cancel()
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
