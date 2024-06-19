//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct List<Item: Codable>: Codable {
  let data: [Item]
  let hasMore: Bool

  public enum CodingKeys: String, CodingKey {
    case data
    case hasMore = "has_more"
  }
}
