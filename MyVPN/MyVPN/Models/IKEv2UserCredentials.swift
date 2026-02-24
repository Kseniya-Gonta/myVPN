//
//  IKEv2UserCredentials.swift
//  MyVPN
//
//  Created by Ксения Гонта on 14. 2. 2026..
//

struct IKEv2UserCredentials: Equatable {
    var serverHost: String
    var remoteIdentifier: String
    var username: String
    var password: String
}
