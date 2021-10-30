//
//  MenuViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit

class MenuViewController: UIViewController {

    
    @IBOutlet weak var easyLevelButton: UIButton!
    @IBOutlet weak var hardLevelButton: UIButton!
    @IBOutlet weak var extremeLevelButton: UIButton!
    @IBOutlet weak var chooseCharacterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inside view did laod menu controller")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        animateMenuAppareance()
        print("inside did apear view menu controller")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("inside will apear view menu controller")
        
        // Hide all elements that will fade in.
        easyLevelButton.alpha = 0
        hardLevelButton.alpha = 0
        extremeLevelButton.alpha = 0
        chooseCharacterButton.alpha = 0
    }
    
    func animateMenuAppareance(){
   
        UIView.animate(withDuration: 1.1, animations: {
            
            self.easyLevelButton.alpha = 1
            self.hardLevelButton.alpha = 1
            self.extremeLevelButton.alpha = 1
            self.chooseCharacterButton.alpha = 1
        })
    }
    
    // TODO: make the disappearance work before leaving current view controller
    func animateMenuDisappearance(){
        
        easyLevelButton.alpha = 1
        hardLevelButton.alpha = 1
        extremeLevelButton.alpha = 1
        chooseCharacterButton.alpha = 1
        
        
        DispatchQueue.main.async {
          
        UIView.animate(withDuration: 4, animations: {
            
            self.easyLevelButton.alpha = 0
            self.hardLevelButton.alpha = 0
            self.extremeLevelButton.alpha = 0
            self.chooseCharacterButton.alpha = 0
        })}
    }
    
    @IBAction func goToGameScene(_ sender: Any) {
        
        let  gameViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "gameViewController") as!
            GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        //animateMenuDisappearance()
        self.present(gameViewController, animated: true, completion: nil)
        
    }
}
