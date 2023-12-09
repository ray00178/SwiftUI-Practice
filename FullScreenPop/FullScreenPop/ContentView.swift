//
//  ContentView.swift
//  FullScreenPop
//
//  Created by Ray on 2023/12/9.
//

import SwiftUI

struct ContentView: View {
  @State private var isEnable: Bool = false

  var body: some View {
    FullSwipeNavigationStack {
      List {
        Section("Sample Header") {
          NavigationLink("Full Swipe View") {
            List {
              Toggle("Enable Full Swipe Pop", isOn: $isEnable)
                .enableFullSwipePop(isEnable)
            }
            .navigationTitle("Full Swipe View")
          }

          NavigationLink("Leading Swipe View") {
            Text("")
              .navigationTitle("Leading Swipe View")
          }
        }
      }
      .navigationTitle("Full Swipe Pop")
    }
  }
}

#Preview {
  ContentView()
}
