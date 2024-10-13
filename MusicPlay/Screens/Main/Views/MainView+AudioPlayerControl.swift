//
//  MainView+AudioPlayerControl.swift
//  MusicPlay
//
//  Created by ZverikRS on 24.03.2024.
//

import UIKit
import SnapKit

// MARK: - delegate

protocol MainViewAudioPlayerControlDelegate: AnyObject {
    func audioPlayerControlViewLast(_ audioPlayerControlView: MainView.AudioPlayerControlView)
    func audioPlayerControlViewStop(_ audioPlayerControlView: MainView.AudioPlayerControlView)
    func audioPlayerControlViewPlay(_ audioPlayerControlView: MainView.AudioPlayerControlView)
    func audioPlayerControlViewPause(_ audioPlayerControlView: MainView.AudioPlayerControlView)
    func audioPlayerControlViewNext(_ audioPlayerControlView: MainView.AudioPlayerControlView)
    func audioPlayerControlViewValueChanged(_ audioPlayerControlView: MainView.AudioPlayerControlView, value: Float)
}

// MARK: - class

extension MainView {
    final class AudioPlayerControlView: BaseView {
        private enum State {
            case play
            case pause
            case stop
        }
        
        // MARK: - public properties
        
        weak var delegate: MainViewAudioPlayerControlDelegate?
        var duration: Double = 0 {
            didSet {
                durationLabel.seconds = duration
            }
        }
        
        var currentTime: Double = 0 {
            didSet {
                slider.value = Float(currentTime) / Float(duration)
                currentTimeLabel.seconds = currentTime
            }
        }
        
        var sougTitle: String {
            get {
                descriptionLabel.text ?? ""
            }
            set {
                let isEmpty = newValue.isEmpty
                descriptionLabel.text = isEmpty ? "#description" : newValue
                descriptionLabel.isHidden = isEmpty
            }
        }
        
        // MARK: - private properties
        
