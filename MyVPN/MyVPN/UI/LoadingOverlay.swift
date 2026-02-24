//
//  LoadingOverlay.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct LoadingOverlay: View {
    let title: String
    let subtitle: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .scaleEffect(1.15)
                    .tint(.white)

                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}
