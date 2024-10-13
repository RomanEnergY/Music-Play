//
//  MainView+CollectionView+ItemCell.swift
//  MusicPlay
//
//  Created by ZverikRS on 29.03.2024.
//

import UIKit
import SnapKit

extension MainView.CollectionView {
    final class ItemCell: BaseCollectionViewCell {
        struct ViewModel {
            enum State {
                case play
                case pause
                case stop
            }
            
            let sougTitle: String
            var state: State = .stop
            let onViewPressed: () -> Void
        }
        
        // MARK: - public properties
        
        var model: ViewModel? {
            didSet {
                titleLabel.text = model?.title
            }
        }
        
        // MARK: - private properties
        
        private let contView: BaseView = {
            let view: BaseView = .init()
            view.setShadowContent(shadowType: .lightGray)
            view.layer.cornerRadius = 10
            return view
        }()
        private let titleLabel: BaseLabel = {
            let label: BaseLabel = .init()
            label.font = AppFont.regular.size(16)
            label.textColor = .black
            label.textAlignment = .left
            label.numberOfLines = 0
            return label
        }()
        
        // MARK: - life cycle
        
        override func config() {
            super.config()
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTap)))
        }
        
        override func addSubviews() {
            super.addSubviews()
            contentView.addSubview(contView)
            contView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(10)
            }
            
            contView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(10)
            }
        }
        
        @objc private func onViewTap(_ sender: UITapGestureRecognizer) {
            sender.view?.blinkAlpha { [weak self] in
                self?.model?.onViewPressed()
            }
        }
    }
}

private extension MainView.CollectionView.ItemCell.ViewModel {
    var title: String {
        [stateToString, sougTitle]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var stateToString: String {
        switch state {
        case .pause:
            return "🟡"
        case .play:
            return "🟢"
        case .stop:
            return ""
        }
    }
}
