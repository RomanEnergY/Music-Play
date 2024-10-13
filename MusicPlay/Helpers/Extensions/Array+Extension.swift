//
//  Array+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 29.03.2024.
//

import Foundation

// MARK: - extension for get Element to safe index

extension Array {
    subscript(safe index: Index?) -> Element? {
        guard let index else { return nil }
        
        guard index >= startIndex,
              index < endIndex
        else {
            return nil
        }
        
        return self[index]
    }
}

// MARK: - extension for replace element to index

extension Array {
    mutating func replace(_ newElement: Element, at i: Int) {
        if self[safe: i] != nil {
            remove(at: i)
            insert(newElement, at: i)
        }
    }
}

// MARK: - extension for first type object

extension Array {
    func first<T>(type: T.Type) -> T? {
        first(where: { $0 is T }) as? T
    }
    
    func last<T>(type: T.Type) -> T? {
        last(where: { $0 is T }) as? T
    }
}

