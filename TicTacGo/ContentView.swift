//
//  ContentView.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var timer = ViewModel()
  @State var isStartButtonDisabled = false
  @State var loops: Double = 1

  var body: some View {
    VStack {
      Text("Exercise time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          Picker(selection: self.$timer.lapTime.exerciseMinutes, label: Text("")) {
            ForEach(0..<6) {
              Text("\($0) min").tag($0)
            }
          }
          .frame(maxWidth: geometry.size.width / 2)
          Picker(selection: self.$timer.lapTime.exerciseSeconds, label: Text("")) {
            ForEach(0..<60) {
              Text("\($0) sec").tag($0)
            }
          }
          .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Rest time:")
        .padding()
      GeometryReader { geometry in
        HStack{
          Picker(selection: self.$timer.lapTime.restMinutes, label: Text("")) {
            ForEach(0..<6) {
              Text("\($0) min").tag($0)
            }
          }
          .frame(maxWidth: geometry.size.width / 2)
          Picker(selection: self.$timer.lapTime.restSeconds, label: Text("")) {
            ForEach(0..<60) {
              Text("\($0) sec").tag($0)
            }
          }
          .frame(maxWidth: geometry.size.width / 2)
        }
      }
      Text("Loops: \(Int(self.loops))")
        .padding()
      HStack {
        Text("1")
        Slider(value: self.$loops, in: 1...10, step: 1.0)
        Text("10")
      }
      .padding(.leading)
      .padding(.trailing)
      HStack {
        Button(action: self.stop,
               label: { Text("STOP")}
        )
          .padding()
        Button(action: self.start,
               label: { Text("START") }
        )
          .disabled(self.isStartButtonDisabled)
          .padding()
      }
    }
  }
  
  func start() {
    timer.startTimer(completion: {
      self.isStartButtonDisabled = false
    })
    isStartButtonDisabled = true
  }
  
  func stop() {
    timer.stopTimer()
    isStartButtonDisabled = false
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
