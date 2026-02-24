//
//  HomeScreen.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import SwiftUI
import NetworkExtension

struct HomeScreen: View {
    @StateObject private var vm = VPNViewModel()
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView {
                VStack(spacing: 14) {
                    header
                    
                    if vm.isLoggedIn {
                        loggedInInfo
                    } else {
                        LoginCard(
                            serverHost: $vm.serverHost,
                            remoteId: $vm.remoteId,
                            username: $vm.username,
                            password: $vm.password,
                            onSave: { await vm.loginAndSave() }
                        )
                    }
                    
                    if let msg = vm.errorMessage {
                        Text(msg)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.red)
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            
            if vm.isBusy {
                LoadingOverlay(title: vm.busyTitle, subtitle: vm.busySubtitle)
                    .animation(.easeInOut(duration: 0.15), value: vm.isBusy)
            }
        }
        .task { await vm.refresh() }
    }

    private var loggedInInfo: some View {
        Group {
            ProfileSummaryCard(server: vm.serverHost, remoteId: vm.remoteId, username: vm.username)

            ConnectionDetailsCard(
                statusText: statusText(vm.status),
                connectedSince: vm.connectedSince,
                server: vm.serverHost
            )

            PinkPrimaryButton(
                title: connectTitle(vm.status),
                isLoading: false,
                isDisabled: false,
                action: {
                    Task {
                        await vm.toggleConnection()
                    }
                }
            )

            Button(role: .destructive) {
                vm.logout()
            } label: {
                Text("Logout")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.black.opacity(0.08))
            .foregroundStyle(.red)
            .padding(.top, 4)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("MyVPN")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("IKEv2 • Personal VPN")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Spacer()
            
            StatusPill(status: vm.status)
        }
    }
    
    private func connectTitle(_ s: NEVPNStatus) -> String {
        switch s {
            case .connected, .connecting, .reasserting: 
                return "Disconnect"
            default: 
                return "Connect"
        }
    }
    
    private func statusText(_ status: NEVPNStatus) -> String {
        switch status {
            case .invalid:
                return "invalid"
            case .disconnected:
                return "disconnected"
            case .connecting:
                return "connecting"
            case .connected:
                return "connected"
            case .reasserting:
                return "reasserting"
            case .disconnecting:
                return "disconnecting"
            @unknown default:
                return "unknown"
        }
    }
}
