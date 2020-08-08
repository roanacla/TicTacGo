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
  let currentTimePublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
  var cancellable: AnyCancellable?
  var lapTime: LapTime?
  
  func startTimer() {
    guard let lapTime = lapTime else { return }
    print(lapTime.description)
    self.cancellable = currentTimePublisher.connect() as? AnyCancellable
  }
  
  func stopTimer() {
    self.currentTimePublisher.connect().cancel()
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
