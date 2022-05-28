//
//  Sudoku.swift
//  Extremest Sudoku
//
//  Created by ronald Guerra on 5/24/22.
//
//  A valid sudoku puzzle must have one and only one solution. This class guarantees the
//  creation of such Sudoku puzzle by:
//
//  * First solving the empty Sudoku puzzle and grabbing only two solutions. Of course, an empty
//    Sudoku puzzle have many solutions, this is why we only grab two of them.
//  * From the two solutions, we only use the first solution to construct the true puzzle
//    by continuously removing one element from the solution and checking that the new puzzle
//    does not have two solutions. If at some point, the puzzle have two solutions then we backtrack
//    one step and return the puzzle. That is the Sudoku puzzle with one and only one solution.
//
//  TODO: Create a size property, so we support general size Sudokus and not only 9X9
//  TODO: Use implications to solve the Sudoku in the Sudoku solver for optimization
//  TODO: Create a Queue of generated Sudokus and store them, so that we can build Sudoku puzzles
//        by shuffling, or implement a server and database, so that Sudoku puzzles are not created
//        on the fly in the user's phone.

import Foundation

class Sudoku{
    
    private var solutions = [[[String]]]()
        
    // Valid Sudoku puzzles.
    private var seedOne = "827154396965327148341689752593468271472513689618972435786235914154796823239841567"
    private var seedTwo = "000000000060300040041600702503000201070510600010902430006035014150790820230800067"
    
    // Since in sudoku the symbols used can be anything, colors abstracts the idea of symbols
    // and the black color reresents like in physics the absense of light.
    private var COLORSYMBOLS = [Color(name: "1", color: .systemPink)
                                , Color(name: "2", color: .red)
                                , Color(name: "3", color: .green)
                                , Color(name: "4", color: .magenta)
                                , Color(name: "5", color: .systemIndigo)
                                , Color(name: "6", color: .lightGray)
                                , Color(name: "7", color: .blue)
                                , Color(name: "8", color: .orange)
                                , Color(name: "9", color: .systemPink)]
    
    private let BLACKCOLORSYMBOL = Color(name: "0", color: .black)
    
