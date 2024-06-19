//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import URLConfig

/// OpenAI Requests
public extension OpenAI {
  ///- Documents: https://platform.openai.com/docs/api-reference/files
  enum Files {}
}

public extension OpenAI.Files {

  /// - Documents: https://platform.openai.com/docs/api-reference/files/create
  /// - Response: `File`
  static func upload(file: URLRequest.File, purpose: String) -> URLRequest {
    var file = file
    file.key = "file"
    
    var request = URLRequest.with(.OpenAI.base) {
      $0.method = .post
      $0.path = "/v1/files"
    }
    request.setMultipartFormData(parameters: ["purpose": purpose],
                                 files: [file])
    return request
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/files/delete
  /// - Response: `DeletionStatus`
  static func delete(fileID: File.ID) -> URLRequest {
    URLRequest.with(.OpenAI.base) {
      $0.method = .delete
      $0.path = "/v1/files/\(fileID)"
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/files/retrieve
  /// - Response: `File`
  static func retrieve(fileID: File.ID) -> URLRequest {
    URLRequest.with(.OpenAI.base) {
      $0.method = .get
      $0.path = "/v1/files/\(fileID)"
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/files/list
  /// - Response `List<File>`
  static var list: URLRequest {
    URLRequest.with(.OpenAI.base) {
      $0.method = .get
      $0.path = "/v1/files"
    }
  }
}

/// - Documents: https://platform.openai.com/docs/api-reference/files/object
public struct File: Codable, Equatable {
  public typealias ID = String
  public let id: ID
  public let object: String
  public let bytes: Int
  public let createdAt: Int
  public let filename: String
  public let purpose: String

  public enum CodingKeys: String, CodingKey {
    case id, object, bytes, filename, purpose
    case createdAt = "created_at"
  }
}
