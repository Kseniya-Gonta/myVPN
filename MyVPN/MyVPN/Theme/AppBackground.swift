//
//  AppBackground.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppColors.blush, AppColors.pink2.opacity(0.35), AppColors.pink.opacity(0.25)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
