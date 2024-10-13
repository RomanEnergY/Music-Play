//
//  MainView+CollectionView.swift
//  MusicPlay
//
//  Created by ZverikRS on 28.03.2024.
//

import UIKit
import DeepDiff

// MARK: - extension for CollectionView

extension MainView {
    final class CollectionView: BaseCollectionView {
        
        // MARK: - public properties
        
        var items: [MainViewModel.Collection.Item]? {
            didSet {
                recalculateData()
            }
        }
        
        // MARK: - enum
        
        fileprivate enum ShowType {
            case item(ItemCell.ViewModel)
        }
        
        // MARK: - private properties
        
        private let queue: DispatchQueue = .init(label: "com.mainView.nollectionView")
        private var showTypes: [ShowType] = []
        
        // MARK: - initializers
        
        init() {
            super.init(
                scrollDirection: .vertical,
                minimumLineSpacing: 10)
        }
        
        // MARK: - life cycle
        
        override func config() {
            super.config()
            register(ItemCell.self)
            clipsToBounds = false
            dataSource = self
            delegate = self
        }
        
        // MARK: - public methods
        
        func play(title: String?) {
            if let enumerateItem = getItemShowType(title: title) {
                updateStateItemCell(to: enumerateItem, state: .play)
            }
        }
        
        func pause(title: String?) {
            if let enumerateItem = getItemShowType(title: title) {
                updateStateItemCell(to: enumerateItem, state: .pause)
            }
        }
        
        func stop(title: String?) {
            if let enumerateItem = getItemShowType(title: title) {
                updateStateItemCell(to: enumerateItem, state: .stop)
            }
        }
        
        // MARK: - private methods
        
        private func recalculateData() {
            synchronize { [weak self] in
                self?.showTypes = (self?.items ?? []).map { .item(
                    .init(
                        sougTitle: $0.title,
                        onViewPressed: $0.onViewPressed))
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                }
            }
        }
        
        private func synchronize(completion: @escaping () -> Void) {
            queue.sync {
                completion()
            }
        }
        
        private func getItemShowType(title: String?) -> EnumeratedSequence<[MainView.CollectionView.ShowType]>.Element? {
            showTypes.enumerated().first(where: { enumerate in
                if case let .item(model) = enumerate.element,
                   model.sougTitle == title {
                    return true
                } else {
                    return false
                }
            })
        }
        
        private func updateStateItemCell(
            to enumerateItem: EnumeratedSequence<[MainView.CollectionView.ShowType]>.Element,
            state: ItemCell.ViewModel.State
        ) {
            if case var .item(model) = enumerateItem.element {
                model.state = state
                showTypes.replace(.item(model), at: enumerateItem.offset)
                
                DispatchQueue.main.async { [weak self] in
                    UIView.performWithoutAnimation {
                        self?.performBatchUpdates({ [weak self] in
                            self?.reloadItems(at: [.init(row: enumerateItem.offset, section: 0)])
                        }, completion: nil)
                    }
                }
            }
        }
    }
}

// MARK: - extension for UICollectionViewDataSource

extension MainView.CollectionView: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        showTypes.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch showTypes[indexPath.row] {
        case .item(let model):
            let cell: ItemCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.model = model
            return cell
        }
    }
}

// MARK: - extension for UICollectionViewDelegateFlowLayout

extension MainView.CollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch showTypes[indexPath.row] {
        case let .item(model):
            let cell: ItemCell = .init()
            cell.model = model
            return cell.getFittingSize(fixWidth: collectionView.frame.width)
        }
    }
}
