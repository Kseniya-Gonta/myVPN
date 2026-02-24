//
//  StatusPill.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI
import NetworkExtension

struct StatusPill: View {
    let status: NEVPNStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundStyle(dotColor)

            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.65))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
    }

    private var label: String {
        switch status {
            case .connected:
                return "Connected"
            case .connecting, .reasserting:
                return "Connecting"
            case .disconnecting:
                return "Disconnecting"
            case .disconnected:
                return "Disconnected"
            case .invalid:
                return "Invalid"
            @unknown default:
                return "Unknown"
        }
    }

    private var dotColor: Color {
        switch status {
            case .connected: return .green
            case .connecting, .reasserting: return .orange
            case .disconnecting: return .orange
            case .disconnected, .invalid: return .gray
            @unknown default: return .gray
        }
    }
}
