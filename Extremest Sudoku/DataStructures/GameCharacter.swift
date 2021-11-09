//
//  GameCharacter.swift
//  Extremest Sudoku
//
//  Created by Owner on 11/3/21.
//

import Foundation

class GameCharacter {
    
    private var name: String
    private var lifePoints: Int

    
    init(name: String, lifePoints: Int = 200) {
        self.name = name
        self.lifePoints = lifePoints
    }
    
    func getlifePoints()->Int{
        return lifePoints
    }
    func isDead()-> Bool{
        var dead = true
        if lifePoints > 0 {
            dead = false
        }
        return dead
    }
    
    func getName()-> String{
        return name
    }

    func hitBy(points: Int){
        lifePoints = lifePoints - points
    }
    func changeName(name: String){
        self.name = name
    }
    
}
