//
//  UIView+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 29.03.2024.
//

import UIKit

// MARK: - extension for System Layout Size Fitting

extension UIView {
    /// Метод возвращает необходимый размер при фиксилованном значении высоты
    /// - Parameter forHeight: статическая высота
    /// - Returns: необходимый размер пересчитанный autoLayout'ом
    func getFittingSize(fixHeight: CGFloat) -> CGSize {
        systemLayoutSizeFitting(
            .init(
                width: CGFloat.greatestFiniteMagnitude,
                height: fixHeight),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required)
    }
    
    /// Метод возвращает необходимый размер при фиксилованном значении ширины
    /// - Parameter forWidth: статическая ширина
    /// - Returns: необходимый размер пересчитанный autoLayout'ом
    func getFittingSize(fixWidth: CGFloat) -> CGSize {
        systemLayoutSizeFitting(
            .init(
                width: fixWidth,
                height: CGFloat.greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
    }
}
// MARK: - extension for shadowContent

extension UIView {
    enum ShadowType {
        case not
        case lightGray
        case lightBlue
        case lightBlueEasy
        case lightBlack
        
        fileprivate var shadowColor: UIColor {
            switch self {
            case .not:
                return .init(red: 0, green: 0, blue: 0, alpha: 0)
            case .lightGray:
                return .init(red: 0, green: 0, blue: 0, alpha: 0.15)
            case .lightBlue:
                return .init(red: 0, green: 0.478, blue: 1, alpha: 0.4)
            case .lightBlueEasy:
                return .init(red: 0, green: 0.478, blue: 1, alpha: 0.35)
            case .lightBlack:
                return .init(red: 0, green: 0, blue: 0, alpha: 0.4)
            }
        }
    }
    
    func setShadowContent(shadowType: ShadowType = .lightGray) {
        backgroundColor = .white
        clipsToBounds = shadowType == .not
        
        layer.shadowColor = shadowType.shadowColor.cgColor
        layer.shadowOpacity = shadowType == .not ? 0 : 1
        layer.shadowRadius = shadowType == .not ? 0 : 20
        layer.shadowOffset = .zero
    }
    
    func setShadowContent(color: UIColor) {
        backgroundColor = .white
        clipsToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 20
        layer.shadowOffset = .zero
    }
}

// MARK: - extension for timeWithAction

extension UIView {
    enum TimeInterval {
        case shortTap
        case longTap
        case baseAnimate
        
        var value: Foundation.TimeInterval {
            switch self {
            case .shortTap:
                return .shortTap
            case .longTap:
                return .longTap
            case .baseAnimate:
                return .baseAnimate
            }
        }
    }
    
    // MARK: - private properties
    
    private static var taskFinishKey: String { "task.finish" }
    private static var completionKey: String { "task.completion" }
    
    // MARK: - internal struct
    
    struct Task {
        let start: () -> Void
        let finish: () -> Void
    }
    
    // MARK: - public methods
    
    func timeWithTask(
        withDuration: TimeInterval = .shortTap,
        task: UIView.Task,
        completion: (() -> Void)? = nil
    ) {
        var userInfo: [String: Any] = [:]
        userInfo[Self.taskFinishKey] = task.finish
        if let completion {
            userInfo[Self.completionKey] = completion
        }
        
        task.start()
        let timer = Timer(
            timeInterval: withDuration.value,
            target: self,
            selector: #selector(timerClickWithAction),
            userInfo: userInfo,
            repeats: false)
        
        // перенос таймера на отдельный runloop
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // MARK: - private methods
    
    @objc private func timerClickWithAction(_ sender: Timer) {
        if let dictionary = sender.userInfo as? [String: Any] {
            if let actionFinish = dictionary[Self.taskFinishKey] as? () -> Void,
               let completion = dictionary[Self.completionKey] as? (() -> Void)? {
                actionFinish()
                completion?()
            }
        }
    }
}

// MARK: - extension for blinkAlpha

extension UIView {
    func blinkAlpha(
        withDuration: TimeInterval
    ) {
        blinkAlpha(withDuration: withDuration, completion: nil)
    }
    
    func blinkAlpha(
        withDuration: TimeInterval = .shortTap,
        completion: (() -> Void)?
    ) {
        let alpha: CGFloat = alpha
        let task: Task = .init(
            start: { [weak self] in
                self?.alpha = alpha - CGFloat(0.3)
                self?.isUserInteractionEnabled = false
            },
            finish: { [weak self] in
                self?.alpha = alpha
                self?.isUserInteractionEnabled = true
            })
        
        timeWithTask(withDuration: withDuration, task: task, completion: completion)
    }
}
