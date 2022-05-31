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

struct PhysicsCategory {
    
    static let weapon: UInt32 = 1
    static let gameCharacter: UInt32 = 2
}


class GameScene: SKScene {
    
    // How much damage does receives the game character for each hit.
    private let DAMAGEPOINTS = 100
    
    var gameCharacterName:String?
    var gameLevel = GameLevel()
    
    // Default game character is Nartuo if no gameCharacterName is provided
    private var gameCharacter = GameCharacter(name: "Caterpillar")
    
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
    private let COLORSYMBOLS = [Color(name: "1", color: .systemPink), Color(name: "2", color: .red)
                                , Color(name: "3", color: .green), Color(name: "4", color: .magenta)
                                , Color(name: "5", color: .systemIndigo), Color(name: "6", color: .lightGray)
                                , Color(name: "7", color: .blue), Color(name: "8", color: .orange)
                                , Color(name: "9", color: .systemPink)]
    
 
    private let BLACKCOLORSYMBOL = Color(name: "0", color: .black)
    private let EMPTYCELLCONTENT = ""
    private let BORDERWIDTH: CGFloat = 1.0
    private let YLEVELGAMEPOSITION: CGFloat = -245
    
    // Flag that tells if the user is jumping.
    private var isJumping = false
    
    // Flag that tells if it is the first undo or not.
    private var isUserFirstUndo = true
    
    // Flag that tells if the user is playing
    private var hasGameSarted = false
    
    // The stack of all the moves the user have made. This is used when undoing.
    private var userMoves = Stack<(SKButton, String)>()
    private var cellsWithSameColor = [(SKButton, UIColor)]()
    
    private var theSolution = [[String]]()
    private var theSudokuPuzzle = [[String]]()
    
    private let separation:CGFloat = 1
    private let darkBoardColor: UIColor = UIColor(red: 0.0/255, green: 94.0/255, blue: 255.0/255, alpha: 1)
    private let softBoardColor: UIColor = UIColor(red: 0.0/255, green: 215.0/255, blue: 230.0/255, alpha: 1)
 
    
    // The button where the time will be displayed.
    private var timerButton = SKButton()
    private var timer = Timer()
    
    // The time limit the user has to complete the sudoku in seconds.
    private var countDown = 0
    // CountUp have to be 4 for the game to start.
    private var countUp =  1
    
    private var hasGeneratedSudoku = false
    
    private var message = SKLabelNode()
    
    // The attack times that tells when the tank will make its attacks.
    private var attacks = Stack<Int>()
    
    
    override func sceneDidLoad(){
        print("scene did load")
 
    }

    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        // Configure the game board.
        if let emiter = SKEmitterNode(fileNamed: "SnowBackground"){
            addChild(emiter)
        }
        configureTopBarButtons()
        configureGameBoard()
        configureNumberPad()
        // Let the top left corner cell be selected.
        boardCells[0][0].state = .Highlighted
        selectedCell = boardCells[0][0]
 
        
        // Configure Game Character.
        if let gameCharacterName = gameCharacterName {
            gameCharacter.changeName(name: gameCharacterName)
        }
        let gameCharacterSprite = gameCharacter.configureCharacter(x: size.width/2.0 + 30, y: YLEVELGAMEPOSITION)
        addChild(gameCharacterSprite)
        gameCharacter.animateGameCharacterIdle()
        
