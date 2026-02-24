//
//  VPNServiceError.swift
//  MyVPN
//
//  Created by Ксения Гонта on 15. 2. 2026..
//

import Foundation

enum VPNServiceError: Error, LocalizedError {
    case invalidProfile
    case invalidPasswordRef
    case preferencesLoadFailed(Error)
    case preferencesSaveFailed(Error)
    case startFailed(Error)
    
    var errorDescription: String? {
        switch self {
            case .invalidProfile: 
                return "Profile is invalid."
            case .invalidPasswordRef: 
                return "Password reference is missing. Please login again."
            case .preferencesLoadFailed(let e): 
                return "loadFromPreferences: \(e.localizedDescription)"
            case .preferencesSaveFailed(let e): 
                return "saveToPreferences: \(e.localizedDescription)"
            case .startFailed(let e): 
                return "startVPNTunnel: \(e.localizedDescription)"
        }
    }
}
