//
//  EnrollInAClassView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI

struct EnrollInAClassView: View {
    let availableClasses: [ClassModel]
       let enrolledClassIDs: Set<UUID>
       let onEnroll: (ClassModel) -> Void

       var body: some View {
           ScrollView {
               VStack(alignment: .leading, spacing: 16) {
                   Text("Enroll in a Class")
                       .font(.title2)
                       .fontWeight(.semibold)
                       .foregroundColor(.primaryColorDark)
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .padding(.top)

                   ForEach(availableClasses) { classModel in
                       let alreadyEnrolled = enrolledClassIDs.contains(classModel.id)

                       VStack(alignment: .leading, spacing: 6) {
                           Text(classModel.name)
                               .font(.headline)
                               .foregroundColor(.primaryColorDarker)

                           let scheduleSummary = getScheduleSummary(from: classModel.schedule.classSchedule)
                           if !scheduleSummary.isEmpty {
                               Text(scheduleSummary)
                                   .font(.caption)
                                   .foregroundColor(.gray)
                           }

                           Button(action: {
                               if !alreadyEnrolled {
                                   onEnroll(classModel)
                               }
                           }) {
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
           .navigationTitle("Enroll in a Class")
           .navigationBarTitleDisplayMode(.inline)
       }
}

#Preview {
//    EnrollInAClassView()
}
