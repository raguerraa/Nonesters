//
//  GameViewController.swift
//  Etremest Sudoku
//
//  Created by Owner on 9/18/21.
//

import UIKit
import SpriteKit
//import GameplayKit

class GameViewController: UIViewController {
    
    // Declare a gameScene property so that the GameViewController has acces to it
    var currentGameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
        
                // Present the scene
                scene.sceneDidLoad()
                
                view.presentScene(scene)
                
                // Initialize the scene
                currentGameScene = scene as? GameScene
                currentGameScene?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func congratulateUser(correct: Bool){
 
        let scoreViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "scoreViewController") as! ScoreViewController
        scoreViewController.correct = correct
        
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
