//
//  BLE_MainView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI

struct BLEMainView: View {
    let user: UserModel
    let enrolledClasses: [ClassModel]
    
    func splitClassesBySessionStatus(classes: [ClassModel]) -> (inSession: [ClassModel], other: [ClassModel]) {
        var inSession: [ClassModel] = []
        var other: [ClassModel] = []

        for classModel in classes {
            if isClassInSession(classModel: classModel) {
                inSession.append(classModel)
            } else {
                other.append(classModel)
            }
        }

        return (inSession, other)
    }
    func isClassInSession(classModel: ClassModel) -> Bool {
        let schedule = classModel.schedule
        let timeZone = schedule.timeZone
        let now = Date()

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.timeZone = timeZone

        let today = formatter.string(from: now)
        guard let todaySlots = schedule.classSchedule.days[today] else {
            return false
        }

        for slot in todaySlots {
            let parts = slot.components(separatedBy: "-")
            guard parts.count == 2 else { continue }

            let startTimeStr = parts[0]
            let endTimeStr = parts[1]

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.timeZone = timeZone

            if
                let startTime = timeFormatter.date(from: startTimeStr),
                let endTime = timeFormatter.date(from: endTimeStr)
            {
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: now)

                var startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                var endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

                startComponents.year = dateComponents.year
                startComponents.month = dateComponents.month
                startComponents.day = dateComponents.day

                endComponents.year = dateComponents.year
                endComponents.month = dateComponents.month
                endComponents.day = dateComponents.day

                if
                    let start = calendar.date(from: startComponents),
                    let end = calendar.date(from: endComponents),
                    now >= start && now <= end
                {
                    return true
                }
            }
        }

        return false
    }

    

    
    var body: some View {
        let (inSession, other) = splitClassesBySessionStatus(classes: enrolledClasses)
        Group {
            if user.role == .teacher {
                BLE_TeacherView(
                    user: user,
                    inSessionClasses: inSession,
                    otherClasses: other
                )
            } else {
                BLE_StudentView(
                    user: user,
                    inSessionClasses: inSession,
                    otherClasses: other,
                    allClasses: enrolledClasses // CHANGE THIS
                )
            }
        }
    }
}

//#Preview {
//    BLE_MainView()
//}
