//
//  gameLevel.swift
//  Extremest Sudoku
//
//  Created by Owner on 11/2/21.
//

enum LevelState {
    case Easy, Hard, Extremest
}


class GameLevel {
    private var timeInSeconds: Int = 0
    private var name = String()
    var state: LevelState = .Easy {
        didSet {
            switch state {
            case .Easy:
                timeInSeconds = 1200
                name = "Easy"
                break
            case .Hard:
                timeInSeconds = 600
                name = "Hard"
                break
            case .Extremest:
                timeInSeconds = 60
                name = "Extremest"
            }
        }
    }
    
    func getTimeInSeconds() -> Int{
        return timeInSeconds
    }
    func getNameLevel() -> String{
        return name
    }
    
    
    
}
