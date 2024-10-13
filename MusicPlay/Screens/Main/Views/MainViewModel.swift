//
//  MainViewModel.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import Foundation

enum MainViewModel {
}

// MARK: - extension for AudioPlayerControl

extension MainViewModel {
    final class AudioPlayerControl {
        let presenter: Presenter
        var view: View?
        
        init(
            presenter: Presenter,
            view: View? = nil
        ) {
            self.presenter = presenter
            self.view = view
        }
    }
}

extension MainViewModel.AudioPlayerControl {
    final class Presenter {
        let last: () -> Void
        let stop: () -> Void
        let pause: () -> Void
        let play: () -> Void
        let next: () -> Void
        let setCurrentValue: (Float) -> Void
        
        init(
            last: @escaping () -> Void,
            stop: @escaping () -> Void,
            pause: @escaping () -> Void,
            play: @escaping () -> Void,
            next: @escaping () -> Void,
            setCurrentValue: @escaping (Float) -> Void
        ) {
            self.last = last
            self.stop = stop
            self.pause = pause
            self.play = play
            self.next = next
            self.setCurrentValue = setCurrentValue
        }
    }
    
    struct View {
        let updateSougTitle: (_ title: String) -> Void
        let updateDuration: (_ duration: Double) -> Void
        let updateCurrentTime: (_ currentTime: Double) -> Void
        let play: (_ title: String?) -> Void
        let pause: (_ title: String?) -> Void
        let stop: (_ title: String?) -> Void
    }
}

// MARK: - extension for Collection

extension MainViewModel {
    final class Collection {
        let presenter: Presenter
        var view: View?
        
        init(
            presenter: Presenter,
            view: View? = nil
        ) {
            self.presenter = presenter
            self.view = view
        }
    }
}

extension MainViewModel.Collection {
    final class Presenter {
    }
    
    struct View {
        let items: (_ items: [Item]) -> Void
    }
    
    final class Item {
        let title: String
        let data: Data
        let onViewPressed: () -> Void
        
        init(
            title: String,
            data: Data,
            onViewPressed: @escaping () -> Void
        ) {
            self.title = title
            self.data = data
            self.onViewPressed = onViewPressed
        }
    }
}
