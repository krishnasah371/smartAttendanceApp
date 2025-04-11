//
//  ClassModel.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//
import Foundation

struct AttendanceRecord {
    let classId: UUID
    let date: Date
    var presentStudentIds: Set<UUID>
}

struct ClassModel: Identifiable, Hashable, Codable {
    let id: Int
    let name: String
    let teacherID: Int
    let teacherName: String
    let teacherEmail: String?
    let schedule: ClassSchedule
    let timeZone: TimeZone
    let startDate: String
    let endDate: String
    var attendancePercentage: Int = 0
    var isBeaconAttached: Bool = false
    var beaconId: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case teacherID = "teacher_id"
        case teacherName = "teacher_name"
        case teacherEmail = "teacher_email"
        case schedule
        case timeZone = "timezone"
        case startDate = "start_date"
        case endDate = "end_date"
        case beaconId = "ble_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        teacherID = try container.decode(Int.self, forKey: .teacherID)
        teacherName = try container.decode(String.self, forKey: .teacherName)
        teacherEmail = try? container.decode(String.self, forKey: .teacherEmail)

        let scheduleString = try container.decode(String.self, forKey: .schedule)
        let scheduleData = Data(scheduleString.utf8)
        schedule = try JSONDecoder().decode(ClassSchedule.self, from: scheduleData)

        timeZone =  try {
            let timeZoneIdentifier = try container.decode(String.self, forKey: .timeZone)
            return TimeZone(identifier: timeZoneIdentifier) ?? .current
        }()
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        beaconId = try? container.decode(String.self, forKey: .beaconId)
    }
}


struct AnyCodable: Codable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let str = try? container.decode(String.self) {
            value = str
        } else if let arr = try? container.decode([String].self) {
            value = arr
        } else {
            throw DecodingError.typeMismatch(
                AnyCodable.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let str = value as? String {
            try container.encode(str)
        } else if let arr = value as? [String] {
            try container.encode(arr)
        } else {
            throw EncodingError.invalidValue(
                value,
                .init(codingPath: encoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }
}
extension AnyCodable: Equatable {
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case let (l as String, r as String):
            return l == r
        case let (l as [String], r as [String]):
            return l == r
        default:
            return false
        }
    }
}

extension AnyCodable: Hashable {
    func hash(into hasher: inout Hasher) {
        if let value = value as? String {
            hasher.combine(value)
        } else if let value = value as? [String] {
            hasher.combine(value)
        }
    }
}





struct ClassSchedule: Codable, Hashable {
    var days: [String: [String]]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // It can either be: {"Monday": ["10:00", "12:00"]}
        // or: {"friday": "2pm-3pm"} — convert to list
        let raw = try container.decode([String: AnyCodable].self)

        var normalized: [String: [String]] = [:]
        for (key, value) in raw {
            switch value.value {
            case let str as String:
                normalized[key.capitalized] = [str]
            case let arr as [String]:
                normalized[key.capitalized] = arr
            default:
                break
            }
        }
        self.days = normalized
    }
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


struct ClassesResponse: Codable {
    let classes: [ClassModel]?
}
