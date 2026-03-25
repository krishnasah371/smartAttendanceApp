//
//  StudentClassStatsView.swift
//  SmartAttendanceTracker
//
//  Created by Krishna Sah kanu on 3/25/26.
//
import SwiftUI

struct StudentClassStatsView: View {
    let classModel: ClassModel
    let updateClassStatus: () -> Void
    
    @Environment(\.dismiss) var dismiss
    // Holds the fetched attendance data
    @State private var attendanceRecords: [MyAttendanceRecord] = []
    @State private var percentage: Int = 0
    @State private var isLoading = true
    @State private var showUnenrollConfirmation = false
    @State private var unenrollError: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header — class name and overall percentage
                VStack(alignment: .leading, spacing: 8) {
                    Text(classModel.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryColorDark)
                    
                    Text("Taught by: \(classModel.teacherName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Big attendance percentage display
                    HStack {
                        Text("Overall Attendance:")
                            .font(.headline)
                        Spacer()
                        Text("\(percentage)%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(percentage >= 75 ? .green : .red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(12)
                }
                
                Divider()
                
                // Attendance history list
                Text("📅 Attendance History")
                    .font(.headline)
                
                if isLoading {
                    // Show loading spinner while fetching
                    HStack {
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    }
                    .padding()
                } else if attendanceRecords.isEmpty {
                    Text("No attendance records yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Each attendance record as a row
                    ForEach(attendanceRecords, id: \.id) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formatDate(record.timestamp))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(record.isManual ? "Manual entry" : "Auto-detected via beacon")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Present/Absent badge
                            Text(record.status == "present" ? "✅ Present" : "❌ Absent")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(record.status == "present" ? .green : .red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(record.status == "present" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                // Unenroll button
                Button(action: {
                    showUnenrollConfirmation = true
                }) {
                    Text("Unenroll from Class")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
            }
            .padding()
        }
        // Confirmation alert before unenrolling
            .navigationTitle("My Attendance")
                    .navigationBarTitleDisplayMode(.inline)
                    .alert("Unenroll from \(classModel.name)?", isPresented: $showUnenrollConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Unenroll", role: .destructive) {
                            Task {
                                await unenrollFromClass()
                            }
                        }
                    } message: {
                        Text("You will lose your attendance history for this class.")
                    }
                    .task {
                        await loadAttendance()
                    }
    }
    
    // Fetches the student's attendance for this class from backend
    private func loadAttendance() async {
        do {
            let data = try await AttendenceService.shared.getMyAttendance(classId: classModel.id)
            await MainActor.run {
                self.attendanceRecords = data.attendance ?? []
                self.percentage = data.percentage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("❌ Failed to load attendance: \(error)")
        }
    }
    
    // Converts ISO timestamp like "2026-03-21T23:06:29Z" to "Mar 21, 2026"
    private func formatDate(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            let display = DateFormatter()
            display.dateStyle = .medium
            return display.string(from: date)
        }
        return timestamp
    }
    
    //unenroll from the class

        private func unenrollFromClass() async {
            do {
                _ = try await ClassService.shared.unenrollFromClass(classId: classModel.id)
                // Navigate back after unenrolling
                await MainActor.run {
                    // This will pop the view since the class no longer exists
                    print("✅ Unenrolled successfully")
                    updateClassStatus() //refresh dashboard
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    unenrollError = error.localizedDescription
                }
                print("❌ Unenroll failed: \(error)")
            }
        }

}
