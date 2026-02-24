//
//  LoginCard.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct LoginCard: View {
    @Binding var serverHost: String
    @Binding var remoteId: String
    @Binding var username: String
    @Binding var password: String

    let onSave: () async -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Login")

                VStack(spacing: 10) {
                    TextField("Server host (vpn.example.com)", text: $serverHost)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    TextField("Remote ID (optional)", text: $remoteId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                PinkPrimaryButton(title: "Save") {
                    Task { await onSave() }
                }
            }
        }
    }
}
