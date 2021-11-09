//
//  Queue.swift
//  Extremest Sudoku
//
//  Created by Owner on 11/3/21.
//

import Collections

struct Queue <Element>{
    private var deque = Deque<Element>()

    mutating func push(_ element: Element) {
        deque.append(element)
    }

    mutating func dequeue() -> Element? {
        return deque.popFirst()
    }

    func peek() -> Element? {
        guard let first = deque.first else { return nil }
        return first
    }
    
    var isEmpty: Bool {
        return deque.isEmpty
    }
    var count: Int {
        return deque.count
    }
    
}
