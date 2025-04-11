import SwiftUI
import Foundation


import SwiftUI

struct AttendanceViewForDate: View {
    @ObservedObject var viewModel: AttendanceViewModel
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("📅 Attendance")
                .font(.title2)
                .fontWeight(.bold)

            Text("Class ID: \(viewModel.classId)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Date: \(formatted(viewModel.date))")
                .font(.subheadline)

            Divider()

            // Student list
            Text("👨‍🎓 Students")
                .font(.headline)

            ForEach(viewModel.allStudents, id: \.id) { student in
                HStack {
                    VStack(alignment: .leading) {
                        Text(student.name)
                            .fontWeight(.medium)
                        Text(student.email)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { viewModel.presentStudentIds.contains(student.id) },
                        set: { _ in viewModel.toggleAttendance(for: student.id) }
                    ))
                    .labelsHidden()
                }
                .padding(.vertical, 4)
            }

            Spacer()

            // Save button
            Button("Save Attendance") {
                viewModel.save()
                onSave()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryColorDark)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
