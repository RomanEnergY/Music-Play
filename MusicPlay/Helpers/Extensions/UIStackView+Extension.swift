//
//  UIStackView+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 31.03.2024.
//

import UIKit

extension UIStackView {
    /// Скрыть view если все arrangedSubviews скрыты
    func performHiddenForAllArrangedSubviewsHidden() {
        isHidden = !(arrangedSubviews.contains(where: { !$0.isHidden }))
    }
    
    /// Скрыть все arrangedSubviews
    func contentAllHidden() {
        arrangedSubviews.forEach { $0.isHidden = true }
    }
    
    /// Выполнить для всех arrangedSubviews метод removeFromSuperview
    func removeAllArrangedSubview() {
        let arrangedSubviews: [UIView] = arrangedSubviews
        arrangedSubviews.reversed().forEach { view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    /// Для передаваемого массива views выполнить метод  addArrangedSubview
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { view in
            addArrangedSubview(view)
        }
    }
}
