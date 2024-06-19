//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct DeletionStatus: Codable {
  public typealias ObjectID = String
  public let id: ObjectID
  public let object: String
  public let deleted: Bool
}
