//
//  MenuViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func goToGameScene(_ sender: Any) {
        
        let  gameViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "gameViewController") as!
            GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        
        self.present(gameViewController, animated: true, completion: nil)
        
    }
}
