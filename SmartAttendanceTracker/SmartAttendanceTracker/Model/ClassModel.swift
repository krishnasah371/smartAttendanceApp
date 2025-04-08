//
//  ClassModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//
import Foundation

struct ClassModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let teacherID: UUID
    let teacherName: String
    let schedule: Schedule
    var attendancePercentage: Int
}

struct Schedule: Codable, Hashable {
    let startDate: Date
    let endDate: Date
    let timeZone: TimeZone
    let classSchedule: ClassSchedule
}

struct ClassSchedule: Codable, Hashable {
    var days: [String: [String]] // e.g., "Monday": ["08:30", "12:30"]
}

func getTodaySchedule(from schedule: ClassSchedule, in timeZone: TimeZone) -> [String] {
    var calendar = Calendar.current
    calendar.timeZone = timeZone

    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.timeZone = timeZone
    
    let today = formatter.string(from: Date())
    return schedule.days[today] ?? []
}

func getNextClassTime(for schedule: ClassSchedule, timeZone: TimeZone) -> String? {
    let todaySlots = getTodaySchedule(from: schedule, in: timeZone)
    
    let now = Date()
    
    // Build a date formatter to parse slot start times
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    timeFormatter.timeZone = timeZone

    var calendar = Calendar.current
    calendar.timeZone = timeZone
    
    for slot in todaySlots {
        let parts = slot.components(separatedBy: "-")
        guard let startTimeStr = parts.first else { continue }

        // Parse "HH:mm" time string into a Date on today's date
        if let slotTime = timeFormatter.date(from: startTimeStr) {
            let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
            var slotComponents = calendar.dateComponents([.hour, .minute], from: slotTime)
            slotComponents.year = nowComponents.year
            slotComponents.month = nowComponents.month
            slotComponents.day = nowComponents.day

            if let slotDate = calendar.date(from: slotComponents), slotDate > now {
                return slot // Return the next future class time like "08:30-09:30"
            }
        }
    }

    return nil
}
