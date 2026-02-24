//
//  StoredVPNProfile.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

struct StoredVPNProfile: Codable, Equatable {
    var serverHost: String
    var remoteIdentifier: String
    var username: String
    var passwordRefBase64: String
}
