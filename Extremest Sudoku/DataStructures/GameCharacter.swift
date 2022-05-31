//
//  GameCharacter.swift
//  Extremest Sudoku
//
//  Created by Owner on 11/3/21.
//

import SpriteKit

class GameCharacter {
    
    private var name: String
    private var lifePoints: Int
    private var gameCharacterSprite = SKSpriteNode()
    private var gameCharacterFrames = [SKTexture]()
 
    
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
    // This changes the name of the game character. Changing the name changes the game character.
    func changeName(name: String){
        self.name = name
    }
    
    // This configure the game character and returns it. The user of this method has add the game
    // character as its child to able to see it.
    func configureCharacter(x: CGFloat, y: CGFloat)->SKSpriteNode{
        
        gameCharacterSprite = SKSpriteNode(imageNamed: name + "_Idle_000")
        gameCharacterSprite.size = CGSize(width: 230, height: 180)
        gameCharacterSprite.position.x = -x + gameCharacterSprite.size.width/2
        gameCharacterSprite.position.y = y
        gameCharacterSprite.xScale = -1
        gameCharacterSprite.zPosition = 0
        
        
        // Add its physics
        let physicsRectangle = CGSize(width: gameCharacterSprite.size.width - 100,
                                      height: gameCharacterSprite.size.height - 100)
        gameCharacterSprite.physicsBody = SKPhysicsBody(rectangleOf: physicsRectangle)
        gameCharacterSprite.physicsBody?.affectedByGravity = false
        gameCharacterSprite.physicsBody?.categoryBitMask = PhysicsCategory.gameCharacter
        gameCharacterSprite.physicsBody?.contactTestBitMask = PhysicsCategory.weapon
        gameCharacterSprite.physicsBody?.isDynamic = false
        
        return gameCharacterSprite
    }
    
    func animateGameCharacterIdle(){
        animateLoopGameCharacter(characterName: name,
                             characterAction: "Idle",
                             timePerFrame: 0.05)
    }
    func animateGameCharacterRunning(){
        
        animateLoopGameCharacter(characterName: name,
                             characterAction: "Running",
                             timePerFrame: 0.02)
    }
        
    private func animateLoopGameCharacter(characterName: String, characterAction: String,
                              timePerFrame: TimeInterval){
        //gameCharacterSprite.removeAllActions()
        let textureAtlas = SKTextureAtlas(named: characterName + "_" + characterAction)
        
        
        for i in 0..<textureAtlas.textureNames.count {
            let numberfile = String(format: "%03d", i)
           
            gameCharacterFrames.append(
                textureAtlas.textureNamed(characterName + "_" + characterAction + "_" + numberfile))
            
        }
        
        // Run the frames
        gameCharacterSprite.run(SKAction.repeatForever(SKAction.animate(with: gameCharacterFrames,
                                                                  timePerFrame: timePerFrame)))
        gameCharacterFrames = [SKTexture]()
    }
    
    func animateGameCharacterHurt(completion: @escaping ()->Void){
        animateOnceGameCharacter(characterName: name,
                                 characterAction: "Idle",
                                 timePerFrame: 0.06,
                                 completion: completion)
    }
    func animateGameCharacterDying(){
        self.gameCharacterSprite.removeAllActions()
        animateOnceGameCharacter(characterName: "All",
                                 characterAction: "Dying",
                                 timePerFrame: 0.09,
                                 completion: {})
    }
    func animateOnceGameCharacter(characterName: String, characterAction: String,
                                 timePerFrame: TimeInterval, completion: @escaping () -> Void){
        let textureAtlas = SKTextureAtlas(named: characterName + "_" + characterAction)
        
        
        for i in 0..<textureAtlas.textureNames.count {
            let numberfile = String(format: "%02d", i)
            gameCharacterFrames.append(
                textureAtlas.textureNamed(characterName + "_" + characterAction + "_0" + numberfile))
            
        }
        
        // Run the frames
        gameCharacterSprite.run(SKAction.animate(with: gameCharacterFrames, timePerFrame: timePerFrame),
                          completion: completion)
        gameCharacterFrames = [SKTexture]()
    }
    func performJump(completion:@escaping ()-> Void){
        //gameCharacterSprite.removeAllActions()
        let height: CGFloat = 60
        let goUp = SKAction.moveBy(x: 0, y: height, duration: 0.1)
        let goDown =  SKAction.moveBy(x: 0, y: -height, duration: 0.6)
        
        if MusicPlayer.shared.getSound(){
            let sound = SKAction.playSoundFileNamed( SoundFileName.Jump.rawValue
                                                     , waitForCompletion: false)
            gameCharacterSprite.run(sound)
        }
        let jumpAction = SKAction.sequence([ goUp, goDown])
        
        gameCharacterSprite.run(jumpAction, completion: {
            completion()
        })
    }
    
    func getPosition()->CGPoint{
        return gameCharacterSprite.position
    }
    
    func getSize()->CGSize{
        return gameCharacterSprite.size
    }

    
}
