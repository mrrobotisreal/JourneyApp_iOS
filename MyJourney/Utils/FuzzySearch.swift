//
//  FuzzySearch.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/27/25.
//

import Foundation
//import SwiftUI

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

//func highlightMatch(_ text: String, query: String) -> Text {
//    guard let range = text.range(of: query, options: .caseInsensitive) else {
//        return Text(text)
//    }
//    let prefix = text[text.startIndex..<range.lowerBound]
//    let match = text[range]
//    let suffix = text[range.upperBound..<text.endIndex]
//
//    return Text(prefix) +
//           Text(match).background(Color.yellow) +
//           Text(suffix)
//}
