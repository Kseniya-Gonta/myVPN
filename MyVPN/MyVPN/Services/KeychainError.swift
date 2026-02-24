//
//  KeychainError.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import CoreFoundation

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
    case missingPersistentRef
}
