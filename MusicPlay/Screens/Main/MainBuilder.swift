//
//  MainBuilder.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import UIKit

final class MainBuilder: BaseBuilderProtocol {
    
    // MARK: - public methods
    
    func build() -> MainViewController {
        let viewController = MainViewController()
        let presenter = MainPresenter(view: viewController)
        viewController.presenter = presenter
        return viewController
    }
}
