//
//  VPNProfileStore.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

import Foundation

protocol VPNProfileStore {
    var profile: StoredVPNProfile? { get }
    func saveProfile(_ profile: StoredVPNProfile)
    func clearProfile()
}

final class UserDefaultsVPNProfileStore: VPNProfileStore {
    private let key = "vpn.profile"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var profile: StoredVPNProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(StoredVPNProfile.self, from: data)
    }

    func saveProfile(_ profile: StoredVPNProfile) {
        let data = try? JSONEncoder().encode(profile)
        defaults.set(data, forKey: key)
    }

    func clearProfile() {
        defaults.removeObject(forKey: key)
    }
}
