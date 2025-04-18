//
//  OpenAI+Errors.swift
//  OpenAI
//
//  Created by Alexey Nenastev on 18.4.25..
//

import Foundation

extension OpenAI {

  struct ErrorResponse: Decodable {
    let error: OpenAI.Error
  }

  struct Error: Swift.Error, Decodable {
    let code: String
    let message: String
    let type: String

    enum Codes {
      static let unsupportedCountryRegionTerritory = "unsupported_country_region_territory"
    }
  }
}
