//
//  GameScene.swift
//  Etremest Sudoku
//
//  Created by Owner on 9/18/21.
//

import SpriteKit
import GameplayKit


struct Move {
    let cell: SKButton
    let color: String
}

struct Color{
    let name: String
    let color: UIColor
}



// TODO. lET'S IMPlemente the theme manager: when finishing the main function of the sudoku

class GameScene: SKScene {
    
    private var gameCharacter = SKSpriteNode(imageNamed: "Lee_Running_000")
    private var gameCharacterFrames = [SKTexture]()
    
    // Declare a gameViewController property so that the GameScene has acces to it
    weak var viewController : GameViewController?
    
    private var boardCells = [[SKButton]]()
    private var gameBoard : SKSpriteNode?
    
    private var numberPad : SKSpriteNode?
    private var numberPadKeys = [SKButton]()
    private var spinnyNode : SKShapeNode?
    private var selectedCell = SKButton()
    private var checkButton = SKButton()
    
    // Since in sudoku the symbols used can be anything, colors abstracts the idea of symbols
    // and the black color reresents like in physics the absense of light
    //private let COLORS = ["1","2","3","4","5","6","7","8","9"]
    private let COLORSYMBOLS = [Color(name: "1", color: .systemPink), Color(name: "2", color: .red)
                                , Color(name: "3", color: .green), Color(name: "4", color: .magenta)
                                , Color(name: "5", color: .systemIndigo), Color(name: "6", color: .lightGray)
                                , Color(name: "7", color: .blue), Color(name: "8", color: .orange)
                                , Color(name: "9", color: .systemPink)]
    
    //private let blackColor = "0"
    private let BLACKCOLORSYMBOL = Color(name: "0", color: .black)
    private let EMPTYCELLCONTENT = ""
    private let BORDERWIDTH: CGFloat = 1.0
    
    private var isUserFirstUndo = true
    
    private var solutions = [[[String]]]()
    
    private var theSolution = [[String]]()
    private var theSudokuPuzzle = [[String]]()
    private var userMoves = Stack<(SKButton, String)>()
    private var cellsWithSameColor = [(SKButton, UIColor)]()
    
    
    private var seed = "827154396965327148341689752593468271472513689618972435786235914154796823239841567"
    private var seedno = "000000000965327148341689752503468271472013689618972435786235914154706823239840567"
    
    private let separation:CGFloat = 1
    private let darkBoardColor: UIColor = UIColor(red: 0.0/255, green: 94.0/255, blue: 255.0/255, alpha: 1)
    // TODO: MAYBE green 230 better
    private let softBoardColor: UIColor = UIColor(red: 0.0/255, green: 215.0/255, blue: 230.0/255, alpha: 1)
    private let primaryThemeColor: UIColor = UIColor(red: 0.0/255, green: 94.0/255, blue: 255.0/255, alpha: 1)
    private let secondaryThemeColor: UIColor = UIColor(red: 0.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1)
    
    private var timerButton = SKButton()
    private var timer = Timer()
    // The time user has to complete the sudoku in seconds
    var countDown = 3600
    private var isTimerCounting = false
    
    
    
    override func didMove(to view: SKView) {
        
        //(theSudokuPuzzle, theSolution) = generate9By9SudokuByBacktracking()
        theSudokuPuzzle = stringSudokuToDoubleArraySudoku(size: 9, sudoku: seedno)
        theSolution = stringSudokuToDoubleArraySudoku(size: 9, sudoku: seed)
        configureTopBarButtons()
        configureGameBoard()
        configureNumberPad()
      
        // Let the top left corner cell be selected
        boardCells[0][0].state = .Highlighted
        selectedCell = boardCells[0][0]
        
        startTimer()
        
        configureCharacter()
        animateGameCharacter()
        
        
        

    }
    func configureCharacter(){
        
        // TODO: Assign game character
        gameCharacter.position  = CGPoint(x: 0, y: -(self.size.height)/2.0 + 110)
        gameCharacter.size = CGSize(width: 150, height: 150)
        self.addChild(gameCharacter)
        
    }
    
