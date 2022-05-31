//
//  MenuViewController.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/27/21.
//

import UIKit
import AVFoundation


class MenuViewController: UIViewController {

    @IBOutlet weak var imageCollectionPicker: UICollectionView!
    
    @IBOutlet weak var imagePicker: UIPickerView!
    @IBOutlet weak var easyLevelButton: UIButton!
    @IBOutlet weak var hardLevelButton: UIButton!
    @IBOutlet weak var extremeLevelButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    @IBOutlet weak var chooseCharacterCollection: UICollectionView!
    
    lazy var backgroundMusic: AVAudioPlayer? = {
        
        guard let url = Bundle.main.url(forResource: "piano", withExtension: "wav") else{
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
    
    let gameCharacters = [GameCharacter(name: "Caterpillar")
                          ,GameCharacter(name: "Muscle")
                          ,GameCharacter(name: "Plant")
                          ,GameCharacter(name: "Bubbles")
                          ,GameCharacter(name: "Blues")
                          ,GameCharacter(name: "Lorenzo")
                          ,GameCharacter(name: "Mint")
                          ,GameCharacter(name: "Tongues")
                     
    ]
    var chosenGameCharacterName = "Caterpillar"
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionPicker.delegate = self
        imageCollectionPicker.dataSource = self
        MusicPlayer.shared.setSounds(state: true)
        configureSoundButton()
        print("inside view did laod menu controller")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        runBackgroundMusic()
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
        chooseCharacterCollection.alpha = 0
        speakerButton.alpha = 0
    }
    
    func animateMenuAppareance(){
   
        UIView.animate(withDuration: 1.1, animations: {
            
            self.easyLevelButton.alpha = 1
            self.hardLevelButton.alpha = 1
            self.extremeLevelButton.alpha = 1
            self.chooseCharacterCollection.alpha = 1
            self.speakerButton.alpha = 1
        })
    }
    
    // TODO: Make the disappearance work before leaving current view controller
    func animateMenuDisappearance(){
        
        easyLevelButton.alpha = 1
        hardLevelButton.alpha = 1
        extremeLevelButton.alpha = 1
        speakerButton.alpha = 1
    
        DispatchQueue.main.async {
          
        UIView.animate(withDuration: 4, animations: {
            
            self.easyLevelButton.alpha = 0
            self.hardLevelButton.alpha = 0
            self.extremeLevelButton.alpha = 0
            self.speakerButton.alpha = 0
            
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
        stopBackgroundMusic()
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
        stopBackgroundMusic()
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
        stopBackgroundMusic()
        self.present(gameViewController, animated: true, completion: nil)
    }
    
    private func runBackgroundMusic(){
        
        if MusicPlayer.shared.getSound(){
            
            backgroundMusic?.play()
        }
    }
    
    private func stopBackgroundMusic(){
        if MusicPlayer.shared.getSound(){
            backgroundMusic?.currentTime = 0
            backgroundMusic?.stop()
        }
    }
    
    private func configureSoundButton(){
        
        if #available(iOS 15, *) {
            speakerButton.setTitle("", for: .normal)
            speakerButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        }else{
            speakerButton.setTitle("Sound", for: .normal)
            
        }
    }
    
    @IBAction func changeMusicState(_ sender: Any) {
        
        if MusicPlayer.shared.getSound(){
            
            stopBackgroundMusic()
            MusicPlayer.shared.setSounds(state: false)
            speakerButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        }else{
            
            backgroundMusic?.prepareToPlay()
            backgroundMusic?.play()
            MusicPlayer.shared.setSounds(state: true)
            speakerButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        }
    }
    
}

extension  MenuViewController:  UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImagePickerCollectionViewCell
        cell?.image.image = UIImage(named: gameCharacters[indexPath.row].getName() + "_Idle_000")?.withHorizontallyFlippedOrientation()
        cell?.image.contentMode = .scaleAspectFit
      
        cell?.characterName.text = gameCharacters[indexPath.row].getName()
        
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
