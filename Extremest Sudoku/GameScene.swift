//
//  GameScene.swift
//  Etremest Sudoku
//
//  Created by Owner on 9/18/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var boardCells = [[SKButton]]()
    private var boardContent = [[Int]]()
    private var gameBoard : SKSpriteNode?
    
    private var numberPad : SKSpriteNode?
    private var numberPadKeys = [SKButton]()
    private var spinnyNode : SKShapeNode?
    private var selectedCell = SKButton()
    
    private var seed = "827154396965327148341689752593468271472513689618972435786235914154796823239841567"
    
    private let separation:CGFloat = 1
    private let darkBoardColor: UIColor = UIColor(red: 0.0/255, green: 94.0/255, blue: 255.0/255, alpha: 1)
    // TODO: MAYBE green 230 better
    private let softBoardColor: UIColor = UIColor(red: 0.0/255, green: 215.0/255, blue: 230.0/255, alpha: 1)
    private let primaryThemeColor: UIColor = UIColor(red: 0.0/255, green: 94.0/255, blue: 255.0/255, alpha: 1)
    private let secondaryThemeColor: UIColor = UIColor(red: 0.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1)
    
    override func didMove(to view: SKView) {
        configureGameBoard()
        configureNumberPad()
      
        
        // Let the top left corner cell be selected
        boardCells[0][0].state = .Highlighted
        selectedCell = boardCells[0][0]
        printSudoku(sudoku: seed)
        let copy = generateSolvedSudokuByShuffling(sudoku: seed)
        printSudoku(sudoku: copy)
        
        
        
 /*
        // Get label node from scene and store it for use later
        self.numberCell = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.numberCell {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
 */
    }
    
    func configureNumberPad(){
        if let gameBoard = gameBoard{
            let padWidth = gameBoard.size.width
            let padHeight = 2*(padWidth/5.0)
            
            numberPad = SKSpriteNode(color: self.backgroundColor, size: CGSize(width: padWidth, height: padHeight))
            
            if let numberPad = numberPad{
                
                numberPad.position = CGPoint(x: 0, y: -80)
                // TODO: This is adding the number pad node right the way
                // try to see if it can be added later in the code with all the number pad cells
                // This should be done when optimizing the app for speed
                numberPad.name = "numberPad"
                //numberPad.color = gameBoard.color
                
                self.addChild(numberPad)
                
                // Now, let's add all the numberic keys
                
                // calculate the square side length of each numeric key with the border
                let sideLengthNumberKey  = (padWidth - 6*separation)/5.0
                
                // First half
                
                var ycoordinatekeyPosition = separation/2.0 + sideLengthNumberKey/2.0
                var xcoordinatekeyPosition = -(4*(sideLengthNumberKey/2.0) + 2*separation)
                let xCoordinateLengthShift = sideLengthNumberKey + separation
                
                for i in 1...5{
                    // let's configure and position the keys
                    
                    let numericKey = SKButton(color: UIColor(red: 0, green: 0, blue: 88/255, alpha: 1), size: CGSize(width: sideLengthNumberKey,
                                              height: sideLengthNumberKey))
                    numericKey.name = "key" + String(i)
                    numericKey.position = CGPoint(x: xcoordinatekeyPosition, y: ycoordinatekeyPosition)
                    xcoordinatekeyPosition = xcoordinatekeyPosition + xCoordinateLengthShift
                    numericKey.state = .Active
                    
                    
                    let numberLabel = SKLabelNode()
                    numberLabel.text = String(i)
                    numberLabel.fontColor = .white
                    numberLabel.horizontalAlignmentMode = .center
                    numberLabel.verticalAlignmentMode = .center
                    numberLabel.fontSize = 30
                    //numberLabel.fontName = "SFPro-Black"
                    
                    
                    numericKey.addChild(numberLabel)
                    numberPad.addChild(numericKey)
                    numericKey.selectedHandler = changeNumber
                    numberPadKeys.append(numericKey)
                }
                ycoordinatekeyPosition = -ycoordinatekeyPosition
                xcoordinatekeyPosition = -(3*(sideLengthNumberKey/2.0) + 2*separation)
                
                // Second Half
                
                for i in 1...4{
                    // let's configure and position the keys
                    
                    let numericKey = SKButton(color: UIColor(red: 0, green: 0, blue: 50/255, alpha: 1), size: CGSize(width: sideLengthNumberKey,
                                              height: sideLengthNumberKey))
                    numericKey.name = "key" + String(i + 5)
                    numericKey.position = CGPoint(x: xcoordinatekeyPosition, y: ycoordinatekeyPosition)
                    xcoordinatekeyPosition = xcoordinatekeyPosition + xCoordinateLengthShift
                    numericKey.state = .Active
                    
                    let numberLabel = SKLabelNode()
                    numberLabel.text = String(i + 5)
                    numberLabel.fontColor = .white
                    numberLabel.horizontalAlignmentMode = .center
                    numberLabel.verticalAlignmentMode = .center
                    numberLabel.fontSize = 30
                    //numberLabel.fontName = "SFPro-Black"
                    
                    numericKey.addChild(numberLabel)
                    numberPad.addChild(numericKey)
                    numericKey.selectedHandler = changeNumber
                    numberPadKeys.append(numericKey)
                }
            }
        }else{
            print("Game Board has not been configure")
        }
    }
    
    func changeNumber(button: SKButton){
        
        if let name = button.name{
            let number = name.replacingOccurrences(of: "key", with: "")
            let child = selectedCell.children[0] as? SKLabelNode
            
            if let child = child {
                child.text = number
                 
            }
        }
    }
    
    func configureGameBoard(){
        gameBoard = childNode(withName: "board") as? SKSpriteNode
        if let gameBoard  = gameBoard{
            
            gameBoard.setScale(CGFloat(1))
            gameBoard.xScale = 1
            gameBoard.yScale = 1
            
            gameBoard.size = CGSize(width: 320,height: 320)
            gameBoard.color = .white//UIColor(red: 0, green: 0, blue: 230/255, alpha: 1) // TODO: maybe blue
            // Let's calculate the side length of each cell square
            
            let numberOfCellsPerRow = 9
            var sideLength = (gameBoard.size.height - separation*10) / CGFloat(numberOfCellsPerRow)

            // let's setup and add all cells of the board
            let yTopLeftCoordinate = gameBoard.size.height/2
            let xTopLeftCoordinate = -gameBoard.size.width/2
            print(yTopLeftCoordinate)
            print(xTopLeftCoordinate)
            var shiftDistanceY = yTopLeftCoordinate - separation
            var shiftDistanceX = separation + xTopLeftCoordinate
            var cellNumber = 0
                        
            var alternateColor = darkBoardColor
            
            for i in 0 ..< 9{
                if i == 3 || i == 6 {
                    if alternateColor.isEqual(softBoardColor){
                        alternateColor = darkBoardColor
                    }
                    else{
                        alternateColor = softBoardColor
                    }
                }
                var rowOfLabels = [SKButton]()
                for j in 0 ..< 9{
                    
                    let cell =  SKButton()
                    
                    //if let playButton = SKSpriteNode() as? SKButton {
                    //cell = playButton
                    
                    cell.size = CGSize(width: sideLength, height: sideLength)
                    
                    if j == 3 || j == 6 {
                        if alternateColor.isEqual(softBoardColor){
                            alternateColor = darkBoardColor
                        }
                        else{
                            alternateColor = softBoardColor
                        }
                    }
                    cell.color = alternateColor
                    cell.anchorPoint = CGPoint(x: 0.5 , y: 0.5)
                    cell.position = CGPoint(x: shiftDistanceX + sideLength/2, y: shiftDistanceY - sideLength/2)
                    //cell.isUserInteractionEnabled = true
                    cell.name = "cell" + String(cellNumber)
                    cell.state = .Active
                    
                    
                    let numberLabel = SKLabelNode()
                    numberLabel.text = String(Int.random(in: 1..<10))
                    numberLabel.fontColor = .white
                    numberLabel.horizontalAlignmentMode = .center
                    numberLabel.verticalAlignmentMode = .center
                    numberLabel.fontSize = 30
                    //numberLabel.fontName = "SFPro-Black"
                    //numberLabel.zPosition = 20
                    
                    //numberLabel.
                    cell.addChild(numberLabel)
                    
                    gameBoard.addChild(cell)
                    shiftDistanceX = shiftDistanceX + separation + sideLength
                    cellNumber = cellNumber + 1
                    rowOfLabels.append(cell)
                    cell.selectedHandler = pressedCellButtonBoard
                }
                
                boardCells.append(rowOfLabels)
                shiftDistanceX = separation + xTopLeftCoordinate
                shiftDistanceY = shiftDistanceY - separation - sideLength
            }
        }
    }
    
    func pressedCellButtonBoard(cell: SKButton){
        selectedCell.state = .Active
        cell.state = .Highlighted
        selectedCell = cell
    }
    
    func generateSolvedSudokuByShuffling(sudoku :String)->String{
        
        var shuffledSudoku = String()
        // TODO: Shuffle the numbers or colors
        
        // shuffle rows

        var bands = [String]()
        for y in 0..<9 {
           
            let start = sudoku.index(sudoku.startIndex, offsetBy: y*9)
            let end = sudoku.index(sudoku.startIndex, offsetBy: y*9 + 9)
            let range = start..<end
            let row = String(sudoku[range])

            bands.append(row)
            
            // Shuffle each band
            if (y + 1)%3 == 0{
              
                var randomIndex = Int.random(in: 0..<3)
                shuffledSudoku = shuffledSudoku + bands[randomIndex]
                bands.remove(at: randomIndex)
                
                randomIndex = Int.random(in: 0..<2)
                shuffledSudoku = shuffledSudoku + bands[randomIndex]
                bands.remove(at: randomIndex)
                
                shuffledSudoku = shuffledSudoku + bands[0]
                bands = []
            }
        }
        // shuffle columns
        
        // shuffle bands
        
        // shuffle stacks
        return shuffledSudoku
    }
    
    func generateSolvedSudoku()->[String]{
        
        return []
    }
    
    func hideValuesInSolvedSudoku(){
        
    }
    
    func printSudoku(sudoku: String){
        
        if(sudoku.count != 81){
            print(sudoku.count)
            print("Error: The sudoku is Incomplete")
            return
        }
        
        for y in 0..<9{
            for x in 0..<9{
                if( x%3 == 0 ){
                    print(" ",terminator: "")
                }
                print(sudoku[sudoku.index(sudoku.startIndex, offsetBy: x + y*9)], terminator: " ")
            }
            if( (y+1)%3 == 0 ){
                print()
            }
            print()
        }
        
        print("=======================>")
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /*
        let rotate = SKAction.rotate(byAngle: 1, duration: 5)
        let repeatRotation = SKAction.repeatForever(rotate)
        if let gameBoard = gameBoard{
            gameBoard.run(repeatRotation)
        }*/
        
        if let gameBoard = gameBoard{
            //gameBoard.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            //gameBoard.xScale = 0.5
            //gameBoard.yScale = 0.5
        }
        /*
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "cell0" {
                print("is being toucheddd")
                touchedNode.alpha = 0.7
            }
            print("here")
        }*/
    }
    
    
 /*
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let label = self.numberCell {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
 */
}
extension String{
    
    subscript(i: Int)->String{
        return String(self[index(startIndex, offsetBy: i)])
    }
}
