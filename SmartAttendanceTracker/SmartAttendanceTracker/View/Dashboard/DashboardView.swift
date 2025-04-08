import SwiftUI

enum UserRole: String {
    case student
    case teacher
}

struct ClassInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let attendancePercentage: Int
}

struct DashboardView: View {
    @State private var showCheckInPopup = false
    @State private var navigateToClassRegistration = false
    @State private var selectedClass: ClassInfo?
    
    let userName = "Bipul"
    let userRole: UserRole = .teacher // Change to `.teacher` to test teacher mode

    let enrolledClasses: [ClassInfo] = [
        ClassInfo(name: "Math 101", attendancePercentage: 85),
        ClassInfo(name: "Physics 202", attendancePercentage: 92),
        ClassInfo(name: "Biology 303", attendancePercentage: 78)
    ]
    
    var averageAttendance: Int {
        guard !enrolledClasses.isEmpty else { return 0 }
        let total = enrolledClasses.reduce(0) { $0 + $1.attendancePercentage }
        return total / enrolledClasses.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Welcome and image
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.primaryColorDark)

                        Text("Welcome, \(userName) 👋")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    // Average Attendance
                    Text("📊 Total Attendance So Far: \(averageAttendance)%")
                        .font(.headline)
                        .foregroundColor(.primaryColorDarker)

                    // Register/Enroll Button
                    Button(action: {
                        navigateToClassRegistration = true
                    }) {
                        Text(userRole == .teacher ? "Register a New Class" : "Enroll in a New Class")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // List of classes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Classes")
                            .font(.headline)
                            .foregroundColor(.primaryColorDark)
                        
                        ForEach(enrolledClasses) { classInfo in
                            Button(action: {
                                selectedClass = classInfo
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(classInfo.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Attendance: \(classInfo.attendancePercentage)%")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }

                    Spacer(minLength: 40)

                    // Optional check-in button
                    Button(action: {
                        showCheckInPopup = true
                    }) {
                        Text("Check in")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert("✅ Attendance Recorded", isPresented: $showCheckInPopup) {
                        Button("OK", role: .cancel) {}
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToClassRegistration) {
                if userRole == .teacher {
                    ClassRegistrationView()
                } else {
                    ClassView()
                }
            }
            .navigationDestination(item: $selectedClass) { classInfo in
                if userRole == .teacher {
                    TeacherClassDetailsView(classInfo: classInfo)
                } else {
                    StudentClassDetailsView(classInfo: classInfo)
                }
            }
            .background(Color.white)
            .preferredColorScheme(.light)
        }
    }
}

struct ClassRegistrationView: View {
    var body: some View {
        Text("Class Registration View (Teacher)")
    }
}

struct ClassView: View {
    var body: some View {
        Text("Enroll in Class View (Student)")
    }
}

struct StudentClassDetailsView: View {
    let classInfo: ClassInfo

    var body: some View {
        Text("Student Details for \(classInfo.name)")
    }
}

struct TeacherClassDetailsView: View {
    let classInfo: ClassInfo

    var body: some View {
        Text("Teacher Details for \(classInfo.name)")
    }
}


// Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
