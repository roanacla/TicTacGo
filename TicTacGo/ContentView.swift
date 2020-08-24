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
  @State var isTimerRunning = false

  //MARK: View Body
  var body: some View {
    VStack {
      Text("Exercise time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          TimePicker(timeUnits: self.$timer.setTime.exercise.minutes,
                     unitsRange: 0..<6,
                     unitsRangeLabel: "min")
            .frame(maxWidth: geometry.size.width / 2)
          TimePicker(timeUnits: self.$timer.setTime.exercise.seconds,
                     unitsRange: 0..<60,
                     unitsRangeLabel: "sec")
            .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Rest time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          TimePicker(timeUnits: self.$timer.setTime.rest.minutes,
                     unitsRange: 0..<6,
                     unitsRangeLabel: "min")
            .frame(maxWidth: geometry.size.width / 2)
          TimePicker(timeUnits: self.$timer.setTime.rest.seconds,
                     unitsRange: 0..<60,
                     unitsRangeLabel: "sec")
            .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Loops: \(Int(self.timer.loops))")
        .padding()
      HStack {
        Text("1")
        Slider(value: self.$timer.loops, in: 1...60, step: 1.0)
        Text("60")
      }
      .padding(.leading)
      .padding(.trailing)
      Button(action: isTimerRunning ? self.stop : self.start,
             label: { Text(isTimerRunning ? "Cancel" : "Start") }
      )
        .disabled(self.timer.setTime.isZero)
        .padding()
    }
  }
  
  //MARK: - Functions
  func start() {
    isTimerRunning = true
    timer.startTimer(completion: {
      self.isTimerRunning = false
    })
  }
  
  func stop() {
    timer.stopTimer()
    isTimerRunning = false
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
