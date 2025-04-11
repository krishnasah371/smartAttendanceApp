//
//  BLE_TeacherView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI

struct BLE_TeacherView: View {
    let user: UserModel
    let inSessionClasses: [ClassModel]
    let otherClasses: [ClassModel]
    var updateClassStatus: () -> Void

    @State private var isAttendanceViewActive = false


       
    
    @State private var showRegisterPage = false
    var body: some View {
        
        NavigationStack {
            
            let students = [
                UserModel(id: "alice@school.com", email: "alice@school.com", name: "Alice Johnson", role: .student),
                UserModel(id: "bob@school.com", email: "bob@school.com", name: "Bob Smith", role: .student),
                UserModel(id: "charlie@school.com", email: "charlie@school.com", name: "Charlie Singh", role: .student),
                UserModel(id: "dave@school.com", email: "dave@school.com", name: "Dave Lee", role: .student),
                UserModel(id: "eve@school.com", email: "eve@school.com", name: "Eve Carter", role: .student),
                UserModel(id: "fatima@school.com", email: "fatima@school.com", name: "Fatima Khan", role: .student)
            ]


               let presentEmails = [
                   "alice@school.com",
                   "charlie@school.com",
                   "fatima@school.com"
               ]

               let viewModel = AttendanceViewModel(
                   classId: 1, // Class ID is still a UUID (unchanged)
                   date: Date(),
                   allStudents: students,
                   initialPresentIds: presentEmails
               )

            
            ScrollView {
                VStack {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 10)
                        .offset(x: -15)
                    
                    // Pushes content to the top
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(30)
                .ignoresSafeArea()
                VStack(spacing: 24) {
                    // Register Button
                    Button {
                        // navigate to class registration
                        showRegisterPage = true
                        
                    } label: {
                        Text("Register a New Class")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // In Session
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Classes in Session")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                            .padding(.horizontal)
                        
                        if inSessionClasses.isEmpty {
                            Text("None")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(inSessionClasses) { classModel in
                                BLE_ClassActionCardView(
                                    classInfo: classModel,
                                    isOngoing: true,
                                    userRole: .teacher,
                                    onPrimaryTap: {
                                        // Start Attendance
                                    },
                                    onSecondaryTap: {
                                        isAttendanceViewActive = true
                                        print(isAttendanceViewActive)
                                    }
                                )
                                .padding()
                            }
                        }
                    }
                    
                    // Other Classes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Other Classes")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColorDark)
                            .padding(.horizontal)
                        
                        ForEach(otherClasses) { classModel in
                            BLE_ClassActionCardView(
                                classInfo: classModel,
                                isOngoing: false,
                                userRole: .teacher,
                                onPrimaryTap: {
                                    // Start Attendance
                                },
                                onSecondaryTap: {
                                    isAttendanceViewActive = true

                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.white)
            .ignoresSafeArea()
            .navigationDestination(isPresented: $showRegisterPage) {
                RegisterNewClassView(
                ) {
                        //TODO: handle registration
                        showRegisterPage = false
                    updateClassStatus()
                    }
                
            }
            .navigationDestination(isPresented: $isAttendanceViewActive) {
                AttendanceViewForDate(viewModel: viewModel) {
                    // TODO: Save Data
                    isAttendanceViewActive = false
                }
            }
        }
        
    }
}
