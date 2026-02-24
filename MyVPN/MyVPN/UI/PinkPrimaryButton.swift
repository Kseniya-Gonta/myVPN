//
//  PinkPrimaryButton.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct PinkPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().tint(.white)
                }
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [AppColors.pink, AppColors.pink2],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: AppColors.pink.opacity(0.25), radius: 16, x: 0, y: 10)
            .opacity((isDisabled || isLoading) ? 0.55 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}
