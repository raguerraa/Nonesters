//
//  Stack.swift
//  Extremest Sudoku
//
//  Created by Owner on 10/25/21.
//
import Collections

struct Stack <Element>{
    private var deque = Deque<Element>()

    mutating func push(_ element: Element) {
        deque.append(element)
    }

    mutating func pop() -> Element? {
        return deque.popLast()
    }

    func peek() -> Element? {
        guard let top = deque.last else { return nil }
        return top
    }
    
    var isEmpty: Bool {
        return deque.isEmpty
    }
    var count: Int {
        return deque.count
    }
    
}
