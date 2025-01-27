//
//  FormatDate.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/25/25.
//

import Foundation

func getDateString() -> String {
    let today = Date.now
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM y"
    
    return formatter.string(from: today)
}

func getTimestampString() -> String {
    return ISO8601DateFormatter().string(from: Date.now)
}

func getTimestampDate(timestampStr: String) -> Date? {
    return ISO8601DateFormatter().date(from: timestampStr)
}

func getWeekdayStr(fromISO isoString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    //    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // TODO: add logic to make this work with fractional and non-fractional time
    guard let date = isoFormatter.date(from: isoString) else {
        return "???"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    
    return formatter.string(from: date)
}

func getFullDateStr(fromISO isoString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    //    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // TODO: add logic to make this work with fractional and non-fractional time
    guard let date = isoFormatter.date(from: isoString) else {
        return "Unknown date"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM y"
    return formatter.string(from: date)
}

func getTimeStr(fromISO isoString: String, includeSpace: Bool = true) -> String {
    let isoFormatter = ISO8601DateFormatter()
//    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // TODO: add logic to make this work with fractional and non-fractional time
    guard let date = isoFormatter.date(from: isoString) else {
        return "??:?? ??"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = includeSpace ? "hh:mm a" : "hh:mma"
    
    return formatter.string(from: date)
}
