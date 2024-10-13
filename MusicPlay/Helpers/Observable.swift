//
//  Observable.swift
//  MusicPlay
//
//  Created by ZverikRS on 28.03.2024.
//

import Foundation

// MARK: - class

final class Observable<T: Equatable> {
    
    // MARK: - public properties
    
    var value: T {
        didSet {
            if value != oldValue {
                listener?(value)
            }
        }
    }
    
    // MARK: - private properties
    
    private var listener: ((T) -> Void)?
    
    // MARK: - initializers
    
    init(_ value: T) {
        self.value = value
    }
    
    // MARK: - public methods
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}
