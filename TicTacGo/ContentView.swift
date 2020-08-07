//
//  ContentView.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/6/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State private var currentTime: Date = Date()
  let timer = ViewModel()

  var body: some View {
    VStack {
      Button(action: self.start,
             label: { Text("OK") }
      )
//      .onReceive(timer.source){ newCurrentTime in
//        print(newCurrentTime)
//      }
    }
    .onReceive(timer.currentTimePublisher){ newCurrentTime in
      print(newCurrentTime)
    }
  }
  
  func start() {
    timer.startTimer()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
