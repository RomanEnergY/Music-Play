//
//  UICollectionView+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 29.03.2024.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: "\(T.classForCoder())", for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Colellection View Cell")
        }
        return cell
    }
}
