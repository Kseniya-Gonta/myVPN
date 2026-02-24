//
//  ConnectionDetailsCard.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct ConnectionDetailsCard: View {
    let statusText: String
    let connectedSince: Date?
    let server: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Connection")

                HStack {
                    Text("State").foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(statusText).foregroundStyle(AppColors.textPrimary)
                }
                .font(.system(.subheadline, design: .rounded))

                HStack {
                    Text("Server").foregroundStyle(AppColors.textSecondary)
                    Spacer()
                    Text(server).foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1).truncationMode(.middle)
                }
                .font(.system(.subheadline, design: .rounded))

                if let since = connectedSince {
                    HStack {
                        Text("Connected since").foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text(since.formatted(date: .abbreviated, time: .standard))
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .font(.system(.subheadline, design: .rounded))
                }
            }
        }
    }
}
