//
//  GameViewController.swift
//  Etremest Sudoku
//
//  Created by Owner on 9/18/21.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    // Declare a gameScene property so that the GameViewController has acces to it
    var currentGameScene: GameScene?
    var characterName = String()
    var gameLevel = GameLevel()
    lazy var backgroundMusic: AVAudioPlayer? = {
        
        guard let url = Bundle.main.url(forResource: "adventure", withExtension: "wav") else{
            return nil
        }
        do {
            let player =  try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
            
        }catch{
            return nil
        }
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
        
                // Present the scene
                scene.sceneDidLoad()
                // Initialize the scene
                currentGameScene = scene as? GameScene
                
                currentGameScene?.gameLevel = gameLevel
                currentGameScene?.gameCharacterName = characterName
                currentGameScene?.viewController = self
                runBackgroundMusic()
                view.presentScene(scene)
                
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentGameScene?.initiateGame()
    }
    private func runBackgroundMusic(){
        if MusicPlayer.shared.getSound(){
            
            backgroundMusic?.play()
        }
    }
    private func stopBackgroundMusic(){
        if MusicPlayer.shared.getSound(){
            backgroundMusic?.stop()
        }
    }
    
  
    
    func congratulateUser(correct: Bool, time: String, level: String){
 
        let scoreViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "scoreViewController") as! ScoreViewController
        
        scoreViewController.correct = correct
        scoreViewController.time = time
        scoreViewController.level = level
        stopBackgroundMusic()
        
        scoreViewController.modalPresentationStyle = .fullScreen
        self.present(scoreViewController, animated: true, completion: nil)
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    /*
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }*/
}
