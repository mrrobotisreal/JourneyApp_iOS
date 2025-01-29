//
//  ViewEntryViewModel.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/28/25.
//

import SwiftUI
import Combine

class ViewEntryViewModel: ObservableObject {
    @Published var entry: EntryListItem?
}
