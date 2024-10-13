//
//  MessageError.swift
//  MusicPlay
//
//  Created by ZverikRS on 27.03.2024.
//

import Foundation

struct MessageError: Error {
    let message: String
}

extension MessageError: LocalizedError {
    var errorDescription: String? {
        message
    }
}
