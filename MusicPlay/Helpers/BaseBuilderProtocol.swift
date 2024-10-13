//
//  BaseBuilderProtocol.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import UIKit

protocol BaseBuilderProtocol {
    associatedtype BuildType: UIViewController
    func build() -> BuildType
}
