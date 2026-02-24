//
//  ProfileSummaryCard.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct ProfileSummaryCard: View {
    let server: String
    let remoteId: String
    let username: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Profile")

                Row(title: "Server", value: server)
                Row(title: "Remote ID", value: remoteId.isEmpty ? "(same as server)" : remoteId)
                Row(title: "Username", value: username)
                Row(title: "Password", value: "Saved in Keychain")
            }
        }
    }

    private struct Row: View {
        let title: String
        let value: String

        var body: some View {
            HStack {
                Text(title).foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text(value).foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .font(.system(.subheadline, design: .rounded))
        }
    }
}
