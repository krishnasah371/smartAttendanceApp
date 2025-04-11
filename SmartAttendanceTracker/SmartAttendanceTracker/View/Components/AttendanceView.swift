import SwiftUI




struct AttendanceViewForDate: View {
    @StateObject private var viewModel: AttendanceViewModel
    init(classId: Int, date: Date) {
        _viewModel = StateObject(wrappedValue: AttendanceViewModel(classId: classId, date: date))
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            Divider()
            studentsList
            Spacer()
            saveButton
        }
        .padding()
        // Add a nice background (optional):
        .background(Color(UIColor.systemGroupedBackground))
        // If wrapped in a NavigationView:
        .navigationBarTitle("Attendance", displayMode: .inline)
    }
}

extension AttendanceViewForDate {
    
    // Header at the top
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("📅 Attendance")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Class ID: \(viewModel.classId)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Date: \((viewModel.date))")
                .font(.subheadline)
        }
    }
    
    // Students list with toggles
    private var studentsList: some View {
        List {
            Section(header: Text("👨‍🎓 Students").font(.headline)) {
                ForEach($viewModel.studentsInClass, id: \.id) { $student in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(student.name)
                                .fontWeight(.medium)
                            Text(student.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Toggle is On if student.id is in presentStudentIds
                        Toggle("", isOn: Binding<Bool>(
                            get: {
                                viewModel.presentStudentIds.contains(student.id)
                            },
                            set: { _ in
                                viewModel.updateAttendence(for: student.id)
                            }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        // If you prefer a plainer style, use .plain or .grouped
    }
    
    // Save button
    private var saveButton: some View {
        Button(action: {
            viewModel.save()
        }) {
            Text("Save Attendance")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.primaryColorDark) // Replace if needed
                .cornerRadius(10)
        }
    }

    // Helper to format the date
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
