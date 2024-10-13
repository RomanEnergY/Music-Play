//
//  AudioPlayerError.swift
//  MusicPlay
//
//  Created by ZverikRS on 24.03.2024.
//

import Foundation

enum AudioPlayerError: Error {
    case message(String)
}

extension AudioPlayerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}
