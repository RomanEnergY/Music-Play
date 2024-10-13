//
//  MainView.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import UIKit
import SnapKit

protocol MainViewDisplayLogic {
    var collectionViewModel: MainViewModel.Collection? { get set}
    var audioPlayerControlViewModel: MainViewModel.AudioPlayerControl? { get set}
    func showLoading()
    func hideLoading()
    func viewWillAppear()
}

// MARK: - class

final class MainView: BaseView {
    
    // MARK: - public properties
    
    var collectionViewModel: MainViewModel.Collection? {
        didSet {
            configCollection()
        }
    }
    
    var audioPlayerControlViewModel: MainViewModel.AudioPlayerControl? {
        didSet {
            configAudioPlayerControl()
        }
    }
    
    // MARK: - private properties
    
    private var audioPlayerControlViewBottomConstraint: Constraint?
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView: UIActivityIndicatorView = .init(style: .medium)
        activityIndicatorView.color = .blue
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    private lazy var collectionView: CollectionView = .init()
    private lazy var audioPlayerControlView: AudioPlayerControlView = {
        let audioPlayerControlView: AudioPlayerControlView = .init()
        audioPlayerControlView.delegate = self
        return audioPlayerControlView
    }()
    
    // MARK: - life cycle
    
    override func config() {
        super.config()
    }
    
    override func addSubviews() {
        super.addSubviews()
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        addSubview(audioPlayerControlView)
        audioPlayerControlView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            audioPlayerControlViewBottomConstraint = $0.bottom.equalToSuperview().constraint
        }
        addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - private methods
    
    private func configCollection() {
        collectionViewModel?.view = .init(
            items: { [weak self] items in
                self?.collectionView.items = items
            })
    }
    
    private func configAudioPlayerControl() {
        audioPlayerControlViewModel?.view = .init(
            updateSougTitle: { [weak self] title in
                self?.audioPlayerControlView.sougTitle = title
            },
            updateDuration: { [weak self] duratison in
                self?.audioPlayerControlView.duration = duratison
            },
            updateCurrentTime: { [weak self] currentTime in
                self?.audioPlayerControlView.currentTime = currentTime
            },
            play: { [weak self] currentSougTitle in
                self?.audioPlayerControlView.play()
                self?.collectionView.play(title: currentSougTitle)
                self?.audioPlayerControlViewAnimateHidden(false)
            },
            pause: { [weak self] currentSougTitle in
                self?.audioPlayerControlView.pause()
                self?.collectionView.pause(title: currentSougTitle)
            },
            stop: { [weak self] currentSougTitle in
                self?.audioPlayerControlView.stop()
                self?.collectionView.stop(title: currentSougTitle)
            })
    }
    
    private func audioPlayerControlViewAnimateHidden(_ isHidden: Bool) {
        if isHidden && audioPlayerControlView.frame.minY != frame.maxY
            || !isHidden && audioPlayerControlView.frame.maxY != frame.maxY {
            audioPlayerControlViewBottomConstraint?.update(inset: isHidden ? -audioPlayerControlView.frame.height : 0)
            UIView.animate(withDuration: .baseAnimate) {
                self.layoutIfNeeded()
            }
        }
    }
}

// MARK: - extension for MainViewDisplayLogic

extension MainView: MainViewDisplayLogic {
    func showLoading() {
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        activityIndicatorView.stopAnimating()
    }
    
    func viewWillAppear() {
        layoutIfNeeded()
        let inset = audioPlayerControlView.frame.height + safeArea(for: .bottom)
        audioPlayerControlViewBottomConstraint?.update(inset: -inset)
    }
}

// MARK: - extension for MainViewAudioPlayerControlDelegate

extension MainView: MainViewAudioPlayerControlDelegate {
    
    func audioPlayerControlViewLast(_ audioPlayerControlView: MainView.AudioPlayerControlView) {
        audioPlayerControlViewModel?.presenter.last()
    }
    
    func audioPlayerControlViewStop(_ audioPlayerControlView: MainView.AudioPlayerControlView) {
        audioPlayerControlViewModel?.presenter.stop()
        audioPlayerControlViewAnimateHidden(true)
    }
    
    func audioPlayerControlViewPlay(_ audioPlayerControlView: AudioPlayerControlView) {
        audioPlayerControlViewModel?.presenter.play()
    }
    
    func audioPlayerControlViewPause(_ audioPlayerControlView: AudioPlayerControlView) {
        audioPlayerControlViewModel?.presenter.pause()
    }
    
    func audioPlayerControlViewNext(_ audioPlayerControlView: MainView.AudioPlayerControlView) {
        audioPlayerControlViewModel?.presenter.next()
    }
    
    func audioPlayerControlViewValueChanged(_ audioPlayerControlView: MainView.AudioPlayerControlView, value: Float) {
        audioPlayerControlViewModel?.presenter.setCurrentValue(value)
    }
}
