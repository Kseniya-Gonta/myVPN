//
//  ValidationError.swift
//  MyVPN
//
//  Created by Ксения Гонта on 25. 2. 2026..
//

import Foundation

enum ValidationError: LocalizedError, Equatable {
    case message(String)

    var errorDescription: String? {
        switch self {
            case .message(let text):
                return text
        }
    }
}
