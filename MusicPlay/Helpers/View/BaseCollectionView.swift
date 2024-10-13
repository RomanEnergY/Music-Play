//
//  BaseCollectionView.swift
//  MusicPlay
//
//  Created by ZverikRS on 28.03.2024.
//

import UIKit

// MARK: - class

class BaseCollectionView: UICollectionView {
    
    // MARK: - public properties
    
    let flowLayout: UICollectionViewFlowLayout
    
    // MARK: - initializers
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    init(
        frame: CGRect = .zero,
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        minimumLineSpacing: CGFloat = 0,
        minimumInteritemSpacing: CGFloat = 0,
        sectionInset: UIEdgeInsets = .zero,
        sectionHeadersPinToVisibleBounds: Bool = false,
        sectionFootersPinToVisibleBounds: Bool = false
    ) {
        let layout: UICollectionViewFlowLayout = .init()
        layout.scrollDirection = scrollDirection
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.sectionInset = sectionInset
        layout.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds
        layout.sectionFootersPinToVisibleBounds = sectionFootersPinToVisibleBounds
        flowLayout = layout
        
        super.init(
            frame: frame,
            collectionViewLayout: layout)
        
        config()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    
    @discardableResult
    override func endEditing(_ force: Bool) -> Bool {
        visibleCells.forEach { $0.endEditing(true) }
        return true
    }
    
    // MARK: - public methods
    
    func config() {
        backgroundColor = .clear
    }
    
    func register<T: UICollectionViewCell>(_ :T.Type) {
        register(T.self, forCellWithReuseIdentifier: "\(T.classForCoder())" )
    }
}
