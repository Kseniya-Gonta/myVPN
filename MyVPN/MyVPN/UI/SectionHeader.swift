//
//  SectionHeader.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
}
