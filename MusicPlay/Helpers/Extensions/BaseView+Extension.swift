//
//  BaseView+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 31.03.2024.
//

import UIKit

// MARK: - extension for safeArea

extension BaseView {
    enum SafeAreaType {
        case left
        case right
        case top
        case bottom
        case width
        case height
        
        var insets: CGFloat {
            switch self {
            case .left:
                return UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0
            case .right:
                return UIApplication.shared.windows.first?.safeAreaInsets.right ?? 0
            case .top:
                return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            case .bottom:
                return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            case .width:
                guard let rootView = UIApplication.shared.windows.first else { return 0 }
                return rootView.bounds.width - SafeAreaType.left.insets - SafeAreaType.right.insets
            case .height:
                guard let rootView = UIApplication.shared.windows.first else { return 0 }
                return rootView.bounds.width - SafeAreaType.top.insets - SafeAreaType.bottom.insets
            }
        }
    }
    
    func safeArea(for type: SafeAreaType) -> CGFloat {
        type.insets
    }
    
    var bottomInset: CGFloat {
        calculateBottomInset(10)
    }
    
    func calculateBottomInset(_ insertForNotBottomToSafeArea: CGFloat) -> CGFloat {
        let bottomInset = safeArea(for: .bottom)
        return bottomInset == 0 ? insertForNotBottomToSafeArea : 0
    }
}
