//
//  BaseCollectionViewCell.swift
//  MusicPlay
//
//  Created by ZverikRS on 28.03.2024.
//

import UIKit

// MARK: - class

class BaseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - initializers
    
    override init(frame: CGRect) {
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
        backgroundColor = .clear
    }
    
    func addSubviews() { }
}
