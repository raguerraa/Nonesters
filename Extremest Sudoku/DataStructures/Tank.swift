//
//  Tank.swift
//  Extremest Sudoku
//
//  Created by ronald Guerra on 5/25/22.
//

import SpriteKit

class Tank{
    
    private var weapon = SKSpriteNode()
    
    // This thows the weapon of the tank to the game character.
    func throwWeapon(){
        
        let moveToYAction = SKAction.moveTo(x: -weapon.position.x - weapon.size.width, duration:1.2)
        
        let reachedDestinationAction = SKAction.removeFromParent()
        if MusicPlayer.shared.getSound(){
        let sound = SKAction.playSoundFileNamed(SoundFileName.Shot.rawValue
                                                , waitForCompletion: false)
            weapon.run(sound)
        }
        weapon.run(SKAction.sequence([moveToYAction, reachedDestinationAction]))
        
        let rotate = SKAction.rotate(byAngle: 15, duration: 1)
        let repeatRotation = SKAction.repeatForever(rotate)
        weapon.run(repeatRotation)
        
    }
    
    // This creates the weapon and position it at (x,y). However, the user of this method has to
    // add it as it child to be able to see it at the screen.
    func createWeapon(x: CGFloat, y: CGFloat)-> SKSpriteNode{
        
        weapon = SKSpriteNode(imageNamed: "Shuriken")
        
        // Since we want the weapon to try to hit the game character we need to create the weapon
        // around the y-coordinate of the game character
        
        let yCoordintateToHit = y
        
        weapon.position.y = yCoordintateToHit
        // the weapon is going to be position to the right side of the screen
        weapon.position.x = x
        weapon.zPosition = 1
        
        // Let's add it physics
        weapon.physicsBody = SKPhysicsBody(circleOfRadius: weapon.size.width/2.0 - 20)
        weapon.physicsBody?.categoryBitMask = PhysicsCategory.weapon
        weapon.physicsBody?.contactTestBitMask = PhysicsCategory.gameCharacter
        weapon.physicsBody?.affectedByGravity = false
        weapon.physicsBody?.isDynamic = true

        return weapon
    }
}