        // Configure the time the player will have and the attack times.
        countDown = gameLevel.getTimeInSeconds()
        attacks = loadAttackTimes(totalTimeInSeconds: countDown)
  
    }
    
    // When everthing is configured, this method is called and initiates the game.
    func initiateGame(){
        startTimerUp()
        DispatchQueue.global().async {
            let sudoku = Sudoku()
            (self.theSudokuPuzzle, self.theSolution) = sudoku.generate9By9SudokuByBacktracking()
            DispatchQueue.main.async { [weak self] in
                
                self?.hasGeneratedSudoku = true
            }
        }
    }

    // This sets up the timer while the user waits for the Sudoku puzzzle to be generated.
    private func startTimerUp(){
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerCounterUp),
                                     userInfo: nil,
                                     repeats: true)
        timer.tolerance = 0.2
    }
    
    // This controls the time before the Sudoku is generated and gives the green light if a Sudoku
    // puzzle exists so that user can start playing.
    @objc func timerCounterUp(){
        
        if hasGeneratedSudoku && countUp > 4{
            
            // The game has started.
            
            hasGameSarted = true
            timer.invalidate()
            message.isHidden = true
            message.zPosition = -1
            
            loadSudokuIntoTheGrid(sudoku: theSudokuPuzzle)
            
            startTimerDown()
            animateBackground()
            gameCharacter.animateGameCharacterRunning()
            return
        }
        var timeToDisplay = "Go!"
        if countUp <= 3 {
            timeToDisplay = String(countUp%60)
        }

        message.text = timeToDisplay
        countUp = countUp + 1
    }
    
    // Set up the timer down.
    func startTimerDown(){
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerCounterDown),
                                     userInfo: nil,
                                     repeats: true)
        timer.tolerance = 0.2
    }
    
    // This gives the user the time limit to solve the puzzle and also controls the attacks of the
    // tank
    @objc func timerCounterDown(){
        
        countDown = countDown - 1
        if countDown < 0 {
            timer.invalidate()
            return
        }
        
        let attackTime = attacks.peek()
        
        if let attackTime = attackTime {
            // If it is time to attack then attack
            if attackTime == countDown {
                _ =  attacks.pop()
                let tank = Tank()
                let weapon = tank.createWeapon(x: size.width/2.0, y: YLEVELGAMEPOSITION - 45)
                addChild(weapon)
                tank.throwWeapon()
            }
        }

        let timeToDisplay = secondsToHoursMinutesSeconds(seconds: countDown)
        timerButton.changeLabel(text: timeToDisplay)
    }
    
    // This stops the timer.
    func stopTime(){
        if timer.isValid {
            timer.invalidate()
        }
    }
    
    // Converts the time given in seconds to a hour, minutes and seconds format for display.
    func secondsToHoursMinutesSeconds(seconds: Int) -> String{
        
        let _ = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        let timeText = String(format: "%02d:%02d", minutes, seconds)

        return timeText
    }
    
    // This exits the game board.
    private func exitGame(button: SKButton){
        stopTime()
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    // This loads all the attack times when the game character will get attacked.
    private func loadAttackTimes(totalTimeInSeconds: Int) -> Stack<Int> {
        
        var attacks = Stack<Int>()
        let MAXNUMBEROFATTACKS = 7
        
        // If there is only one second to attack, then it's preferable not to attack
        if totalTimeInSeconds < 2{
            return attacks
        }
        
        // Let's determine how many attacks there might be. This isn't the actual number of attack
        // times since there might be duplicates when randomly choosing time attacks.
        let numberOfAttacks = Int.random(in: 5..<MAXNUMBEROFATTACKS)

        var randomAttackTimes = [Int]()
        for _ in 0..<numberOfAttacks{
            
            let randomAttackTime = Int.random(in: 1..<totalTimeInSeconds)
            
            print(randomAttackTime)
            randomAttackTimes.append(randomAttackTime)
        }
        
        // Remove duplicate attack times. This array holds the actual attack times.
        var uniqueRandomAttackTimes = Array(Set(randomAttackTimes))
        
        
        uniqueRandomAttackTimes.sort()
        
        for times in uniqueRandomAttackTimes{
            attacks.push(times)
        }
        
        print(attacks)
        return attacks
    }
    
    // This loads the Sudoku puzzle into the game baord.
    private func loadSudokuIntoTheGrid(sudoku: [[String]]){
        
        for y in 0..<sudoku.count{
            for x in 0..<sudoku[0].count{
                
                if sudoku[y][x] != BLACKCOLORSYMBOL.name {
                    boardCells[y][x].changeFontColor(color: .black)
                    boardCells[y][x].changeLabel(text: sudoku[y][x] )
                    
                }
            }
        }
    }
    
    // This has an assumption about how the user would like the undo work. the user doesn't care
    // about the changes it makes to a particular cell, but only the last change. This change is
    // saved in the moves stack.
    private func undo(button: SKButton){

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
    
    private func printSk(stk: Stack<(SKButton,String)>){
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
    
    // This checks if the user solution is correct and give its score.
    private func checkSudokuCorrectness(button: SKButton){
        var correct = true
        let userSolution = getUserSolutionAttempt(board: boardCells)
        
        for y in 0..<boardCells.count{
            for x in 0..<boardCells[0].count{
                
                if userSolution[y][x] != theSolution[y][x]{
                    correct = false
                }
            }
        }
        
        let timeSeconds = gameLevel.getTimeInSeconds() - countDown
        let time = secondsToHoursMinutesSeconds(seconds: timeSeconds)
        
        viewController?.congratulateUser(correct: correct, time: time, level: gameLevel.getNameLevel())
    }
    
    // This gets the user solution from the game board.
    private func getUserSolutionAttempt(board: [[SKButton]])->[[String]]{
        
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
    
    // This changes the selected cell's number in the game board according to the button number that
    // was pressed by the user.
    private func changeNumber(button: SKButton){
        
        if !hasGameSarted {
            return
        }
        
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
    
    // Finds the first empty cell in the game board reading the Sudoku puzzle from left to right.
    private func findEmptyCell(sudokuPuzzle: [[String]])->(y :Int, x :Int){
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

    // resets the cell colors to its normal.
    private func resetColors(){
        for cell in cellsWithSameColor {
            cell.0.color = cell.1
        }
        cellsWithSameColor = []
    }
    
    // This gets called when the user pressed a key in the game board and highlights all the cells
    // in the game board with the same number.
    private func pressedCellButtonBoard(cell: SKButton){
        
        // Before changing the number of the new slected cell, reset the colors of the
        // previous cells to normal color.
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
    
    // Find all the cell that have the same color. In other words, it finds all the cells that have
    // the same number and store its actual color in the game board.
    private func findAllCellsWithColor(color: String, boardCells: [[SKButton]])->[(SKButton, UIColor)]{
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
    
    // If there is touching outside the gameboard, the game character must jump.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isJumping && !gameCharacter.isDead(){
            isJumping = true
            
            gameCharacter.performJump(completion: { self.isJumping = false})
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    /**************************************************************************
     *******************This animates the bacground and collitions*************
     **************************************************************************/
    
    // This animates the the two background mountains with different speeds
    private func animateBackground(){
 
        animateBackgroundElement(element: "mountain1_0", elementTwin: "mountain1_1", duration: 5)
        animateBackgroundElement(element: "mountain2_0", elementTwin: "mountain2_1", duration: 15)
    }
    // This stops the animation of the mountains.
    private func stopBackGroundAnimation(){
        let backgroundMountain = childNode(withName: "mountain2_0") as? SKSpriteNode
        let backgroundTwinMountain = childNode(withName: "mountain2_1") as? SKSpriteNode
        let foregroundMountain = childNode(withName: "mountain1_0") as? SKSpriteNode
        let foregroundTwinMountain = childNode(withName: "mountain1_1") as? SKSpriteNode
        backgroundMountain?.removeAllActions()
        backgroundTwinMountain?.removeAllActions()
        foregroundMountain?.removeAllActions()
        foregroundTwinMountain?.removeAllActions()
    }
    // Animates a background element that is moving from right to left.
    private func animateBackgroundElement(element: String, elementTwin: String, duration: TimeInterval){
        
        let foreground = childNode(withName: element) as? SKSpriteNode
        let foregroundTwin = childNode(withName: elementTwin) as? SKSpriteNode
        
        if let foreground = foreground{
            if let foregroundTwin = foregroundTwin{
                

                let mountainWidth = foreground.size.width
        
                let moveLeft = SKAction.moveBy(x: -mountainWidth, y: 0, duration: duration)
                let moveReset = SKAction.moveBy(x: mountainWidth, y: 0, duration: 0)
                let moveLoop = SKAction.sequence([moveLeft,moveReset])
                let moveForever = SKAction.repeatForever(moveLoop)
                
                foreground.run(moveForever)
                foregroundTwin.run(moveForever)
            }
        }
    }

    // This animates the collition of the shuriken with the game character.
    private func animateSmokeCollition(){
        
        let smoke = SKSpriteNode(imageNamed: "Smoke_000")
        smoke.position.x = gameCharacter.getPosition().x
        smoke.position.y = gameCharacter.getPosition().y - 30
        smoke.zPosition = 2
        smoke.size = CGSize(width: 150, height: 150)
        
        addChild(smoke)
        var framesSmoke = [SKTexture]()
        
        let textureAtlas = SKTextureAtlas(named: "Smoke")
        for i in 0..<textureAtlas.textureNames.count {
            let numberfile = String(format: "%02d", i)
            framesSmoke.append(textureAtlas.textureNamed("Smoke_0" + numberfile))
        }
        
        
        // Run the frames
        if MusicPlayer.shared.getSound() {
            let sound = SKAction.playSoundFileNamed(SoundFileName.Collition.rawValue
                                                    , waitForCompletion: false)
            smoke.run(sound)
        }
        
        let endAction = SKAction.removeFromParent()
        let animate = SKAction.animate(with: framesSmoke, timePerFrame: 0.05)
        smoke.run(SKAction.sequence ([ animate, endAction]))
    }
    
    /**************************************************************************
     *************This Configures the game board, number pad and buttons ******
     **************************************************************************/
    
    // This configure the game board where the sudoku puzzle will be displayed.
    private func configureGameBoard(){
        gameBoard = childNode(withName: "board") as? SKSpriteNode
        if let gameBoard  = gameBoard{
            
            gameBoard.setScale(CGFloat(1))
            gameBoard.xScale = 1
            gameBoard.yScale = 1
            
            gameBoard.size = CGSize(width: 320,height: 320)
            gameBoard.color = .white
            
            // Let's calculate the side length of each cell square.
            let numberOfCellsPerRow = 9
            let sideLength = (gameBoard.size.height - separation*10) / CGFloat(numberOfCellsPerRow)

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
                    /* TODO: Delete
                    if theSudokuPuzzle[i][j] != BLACKCOLORSYMBOL.name {
                        cell.changeLabel(text: theSudokuPuzzle[i][j])
                        cell.changeFontColor(color: .black)
                    }else{
                        cell.changeFontColor(color: .white)
                    }*/
                    cell.changeFontColor(color: .white)
                    cell.changeLabel(text: "")
                    cell.state = .Active
                    cell.zPosition = 1
   
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
            
            let messageBox = SKSpriteNode()
            messageBox.position = .zero
            messageBox.size = CGSize(width: gameBoard.size.width - 2*sideLength, height: gameBoard.size.height - 4*sideLength)
            
            // Let's add the message label
            message = SKLabelNode()
            message.fontColor = .white
            message.fontName = "PingFangHK-Semibold"
            
     
            message.text = "0"
            message.position = .zero
            message.zPosition = 2
          
            message.fontSize = 100
            message.horizontalAlignmentMode = .center
            message.verticalAlignmentMode = .center
            
            gameBoard.addChild(message)
            
            messageBox.zPosition = 1
            messageBox.isHidden = false
        }
    }
    
    // This configure the number pad.
    private func configureNumberPad(){
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
                
                
                self.addChild(numberPad)
                
                // Now, let's add all the numberic keys.
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
                    numericKey.zPosition = 1
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
                    numericKey.zPosition = 1
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
                checkButton.zPosition = 1
                
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
                undoButton.zPosition = 1
                numberPad.addChild(undoContainer)
            }
        }else{
            print("Game Board has not been configure")
        }
    }
    
    // This configures the top bar where the buttons of the quit, time, and name are.
    private func configureTopBarButtons() {
        
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
            countDown = gameLevel.getTimeInSeconds()
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
            if let gameCharacterName = gameCharacterName {
                pencilButton.changeLabel(text: gameCharacterName)
            }
            pencilButton.changeFontSize(fontSize: 15)
            pencilButton.state = .Active
            pencilContainer.addChild(pencilButton)
        }
    }
    
    
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

extension GameScene: SKPhysicsContactDelegate {
    

    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        gameCharacter.hitBy(points: DAMAGEPOINTS)
        animateSmokeCollition()
        
        if gameCharacter.isDead() {
            stopBackGroundAnimation()
            gameCharacter.animateGameCharacterHurt(completion: {
                self.gameCharacter.animateGameCharacterDying()
            })
            stopTime()
            
            // Go to Score View controller
            let timeSeconds = gameLevel.getTimeInSeconds() - countDown
            let time = secondsToHoursMinutesSeconds(seconds: timeSeconds)
            let levelName = gameLevel.getNameLevel()
            
            print(countDown)
            print(levelName)
            print(time)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {[weak self] in
                
                self?.viewController?.congratulateUser(correct: false, time: time, level: levelName)
            })
    
        }else{
            gameCharacter.animateGameCharacterHurt(completion: gameCharacter.animateGameCharacterRunning)
        }
        
        // When a collition exists delete the weapon
        if bodyA.categoryBitMask == PhysicsCategory.weapon &&
            bodyB.categoryBitMask == PhysicsCategory.gameCharacter{
            //animateCollition()
            bodyA.node?.removeFromParent()
            
        }else if  bodyB.categoryBitMask == PhysicsCategory.weapon &&
                    bodyA.categoryBitMask == PhysicsCategory.gameCharacter{
            //animateCollition()
            bodyB.node?.removeFromParent()
        }
        
    }
}
