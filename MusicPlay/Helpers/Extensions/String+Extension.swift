//
//  String+Extension.swift
//  MusicPlay
//
//  Created by ZverikRS on 29.03.2024.
//

import Foundation

extension String {
    subscript(safe index: Int) -> Character? {
        return Array(self)[safe: index]
    }
}
