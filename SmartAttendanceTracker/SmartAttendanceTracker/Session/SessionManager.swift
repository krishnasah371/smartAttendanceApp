//
//  SessionManager.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import Foundation
import SwiftUI

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = AuthManager.shared.isLoggedIn
}

