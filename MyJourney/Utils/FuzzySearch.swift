//
//  FuzzySearch.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/27/25.
//

import Foundation
import SwiftUI

func fuzzyMatch(_ text: String, query: String) -> Bool {
    let lowerText = text.lowercased()
    let lowerQuery = query.lowercased()
    guard !lowerQuery.isEmpty else {
        return true
    }
    
    var i = lowerText.startIndex
    var j = lowerQuery.startIndex
    
    while i < lowerText.endIndex && j < lowerQuery.endIndex {
        if lowerText[i] == lowerQuery[j] {
            j = lowerQuery.index(after: j)
        }
        i = lowerText.index(after: i)
    }
    
    return j == lowerQuery.endIndex
}

func fuzzyMatchIndices(in text: String, query: String) -> Set<Int> {
    let lowerText = text.lowercased()
    let lowerQuery = query.lowercased()
    guard !lowerQuery.isEmpty else {
        return []
    }
    
    var matchedIndices = Set<Int>()
    
    var textIndex = lowerText.startIndex
    var queryIndex = lowerQuery.startIndex
    
    var currentTextPos = 0
    while textIndex < lowerText.endIndex && queryIndex < lowerQuery.endIndex {
        if lowerText[textIndex] == lowerQuery[queryIndex] {
            matchedIndices.insert(currentTextPos)
            queryIndex = lowerQuery.index(after: queryIndex)
        }
        textIndex = lowerText.index(after: textIndex)
        currentTextPos += 1
    }
    
    return matchedIndices
}

func highlightFuzzyMatches(text: String, matchedIndices: Set<Int>) -> AttributedString {
    if matchedIndices.isEmpty {
        return AttributedString(text)
    }
    
    var attributed = AttributedString(text)
    
    for i in matchedIndices {
        if i < text.count {
            let nsRange = NSRange(location: i, length: 1)
            if let range = Range(nsRange, in: attributed) {
                attributed[range].backgroundColor = .yellow
            }
        }
    }
    
    return attributed
}

func findSubstrings(in text: String, query: String) -> [Range<String.Index>] {
    guard !query.isEmpty else { return [] }
    
    let lowerText = text.lowercased()
    let lowerQuery = query.lowercased()
    
    var ranges: [Range<String.Index>] = []
    var searchStartIndex = lowerText.startIndex
    
    while searchStartIndex < lowerText.endIndex,
          let range = lowerText.range(of: lowerQuery,
                                      options: [],
                                      range: searchStartIndex..<lowerText.endIndex)
    {
        // Convert the found `range` in the lowerText
        // to the equivalent range in the original `text`.
        let lowerBoundOffset = lowerText.distance(from: lowerText.startIndex, to: range.lowerBound)
        let upperBoundOffset = lowerText.distance(from: lowerText.startIndex, to: range.upperBound)
        
        let realLower = text.index(text.startIndex, offsetBy: lowerBoundOffset)
        let realUpper = text.index(text.startIndex, offsetBy: upperBoundOffset)
        
        let realRange = realLower..<realUpper
        ranges.append(realRange)
        
        // Move `searchStartIndex` to `range.upperBound` in lowerText,
        // so we can find subsequent matches.
        searchStartIndex = range.upperBound
    }
    
    return ranges
}

func highlightSubstringMatches(text: String, matches: [Range<String.Index>]) -> AttributedString {
    // Convert `text` to SwiftUI’s `AttributedString`
    var attributed = AttributedString(text)
    
    // Convert each substring Range<String.Index> into an NSRange for AttributedString
    for range in matches {
        // NSRange from text’s startIndex
        let startOffset = text.distance(from: text.startIndex, to: range.lowerBound)
        let length = text.distance(from: range.lowerBound, to: range.upperBound)
        let nsRange = NSRange(location: startOffset, length: length)
        
        // Convert that to Range in AttributedString
        if let attributedRange = Range(nsRange, in: attributed) {
            // Set highlight background
            attributed[attributedRange].backgroundColor = .yellow
            // Optionally set foreground color
            // attributed[attributedRange].foregroundColor = .black
        }
    }
    
    return attributed
}
