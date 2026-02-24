//
//  KeychainSecretStore.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

import Foundation
import Security

protocol SecretStore {
    func storePassword(_ password: String, account: String, service: String) throws -> Data
    func deletePassword(account: String, service: String) throws
}

final class KeychainSecretStore: SecretStore {
    
    func storePassword(_ password: String, account: String, service: String) throws -> Data {
        let passwordData = Data(password.utf8)
        
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecReturnPersistentRef as String: true
        ]
        
        var addedItem: CFTypeRef?
        let addStatus = SecItemAdd(addQuery as CFDictionary, &addedItem)
        
        if addStatus == errSecSuccess {
            guard let ref = addedItem as? Data else { throw KeychainError.missingPersistentRef }
            return ref
        }
        
        if addStatus == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let updateAttrs: [String: Any] = [
                kSecValueData as String: passwordData
            ]
            
            let updStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttrs as CFDictionary)
            guard updStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updStatus)
            }
            
            let fetchQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecReturnPersistentRef as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var fetchedItem: CFTypeRef?
            let copyStatus = SecItemCopyMatching(fetchQuery as CFDictionary, &fetchedItem)
            guard copyStatus == errSecSuccess else { throw KeychainError.unexpectedStatus(copyStatus) }
            guard let ref = fetchedItem as? Data else { throw KeychainError.missingPersistentRef }
            return ref
        }
        
        throw KeychainError.unexpectedStatus(addStatus)
    }
    
    func deletePassword(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
