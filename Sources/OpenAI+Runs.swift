//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation
import URLConfig

public extension OpenAI {
  ///- Documents: https://platform.openai.com/docs/api-reference/runs
  enum Runs {}
}

public extension OpenAI.Runs {

  /// - Documents: https://platform.openai.com/docs/api-reference/runs/createRun
  /// - Response: `Run`
  static func create(threadID: OpenAI.Thread.ID, _ body: RunRequest) -> URLRequest  {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .post
      $0.path = "/v1/threads/\(threadID)/runs"
      $0.bodyModel = body
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/runs/getRun
  /// - Response `Run`
  static func retrieve(threadID: OpenAI.Thread.ID, runID: Run.ID) -> URLRequest {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .get
      $0.path = "/v1/threads/\(threadID)/runs/\(runID)"
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/runs/cancelRun
  /// - Response: `Run`
  static func cancel(threadID: OpenAI.Thread.ID, runID: Run.ID) -> URLRequest {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .post
      $0.path = "/v1/threads/\(threadID)/runs/\(runID)"
    }
  }

  /// - Documents: https://platform.openai.com/docs/api-reference/runs/submitToolOutputs
  /// - Response: `Run`
  static func sumbitToolOutput(threadID: OpenAI.Thread.ID, runID: Run.ID, _ body: SubmitToolOutputRequest) -> URLRequest {
    URLRequest.with(.OpenAI.assistant) {
      $0.method = .post
      $0.path = "/v1/threads/\(threadID)/runs/\(runID)/submit_tool_outputs"
      $0.bodyModel = body
    }
  }
}


public struct RunRequest: Encodable {
  public let assistantId: String
  public let model: String?
  public let instructions: String?
  public let additionalInstructions: String?
  public let additionalMessages: [String]?
  public let tools: [Tool]?
  public let metadata: [String: String]?
  public let temperature: Double?
  public let topP: Double?
  public let stream: Bool?
  public let toolChoice: ToolChoice?
  public let responseFormat: ResponseFormat?

  enum CodingKeys: String, CodingKey {
    case assistantId = "assistant_id"
    case model
    case instructions
    case additionalInstructions = "additional_instructions"
    case additionalMessages = "additional_messages"
    case tools
    case metadata
    case temperature
    case topP = "top_p"
    case stream
    case responseFormat = "response_format"
    case toolChoice = "tool_choice"
  }

  public init(assistantId: String,
              model: String? = nil,
              instructions: String? = nil,
              additionalInstructions: String? = nil,
              additionalMessages: [String]? = nil,
              tools: [Tool]? = nil,
              metadata: [String : String]? = nil,
              temperature: Double? = nil,
              topP: Double? = nil,
              stream: Bool? = nil,
              responseFormat: ResponseFormat? = nil,
              toolChoice: ToolChoice? = nil) {
    self.assistantId = assistantId
    self.model = model
    self.instructions = instructions
    self.additionalInstructions = additionalInstructions
    self.additionalMessages = additionalMessages
    self.tools = tools
    self.metadata = metadata
    self.temperature = temperature
    self.topP = topP
    self.stream = stream
    self.responseFormat = responseFormat
    self.toolChoice = toolChoice
  }
}

/// - Documents: https://platform.openai.com/docs/api-reference/runs/object
public struct Run: Decodable {
  public typealias ID = String
  public let id: ID
  public let object: String
  public let createdAt: Int
  public let assistantId: String
  public let threadId: String
  public let status: Status
  public let startedAt: Int?
  public let expiresAt: Int?
  public let cancelledAt: Int?
  public let failedAt: Int?
  public let completedAt: Int?
  public let lastError: LastError?
  public let model: String
  public let instructions: String?
  public let tools: [Tool]
  public let metadata: [String: String]
  public let incompleteDetails: IncompleteDetails?
  public let usage: Usage?
  public let temperature: Double?
  public let topP: Double?
  public let maxPromptTokens: Int?
  public let maxCompletionTokens: Int?
  public let truncationStrategy: TruncationStrategy?
  public let responseFormat: ResponseFormat
  public let toolChoice: ToolChoice
  public let requiredAction: RequiredAction?
  public let parallelToolCalls: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case object
    case createdAt = "created_at"
    case assistantId = "assistant_id"
    case threadId = "thread_id"
    case status
    case startedAt = "started_at"
    case expiresAt = "expires_at"
    case cancelledAt = "cancelled_at"
    case failedAt = "failed_at"
    case completedAt = "completed_at"
    case lastError = "last_error"
    case model
    case instructions
    case tools
    case metadata
    case incompleteDetails = "incomplete_details"
    case usage
    case temperature
    case topP = "top_p"
    case maxPromptTokens = "max_prompt_tokens"
    case maxCompletionTokens = "max_completion_tokens"
    case truncationStrategy = "truncation_strategy"
    case responseFormat = "response_format"
    case toolChoice = "tool_choice"
    case parallelToolCalls = "parallel_tool_calls"
    case requiredAction = "required_action"
  }


