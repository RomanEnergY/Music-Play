//
//  MainPresenter.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import Foundation

// MARK: - businessLogic

protocol MainPresentetionBusinessLogic: AnyObject {
    func start()
    func addSong(for url: URL)
}

// MARK: - class

final class MainPresenter {
    
    // MARK: - public properties
    
    private var collectionViewModel: MainViewModel.Collection?
    private var audioPlayerControlViewModel: MainViewModel.AudioPlayerControl?
    
    // MARK: - private properties
    
    private weak var view: MainControllerDisplayLogic?
    private let locker: NSLock = .init()
    private let queue: DispatchQueue = .init(label: "com.mainPresenter")
    private var currentSougTitle: String?
    private var items: [MainViewModel.Collection.Item] = []
    private lazy var songManager: SongManager = { .shared }()
    private lazy var audioPlayer: AudioPlayerBusinessLogic = {
        let audioPlayer: AudioPlayer = .init()
        audioPlayer.delegate = self
        return audioPlayer
    }()
    
    // MARK: - initializers
    
    init(view: MainControllerDisplayLogic) {
        self.view = view
    }
    
    // MARK: - private methods
    
    private func createCollectionViewModel() {
        synchronized { [weak self] in
            guard let self else { return }
            self.collectionViewModel = .init(
                presenter: .init())
            
            self.mainQueueAsync { [weak self] in
                guard let model = self?.collectionViewModel else { return }
                self?.view?.reloadCollectionViewModel(model: model)
                self?.reloadCollection()
            }
        }
    }
    
    private func reloadCollection() {
        let items: [MainViewModel.Collection.Item] = (songManager.featch() ?? []).compactMap { item in
            guard
                let title = item.title,
                let data = item.data
            else {
                return nil
            }
            
            return .init(
                title: item.title ?? "",
                data: data,
                onViewPressed: { [weak self] in
                    self?.play(
                        title: title,
                        data: data,
                        completion: nil)
                })
        }
        
        self.items = items
        collectionViewModel?.view?.items(items)
    }
    
    private func createAudioPlayerControlViewModel() {
        synchronized { [weak self] in
            guard let self else { return }
            self.audioPlayerControlViewModel = self.audioPlayerControlViewModel ?? .init(
                presenter: .init(
                    last: { [weak self] in
                        self?.audioPlayer.last()
                    },
                    stop: { [weak self] in
                        if let currentSougTitle = self?.currentSougTitle {
                            self?.audioPlayerControlViewModel?.view?.stop(currentSougTitle)
                        }
                        self?.currentSougTitle = nil
                        self?.audioPlayer.stop()
                    },
                    pause: { [weak self] in
                        self?.audioPlayer.pause()
                    },
                    play: { [weak self] in
                        self?.audioPlayer.play()
                    },
                    next: { [weak self] in
                        self?.audioPlayer.next()
                    },
                    setCurrentValue: { [weak self] value in
                        self?.audioPlayer.setCurrentValue(value)
                    }))
            
            self.mainQueueAsync { [weak self] in
                guard let model = self?.audioPlayerControlViewModel else { return }
                self?.view?.reloadAudioPlayerControlViewModel(model: model)
            }
        }
    }
    
    private func playAndSave(for url: URL) {
        view?.showLoading()
        play(for: url) { [weak self] model, error in
            defer { self?.view?.hideLoading() }
            if let error {
                self?.showError(MessageError(message: error.localizedDescription))
            } else if let model {
                self?.trySave(model: model)
            }
        }
    }
    
    private func play(for url: URL, completion: @escaping (SongModel?, Error?) -> Void) {
        do {
            let title = url.lastPathComponent
            let data = try Data(contentsOf: url)
            play(title: title, data: data) { model in
                if let model {
                    completion(model, nil)
                }
            }
        } catch let error {
            completion(nil, error)
        }
    }
    
    private func play(title: String, data: Data, completion: ((SongModel?) -> Void)?) {
        if let currentSougTitle {
            audioPlayerControlViewModel?.view?.stop(currentSougTitle)
        }
        
        audioPlayer.play(data: data) { [weak self] result in
            self?.mainQueueAsync { [weak self] in
                switch result {
                case .failure(let error):
                    self?.showError(error)
                    completion?(nil)
                case .success(let model):
                    self?.currentSougTitle = title
                    self?.audioPlayerControlViewModel?.view?.updateSougTitle(title)
                    completion?(.init(
                        title: title,
                        data: model.data))
                }
            }
        }
    }
    
    private func trySave(model: SongModel) {
        if songManager.featch(title: model.title) == nil {
            if songManager.create(title: model.title, data: model.data) == nil {
                showError(MessageError(message: "Ошибка сохранения, попробуйте еще раз"))
            } else {
                reloadCollection()
            }
        }
    }
    
    private func showError(_ error: Error) {
        view?.showError(error)
    }
    
    private func synchronized(completion: @escaping () -> Void) {
        locker.lock()
        queue.async { [weak self] in
            completion()
            self?.locker.unlock()
        }
    }
    
    private func mainQueueAsync(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            completion()
        }
    }
}

// MARK: - extension for MainPresentetionBusinessLogic

extension MainPresenter: MainPresentetionBusinessLogic {
    func start() {
        createCollectionViewModel()
        createAudioPlayerControlViewModel()
    }
    
    func addSong(for url: URL) {
        playAndSave(for: url)
    }
}

// MARK: - extension for AudioPlayerDelegate

extension MainPresenter: AudioPlayerDelegate {
    func audioPlayerDidLast(_ audioPlayer: AudioPlayer) {
        if let currentSougTitle,
           let index = items.firstIndex(where: { $0.title == currentSougTitle }),
           let newxtItem = items[safe: index - 1] ?? items[safe: index] {
            play(title: newxtItem.title, data: newxtItem.data, completion: nil)
        } else {
            audioPlayer.stop()
        }
    }
    
    func audioPlayerDidStop(_ audioPlayer: AudioPlayer) {
        audioPlayerControlViewModel?.view?.stop(currentSougTitle)
    }
    
    func audioPlayerDidPlay(_ audioPlayer: AudioPlayer) {
        audioPlayerControlViewModel?.view?.play(currentSougTitle)
    }
    
    func audioPlayerDidPause(_ audioPlayer: AudioPlayer) {
        audioPlayerControlViewModel?.view?.pause(currentSougTitle)
    }
    
    func audioPlayerDidNext(_ audioPlayer: AudioPlayer) {
        if let currentSougTitle,
           let index = items.firstIndex(where: { $0.title == currentSougTitle }),
           let newxtItem = items[safe: index + 1] {
            play(title: newxtItem.title, data: newxtItem.data, completion: nil)
        }
    }
    
    func audioPlayerDuration(_ audioPlayer: AudioPlayer, duration: Double) {
        audioPlayerControlViewModel?.view?.updateDuration(duration)
    }
    
    func audioPlayerCurrentTime(_ audioPlayer: AudioPlayer, currentTime: Double) {
        audioPlayerControlViewModel?.view?.updateCurrentTime(currentTime)
    }
}