    private func stringSudokuToDoubleArraySudoku(size :Int, sudoku: String) ->[[String]]{
        
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
    
    private func doubleArraySudokuToStringSudoku(size :Int, sudoku: [[String]]) -> String{
        var stringSudoku = String()
        for y in 0..<size{
            for x in 0..<size{
                stringSudoku = stringSudoku + sudoku[y][x]
            }
        }
        return stringSudoku
    }
    
    // This generates Sudoku puzzles from shuffling a perfectly valid Sudoku puzzle.
    func generateSudokuByShuffling(size: Int, sudoku :String)->String{
        
        // TODO: Check that width and height are integers.
        var shuffledSudoku = String()
        
        // TODO: Shuffle the numbers or colors.
        
        // shuffle rows
        var doubleArraySudoku = stringSudokuToDoubleArraySudoku(size: size, sudoku: sudoku)
        
        // TODO: Check that size is an integer from the perfect squares set.
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
        
        // TODO: shuffle stacks
        
        shuffledSudoku = doubleArraySudokuToStringSudoku(size: size, sudoku: doubleArraySudoku)
        return shuffledSudoku
    }
    
    // This generates a Sudoku puzzle and its solution by backtracking.
    func generate9By9SudokuByBacktracking()->(puzzle: [[String]], solution:[[String]]){
        
        // Start with an almost empty sudoku. I call it The Sudoku puzzle seed.
        // Populate the empty sudoku with 17( for 9X9 sudoku) colors as long as they dont break the
        // rules of sudoku.
        
        let sSudokuPuzzle = "000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
        while(solutions.isEmpty){ // while sudoku has no solutions then keep iterating
            
            // TODO: populate 17 clues.
            // I will probaly have to do backtracking here.
            
            // If the 17 colors sudoku has no solution it has to be repopulated again until it finds
            // one puzzle with 17 colors that have at least one solution.
            
            // Make the solver solve the sudoku puzzle. We don't care how many solutions it can have
            // the current puzzle, it is very very likely that it will have more than one
            let sudoku = stringSudokuToDoubleArraySudoku(size: 9, sudoku: sSudokuPuzzle)
            sudokuSolver(sudokuPuzzle: sudoku)
        }
        // TODO: There is a loop hole in all alogrithms like this or similar that build up a sudoku
        // puzzle like this. Although the chances are very low, it can happen that you keep randomly
        // choosing a puzzle that has no solution. It will iterate forever. Maybe if population of
        // 17 clues works backtracking eliminates this posibility. This posibility is extremely low
        // to the point, I won't live to see it happen.
        
        // Grab randomly one of the solution to the sudoku puzzle, then one by one remove colors
        // until it have more than two solutions. Then that the means that the previous sudoku
        // puzzle had only one solution, return that puzzle
        
        let solution = solutions[0]
        
        // Now, we will build the Sudoku puzzle from the solution and store it here.
        var puzzle = solutions[0]

        var x = -1
        var y = -1
        var move = BLACKCOLORSYMBOL.name
        solutions = []
        
        while(solutions.count < 2){
            
            solutions = []
            (y, x) = findNoneEmptyCell(sudokuPuzzle: puzzle)
            
            // The case that are all empty
            if (y == -1) && (x == -1){
                
                preconditionFailure("Error: Couldn't Make puzzle. Check Sudoku generator.")
            }
            
            move = puzzle[y][x]
            puzzle[y][x] = BLACKCOLORSYMBOL.name
            
            // Check that the new puzzle will not have more than two solutions.
            sudokuSolver(sudokuPuzzle: puzzle)
        }
        
        // Undo the move that generated two solutions.
        puzzle[y][x] = move
    
        return (puzzle, solution)
    }
    
    // This randomly finds a none empty spot in the Sudoku puzzle. If there is none then it returns
    // (-1,-1)
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
    
    // This finds the first empty spot reading from left to right and top to bottom in the Sudoku
    // puzzle and it return its position. If there is no empty cells then it returns (-1,-1)
    func findEmptyCell(sudokuPuzzle: [[String]])->(y :Int, x :Int){
        
        var x = -1
        var y = -1
        
        for j in 0..<sudokuPuzzle.count{
            for i in 0..<sudokuPuzzle[0].count{
                
                if sudokuPuzzle[j][i] == BLACKCOLORSYMBOL.name{
                    y = j
                    x = i
                    return (y, x)
                }
            }
        }
        
        return (-1, -1)
    }

    // This, given a Sudoku puzzle, solves the Sudoku puzzle and saves the result in solutions.
    // Note, that there may be more than one solution to the Sudoku puzzle. If it has more than two
    // solutions then it will only return two of them.
    private func sudokuSolver(sudokuPuzzle: [[String]]){

        if solutions.count >= 2{
            return
        }
        
        var x = -1
        var y = -1
        
        // Find the closest empty spot.
        (y, x) = findEmptyCell(sudokuPuzzle: sudokuPuzzle)
        
        // If there are no more empty spots then Sudoku is solved.
        // Save it.
        if (x == -1) && (y == -1){
            solutions.append(sudokuPuzzle)
            return
        }
        COLORSYMBOLS.shuffle()

        for color in COLORSYMBOLS{
            
            if isAPossibleMove(move: color.name, x: x, y: y, sudokuPuzzle: sudokuPuzzle){
                var newSudokuPuzzle = sudokuPuzzle
                newSudokuPuzzle[y][x] = color.name
                sudokuSolver(sudokuPuzzle: newSudokuPuzzle)
            }
        }
        return
    }
    
    // This determines if making a move in the (x,y) coordinate of the sudoku is possible.
    private func isAPossibleMove(move: String, x: Int, y: Int, sudokuPuzzle: [[String]])->Bool{
        
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
    
    // This determines if the Sudoku puzzle doesn't violate any rules of Sudoku. However, this does
    // not tell if the sudoku puzzle will have a solution or only one solution.
    private func isValidSudoku(sudokuPuzzle: [[String]])->Bool{
       
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

    // Prints the Sudoku.
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
}
