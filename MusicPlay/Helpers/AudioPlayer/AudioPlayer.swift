//
//  AudioPlayer.swift
//  MusicPlay
//
//  Created by ZverikRS on 24.03.2024.
//

import Foundation
import AVFoundation

protocol AudioPlayerBusinessLogic: AnyObject {
    func play(data: Data, completion: @escaping (Result<(AudioPlayerModel), AudioPlayerError>) -> Void)
    func last()
    func stop()
    func pause()
    func play()
    func next()
    func setCurrentValue(_ value: Float)
}

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayerDidLast(_ audioPlayer: AudioPlayer)
    func audioPlayerDidStop(_ audioPlayer: AudioPlayer)
    func audioPlayerDidPause(_ audioPlayer: AudioPlayer)
    func audioPlayerDidPlay(_ audioPlayer: AudioPlayer)
    func audioPlayerDidNext(_ audioPlayer: AudioPlayer)
    func audioPlayerDuration(_ audioPlayer: AudioPlayer, duration: Double)
    func audioPlayerCurrentTime(_ audioPlayer: AudioPlayer, currentTime: Double)
}

// MARK: - class

final class AudioPlayer: NSObject {
    
    // MARK: - private properties
    
    private let queue: DispatchQueue = .init(label: "com.audioPlayer")
    private var audioPlayer: AVAudioPlayer?
    private var timerCalculatePlayCurrentTime: Timer?
    private var timerDelayPause: Timer?
    private var isStopped: Bool = true
    
    // MARK: - public properties
    
    weak var delegate: AudioPlayerDelegate?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: nil)
    }
    
    // MARK: - private methods
    
    private func mainAsync(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            completion()
        }
    }
    
    private func synchronization(completion: @escaping () -> Void) {
        queue.sync {
            completion()
        }
    }
    
    @objc private func onTickCalculatePlayCurrentTime() {
        mainAsync { [weak self] in
            guard
                let self,
                let audioPlayer = self.audioPlayer
            else {
                return
            }
            self.delegate?.audioPlayerCurrentTime(self, currentTime: audioPlayer.currentTime)
        }
    }
    
    @objc private func onTickDelayPause() {
        audioPlayer?.play()
    }
    
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            audioPlayer?.pause()
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    audioPlayer?.play()
                }
            }
        @unknown default:
            print("🟢 \(#fileID) \(#function):\(#line) ~ Неизвестный тип прерывания")
        }
    }
}

// MARK: - extension for AudioPlayerBusinessLogic

extension AudioPlayer: AudioPlayerBusinessLogic {
    func play(data: Data, completion: @escaping (Result<(AudioPlayerModel), AudioPlayerError>) -> Void) {
        synchronization { [weak self] in
            guard let self else { return }
            do {
                self.audioPlayer = try .init(data: data)
                self.audioPlayer?.play()
                self.isStopped = false
                self.audioPlayer?.delegate = self
                
                let timerCalculatePlayCurrentTime = Timer(
                    timeInterval: 0.5,
                    target: self,
                    selector: #selector(self.onTickCalculatePlayCurrentTime),
                    userInfo: nil,
                    repeats: true)
                
                // перенос таймера на отдельный runloop
                RunLoop.current.add(timerCalculatePlayCurrentTime, forMode: .common)
                self.timerCalculatePlayCurrentTime = timerCalculatePlayCurrentTime
                completion(.success(.init(data: data)))
                
                self.mainAsync { [weak self] in
                    guard
                        let self,
                        let audioPlayer = self.audioPlayer
                    else {
                        return
                    }
                    self.delegate?.audioPlayerDidPlay(self)
                    self.delegate?.audioPlayerDuration(self, duration: audioPlayer.duration)
                    self.delegate?.audioPlayerCurrentTime(self, currentTime: audioPlayer.currentTime)
                }
            } catch (let error) {
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func last() {
        mainAsync { [weak self] in
            guard let self else { return }
            self.delegate?.audioPlayerDidLast(self)
        }
    }
    
    func stop() {
        synchronization { [weak self] in
            guard let self else { return }
            self.isStopped = true
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            
            self.timerCalculatePlayCurrentTime?.invalidate()
            self.timerCalculatePlayCurrentTime = nil
            
            self.mainAsync { [weak self] in
                guard let self else { return }
                self.delegate?.audioPlayerDidStop(self)
            }
        }
    }
    func pause() {
        mainAsync { [weak self] in
            guard let self else { return }
            self.audioPlayer?.pause()
            self.delegate?.audioPlayerDidPause(self)
        }
    }
    
    func play() {
        mainAsync { [weak self] in
            guard let self else { return }
            self.audioPlayer?.play()
            self.delegate?.audioPlayerDidPlay(self)
        }
    }
    
    func next() {
        mainAsync { [weak self] in
            guard let self else { return }
            self.delegate?.audioPlayerDidNext(self)
        }
    }
    
    func setCurrentValue(_ value: Float) {
        synchronization { [weak self] in
            guard
                let self,
                let audioPlayer = self.audioPlayer
            else {
                return
            }
            
            let currentTime = audioPlayer.duration * Double(value)
            if Int(audioPlayer.currentTime) != Int(currentTime) {
                audioPlayer.pause()
                let value = Double(value)
                if value < 1, value >= 0 {
                    audioPlayer.currentTime = audioPlayer.duration * Double(value)
                    self.timerDelayPause?.invalidate()
                    self.timerDelayPause = nil
                    
                    let timerDelayPause = Timer(
                        timeInterval: 0.3,
                        target: self,
                        selector: #selector(self.onTickDelayPause),
                        userInfo: nil,
                        repeats: false)
                    
                    // перенос таймера на отдельный runloop
                    RunLoop.current.add(timerDelayPause, forMode: .common)
                    self.timerDelayPause = timerDelayPause
                    
                } else {
                    audioPlayer.stop()
                }
            }
        }
    }
}

// MARK: - extension for AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if isStopped {
                stop()
            } else {
                next()
            }
        }
    }
}
