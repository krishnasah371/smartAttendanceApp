//
//  RootView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import SwiftUI
struct RootView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        if sessionManager.isLoggedIn {
            MainTabView()
        } else {
            SplashScreenView()
        }
    }
}

#Preview {
    RootView()
}
