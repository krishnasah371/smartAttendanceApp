//
//  MainTabView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/7/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) var dismiss

    
    let user: UserModel = UserModel(
        email: "bipul@example.com",
        name: "Bipul",
        role: .teacher
    )
    let sampleClasses: [ClassModel] = [
        .init(id: UUID(), name: "Math 101", teacherID: UUID(),teacherName: "Miss Tee", schedule: Schedule(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
            timeZone: TimeZone.current,
            classSchedule: ClassSchedule(days: [
                "Monday": ["08:30-09:30", "14:00-15:00"],
                "Tuesday": ["10:00-11:00"],
                "Friday": ["13:00-14:00"]
            ])
        ), attendancePercentage: 85),
        .init(id: UUID(), name: "Physics 202", teacherID: UUID(),teacherName: "Miss TwoTee", schedule: Schedule(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
            timeZone: TimeZone.current,
            classSchedule: ClassSchedule(days: [
                "Monday": ["08:30-09:30", "14:00-15:00"],
                "Tuesday": ["10:00-11:00"],
                "Friday": ["13:00-14:00"]
            ])
        ), attendancePercentage: 92),
        .init(id: UUID(), name: "Biology 303", teacherID: UUID(), teacherName: "Mr ThreeTee", schedule: Schedule(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
            timeZone: TimeZone.current,
            classSchedule: ClassSchedule(days: [
                "Monday": ["08:30-09:30", "14:00-15:00"],
                "Tuesday": ["10:00-11:00"],
                "Friday": ["13:00-14:00"]
            ])
        ),  attendancePercentage: 78)
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(user: user, classes: sampleClasses)
                .tabItem {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2")
                }
                .tag(0)

            BLEScanView()
                .tabItem {
                    Label("Attendance", systemImage: "calendar")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tabViewStyle(DefaultTabViewStyle()) // ✅ For iPad bottom tab bar
    }
}

