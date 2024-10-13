//
//  MainViewController.swift
//  MusicPlay
//
//  Created by ZverikRS on 22.03.2024.
//

import UIKit
import SnapKit

// MARK: - displayLogic

protocol MainControllerDisplayLogic: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(_ error: Error)
    func reloadCollectionViewModel(model: MainViewModel.Collection)
    func reloadAudioPlayerControlViewModel(model: MainViewModel.AudioPlayerControl)
}

// MARK: - class

final class MainViewController: UIViewController {
    
    // MARK: - public properties
    
    var presenter: MainPresentetionBusinessLogic?
    
    // MARK: - private properties
    
    private var mainView: MainViewDisplayLogic?
    
    // MARK: - initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        super.loadView()
        let mainView = MainView()
        view = mainView
        self.mainView = mainView
        presenter?.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MainScreen"
        view.backgroundColor = .white
        configRightBarButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView?.viewWillAppear()
    }
    
    // MARK: - private methods
    
    private func configRightBarButtonItem() {
        navigationItem.rightBarButtonItem = .init(
            title: "Добавить",
            style: .plain ,
            target: self ,
            action: #selector(onAddButtonTouchUpInside))
    }
    
    private func mainQueueAsync(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            completion()
        }
    }
    
    @objc private func onAddButtonTouchUpInside(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
}

// MARK: - extension for MainControllerDisplayLogic

extension MainViewController: MainControllerDisplayLogic {
    func showLoading() {
        mainView?.showLoading()
    }
    
    func hideLoading() {
        mainView?.hideLoading()
    }
    
    func showError(_ error: Error) {
        let alert: UIAlertController = .init(
            title: "Сообщение",
            message: error.localizedDescription,
            preferredStyle: .alert)
        
        alert.addAction(.init(
            title: "Понятно",
            style: .default))
        
        present(alert, animated: true)
    }
    
    func reloadCollectionViewModel(model: MainViewModel.Collection) {
        mainView?.collectionViewModel = model
    }
    
    func reloadAudioPlayerControlViewModel(model: MainViewModel.AudioPlayerControl) {
        mainView?.audioPlayerControlViewModel = model
    }
}

// MARK: - extension for UIDocumentPickerDelegate

extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }
        presenter?.addSong(for: url)
    }
}
