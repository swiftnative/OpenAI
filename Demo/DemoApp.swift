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
        #warning("Provide you api_key for use")
        URLRequest.Config.OpenAI.apiKey = "<API_KEY>"
      }
    }
  }
}
