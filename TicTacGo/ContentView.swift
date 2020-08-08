//
//  ContentView.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State private var exerSeconds: Int = 0
  @State private var exerMinutes: Int = 0
  @State private var restSeconds: Int = 0
  @State private var restMinutes: Int = 0
  
  let timer = ViewModel()

  var body: some View {
    VStack {
      GeometryReader { geometry in
        VStack {
          Text("Exercise time:")
          HStack{
            Picker(selection: self.$exerMinutes, label: Text("")) {
              ForEach(0..<6) {
                Text("\($0) min").tag($0)
              }
            }
            .frame(maxWidth: geometry.size.width / 2)
            Picker(selection: self.$exerSeconds, label: Text("")) {
              ForEach(0..<60) {
                Text("\($0) sec").tag($0)
              }
            }
            .frame(maxWidth: geometry.size.width / 2)
          }
          Text("Rest time:")
          HStack{
            Picker(selection: self.$restMinutes, label: Text("")) {
              ForEach(0..<6) {
                Text("\($0) min").tag($0)
              }
            }
            .frame(maxWidth: geometry.size.width / 2)
            Picker(selection: self.$restSeconds, label: Text("")) {
              ForEach(0..<60) {
                Text("\($0) sec").tag($0)
              }
            }
            .frame(maxWidth: geometry.size.width / 2)
          }
        }
      }
      HStack {
        Button(action: self.start,
               label: { Text("START") }
        )
        .padding()
        Button(action: self.stop,
               label: { Text("STOP")}
        )
        .padding()
      }
      .onReceive(timer.currentTimePublisher){ newCurrentTime in
        print(newCurrentTime)
      }
    }
  }
  
  func start() {
    let lapTime = LapTime(exerciseMinutes: exerMinutes, exerciseSeconds: exerSeconds, restMinutes: restMinutes, restSeconds: restSeconds)
    timer.lapTime = lapTime
    timer.startTimer()
  }
  
  func stop() {
    timer.stopTimer()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
