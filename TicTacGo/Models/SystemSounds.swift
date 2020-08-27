//
//  SystemSounds.swift
//  TicTacGo
//
//  Created by Roger Navarro on 8/25/20.
//  Copyright © 2020 Roger Navarro. All rights reserved.
//

import Foundation
import AudioToolbox

enum SoundName: String {
  case start = "start.caf"
  case rest = "rest.caf"
  case end = "end.caf"
}
                    
class SystemSounds {
  //MARK: - Properties
  
  static var soundsData: [SoundName: SystemSoundID] = {
    let startSoundID: SystemSoundID = 0
    let middleSoundID: SystemSoundID = 0
    let endSoundID: SystemSoundID = 0
    return [.start: startSoundID, .rest: middleSoundID, .end: endSoundID]
  }()
  
//  MARK: - Sound Functions
  static func loadSoundEffects() {
    for soundID in soundsData {
      if let path = Bundle.main.path(forResource: soundID.key.rawValue, ofType: nil) {
        let fileURL = URL(fileURLWithPath: path, isDirectory: false)
        let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundsData[soundID.key]!)
        if error != kAudioServicesNoError {
          print("Error code \(error) loading sound: \(path)")
        }
      }
    }
  }
  
  static func unloadAllSoundEffects() {
    for sound in soundsData {
      AudioServicesDisposeSystemSoundID(sound.value)
    }
  }
  
  static func playSoundEffect(soundName: SoundName, completion: (()->())? = nil) {
    if let soundID = soundsData[soundName] {
      if let completionBlock = completion {
        AudioServicesPlaySystemSoundWithCompletion(soundID) {
          completionBlock()
        }
      } else {
        AudioServicesPlaySystemSound(soundID)
      }
    }
  }
}
