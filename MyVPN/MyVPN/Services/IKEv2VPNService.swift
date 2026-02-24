//
//  IKEv2VPNService.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

import Foundation
import NetworkExtension

protocol VPNServiceProtocol {
    var status: NEVPNStatus { get }
    var connectedDate: Date? { get }
    func load() async throws
    func applyProfile(_ profile: StoredVPNProfile) async throws
    func connect() throws
    func disconnect()
}

final class IKEv2VPNService: VPNServiceProtocol {
    
    private let manager: NEVPNManager
    
    init(manager: NEVPNManager = .shared()) {
        self.manager = manager
    }
    
    var status: NEVPNStatus { manager.connection.status }
    var connectedDate: Date? { manager.connection.connectedDate }
    
    func load() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            manager.loadFromPreferences { error in
                if let error { cont.resume(throwing: VPNServiceError.preferencesLoadFailed(error)) }
                else { cont.resume(returning: ()) }
            }
        }
    }
    
    func applyProfile(_ profile: StoredVPNProfile) async throws {
        guard !profile.serverHost.isEmpty, !profile.username.isEmpty else {
            throw VPNServiceError.invalidProfile
        }
        guard let passwordRef = Data(base64Encoded: profile.passwordRefBase64) else {
            throw VPNServiceError.invalidPasswordRef
        }
        
        try await load()
        
        let p = NEVPNProtocolIKEv2()
        p.serverAddress = profile.serverHost
        p.remoteIdentifier = profile.remoteIdentifier.isEmpty ? profile.serverHost : profile.remoteIdentifier
        p.username = profile.username
        p.passwordReference = passwordRef
        p.useExtendedAuthentication = true
        p.disconnectOnSleep = false
        p.deadPeerDetectionRate = .high
        
        manager.protocolConfiguration = p
        manager.localizedDescription = "MyVPN"
        manager.isEnabled = true
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.saveToPreferences { error in
                if let error {
                    continuation.resume(throwing: VPNServiceError.preferencesSaveFailed(error))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        
        try await load()
    }
    
    func connect() throws {
        do {
            try manager.connection.startVPNTunnel()
        } catch {
            throw VPNServiceError.startFailed(error)
        }
    }
    
    func disconnect() {
        manager.connection.stopVPNTunnel()
    }
}
