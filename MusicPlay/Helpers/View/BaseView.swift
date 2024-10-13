//
//  BaseView.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import UIKit

// MARK: - class

class BaseView: UIView {
    
    // MARK: - initializers
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        config()
        addSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public methods
    
    func config() {
    }
    
    func addSubviews() {
    }
}
