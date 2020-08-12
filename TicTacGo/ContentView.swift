//
//  ContentView.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import SwiftUI

struct TimePicker: View {
  @Binding var timeUnits: Int
  var unitsRange: Range<Int>
  var unitsRangeLabel: String
  
  var body: some View {
    Picker(selection: self.$timeUnits, label: Text("")) {
      ForEach(unitsRange) {
        Text("\($0) " + self.unitsRangeLabel)
      }
    }
  }
}

struct ContentView: View {
  @ObservedObject var timer = ViewModel()
  @State var isStartButtonDisabled = false
  @State var isTimerRunning = false

  var body: some View {
    VStack {
      Text("Exercise time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          TimePicker(timeUnits: self.$timer.lapTime.exerciseMinutes,
                     unitsRange: 0..<6,
                     unitsRangeLabel: "min")
            .frame(maxWidth: geometry.size.width / 2)
          TimePicker(timeUnits: self.$timer.lapTime.exerciseSeconds,
                     unitsRange: 0..<60,
                     unitsRangeLabel: "sec")
            .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Rest time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          TimePicker(timeUnits: self.$timer.lapTime.restMinutes,
                     unitsRange: 0..<6,
                     unitsRangeLabel: "min")
            .frame(maxWidth: geometry.size.width / 2)
          TimePicker(timeUnits: self.$timer.lapTime.restSeconds,
                     unitsRange: 0..<60,
                     unitsRangeLabel: "sec")
            .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Loops: \(Int(self.timer.loops))")
        .padding()
      HStack {
        Text("1")
        Slider(value: self.$timer.loops, in: 1...10, step: 1.0)
        Text("10")
      }
      .padding(.leading)
      .padding(.trailing)
      HStack {
        Button(action: self.stop,
               label: { Text("STOP")}
        )
          .padding()
        Button(action: isTimerRunning ? self.pause : self.start,
               label: { Text(isTimerRunning ? "STOP" : "START") }
        )
          .disabled(self.isStartButtonDisabled)
          .padding()
      }
    }
  }
  
  func start() {
    isTimerRunning = true
    timer.startTimer(completion: {
      self.isStartButtonDisabled = false
      self.isTimerRunning = false
    })
    isStartButtonDisabled = true
  }
  
  func pause() {
    print("Pause!")
  }
  
  func stop() {
    timer.stopTimer()
    isStartButtonDisabled = false
    isTimerRunning = false
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
