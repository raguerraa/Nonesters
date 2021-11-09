//
//  MenuViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var imageCollectionPicker: UICollectionView!
    
    @IBOutlet weak var imagePicker: UIPickerView!
    @IBOutlet weak var easyLevelButton: UIButton!
    @IBOutlet weak var hardLevelButton: UIButton!
    @IBOutlet weak var extremeLevelButton: UIButton!
    //@IBOutlet weak var chooseCharacterButton: UIButton!
    
    @IBOutlet weak var chooseCharacterCollection: UICollectionView!
    
    let gameCharacters = [GameCharacter(name: "Naruto"),
                          GameCharacter(name: "Lee"),
                          GameCharacter(name: "Neji"),
                          GameCharacter(name: "Kakashi"),
                          GameCharacter(name: "Sakura"),
                          GameCharacter(name: "Zabuza")]
    var chosenGameCharacterName = "Naruto"
     
    override func viewDidLoad() {
        super.viewDidLoad()
        //imagePicker.delegate = self
        //imagePicker.dataSource = self
        imageCollectionPicker.delegate = self
        imageCollectionPicker.dataSource = self
        
        
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
        //chooseCharacterButton.alpha = 0
        chooseCharacterCollection.alpha = 0
    }
    
    func animateMenuAppareance(){
   
        UIView.animate(withDuration: 1.1, animations: {
            
            self.easyLevelButton.alpha = 1
            self.hardLevelButton.alpha = 1
            self.extremeLevelButton.alpha = 1
            //self.chooseCharacterButton.alpha = 1
            self.chooseCharacterCollection.alpha = 1
        })
    }
    
    // TODO: make the disappearance work before leaving current view controller
    func animateMenuDisappearance(){
        
        easyLevelButton.alpha = 1
        hardLevelButton.alpha = 1
        extremeLevelButton.alpha = 1
        //chooseCharacterButton.alpha = 1
        
        
        DispatchQueue.main.async {
          
        UIView.animate(withDuration: 4, animations: {
            
            self.easyLevelButton.alpha = 0
            self.hardLevelButton.alpha = 0
            self.extremeLevelButton.alpha = 0
            //self.chooseCharacterButton.alpha = 0
        })}
    }
    
    
    @IBAction func goToGameSceneEasy(_ sender: Any) {
        let  gameViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "gameViewController") as!
            GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        gameViewController.characterName = chosenGameCharacterName
        
        let gameLevel = GameLevel()
        gameLevel.state = .Easy
        gameViewController.gameLevel = gameLevel
        self.present(gameViewController, animated: true, completion: nil)
    }
    @IBAction func goToGameSceneHard(_ sender: Any) {
        let  gameViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "gameViewController") as!
            GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        gameViewController.characterName = chosenGameCharacterName
        
        let gameLevel = GameLevel()
        gameLevel.state = .Hard
        gameViewController.gameLevel = gameLevel
        self.present(gameViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func goToGameSceneExtremest(_ sender: Any) {
        let  gameViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "gameViewController") as!
            GameViewController
        gameViewController.modalPresentationStyle = .fullScreen
        gameViewController.characterName = chosenGameCharacterName
        
        let gameLevel = GameLevel()
        gameLevel.state = .Extremest
        gameViewController.gameLevel = gameLevel
        self.present(gameViewController, animated: true, completion: nil)
    }
}

extension  MenuViewController:  UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImagePickerCollectionViewCell
        cell?.image.image = UIImage(named: gameCharacters[indexPath.row].getName() + "_Idle_000")
        cell?.characterName.text = gameCharacters[indexPath.row].getName()
        // TODO: ifix the force unwrap
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chosenGameCharacterName = gameCharacters[indexPath.row].getName()
        print(chosenGameCharacterName)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in imageCollectionPicker.visibleCells {
            let indexPath = imageCollectionPicker.indexPath(for: cell)
                if let indexPath = indexPath{
                    chosenGameCharacterName = gameCharacters[indexPath.row].getName()
                }else{
                    chosenGameCharacterName = "Naruto"
                }
            }
    }
    
}

extension MenuViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size  = imageCollectionPicker.frame.size
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
}
//extension MenuViewController: {
    
//}

/*UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }

    // MARK: UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {


        var myImageView = UIImageView()

        switch row {
        case 0:
            myImageView = UIImageView(image: UIImage(named:"Lee_Idle_000"))
        case 1:
            myImageView = UIImageView(image: UIImage(named:"Lee_Idle_001"))
        case 2:
            myImageView = UIImageView(image: UIImage(named:"Lee_Idle_002"))
      

        default:
            myImageView.image = nil
            print("item dsjdjsdj")

            return myImageView
        }
        return myImageView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        // do something with selected row
    }
}*/
