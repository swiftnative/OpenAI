//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation
import URLConfig
import HTTPTypes

public enum OpenAI {}

public extension URLRequest.Config {

  enum OpenAI {

    public static var apiKey: String = ""

    public static var base: URLRequest.Config {
      var config = URLRequest.Config()
      config.host = "https://api.openai.com"
      config.headers[.authorization] = "Bearer \(apiKey)"
      return config
    }

    public static var assistant: URLRequest.Config {
      var config = base
      config.headers[.OpenAI.beta] = "assistants=v2"
      return config
    }
  }
}

public extension HTTPField.Name {
  enum OpenAI {
    public static let beta = HTTPField.Name("OpenAI-Beta")!
  }
}
