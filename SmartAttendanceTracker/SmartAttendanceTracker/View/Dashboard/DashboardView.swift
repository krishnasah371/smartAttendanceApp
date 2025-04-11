import SwiftUI


struct ClassInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let attendancePercentage: Int
}

struct DashboardView: View {
    let user: UserModel
    let classes: [ClassModel]
    @State private var selectedClass: ClassModel?
    @State private var showRegisterOrJoinClassPage = false
    
    var totalAttendance: Int {
        classes.map(\.attendancePercentage).reduce(0, +) / max(1, classes.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                     
                    // Welcome
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.primaryColorDark)
                        
                        Text("Welcome, \(user.name) 👋")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                        
                    Text("📊 Total Attendance So Far: \(totalAttendance)%")
                        .font(.headline)
                        .foregroundColor(.primaryColorDarker)
                    
                    // Button
                    Button {
                        showRegisterOrJoinClassPage = true
                    } label: {
                        Text(user.role == .teacher ? "Register a New Class" : "Enroll in a New Class")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    TodayScheduleView(classes: classes)
                    // Your Classes
                    
                    ForEach(classes) { classInfo in
                        ClassesSummaryView(
                                classInfo: classInfo,
                                userRole: user.role,
                                onTap: {
                                    selectedClass = classInfo
                                }
                            )
                    }

                    // Schedule Today
                    
                    Spacer(minLength: 40)
                }
                .padding()
                .navigationDestination(item: $selectedClass) { classModel in
                    if user.role == .teacher {
                        TeacherClassStatsView(classModel: classModel)
                    } else {
                        StudentClassStatsView(classModel: classModel)
                    }
                }
                .navigationDestination(isPresented: $showRegisterOrJoinClassPage) {
                    if user.role == .teacher {
                        RegisterNewClassView( onRegister: {
                            // TODO: Handle Register
                            showRegisterOrJoinClassPage = false
                        })
                        
                    } else {
                        EnrollInAClassView(availableClasses: classes, enrolledClassIDs:Set(classes.map(\.id)), onEnroll:  { selectedClass in
                            // TODO: handle enrollment
                            showRegisterOrJoinClassPage = false
                        })
                    }
                }
            }
            .background(Color.white)
            
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

struct TeacherClassStatsView: View {
    let classModel: ClassModel

    var body: some View {
        Text("Teacher View for \(classModel.name)")
    }
}

struct StudentClassStatsView: View {
    let classModel: ClassModel

    var body: some View {
        Text("Student View for \(classModel.name)")
    }
}
