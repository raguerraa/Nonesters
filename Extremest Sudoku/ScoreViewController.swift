//
//  ScoreViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit

class ScoreViewController: UIViewController {
    var correct: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func goBackToMenu(_ sender: Any) {
        // Dismiss two time to go back to the menu view controller
        presentingViewController?.dismiss(animated: false, completion: nil)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
