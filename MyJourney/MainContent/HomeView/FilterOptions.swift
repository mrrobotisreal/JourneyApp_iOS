//
//  FilterOptions.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/28/25.
//

import Foundation

enum SortRule: String, CaseIterable, Identifiable {
    case newest = "Newest"
    case oldest = "Oldest"
    
    var id: String { self.rawValue }
}

enum Timeframe: String, CaseIterable, Identifiable {
    case all = "All time"
    case past30Days = "Past 30 days"
    case past3Months = "Past 3 months"
    case past6Months = "Past 6 months"
    case pastYear = "Past year"
    case customRange = "Select a timeframe"
    
    var id: String { self.rawValue }
}

//typealias Location = String
//typealias Tag = String

struct FilterOptions {
    var selectedLocations: Set<LocationData> = []
    var selectedTags: Set<TagData> = []
    
    var sortRule: SortRule = .newest
    
    // If user picks customRange, they can specify a date "from" and "to"
    var timeframe: Timeframe = .all
    var fromDate: Date? = nil
    var toDate: Date? = nil
}
