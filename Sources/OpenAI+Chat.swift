//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import URLConfig

/// OpenAI Requests
public extension OpenAI {
  ///- Documents: https://platform.openai.com/docs/api-reference/chat
  enum Chat {}
}

public extension OpenAI.Chat {

  /// - Documents: https://platform.openai.com/docs/api-reference/chat/create
  /// - Response: `ChatCompletion`
  static func completion(_ body: ChatCompletionRequest) -> URLRequest {
    URLRequest.with(.OpenAI.base) {
      $0.method = .post
      $0.path = "/v1/chat/completions"
      $0.bodyModel = body
    }
  }
}

public struct ChatCompletionRequest: Encodable {
  public let model: String
  public let messages: [Message]
  public let temperature: Double?
  public let topP: Double?
  public let n: Int?
  public let stream: Bool?
  public let stop: [String]?
  public let maxTokens: Int?
  public let presencePenalty: Double?
  public let frequencyPenalty: Double?
  public let logitBias: [String: Double]?
  public let user: String?
  public let tools: [Tool]?
  public let toolChoice: ToolChoice?

  public init(model: String,
              messages: [Message],
              temperature: Double? = nil,
              topP: Double? = nil,
              n: Int? = nil,
              stream: Bool? = nil,
              stop: [String]? = nil,
              maxTokens: Int? = nil,
              presencePenalty: Double? = nil,
              frequencyPenalty: Double? = nil,
              logitBias: [String: Double]? = nil,
              user: String? = nil,
              tools: [Tool]? =  nil,
              toolChoice: ToolChoice? = nil) {
    self.model = model
    self.messages = messages
    self.temperature = temperature
    self.topP = topP
    self.n = n
    self.stream = stream
    self.stop = stop
    self.maxTokens = maxTokens
    self.presencePenalty = presencePenalty
    self.frequencyPenalty = frequencyPenalty
    self.logitBias = logitBias
    self.user = user
    self.tools = tools
    self.toolChoice = toolChoice
  }

  public enum Role: String, Codable {
    case user, assistant, system
  }

  public enum Message: Codable {
    case system(SystemMessage)
    case user(UserMessage)
    case assistant(AssistantMessage)

    enum CodingKeys: String, CodingKey {
      case role
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(Role.self, forKey: .role)
      let singleValueContainer = try decoder.singleValueContainer()

      switch type {
      case .system:
        let message = try singleValueContainer.decode(SystemMessage.self)
        self = .system(message)
      case .user:
        let message = try singleValueContainer.decode(UserMessage.self)
        self = .user(message)
      case .assistant:
        let message = try singleValueContainer.decode(AssistantMessage.self)
        self = .assistant(message)
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .system(let message):
        try container.encode(message)
      case .assistant(let message):
        try container.encode(message)
      case .user(let message):
        try container.encode(message)
      }
    }
  }

  public struct SystemMessage: Codable {
    public let role: Role
    public let content: String
    public let name: String?

    public init(content: String, name: String? = nil) {
      self.role = .system
      self.content = content
      self.name = name
    }
  }

  public struct UserMessage: Codable {
    public let role: Role
    public let content: Content
    public let name: String?

    public init(content: Content, name: String? = nil) {
      self.role = .user
      self.content = content
      self.name = name
    }

    public init(name: String? = nil, _ contentParts: ContentPart...) {
      self.init(content: .array(contentParts), name: name)
    }
  }

  public struct AssistantMessage: Codable {
    public let role: Role
    public let content: String
    public let name: String?
    public let toolCalls: [ToolCall]?

    enum CodingKeys: String, CodingKey {
      case role, content, name
      case toolCalls = "tool_calls"
    }

    public init(content: String, name: String? = nil, toolCalls: [ToolCall]?) {
      self.role = .assistant
      self.content = content
      self.name = name
      self.toolCalls = toolCalls
    }
  }

  enum CodingKeys: String, CodingKey {
    case model
    case messages
    case temperature
    case topP = "top_p"
    case n
    case stream
    case stop
    case maxTokens = "max_tokens"
    case presencePenalty = "presence_penalty"
    case frequencyPenalty = "frequency_penalty"
    case logitBias = "logit_bias"
    case user
    case tools
    case toolChoice = "tool_choice"
  }
}

/// - Documents: https://platform.openai.com/docs/api-reference/chat/object
public struct ChatCompletion: Decodable {
  public typealias ID = String
  public let id: ID
  public let object: String
  public let created: Int
  public let model: String
  public let usage: Usage
  public let choices: [Choice]

  public struct Usage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
      case promptTokens = "prompt_tokens"
      case completionTokens = "completion_tokens"
      case totalTokens = "total_tokens"
    }
  }

  public struct Choice: Codable {
    public let index: Int
    public let message: Message
    public let finishReason: String?

    enum CodingKeys: String, CodingKey {
      case index
      case message
      case finishReason = "finish_reason"
    }
  }

  public struct Message: Codable {
    public let role: String
    public let content: String?
    public let toolCalls: [ToolCall]?

    enum CodingKeys: String, CodingKey {
      case role
      case content
      case toolCalls = "tool_calls"
    }
  }

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case created
    case model
    case usage
    case choices
  }
}
