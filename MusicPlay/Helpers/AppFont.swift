//
//  AppFont.swift
//  MusicPlay
//
//  Created by ZverikRS on 28.03.2024.
//

import UIKit

enum AppFont {
    /// weight: 100
    case thin
    /// weight: 300
    case light
    /// weight: 400
    case regular
    /// weight: 500
    case medium
    /// weight: 700
    case bold
    /// weight: 900
    case black
    
    // MARK: - public methods
    
    func size(_ size: CGFloat) -> UIFont {
        switch self {
        case .thin:
            return .systemFont(ofSize: size, weight: .thin)
        case .light:
            return .systemFont(ofSize: size, weight: .light)
        case .regular:
            return .systemFont(ofSize: size, weight: .regular)
        case .medium:
            return .systemFont(ofSize: size, weight: .medium)
        case .bold:
            return .systemFont(ofSize: size, weight: .bold)
        case .black:
            return .systemFont(ofSize: size, weight: .black)
        }
    }
}
