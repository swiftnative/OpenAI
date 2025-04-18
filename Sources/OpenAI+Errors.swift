//
//  OpenAI+Errors.swift
//  OpenAI
//
//  Created by Alexey Nenastev on 18.4.25..
//

import Foundation

public extension OpenAI {

  struct ErrorResponse: Decodable {
    public let error: OpenAI.Error

    public init(error: OpenAI.Error) {
      self.error = error
    }
  }

  struct Error: Swift.Error, Decodable {
    public let code: String
    public let message: String
    public let type: String

    public enum Codes {
      public static let unsupportedCountryRegionTerritory = "unsupported_country_region_territory"
    }

    public init(code: String, message: String, type: String) {
      self.code = code
      self.message = message
      self.type = type
    }
  }
}
