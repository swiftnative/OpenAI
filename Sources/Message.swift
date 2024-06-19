//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import Foundation

public struct Message: Codable {
  public let role: Role
  public let content: Content
}

public enum Role: String, Codable {
  case user, assistant
}

public enum Content: Codable {
  case string(String)
  case array([ContentPart])

  public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .string(let value):
          try container.encode(value)
      case .array(let value):
          try container.encode(value)
      }
  }
}

public enum ContentPart: Codable {
  case text(TextContent)
  case imageFile(ImageFileContent)
  case imageUrl(ImageUrlContent)

  enum CodingKeys: String, CodingKey {
    case type
  }

  enum ContentType: String, Codable {
    case text, imageFile = "image_file", imageUrl = "image_url"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ContentType.self, forKey: .type)
    let singleValueContainer = try decoder.singleValueContainer()

    switch type {
    case .text:
      let textContent = try singleValueContainer.decode(TextContent.self)
      self = .text(textContent)
    case .imageFile:
      let imageFile = try singleValueContainer.decode(ImageFileContent.self)
      self = .imageFile(imageFile)
    case .imageUrl:
      let imageUrl = try singleValueContainer.decode(ImageUrlContent.self)
      self = .imageUrl(imageUrl)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .text(let textContent):
      try container.encode(textContent)
    case .imageFile(let imageFile):
      try container.encode(imageFile)
    case .imageUrl(let imageUrl):
      try container.encode(imageUrl)
    }
  }
}

public enum Detail: String, Codable {
  case auto, low, high
}

public struct TextContent: Codable {
  public let type: String
  public let text: String

  public init(_ text: String) {
    self.type = "text"
    self.text = text
  }


  public var contentPart: ContentPart { .text(self) }
}

public struct ImageFileContent: Codable {
  public let type: String
  public let imageFile: File

  public init(imageFile: File) {
    self.type = "image_file"
    self.imageFile = imageFile
  }

  public enum CodingKeys: String, CodingKey {
    case imageFile = "image_file"
    case type
  }

  public struct File: Codable {
    public let fileId: String
    public let detail: Detail?

    public init(fileId: String, detail: Detail? = nil) {
      self.fileId = fileId
      self.detail = detail
    }

    public enum Detail: String, Codable {
      case auto, low, high
    }

    public enum CodingKeys: String, CodingKey {
      case fileId = "file_id"
      case detail
    }
  }
}

public struct ImageUrlContent: Codable {
  public let imageUrl: ImageUrl
  public let type: String

  public enum CodingKeys: String, CodingKey {
    case imageUrl = "image_url"
    case type
  }

  public struct ImageUrl: Codable {
    public let url: String
    public let detail: Detail?
  }

  public init(imageUrl: ImageUrl) {
    self.type = "image_url"
    self.imageUrl = imageUrl
  }

  public init(url: String, detail: Detail? = nil) {
    self.init(imageUrl: .init(url: url, detail: detail))
  }

  public var contentPart: ContentPart { .imageUrl(self) }
}
