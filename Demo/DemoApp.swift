//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import OpenAI

@main
struct DemoApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ChartAnalysView()
      }
      .onAppear {
        URLRequest.Config.OpenAI.apiKey = "<API_KEY>"
      }
    }
  }
}
