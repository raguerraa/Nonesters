//
//  MusicPlayer.swift
//  Extremest Sudoku
//
//  Created by ronald Guerra on 5/25/22.
//

import Foundation
import SpriteKit

let soundSate = "musicState"

enum SoundFileName: String{
    
    case TapFile = "click.wav"
    case Shot = "gun.wav"
    case Collition = "crash.wav"
    case Jump = "jump.wav"
}

class MusicPlayer{
    
    private init(){}
    
    static let shared = MusicPlayer()
    
    func setSounds(state: Bool){
        UserDefaults.standard.setValue(state, forKey: soundSate)
        UserDefaults.standard.synchronize()
    }
    func getSound()->Bool{
        return UserDefaults.standard.bool(forKey: soundSate)
    }
    
}
