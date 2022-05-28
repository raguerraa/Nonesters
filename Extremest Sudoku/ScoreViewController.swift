//
//  ScoreViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit

class ScoreViewController: UIViewController {
    var correct: Bool = false
    var time: String?
    var level: String?
    
    @IBOutlet weak var message: UITextField!
    
    @IBOutlet weak var completionTime: UITextField!
    
    @IBOutlet weak var levelName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if correct {
            message.text = "Good Job"
        }else{
            message.text = "Try Again"
        }
        
        if let time = time {
            completionTime.text = " " + time
        }
        
        if let level = level {
            levelName.text = level
        }

        // Do any additional setup after loading the view.
    }
    @IBAction func goBackToMenu(_ sender: Any) {
        // Dismiss two time to go back to the menu view controller
        presentingViewController?.dismiss(animated: false, completion: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
