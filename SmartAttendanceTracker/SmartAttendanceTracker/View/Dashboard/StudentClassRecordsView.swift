//
//  StudentClassRecordsView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/9/25.
//


import SwiftUI

struct StudentClassRecordsView: View {
    let viewModel: StudentClassRecordViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting
            VStack(alignment: .leading, spacing: 4) {
                Text("👋 Hello, \(viewModel.student.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("📘 Class: \(viewModel.className)")
                    .font(.headline)
                    .foregroundColor(.primaryColorDarker)
            }

            Divider()

            Text("📅 Your Attendance Record")
                .font(.headline)
                .padding(.bottom, 4)

            if viewModel.attendanceRecords.isEmpty {
                Text("No attendance records available yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.attendanceRecords.keys.sorted(by: >), id: \.self) { date in
                    let presentList = viewModel.attendanceRecords[date] ?? []
                    let wasPresent = presentList.contains(viewModel.student.email)

                    HStack {
                        Text(formatted(date))
                            .font(.subheadline)
                        Spacer()
                        Text(wasPresent ? "✅ Present" : "❌ Absent")
                            .font(.subheadline)
                            .foregroundColor(wasPresent ? .green : .red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(wasPresent ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }

            Spacer()
        }
        .padding()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
