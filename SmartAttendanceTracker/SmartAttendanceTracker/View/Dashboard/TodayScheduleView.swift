//
//  TodayScheduleView.swift
//  SmartAttendanceTracker
//
//  Created by Bipul Aryal on 4/8/25.
//

import SwiftUI

struct TodayScheduleItem: Hashable {
    let className: String
    let time: String
}
struct TodayScheduleView: View {
    let classes: [ClassModel]
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Heading: "Your Tuesday Schedule"
            let todayName = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
            let weekday = todayName.components(separatedBy: ",").first ?? "Today"

            Text("Your \(weekday)'s Schedule")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryColorDark)
                .frame(maxWidth: .infinity, alignment: .center)

            // Collect all class-time pairs for today
            let todaysSchedule: [TodayScheduleItem] = classes.flatMap { classModel in
                let times = getTodaySchedule(from: classModel.schedule, in: classModel.timeZone)
                return times.map { TodayScheduleItem(className: classModel.name, time: $0) }
            }

            if todaysSchedule.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "party.popper.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.primaryAccent)

                    Text("Hurrah! No classes today.")
                        .font(.headline)
                        .foregroundColor(.primaryColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondaryBackground)
                .cornerRadius(14)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(todaysSchedule, id: \.self) { entry in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(entry.className)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primaryColorDark)
                                            .lineLimit(1)

                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.primaryColor)
                                            Text(entry.time)
                                                .font(.subheadline)
                                                .foregroundColor(.primaryColorDarker)
                                        }
                                    }
                                    .padding()
                                    .frame(width: 200, alignment: .leading)
                                    .background(Color.gray.opacity(0.07))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

    }
}
//
//#Preview {
//    TodayScheduleView()
//}