        private var delayTimer: Timer?
        private lazy var durationLabel: TimeLabel = .init()
        private lazy var currentTimeLabel: TimeLabel = .init()
        private lazy var descriptionLabel: UILabel = {
            let label: UILabel = .init()
            label.textColor = .white
            return label
        }()
        private lazy var lastButton: Button = {
            let button: Button = .init()
            button.setImage(.init(asset: Asset.ImageAssets.AudioPlayer.last), for: .normal)
            button.addTarget(self, action: #selector(onButtonUpInside), for: .touchUpInside)
            return button
        }()
        private lazy var stopButton: Button = {
            let button: Button = .init()
            button.setImage(.init(asset: Asset.ImageAssets.AudioPlayer.stop), for: .normal)
            button.addTarget(self, action: #selector(onButtonUpInside), for: .touchUpInside)
            return button
        }()
        private lazy var pauseButton: Button = {
            let button: Button = .init()
            button.setImage(.init(asset: Asset.ImageAssets.AudioPlayer.pause), for: .normal)
            button.addTarget(self, action: #selector(onButtonUpInside), for: .touchUpInside)
            return button
        }()
        private lazy var playButton: Button = {
            let button: Button = .init()
            button.setImage(.init(asset: Asset.ImageAssets.AudioPlayer.play), for: .normal)
            button.addTarget(self, action: #selector(onButtonUpInside), for: .touchUpInside)
            button.isHidden = true
            return button
        }()
        private lazy var nextButton: Button = {
            let button: Button = .init()
            button.setImage(.init(asset: Asset.ImageAssets.AudioPlayer.next), for: .normal)
            button.addTarget(self, action: #selector(onButtonUpInside), for: .touchUpInside)
            return button
        }()
        private let controlStack: BaseStackView = .init(
            axis: .horizontal,
            spacing: 20,
            alignment: .center,
            distribution: .fillEqually)
        
        private lazy var slider: UISlider = {
            let slider: UISlider = .init()
            slider.addTarget(self, action: #selector(onSliderValueChanged), for: .valueChanged)
            slider.tintColor = .white
            return slider
        }()
        
        // MARK: - initializers
        
        override init(frame: CGRect = .zero) {
            super.init(frame: frame)
            config()
            stop()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - public methods
        
        func stop() {
            
        }
        
        func pause() {
            playButton.isHidden = false
            pauseButton.isHidden = true
            layoutIfNeeded()
        }
        
        func play() {
            playButton.isHidden = true
            pauseButton.isHidden = false
            layoutIfNeeded()
        }
        
        // MARK: - life cycle
        
        override func addSubviews() {
            super.addSubviews()
            
            let contentView: BaseView = .init()
            let color: UIColor = .init(asset: Asset.ColorAssets.AudioPlayerControl.background) ?? .clear
            contentView.setShadowContent(color: color)
            contentView.layer.cornerRadius = 10
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            contentView.backgroundColor = color
            
            addSubview(contentView)
            contentView.addSubview(descriptionLabel)
            contentView.addSubview(currentTimeLabel)
            contentView.addSubview(durationLabel)
            contentView.addSubview(controlStack)
            contentView.addSubview(slider)
            
            contentView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            descriptionLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(10)
                $0.leading.equalToSuperview().inset(20)
                $0.trailing.equalToSuperview().inset(20)
            }
            
            slider.snp.makeConstraints {
                $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
                $0.leading.equalToSuperview().inset(20)
                $0.trailing.equalToSuperview().inset(20)
            }
            
            currentTimeLabel.snp.makeConstraints {
                $0.top.equalTo(slider.snp.bottom).offset(10)
                $0.leading.equalToSuperview().inset(20)
                
            }
            durationLabel.snp.makeConstraints {
                $0.top.equalTo(currentTimeLabel)
                $0.trailing.equalToSuperview().inset(20)
            }
            
            controlStack.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalTo(currentTimeLabel)
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(bottomInset)
            }
            
            let buttons = [lastButton, stopButton, playButton, pauseButton, nextButton]
            buttons.forEach {
                $0.snp.makeConstraints {
                    $0.size.equalTo(CGSize(rect: 40))
                }
            }
            
            controlStack.addArrangedSubviews(buttons)
        }
        
        @objc private func onButtonUpInside(_ sender: UIButton) {
            switch sender {
            case lastButton:
                delegate?.audioPlayerControlViewLast(self)
            case stopButton:
                delegate?.audioPlayerControlViewStop(self)
            case pauseButton:
                delegate?.audioPlayerControlViewPause(self)
            case playButton:
                delegate?.audioPlayerControlViewPlay(self)
            case nextButton:
                delegate?.audioPlayerControlViewNext(self)
            default:
                break
            }
        }
        
        @objc private func onSliderValueChanged(_ sender: UISlider) {
            delegate?.audioPlayerControlViewValueChanged(self, value: sender.value)
        }
    }
}

// MARK: - extension for TimeLabel

extension MainView.AudioPlayerControlView {
    final class TimeLabel: UILabel {
        
        // MARK: - public properties
        
        var seconds: Double {
            didSet {
                let hours = Int(seconds) / 3600
                let minutes = Int(seconds) % 3600 / 60
                let seconds = Int(seconds) % 3600 % 60
                if hours != 0 {
                    text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                } else {
                    text = String(format: "%02d:%02d", minutes, seconds)
                }
            }
        }
        
        // MARK: - initializers
        
        init(
            frame: CGRect = .zero,
            seconds: Double = 0
        ) {
            self.seconds = seconds
            super.init(frame: frame)
            textColor = .white
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - extension for Button

extension MainView.AudioPlayerControlView {
    final class Button: UIButton {
        
        // MARK: - public properties
        
        var hitTestBoundsInset: CGFloat = 5
        
        // MARK: - life cycle
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let convertToSelfView = convert(point, to: self)
            let newBounds: CGRect = bounds.insetBy(dx: -hitTestBoundsInset, dy: -hitTestBoundsInset)
            if isUserInteractionEnabled, newBounds.contains(convertToSelfView) {
                return self
            } else {
                return super.hitTest(point, with: event)
            }
        }
    }
}
