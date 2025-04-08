//
//  ClassesSummaryView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI


struct ClassesSummaryView: View {
    
    let classInfo: ClassModel
        let userRole: UserRole
        let onTap: () -> Void
    func getScheduleSummary(from classSchedule: ClassSchedule) -> String {
        let dayOrder = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayShortNames: [String: String] = [
            "Monday": "Mon", "Tuesday": "Tue", "Wednesday": "Wed",
            "Thursday": "Thu", "Friday": "Fri", "Saturday": "Sat", "Sunday": "Sun"
        ]

        var summaryLines: [String] = []

        for day in dayOrder {
            guard let timeSlots = classSchedule.days[day], !timeSlots.isEmpty else { continue }
            
            let shortDay = dayShortNames[day] ?? day
            let line = "\(shortDay): \(timeSlots.joined(separator: ", "))"
            summaryLines.append(line)
        }

        return summaryLines.joined(separator: "\n")
    }
    
        var body: some View {
            Button(action: onTap) {
                HStack  {
                    VStack(spacing: 10) {
                        Text(classInfo.name)
                            .font(.title3)
                            .foregroundColor(.primaryColor)
                        
                        if userRole == .student {
                            Text("Taught by: \(classInfo.teacherName)")
                                .font(.subheadline)
                                .foregroundColor(.primaryColorDarker)
                        }
                        
                        let scheduleSummary = getScheduleSummary(from: classInfo.schedule.classSchedule)
                        if !scheduleSummary.isEmpty {
                            Text("Schedule: \(scheduleSummary)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    VStack(spacing: 10){
                        Text("Attendance:")
                                .font(.subheadline)
                                .foregroundColor(.primaryColorDarker)
                            
                            Text("\(classInfo.attendancePercentage)%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryColorDarker)
                        
                        if let next = getNextClassTime(
                            for: classInfo.schedule.classSchedule,
                            timeZone: classInfo.schedule.timeZone
                        ) {
                            Text("Next Class: \(next)")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
}
