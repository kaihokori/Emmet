import Foundation
import SwiftUI

struct EventRowView: View {
    let eventInfo: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AddressHelper.truncate(eventInfo.name ?? "Unknown Name", toLength: 40))
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundStyle(EventHelper.eventAltColor(eventType: eventInfo.type ?? ""))

            HStack {
                if let eventDate = eventInfo.date, let timeZoneIdentifier = eventInfo.timezone {
                    let localEventDate = EventDateHelper.convertToLocalTime(date: eventDate, timeZoneIdentifier: timeZoneIdentifier)
                    
                    if isDifferentTimezone(timeZoneIdentifier: timeZoneIdentifier) {
                        let deviceTime = EventDateHelper.formatTime(eventDate)
                        let localTime = EventDateHelper.formatTime(localEventDate)
                        let dateLabel = "\(localTime) (\(deviceTime) on \(EventDateHelper.formatDateShort(eventDate)))"
                        Label(dateLabel, systemImage: "clock")
                            .font(.system(size: 14))
                            .foregroundStyle(EventHelper.eventAltColor(eventType: eventInfo.type ?? ""))
                    } else {
                        Label(EventDateHelper.formatTime(localEventDate), systemImage: "clock")
                            .font(.system(size: 14))
                            .foregroundStyle(EventHelper.eventAltColor(eventType: eventInfo.type ?? ""))
                    }
                } else {
                    Text("Time Unknown")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(EventHelper.eventColor(eventType: eventInfo.type ?? ""), in: RoundedRectangle(cornerRadius: 15))
        .strikethrough(EventDateHelper.isEventDatePassed(eventDate: eventInfo.date), pattern: .solid, color: EventHelper.eventAltColor(eventType: eventInfo.type ?? ""))
    }

    private func isDifferentTimezone(timeZoneIdentifier: String) -> Bool {
        return TimeZone.current.identifier != timeZoneIdentifier
    }
}

struct TimeLabel: View {
    var dateLabel: String
    var eventType: String

    var body: some View {
        Label(dateLabel, systemImage: "clock")
            .font(.system(size: 14))
            .foregroundStyle(EventHelper.eventAltColor(eventType: eventType))
    }
}