    func animateGameCharacter(){
        
        let textureAtlas = SKTextureAtlas(named: "Lee_Running")
        for name in textureAtlas.textureNames {
            
            gameCharacterFrames.append(textureAtlas.textureNamed(name))
            
        }
        
        // Run the frames
        gameCharacter.run(SKAction.repeatForever(SKAction.animate(with: gameCharacterFrames,
                                                                  timePerFrame: 0.04)))
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerCounter),
                                     userInfo: nil,
                                     repeats: true)
        timer.tolerance = 0.2
    }
    @objc func timerCounter(){
        
        countDown = countDown - 1
        if countDown < 0 {
            timer.invalidate()
            return
        }
        let timeToDisplay = secondsToHoursMinutesSeconds(seconds: countDown)
        timerButton.changeLabel(text: timeToDisplay)
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> String{
        
        let _ = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        let timeText = String(format: "%02d:%02d", minutes, seconds)

        return timeText
    }
    
    
    func configureTopBarButtons() {
        
        let topBarFont = "PingFangHK-Semibold"
        let topBarFontSize:CGFloat = 15.0
        
        
        let sizeTopContainers = CGSize(width: 80, height: 20)
        // Configure exit button
        let exitContainer = childNode(withName: "exitContainer") as? SKSpriteNode
        if let exitContainer = exitContainer{
            exitContainer.setScale(1)
            exitContainer.size = sizeTopContainers
            let exitButton = SKButton(color: self.backgroundColor,
                                      size: CGSize( width: exitContainer.size.width -
                                            2*BORDERWIDTH, height:
                                            exitContainer.size.height - 2*BORDERWIDTH))
            
            exitButton.state = .Active
            exitButton.changeFont(fontName: topBarFont)
            exitButton.changeLabel(text: "quit")
            exitButton.changeFontSize(fontSize: topBarFontSize)
            exitButton.selectedHandler = exitGame
            exitContainer.addChild(exitButton)
        }
        
        // Configure timer label
        let timerContainer = childNode(withName: "timerContainer") as? SKSpriteNode
        if let timerContainer = timerContainer {
            timerContainer.setScale(1)
            timerContainer.size = sizeTopContainers
            timerButton = SKButton(color: .systemPink,
                                      size: CGSize( width: timerContainer.size.width -
                                            2*BORDERWIDTH, height:
                                            timerContainer.size.height - 2*BORDERWIDTH))
            
            // We need a monospace font, so that the displayed time doesn't look like moving
            timerButton.changeFont(fontName: "Courier-Bold")
            timerButton.changeLabel(text: secondsToHoursMinutesSeconds(seconds: countDown))
            timerButton.changeFontSize(fontSize: topBarFontSize)
            timerContainer.addChild(timerButton)
        }
        
        // Configure pencil
        let pencilContainer = childNode(withName: "pencilContainer") as? SKSpriteNode
        if let pencilContainer = pencilContainer {
            pencilContainer.setScale(1)
            pencilContainer.size = sizeTopContainers
            let pencilButton = SKButton(color: .systemGreen,
                                      size: CGSize( width: pencilContainer.size.width -
                                            2*BORDERWIDTH, height:
                                            pencilContainer.size.height - 2*BORDERWIDTH))
            
            pencilButton.changeFont(fontName: topBarFont)
            pencilButton.changeLabel(text: "pencil")
            pencilButton.changeFontSize(fontSize: 15)
            pencilButton.state = .Active
            pencilContainer.addChild(pencilButton)
        }
    }
    
    func exitGame(button: SKButton){
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func configureNumberPad(){
        if let gameBoard = gameBoard{
            let padWidth = gameBoard.size.width
            let padHeight = 2*(padWidth/5.0)
            
            numberPad = SKSpriteNode(color: self.backgroundColor, size: CGSize(width: padWidth,
                                                                               height: padHeight))
            
            if let numberPad = numberPad{
                
                numberPad.position = CGPoint(x: 0, y: -120)
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
                    let numericKey = SKButton(color: UIColor(red: 0, green: 0, blue: 88/255,
                                            alpha: 1), size: CGSize(width: sideLengthNumberKey,
                                            height: sideLengthNumberKey))
                    numericKey.name = "key" + String(i)
                    numericKey.position = CGPoint(x: xcoordinatekeyPosition,
                                                  y: ycoordinatekeyPosition)
                    numericKey.state = .Active
                    numericKey.changeLabel(text: String(i))
                    numericKey.selectedHandler = changeNumber
                    numberPad.addChild(numericKey)
                    numberPadKeys.append(numericKey)
                    xcoordinatekeyPosition = xcoordinatekeyPosition + xCoordinateLengthShift
                }
                ycoordinatekeyPosition = -ycoordinatekeyPosition
                xcoordinatekeyPosition = -(3*(sideLengthNumberKey/2.0) + 2*separation)
                
                // Second Half
                for i in 1...4{
                    // let's configure and position the keys
                    let numericKey = SKButton(color: UIColor(red: 0, green: 0, blue: 50/255,
                                              alpha: 1), size: CGSize(width: sideLengthNumberKey,
                                              height: sideLengthNumberKey))
                    numericKey.name = "key" + String(i + 5)
                    numericKey.position = CGPoint(x: xcoordinatekeyPosition,
                                                  y: ycoordinatekeyPosition)
                    numericKey.state = .Active
                    numericKey.changeLabel(text: String(i + 5))
                    numericKey.selectedHandler = changeNumber
                    numberPad.addChild(numericKey)
                    numberPadKeys.append(numericKey)
                    xcoordinatekeyPosition = xcoordinatekeyPosition + xCoordinateLengthShift
                }
                
                xcoordinatekeyPosition = (2*sideLengthNumberKey +
                                          (sideLengthNumberKey/2.0 - separation/2.0)/2.0 +
                                            2*separation + separation/2.0)
                
                
                var buttonConfiguration = UIImage.SymbolConfiguration(weight: .bold)
                // configure Check button
                
                let checkButtonlength =  sideLengthNumberKey/2.0 - separation/2.0
                
                let containerCheckButton = SKSpriteNode(color: self.backgroundColor, size: CGSize(width:
                                           checkButtonlength,
                                           height: sideLengthNumberKey))
                
                containerCheckButton.position = CGPoint(x: xcoordinatekeyPosition, y: ycoordinatekeyPosition)
                
                var playImage = UIImage(systemName: "checkmark", withConfiguration: buttonConfiguration)
                playImage = playImage?.withRenderingMode(.alwaysOriginal)
                playImage = playImage?.withColor(.green)
                var texture = SKTexture(image: playImage!)
                checkButton = SKButton(texture: texture, color: .white, size: CGSize(width:
                                           checkButtonlength - 8*separation,
                                           height: checkButtonlength - 8*separation))
                
                containerCheckButton.addChild(checkButton)
                
                checkButton.name = "checkButton"
                checkButton.position = .zero
                checkButton.state = .Highlighted
                checkButton.colorBlendFactor = 1
                
                
                checkButton.selectedHandler = checkSudokuCorrectness
                numberPad.addChild(containerCheckButton)
                
                
                // configure undo button
                
                let undoButtonLength = sideLengthNumberKey/2.0 - separation - separation/2.0
                xcoordinatekeyPosition = -xcoordinatekeyPosition - separation/2.0
                
                let undoContainer  = SKSpriteNode(color: self.backgroundColor, size: CGSize(width: undoButtonLength,
                                    height: sideLengthNumberKey))
                
                undoContainer.position = CGPoint(x: xcoordinatekeyPosition, y: ycoordinatekeyPosition)
                
                buttonConfiguration = UIImage.SymbolConfiguration(weight: .light)
                var image = UIImage(systemName: "arrow.uturn.backward", withConfiguration: buttonConfiguration)
                image = image?.withRenderingMode(.alwaysOriginal)
                image = image?.withColor(.white)
                texture = SKTexture(image: image!)
                
                let undoButton = SKButton(texture: texture, color: .white, size: CGSize(width:
                                        undoButtonLength - 4*separation, height:undoButtonLength - 4*separation))
                
                undoContainer.addChild(undoButton)
                undoButton.colorBlendFactor = 1
                undoButton.name = "undoButton"
                undoButton.selectedHandler = undo
                undoButton.state = .Active
                numberPad.addChild(undoContainer)
            }
        }else{
            print("Game Board has not been configure")
        }
    }
    
    // This is an assamption about how the user would like the undo work. the user doesn't care
    // about the changes it makes to a particular cell, but only the last change. This change is
    // saved in the moves stack.
    func undo(button: SKButton){
        resetColors()
        if userMoves.isEmpty {
            return
        }
        
        // The user doesn't care about the last move, since it is working on it.
        if isUserFirstUndo {
            _ = userMoves.pop()
        }
        // The previous move will be retrieve.
        
        let lastMove =  userMoves.pop()
        
        printSk(stk: userMoves)
        
        if let (lastCell, number) = lastMove {
            // Make the old selected cell empty and active
            selectedCell.state = .Active
            
            // Retrive the old value to the new selected cell
            selectedCell = lastCell
            selectedCell.state = .Highlighted
            selectedCell.changeLabel(text: number)
        }
        isUserFirstUndo = false
    }
    
    func printSk(stk: Stack<(SKButton,String)>){
        var r = stk
        while !r.isEmpty {
            if r.peek()?.1 == ""{
                _ = r.pop()
                print("0", terminator: " ")
            }else{
                print(r.pop()?.1 ?? "N/A", terminator: " ")
            }
        }
        
        print("========>")
    }
    func checkSudokuCorrectness(button: SKButton){
        var correct = true
        let userSolution = getUserSolutionAttempt(board: boardCells)
        
        for y in 0..<boardCells.count{
            for x in 0..<boardCells[0].count{
                
                if userSolution[y][x] != theSolution[y][x]{
                    correct = false
                }
            }
        }
        
        viewController?.congratulateUser(correct: correct)
    
        if correct {
            /*
            let ac = UIAlertController(title: "Correct", message: "Good Job",
                                    preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            view?.window?.rootViewController?.present(ac, animated: true)*/
        }else{
            /*
            let ac = UIAlertController(title: "Incorrect", message: "Correct it Or Quit",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            view?.window?.rootViewController?.present(ac, animated: true)
            */
        }
    }
    
    func getUserSolutionAttempt(board: [[SKButton]])->[[String]]{
        
        var userSolution = [[String]]()
        for y in 0..<board.count{
            var row = [String]()
            for x in 0..<board[0].count{
                
                let cellContent = board[y][x].getLabel()
                
                if cellContent == EMPTYCELLCONTENT{
                    row.append(BLACKCOLORSYMBOL.name)
                }else{
                    row.append(board[y][x].getLabel())
                }
            }
            userSolution.append(row)
            row = []
        }
        return userSolution
    }
        
    func changeNumber(button: SKButton){
        
        let number = button.getLabel()
        if selectedCell.getFontColor() == UIColor.init(red: 1, green: 1, blue: 1, alpha: 1) {
            
            // If the selected cell has a number that is the same input number the user wants to add
            // then don't add that number to the user moves stack.
            if number != selectedCell.getLabel() {
                
                // If the cell selected is empty then add that to the move stack
                // becuase it counts as a move and the incoming number with the same cell as the
                // next move.
                if selectedCell.getLabel() == "" {
                    userMoves.push((selectedCell, selectedCell.getLabel()))
                    userMoves.push((selectedCell, number))
                }else{
                    
                    let lastMove = userMoves.peek()
                    if let (lastMoveCell, _) = lastMove {
                        // If we are changing the selected cell number with another number
                        // then only add that number with the same cell as a move.
                        if selectedCell.isEqual(lastMoveCell) {
                            
                            userMoves.push((selectedCell, number))
                            
                        }else{
                            // If the selected cell is differente than the last move cell
                            // then save the number that was in the selected cell so that it can be
                            // restored as the previous move. Then, save the new number with the
                            // same cell as a new move.
                            userMoves.push((selectedCell, selectedCell.getLabel()))
                            userMoves.push((selectedCell, number))
                        }
                    }
                }
                // Update last move and selected cell
                selectedCell.changeLabel(text: number)
                printSk(stk: userMoves)
                
                // Since the user just made one or two moves, then the next time, it makes an undo
                // it will be the first undo
                isUserFirstUndo = true
            }
        }
        
        let userSolution = getUserSolutionAttempt(board: boardCells)
    
        let (y, x) = findEmptyCell(sudokuPuzzle: userSolution)
        
        // If there is no empty cells, then make the checkButton clickable
        if (y == -1) && (x == -1){
            checkButton.state = .Active
        }
    }
    
    func configureGameBoard(){
        gameBoard = childNode(withName: "board") as? SKSpriteNode
        if let gameBoard  = gameBoard{
            
            gameBoard.setScale(CGFloat(1))
            gameBoard.xScale = 1
            gameBoard.yScale = 1
            
            gameBoard.size = CGSize(width: 320,height: 320)
            gameBoard.color = .white//UIColor(red: 0, green: 0, blue: 230/255, alpha: 1)
            // TODO: maybe blue
            // Let's calculate the side length of each cell square
            
            let numberOfCellsPerRow = 9
            var sideLength = (gameBoard.size.height - separation*10) / CGFloat(numberOfCellsPerRow)

            // let's setup and add all cells of the board
            let yTopLeftCoordinate = gameBoard.size.height/2
            let xTopLeftCoordinate = -gameBoard.size.width/2
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
                    cell.position = CGPoint(x: shiftDistanceX + sideLength/2,
                                            y: shiftDistanceY - sideLength/2)
                    cell.name = "cell" + String(cellNumber)
                    
                    if theSudokuPuzzle[i][j] != BLACKCOLORSYMBOL.name {
                        cell.changeLabel(text: theSudokuPuzzle[i][j])
                        cell.changeFontColor(color: .black)
                    }else{
                        cell.changeFontColor(color: .white)
                    }
                    cell.state = .Active
   
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
            
            // TODO create my own alert message window for the game
            let messageBox = SKSpriteNode()
            messageBox.color = .green
            messageBox.position = .zero
            messageBox.size = CGSize(width: gameBoard.size.width - 2*sideLength, height: gameBoard.size.height - 4*sideLength)
            
            // Let's add the message label
            let message = SKLabelNode()
            message.fontColor = .white
            
            
            message.lineBreakMode = .byClipping
     
            message.text = "Fill all Empty Cells"
            message.position = .zero
            message.fontName = "SFPro-Black"
            message.fontSize = 30
            message.horizontalAlignmentMode = .center
            
            gameBoard.addChild(messageBox)
            messageBox.addChild(message)
            
            messageBox.zPosition = 1
            messageBox.isHidden = true
            
        }
    }
    
    func resetColors(){
        for cell in cellsWithSameColor {
            cell.0.color = cell.1
        }
        cellsWithSameColor = []
    }
    
    func pressedCellButtonBoard(cell: SKButton){
        
 
        // Before making changing the colors of the new sleected cell, reset the colors of the
        // previous cells to normal color
        resetColors()
        
        // If the cell has a number
        if cell.getLabel() != EMPTYCELLCONTENT {
            let targetColor = cell.getLabel()
    
            // Make the cells have a new color momentarily
            cellsWithSameColor = findAllCellsWithColor(color: targetColor, boardCells: boardCells)
            for cell in cellsWithSameColor {
                var color = UIColor.black
                for colorSymbol in COLORSYMBOLS{
                    if colorSymbol.name == targetColor{
                        color  = colorSymbol.color
                    }
                }
                
                cell.0.color = color
            }
        }
        
        selectedCell.state = .Active
        cell.state = .Highlighted
        selectedCell = cell
    }
    
    func findAllCellsWithColor(color: String, boardCells: [[SKButton]])->[(SKButton, UIColor)]{
        var sameColorCells = [(SKButton, UIColor)]()
        for y in 0..<boardCells.count {
            for x in 0..<boardCells[0].count {
                if boardCells[y][x].getLabel() == color {
                    sameColorCells.append((boardCells[y][x], boardCells[y][x].color))
                }
            }
        }
        return sameColorCells
    }
    
    func stringSudokuToDoubleArraySudoku(size :Int, sudoku: String) ->[[String]]{
        
        var arraySudoku = [[String]]()
        for y in 0..<size{
            var row = [String]()
            for x in 0..<size{
                row.append(sudoku[x + y*size])
            }
            arraySudoku.append(row)
        }
        return arraySudoku
    }
    
    func doubleArraySudokuToStringSudoku(size :Int, sudoku: [[String]]) -> String{
        var stringSudoku = String()
        for y in 0..<size{
            for x in 0..<size{
                stringSudoku = stringSudoku + sudoku[y][x]
            }
        }
        return stringSudoku
    }
    
    func generateSudokuByShuffling(size: Int, sudoku :String)->String{
        
        //TODO: Check that width and height are integers
        var shuffledSudoku = String()
        // TODO: Shuffle the numbers or colors
        
        // shuffle rows
        var doubleArraySudoku = stringSudokuToDoubleArraySudoku(size: size, sudoku: sudoku)
        
        //print(doubleArraySudoku)
        // TODO: Check that size is an integer from the perfect squares set
        let blockSize = Int(Double(size).squareRoot())
        
        var bands = [[String]]()
        for y in 0..<size{
            
            bands.append(doubleArraySudoku[y])
            // Shuffle rows within each band
            if (y + 1)%blockSize == 0{
                
                var pool = blockSize
                for x in 0..<blockSize{
                    let randomIndex = Int.random(in: 0..<pool)
                    doubleArraySudoku[x+y+1-blockSize] = bands[randomIndex]
                    bands.remove(at: randomIndex)
                    pool = pool - 1
                }
                bands = [[String]]()
            }
        }
        

        // shuffle columns
        var stacks = [[String]]()
        
        for y in 0..<size{
            var stack = [String]()
            for x in 0..<size{
                stack.append(doubleArraySudoku[x][y])
            }
            stacks.append(stack)
         
            // Shuffle columns within each stack
            if (y + 1)%blockSize == 0{
                
                var pool = blockSize
                for x in 0..<blockSize{
                    let randomIndex = Int.random(in: 0..<pool)
                    
                    // Put each random column into the column
                    
                    for i in 0..<size{
                        doubleArraySudoku[i][x + y + 1 - blockSize] = stacks[randomIndex][i]
                    }
                    
                    stacks.remove(at: randomIndex)
                    pool = pool - 1
                }
                stacks = [[String]]()
            }
        }
        
        // shuffle bands
        
        bands = [[String]]()
        for i in 0..<size{
            bands.append(doubleArraySudoku[i])
        }
        
        var poolOfBands = blockSize
        var randomBandIndex:Int = 0
        for y in 0..<blockSize{
  
            // Let's put that band into one of the bands randomly chosen
            randomBandIndex = blockSize*(Int.random(in: 0..<poolOfBands))
            
            var columnCounter = blockSize*y
            
            for i in randomBandIndex..<(blockSize+randomBandIndex){
                doubleArraySudoku[columnCounter] = bands[i]
                columnCounter = columnCounter + 1
            }
            let counter = blockSize+randomBandIndex-1
            for j in 0..<blockSize{
                
                bands.remove(at: counter-j)
            }
            poolOfBands = poolOfBands - 1
        }
        
        // TODOL: shuffle stacks
        
        shuffledSudoku = doubleArraySudokuToStringSudoku(size: size, sudoku: doubleArraySudoku)
        return shuffledSudoku
    }
    
    func generate9By9SudokuByBacktracking()->(puzzle: [[String]], solution:[[String]]){
        // Star with an empty sudoku
        // Populate the empty sudoku with 17( for 9X9 sudoku) colors as long as they dont break the
        // rules of sudoku
        
        let sSudokuPuzzle = "000000000000000000000000000000000000000000000000000000000000000000020000000000000"
        
        
        while(solutions.isEmpty){ // while sudoku has no solutions then keep iterating
            
            // populate 17 clues.
            // I will probaly have to do backtracking here.
            
            // If the 17 colors sudoku has no solution it has to be repopulated again until it finds one
            // puzzle with 17 colors that have at least one solution.
            
            // Make the solver solve the sudoku puzzle. We don't care how many solutions it can have
            // the current puzzle, it is very very likely that it will have more than one
            let sudoku = stringSudokuToDoubleArraySudoku(size: 9, sudoku: sSudokuPuzzle)
            
            sudokuSolver(sudokuPuzzle: sudoku)
            
            
        }// TODO: There is a loop hole in all alogrithms like this or similar that build up a sudoku
        // puzzle like this. Although the chances are very low, it can happen that you keep randomly
        // choosing a puzzle that has no solution. It will iterate forever. Maybe if population of
        // 17 clues works backtracking liminates this posibility
        
        // Grab randomly one of the solution to the sudoku puzzle, then one by one remove colors
        // until it have more than two solutions. Then that the means that the previous sudoku
        // puzzle had only one solution, return that puzzle
        
        let solution = solutions[0]
        var puzzle = solutions[0]
        
        print(puzzle)
        
        
        var x = -1
        var y = -1
        var move = BLACKCOLORSYMBOL.name
        solutions = []
        while(solutions.count < 2){
            solutions = []
            (y, x) = findNoneEmptyCell(sudokuPuzzle: puzzle)
            
            // The case that are all empty
            if (y == -1) && (x == -1){
                
                print("Couldn't Make puzzle")
                return ([],[])
            }
            
            move = puzzle[y][x]
            puzzle[y][x] = BLACKCOLORSYMBOL.name
            
            // Check that the new puzzle will not have more than two solutions
            sudokuSolver(sudokuPuzzle: puzzle)
        }
        
        // undo the move that generated two
        puzzle[y][x] = move
    
        return (puzzle, solution)
    }
    
    // TODO: Maybe we dont need randomly but just the first one it finds
    func findNoneEmptyCell(sudokuPuzzle: [[String]])->(y: Int, x: Int){
        
        var x = -1
        var y = -1
        
        var indices = [(y: Int, x: Int)]()
        for j in 0..<sudokuPuzzle.count{
            for i in 0..<sudokuPuzzle[0].count{
                
                if sudokuPuzzle[j][i] != BLACKCOLORSYMBOL.name{
                    y = j
                    x = i
                    indices.append((y, x))
                }
            }
        }
        
        if indices.isEmpty{
            return (-1, -1)
        }
        
        let randomIndex = Int.random(in: 0..<indices.count)
        
        return indices[randomIndex]
        
    }
    
    func findEmptyCell(sudokuPuzzle: [[String]])->(y :Int, x :Int){
        var x = -1
        var y = -1
        
        var indices = [(y: Int, x: Int)]()
        for j in 0..<sudokuPuzzle.count{
            for i in 0..<sudokuPuzzle[0].count{
                
                if sudokuPuzzle[j][i] == BLACKCOLORSYMBOL.name{
                    y = j
                    x = i
                    indices.append((y, x))
                }
            }
        }
        
        if indices.isEmpty{
            return (-1, -1)
        }
        
        //let randomIndex = Int.random(in: 0..<indices.count)
        
        return indices[0]//randomIndex]
    }
    
    func sudokuSolver(sudokuPuzzle: [[String]]){
        
        // base case
        if solutions.count >= 2{
            return
        }
        
        // Find the closest cell with no color
        var x = -1
        var y = -1

        (y, x) = findEmptyCell(sudokuPuzzle: sudokuPuzzle)
        
        //print("Pair: ", y, " ",x)
        // if there is no more cells with no color cells then is solved
        if (x == -1) && (y == -1){
            /*
            print("")
            print("This is a solution: ")
            print("")

            let su = doubleArraySudokuToStringSudoku(size: 9, sudoku: sudokuPuzzle)
            printSudoku(sudoku: su)
            */
            solutions.append(sudokuPuzzle)
            
            return
        }
        
        // Make a guess
        // TODO: Implement implications. The sudoku solver should make implecations as far as it can
        // go only then should make guesses. Making a guess of the possible value should be last
        // resource. This should be done when optimizing the production of sudoku puzzles.
        
        // TODO: Change it to a random color when finishing the sudoku solver

        for i in 0..<COLORSYMBOLS.count{

            if isAPossibleMove(move: COLORSYMBOLS[i].name, x: x, y: y, sudokuPuzzle: sudokuPuzzle){
                
                // make move // TODO: Make it so that it goes through all posibilities so that it
                // generates all solutions for now is producing only one solution
                var newSudokuPuzzle = sudokuPuzzle
                newSudokuPuzzle[y][x] = COLORSYMBOLS[i].name
                sudokuSolver(sudokuPuzzle: newSudokuPuzzle)
                
                // We don't have to undo the move since the change was made to the newsudoku
            }
        }
        return
    }
    
    func isAPossibleMove(move: String, x: Int, y: Int, sudokuPuzzle: [[String]])->Bool{
        
        // Make sure that the move is an empty cell
        if sudokuPuzzle[y][x] != BLACKCOLORSYMBOL.name {
            return false
        }
        
        // Check if making the move will not break any of the rules of sudoku.
        // if it breaks one rule then return false meaning that the move is not possible.
        
        var modifiedPuzzle = sudokuPuzzle
        modifiedPuzzle[y][x] = move
        
        return isValidSudoku(sudokuPuzzle: modifiedPuzzle)
        
    }
    
    func isValidSudoku(sudokuPuzzle: [[String]])->Bool{
       
        var row = [String]()
        row = []
        var columns = [[String]]()
        for _ in 0..<sudokuPuzzle.count{
            columns.append([])
        }
        var boxes = [[String]]()
        for _ in 0..<sudokuPuzzle.count{
            boxes.append([])
        }
        
        for y in 0..<sudokuPuzzle.count{
            for x in 0..<sudokuPuzzle[0].count{
                
                if sudokuPuzzle[y][x] != BLACKCOLORSYMBOL.name{
                    // there shouldn't be two cells with the same values in a row
                    if row.contains(sudokuPuzzle[y][x]){
                        return false
                    }
                    // there shouldn't be two cells with the same values in a column
                    row.append(sudokuPuzzle[y][x])
                    if columns[x].contains(sudokuPuzzle[y][x]){
                        return false
                    }
                    columns[x].append(sudokuPuzzle[y][x])
                    
                    let boxIndex = y/3*3 + x/3
                    // there shouldn't be two cells with the same values in a block
                    if boxes[boxIndex].contains(sudokuPuzzle[y][x]){
                        return false
                    }
                    boxes[boxIndex].append(sudokuPuzzle[y][x])
                }
            }
            row = []
        }
        return true
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
extension UIImage {
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
}
