//
//  BLE_ClassActionCardView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//
import SwiftUI

struct BLE_ClassActionCardView: View {
    let classInfo: ClassModel
    let isOngoing: Bool
    let userRole: UserRole
    let onPrimaryTap: () -> Void
    let onSecondaryTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(classInfo.name)
                .font(.headline)
                .foregroundColor(.primaryColorDarker)

            let scheduleSummary = getScheduleSummary(from: classInfo.schedule)
            if !scheduleSummary.isEmpty {
                Text("Schedule: \(scheduleSummary)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            HStack {
                Button(action: onPrimaryTap) {
                    Text(userRole == .teacher ? "Start Attendance" : "Attend Class")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.primaryColor)
                        .cornerRadius(8)
                }

                if userRole == .teacher, let onSecondaryTap = onSecondaryTap {
                    Spacer()

                    Button(action: onSecondaryTap) {
                        Text("View Attendance")
                            .font(.subheadline)
                            .foregroundColor(.primaryColorDark)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.07))
        .cornerRadius(12)
    }
}
