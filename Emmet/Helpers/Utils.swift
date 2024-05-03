import Foundation
import SwiftUI
import CoreLocation

struct EventHelper {
    static func eventIcon(eventType: String) -> String {
        switch eventType {
        case "Activity":
            return "figure.play"
        case "Food":
            return "fork.knife"
        case "Stay":
            return "bed.double.fill"
        case "Travel":
            return "figure.wave"
        case "Other":
            return "aqi.medium"
        default:
            return "questionmark"
        }
    }

    static func eventColor(eventType: String) -> Color {
        switch eventType {
        case "Activity":
            return Color.green
        case "Food":
            return Color.yellow
        case "Stay":
            return Color.red
        case "Travel":
            return Color.purple
        case "Other":
            return Color.gray
        default:
            return Color.blue
        }
    }

    static func eventAltColor(eventType: String) -> Color {
        switch eventType {
        case "Activity":
            return Color.white
        case "Food":
            return Color.black
        case "Stay":
            return Color.white
        case "Travel":
            return Color.white
        case "Other":
            return Color.white
        default:
            return Color.white
        }
    }
}

struct EventDateHelper {
    static func isEventDatePassed(eventDate: Date?) -> Bool {
        guard let eventDate = eventDate else { return false }
        return eventDate < Date()
    }

    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
    
    static func formatDateShort(_ date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = Int(dayFormatter.string(from: date))!

        let daySuffix: String
        switch day {
        case 1, 21, 31: daySuffix = "st"
        case 2, 22: daySuffix = "nd"
        case 3, 23: daySuffix = "rd"
        default: daySuffix = "th"
        }

        return "\(day)\(daySuffix)"
    }

    static func formatDateMedium(_ date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = Int(dayFormatter.string(from: date))!

        let daySuffix: String
        switch day {
        case 1, 21, 31: daySuffix = "st"
        case 2, 22: daySuffix = "nd"
        case 3, 23: daySuffix = "rd"
        default: daySuffix = "th"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "d'\(daySuffix)' MMM' @ 'h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }
    
    static func formatDateLarge(_ date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let day = Int(dayFormatter.string(from: date))!

        let daySuffix: String
        switch day {
        case 1, 21, 31: daySuffix = "st"
        case 2, 22: daySuffix = "nd"
        case 3, 23: daySuffix = "rd"
        default: daySuffix = "th"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d'\(daySuffix)' MMMM"
        return formatter.string(from: date)
    }
    
    static func convertToLocalTime(date: Date, timeZoneIdentifier: String) -> Date {
        let timeZone = TimeZone(identifier: timeZoneIdentifier) ?? TimeZone.current
        let delta = TimeInterval(timeZone.secondsFromGMT(for: date) - TimeZone.current.secondsFromGMT(for: date))
        return date.addingTimeInterval(delta)
    }
}

struct AdviceLevelHelper {
    static func adviceLevelColor(for adviceLevel: String) -> Color {
        switch adviceLevel {
        case "Exercise normal safety precautions":
            return Color.green
        case "Exercise a high degree of caution":
            return Color.yellow
        case "Do not travel":
            return Color.red
        default:
            return Color(UIColor.systemGroupedBackground)
        }
    }
    
    static func adviceLevelAltColor(for adviceLevel: String) -> Color {
        switch adviceLevel {
        case "Exercise normal safety precautions":
            return Color.white
        case "Exercise a high degree of caution":
            return Color.black
        case "Do not travel":
            return Color.white
        default:
            return Color.black
        }
    }
}

struct AddressHelper {
    static func formattedAddress(for place: CLPlacemark) -> String {
        var addressParts = [String]()
        
        if let subThoroughfare = place.subThoroughfare, let thoroughfare = place.thoroughfare {
            addressParts.append("\(subThoroughfare) \(thoroughfare)")
        } else if let thoroughfare = place.thoroughfare {
            addressParts.append(thoroughfare)
        }
        
        let localityAreaCode = [place.locality, place.administrativeArea, place.postalCode].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        if !localityAreaCode.isEmpty {
            addressParts.append(localityAreaCode)
        }
        
        if let country = place.country {
            addressParts.append(country)
        }
        
        return addressParts.joined(separator: ", ")
    }

    static func formattedAddress(subThoroughfare: String?, thoroughfare: String?, locality: String?, administrativeArea: String?, postalCode: String?, country: String?) -> String {
        var parts: [String] = []

        if let subThoroughfare = subThoroughfare, !subThoroughfare.isEmpty {
            parts.append(subThoroughfare)
        }

        if let thoroughfare = thoroughfare, !thoroughfare.isEmpty {
            if !parts.isEmpty {
                parts[parts.count - 1].append(" \(thoroughfare)")
            } else {
                parts.append(thoroughfare)
            }
        }

        if let locality = locality, !locality.isEmpty {
            parts.append(locality)
        }

        var adminPostalCombo = ""
        if let administrativeArea = administrativeArea, !administrativeArea.isEmpty {
            adminPostalCombo = administrativeArea
        }

        if let postalCode = postalCode, !postalCode.isEmpty {
            if !adminPostalCombo.isEmpty {
                adminPostalCombo.append(" \(postalCode)")
            } else {
                adminPostalCombo = postalCode
            }
        }

        if !adminPostalCombo.isEmpty {
            parts.append(adminPostalCombo)
        }

        if let country = country, !country.isEmpty {
            parts.append(country)
        }

        return parts.joined(separator: ", ")
    }
    
    static func truncate(_ str: String, toLength maxLength: Int) -> String {
        if str.count > maxLength {
            let trimmedIndex = str.index(str.startIndex, offsetBy: maxLength - 3)
            return String(str[..<trimmedIndex]) + "..."
        } else {
            return str
        }
    }
}