  public enum Status: String, Codable {
    case queued = "queued"
    case inProgress = "in_progress"
    case requiresAction = "requires_action"
    case cancelling = "cancelling"
    case cancelled = "cancelled"
    case failed = "failed"
    case completed = "completed"
    case incomplete = "incomplete"
    case expired = "expired"
  }
}

public struct SubmitToolOutputRequest: Encodable {
  let stream: Bool?
  let toolOutputs: [ToolOutput]

  public init(stream: Bool? = nil, toolOutputs: [ToolOutput]) {
    self.stream = stream
    self.toolOutputs = toolOutputs
  }

  enum CodingKeys: String, CodingKey {
    case toolOutputs = "tool_outputs"
    case stream
  }
}

public struct ToolOutput: Encodable {
  let toolCallID: String?
  let output: String?

  enum CodingKeys: String, CodingKey {
    case toolCallID = "tool_call_id"
    case output
  }
}

public enum ResponseFormat: Codable {
  case string(String)
  case object(ResponseType)

  enum CodingKeys: String, CodingKey {
    case type
  }

  public enum ResponseType: String, Codable {
    case text = "text"
    case jsonObject = "json_object"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let stringValue = try? container.decode(String.self) {
      self = .string(stringValue)
    } else {
      let nestedContainer = try decoder.container(keyedBy: CodingKeys.self)
      let type = try nestedContainer.decode(ResponseType.self, forKey: .type)
      self = .object(type)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .object(let type):
      var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
      try nestedContainer.encode(type, forKey: .type)
    }
  }
}

public enum  RequiredAction: Decodable {
  case submitToolOutputs(SubmitToolOutput)

  enum CodingKeys: String, CodingKey {
    case type
    case submitToolOutputs = "submit_tool_outputs"
  }

  public struct SubmitToolOutput: Decodable {
    let toolCalls: [ToolCall]

    enum CodingKeys: String, CodingKey {
      case toolCalls = "tool_calls"
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "submit_tool_outputs":
      let toolCalls = try container.decode(SubmitToolOutput.self, forKey: .submitToolOutputs)
      self = .submitToolOutputs(toolCalls)
    default:
      throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool type")
    }
  }
}

public enum ToolCall: Codable {
  case function(FunctionCall)

  private enum CodingKeys: String, CodingKey {
    case type
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    let singleValueContainer = try decoder.singleValueContainer()

    switch type {
    case "function":
      let function = try singleValueContainer.decode(FunctionCall.self)
      self = .function(function)
    default:
      throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool type")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .function(let call):
      try container.encode(call)
    }
  }

  public struct FunctionCall: Codable {
    let id: String
    let type: String
    let function: Function

    public func decodeArguments<D: Decodable>(to type: D.Type = D.self) throws -> D {
      try function.decodeArguments(to: type)
    }
  }

  // Define the Function object
  public struct Function: Codable {
    public let name: String
    public let arguments: String

    public func decodeArguments<D: Decodable>(to type: D.Type = D.self) throws -> D {
      try JSONDecoder().decode(type, from: arguments.data(using: .utf8)!)
    }
  }
}

public struct LastError: Codable {
  public let message: String
  public let code: Int?
}

public struct IncompleteDetails: Codable {
  public let reason: String
}

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

public struct TruncationStrategy: Codable {
  public let type: String
  public let lastMessages: [String]?

  enum CodingKeys: String, CodingKey {
    case type
    case lastMessages = "last_messages"
  }
}
