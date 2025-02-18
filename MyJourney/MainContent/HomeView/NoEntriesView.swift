//
//  NoEntriesView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/15/25.
//

import SwiftUI

struct NoEntriesView: View {
    var navigateToNewEntry: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("You haven't created any entries yet... Click the button below or swipe up from the bottom and open the menu to create a new entry!")
                .font(.custom("Nexa Script Light", size: 18))
                .padding()
            
            Button(action: {
                navigateToNewEntry()
            }) {
                Image(systemName: "lightbulb.max.fill")
                    .foregroundColor(.white)
                Text("Create A New Entry")
                    .font(.custom("Nexa Script Heavy", size: 18))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .cornerRadius(12)
            .background(Color(red: 0.039, green: 0.549, blue: 0.749))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(red: 0.533, green: 0.875, blue: 0.949))
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color(red: 0.008, green: 0.157, blue: 0.251), lineWidth: 2)
        )
    }
}

//#Preview {
//    NoEntriesView()
//}
