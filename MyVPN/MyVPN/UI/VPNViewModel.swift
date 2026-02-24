//
//  VPNViewModel.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

import Combine
import Foundation
import NetworkExtension

@MainActor
final class VPNViewModel: ObservableObject {
    enum BusyState: Equatable {
        case savingProfile
        case preparingVPN
        case connecting
        case disconnecting

        var title: String {
            switch self {
                case .savingProfile:
                    return "Saving profile…"
                case .preparingVPN:
                    return "Preparing VPN…"
                case .connecting:
                    return "Connecting…"
                case .disconnecting:
                    return "Disconnecting…"
            }
        }

        var subtitle: String? {
            switch self {
                case .savingProfile:
                    return "Securing credentials in Keychain"
                case .preparingVPN:
                    return "Installing configuration"
                case .connecting:
                    return "Starting secure tunnel"
                case .disconnecting:
                    return nil
            }
        }
    }

    struct LoginInput: Equatable {
        let host: String
        let remoteId: String
        let username: String
        let password: String
    }

    @Published var serverHost = ""
    @Published var remoteId = ""
    @Published var username = ""
    @Published var password = ""

    @Published var isLoggedIn = false
    @Published var status: NEVPNStatus = .invalid
    @Published var connectedSince: Date?
    @Published var errorMessage: String?

    @Published var busyState: BusyState?

    var isBusy: Bool { busyState != nil }
    var busyTitle: String { busyState?.title ?? "" }
    var busySubtitle: String? { busyState?.subtitle }

    private let vpn: VPNServiceProtocol
    private let store: VPNProfileStore
    private let secrets: SecretStore

    private let keychainService = "com.example.MyVPN"
    private let keychainAccount = "vpn-password"

    private var statusObserver: NSObjectProtocol?

    init(vpn: VPNServiceProtocol, store: VPNProfileStore, secrets: SecretStore) {
        self.vpn = vpn
        self.store = store
        self.secrets = secrets

        if let profile = store.profile {
            serverHost = profile.serverHost
            remoteId = profile.remoteIdentifier
            username = profile.username
            isLoggedIn = true
        }

        observeStatus()

        Task { [weak self] in
            await self?.refresh()
        }
    }

    convenience init() {
        self.init(
            vpn: IKEv2VPNService(),
            store: UserDefaultsVPNProfileStore(),
            secrets: KeychainSecretStore()
        )
    }

    deinit {
        if let observer = statusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func refresh() async {
        do {
            try await vpn.load()
            updateConnectionInfo()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func loginAndSave() async {
        guard !isBusy else { return }
        errorMessage = nil

        do {
            let input = try makeLoginInput()
            busyState = .savingProfile
            let profile = try saveProfile(input: input)
            password = ""
            isLoggedIn = true

            busyState = .preparingVPN
            try await applyProfile(profile)

            await refresh()
            busyState = nil
        } catch {
            busyState = nil
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func toggleConnection() async {
        guard !isBusy else { return }
        errorMessage = nil

        switch status {
            case .connected, .connecting, .reasserting:
                busyState = .disconnecting
                vpn.disconnect()

            case .disconnected, .invalid, .disconnecting:
                guard store.profile != nil else {
                    isLoggedIn = false
                    errorMessage = "Please login first."
                    return
                }

                busyState = .connecting

                do {
                    try vpn.connect()
                } catch {
                    busyState = nil
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }

            @unknown default:
                break
        }
    }

    func logout() {
        guard !isBusy else { return }
        errorMessage = nil

        vpn.disconnect()

        do {
            try secrets.deletePassword(account: keychainAccount, service: keychainService)
        } catch {}

        store.clearProfile()

        isLoggedIn = false
        serverHost = ""
        remoteId = ""
        username = ""
        password = ""
        connectedSince = nil
        status = vpn.status
        busyState = nil
    }

    private func makeLoginInput() throws -> LoginInput {
        let host = serverHost.trimmingCharacters(in: .whitespacesAndNewlines)
        let rid  = remoteId.trimmingCharacters(in: .whitespacesAndNewlines)
        let user = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password

        guard !host.isEmpty else { throw ValidationError.message("Enter server host.") }
        guard !user.isEmpty else { throw ValidationError.message("Enter username.") }
        guard !pass.isEmpty else { throw ValidationError.message("Enter password.") }

        return LoginInput(host: host, remoteId: rid, username: user, password: pass)
    }

    private func saveProfile(input: LoginInput) throws -> StoredVPNProfile {
        let ref = try secrets.storePassword(input.password, account: keychainAccount, service: keychainService)

        let profile = StoredVPNProfile(
            serverHost: input.host,
            remoteIdentifier: input.remoteId,
            username: input.username,
            passwordRefBase64: ref.base64EncodedString()
        )

        store.saveProfile(profile)
        return profile
    }

    private func applyProfile(_ profile: StoredVPNProfile) async throws {
        try await Task.detached(priority: .userInitiated) { [vpn] in
            try await vpn.applyProfile(profile)
        }.value
    }

    private func updateConnectionInfo() {
        status = vpn.status
        connectedSince = vpn.connectedDate
    }

    private func observeStatus() {
        statusObserver = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.updateConnectionInfo()
                let newStatus = self.vpn.status

                switch self.busyState {
                    case .connecting:
                        switch newStatus {
                            case .connected:
                                self.busyState = nil
                            case .disconnected, .invalid:
                                self.busyState = nil
                            case .connecting, .reasserting, .disconnecting:
                                break
                            @unknown default:
                                break
                        }

                    case .disconnecting:
                        switch newStatus {
                            case .disconnected, .invalid:
                                self.busyState = nil
                            case .connected, .connecting, .reasserting, .disconnecting:
                                break
                            @unknown default:
                                break
                        }

                    case .savingProfile, .preparingVPN, .none:
                        break
                }
            }
        }
    }
}
