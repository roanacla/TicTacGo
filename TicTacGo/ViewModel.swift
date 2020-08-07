//
//  ViewModel.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation
import Combine

public class ViewModel {
  let currentTimePublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)
  var cancellable: AnyCancellable?
  var source = PassthroughSubject<Int, Never>()
  
  func startTimer() {
    self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    source.send(1)
    source.send(2)
    source.send(3)
  }
  
  deinit {
      self.cancellable?.cancel()
  }
}
