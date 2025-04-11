//
//  EnrollInAClassView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI

struct EnrollInAClassView: View {
    @State var availableClasses: [ClassModel]
    @State var isLoading: Bool = true
    @State var enrolledClassIDs: Set<Int>
    var didEnrollInClass: () -> Void

    @State private var fetchError: String?
       var body: some View {
           ScrollView {
               if isLoading {
                   ProgressView("Fetching your classes...")
                       .task {
                           await fetchAllClassesView()
                       }
               } else {
                   VStack(alignment: .leading, spacing: 16) {
                       Text("Enroll in a Class")
                           .font(.title2)
                           .fontWeight(.semibold)
                           .foregroundColor(.primaryColorDark)
                           .frame(maxWidth: .infinity, alignment: .leading)
                           .padding(.top)
                       
                       ForEach($availableClasses, id: \.id) { $classModel in
                           let alreadyEnrolled = enrolledClassIDs.contains(classModel.id)
                           
                           VStack(alignment: .leading, spacing: 6) {
                               Text(classModel.name)
                                   .font(.headline)
                                   .foregroundColor(.primaryColorDarker)
                               
                               let scheduleSummary = getScheduleSummary(from: classModel.schedule)
                               if !scheduleSummary.isEmpty {
                                   Text(scheduleSummary)
                                       .font(.caption)
                                       .foregroundColor(.gray)
                               }
                               
                               Button(action:{
                                   Task {
                                       await enrollInClass(classModel.id)
                                   }
                               }){
                                   Text(alreadyEnrolled ? "Enrolled" : "Enroll")
                                       .font(.subheadline)
                                       .fontWeight(.medium)
                                       .foregroundColor(alreadyEnrolled ? .gray : .white)
                                       .padding()
                                       .frame(maxWidth: .infinity)
                                       .background(alreadyEnrolled ? Color.gray.opacity(0.2) : Color.primaryColor)
                                       .cornerRadius(10)
                               }
                               .disabled(alreadyEnrolled)
                           }
                           .padding()
                           .background(Color.gray.opacity(0.06))
                           .cornerRadius(12)
                       }
                   }
                   .padding()
               }
           }
           .navigationTitle("Enroll in a Class")
           .navigationBarTitleDisplayMode(.inline)
       }
    
    private func fetchAllClassesView() async {
        do {
            let fetched = try await ClassService.shared.fetchAllClasses()
            print(fetched ?? [], "fetched")
            self.availableClasses = fetched ?? []
        } catch let error as NetworkError {
            self.fetchError = error.localizedDescription
            self.availableClasses = []
        } catch {
            self.fetchError = error.localizedDescription
            self.availableClasses = []
        }
        self.isLoading = false
    }
    
    private func enrollInClass(_ classId: Int) async {
//        self.isLoading = true
        do {
            let response = try await ClassService.shared.enrollInAClass(classId:classId)
            if response?.message == "Enrolled in class successfully" {
                enrolledClassIDs.insert(classId)
            }
        } catch let error as NetworkError {
            self.fetchError = error.localizedDescription
        } catch {
            self.fetchError = error.localizedDescription
        }
        didEnrollInClass()
        
//        self.isLoading = false
    }
}

#Preview {
//    EnrollInAClassView()
}
