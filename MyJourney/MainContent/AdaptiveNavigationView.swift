//
//  AdaptiveNavigationView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 2/5/25.
//

import SwiftUI

struct AdaptiveNavigationView<Content: View>: View {
    let content: Content
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView(columnVisibility: .constant(.detailOnly)) {
                EmptyView()
            } detail: {
                content.navigationBarHidden(true)
            }
        } else {
            NavigationView {
                content
            }
        }
    }
}

//#Preview {
//    AdaptiveNavigationView()
//}
