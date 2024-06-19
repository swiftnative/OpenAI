//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import URLConfig

public extension OpenAI {
  /// - Documents: https://platform.openai.com/docs/api-reference/threads
  enum Threads {}
}

public extension OpenAI.Threads {
  
  /// - Documents: https://platform.openai.com/docs/api-reference/threads/createThread
  /// - Response: `Thread`
  static func create(_ body: ThreadRequest? = nil) -> URLRequest  {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .post
      $0.path = "/v1/threads"
      $0.bodyModel = body
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/threads/getThread
  /// Response `Thread`
  static func retrieve(threadID: OpenAI.Thread.ID) -> URLRequest {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .get
      $0.path = "/v1/threads/\(threadID)"
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/threads/deleteThread
  /// - Response: `DeletionStatus`
  static func delete(threadID: OpenAI.Thread.ID) -> URLRequest {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .delete
      $0.path = "/v1/threads/\(threadID)"
    }
  }
}

public extension OpenAI {
  /// - Documents: https://platform.openai.com/docs/api-reference/threads/object
  struct Thread: Codable {

    public typealias ID = String
    public let id: ID
    public let object: String
    public let createdAt: Int
    public let toolResources: ToolResources?
    public let metadata: [String: String]?

    enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case toolResources = "tool_resources"
      case metadata
    }
  }
}

public struct ThreadRequest: Encodable {
  let messages: [Message]
//  let toolResources: String?

//  enum CodingKeys: String, CodingKey {
//    case toolResources = "tool_resources"
//  }
}

