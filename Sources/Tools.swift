//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import Foundation

public struct ToolResources: Codable {
  public let codeInterpreter: CodeInterpreter?
  public let fileSearch: FileSearch?

  enum CodingKeys: String, CodingKey {
    case codeInterpreter = "code_interpreter"
    case fileSearch = "file_search"
  }

  // Define the CodeInterpreter object
  public struct CodeInterpreter: Codable {
    public let fileIds: [String]

    enum CodingKeys: String, CodingKey {
      case fileIds = "file_ids"
    }
  }

  // Define the FileSearch object
  public struct FileSearch: Codable {
    public let vectorStoreIds: [String]

    enum CodingKeys: String, CodingKey {
      case vectorStoreIds = "vector_store_ids"
    }
  }
}

public enum Tool: Codable {
  case codeInterpreter
  case fileSearch(FileSearch)
  case function(Function)

  private enum CodingKeys: String, CodingKey {
    case type
    case fileSearch = "file_search"
    case function
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    switch type {
    case "code_interpreter":
      self = .codeInterpreter
    case "file_search":
      let fileSearch = try container.decode(FileSearch.self, forKey: .fileSearch)
      self = .fileSearch(fileSearch)
    case "function":
      let function = try container.decode(Function.self, forKey: .function)
      self = .function(function)
    default:
      throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid tool type")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .codeInterpreter:
      try container.encode("code_interpreter", forKey: .type)
    case .fileSearch(let fileSearch):
      try container.encode("file_search", forKey: .type)
      try container.encode(fileSearch, forKey: .fileSearch)
    case .function(let function):
      try container.encode("function", forKey: .type)
      try container.encode(function, forKey: .function)
    }
  }
  // Define the FileSearch object
  public struct FileSearch: Codable {
  }

  // Define the Function object
  public struct Function: Codable {
    public let name: String
    public let description: String?
    public let parameters: String?

    private let encoded: [String: Any]?

    enum CodingKeys: String, CodingKey {
      case name
      case description
      case parameters
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(String.self, forKey: .name)
      self.description = try container.decodeIfPresent(String.self, forKey: .description)
      self.encoded = nil
      if let parametersString = try? container.decode(String.self, forKey: .parameters) {
        self.parameters = parametersString
      } else if let parametersData = try? container.decode(Data.self, forKey: .parameters) {
        self.parameters = String(data: parametersData, encoding: .utf8)
      } else {
        self.parameters = nil
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(name, forKey: .name)
      if let description {
        try container.encode(description, forKey: .description)
      }

      if let encoded {
        try container.encode(JSONAny(encoded), forKey: .parameters)
      }
    }

    public init(name: String, description: String? = nil, parameters: String? = nil) throws {
      self.name = name
      self.description = description
      self.parameters = parameters

      if let parameters {
        let data = Data(parameters.utf8)
        self.encoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
      } else {
        self.encoded = nil
      }
    }
  }
}

public enum ToolChoice: Codable {
  case none
  case auto
  case required
  case specificTool(Tool)

  enum CodingKeys: String, CodingKey {
    case type
    case function
  }

  public static func function(name: String) -> Self {
    .specificTool(Tool(function: name))
  }

  public struct Tool: Codable {
    let type: String
    let function: Function?

    public init(function name: String) {
      self.type = "function"
      self.function = Function(name: name)
    }

    public init(type: String, function: Function?) {
      self.type = type
      self.function = function
    }

    public struct Function: Codable {
      let name: String
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let stringValue = try? container.decode(String.self) {
      switch stringValue {
      case "none":
        self = .none
      case "auto":
        self = .auto
      case "required":
        self = .required
      default:
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value")
      }
    } else {
      let nestedContainer = try decoder.container(keyedBy: CodingKeys.self)
      let type = try nestedContainer.decode(String.self, forKey: .type)
      let function = try nestedContainer.decodeIfPresent(Tool.Function.self, forKey: .function)
      self = .specificTool(Tool(type: type, function: function))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .none:
      try container.encode("none")
    case .auto:
      try container.encode("auto")
    case .required:
      try container.encode("required")
    case .specificTool(let tool):
      var nestedContainer = encoder.container(keyedBy: CodingKeys.self)
      try nestedContainer.encode(tool.type, forKey: .type)
      try nestedContainer.encodeIfPresent(tool.function, forKey: .function)
    }
  }
}

struct JSONAny: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([String: JSONAny].self) {
            self.value = value.mapValues { $0.value }
        } else if let value = try? container.decode([JSONAny].self) {
            self.value = value.map { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = self.value as? Bool {
            try container.encode(value)
        } else if let value = self.value as? Int {
            try container.encode(value)
        } else if let value = self.value as? Double {
            try container.encode(value)
        } else if let value = self.value as? String {
            try container.encode(value)
        } else if let value = self.value as? [String: Any] {
            try container.encode(value.mapValues { JSONAny($0) })
        } else if let value = self.value as? [Any] {
            try container.encode(value.map { JSONAny($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported JSON value"))
        }
    }
}
