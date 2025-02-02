//
//  ExtractUniqueLocationsAndTags.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/30/25.
//

import Foundation

func getUniqueLocations(from entries: [EntryListItem]) -> [LocationData] {
    let uniqueLocations = Set(entries
        .flatMap { $0.locations }
    )
    return Array(uniqueLocations)
}

func getUniqueTags(from entries: [EntryListItem]) -> [TagData] {
    let uniqueTags = Set(entries
        .flatMap { $0.tags }
    )
    return Array(uniqueTags)
}
