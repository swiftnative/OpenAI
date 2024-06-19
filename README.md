# OpenAI

Swift implementation of [OpenAI API](https://platform.openai.com/docs/api-reference/chat)

Supported: 
- Files 
- Chat Completion
- Assitants

## Getting Started

Add the following dependency clause to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/swiftnative/OpenAI.git", from: "1.0.0")
]
```

## Usage
> You can find demo app inside and tests to get an idea of the usage.


It's build with [URLConfig](https://github.com/swiftnative/URLConfig) to be native and flexible.

API provide URLRequest for making call, and all Codable models you need.

```swift
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
```

Just 3 steps to interact with OpenAI

```swift
/// Create URLRequest
let createCompletionBody = ChatCompletionRequest(model: .OpenAI.gpt_4o_2024_05_13,
                                                     messages: [.system(systemMessage),
                                                                .user(userMesage)
                                                     ],
                                                     tools: [.function(function)],
                                                     toolChoice: .function(name: function.name))

let createCompletion = OpenAI.Chat.completion(createCompletionBody)

/// Make Call
let response = try await URLSession.shared.response(for: createCompletion)

/// Hadle Response
let completion: ChatCompletion = try response.decode()

```

#### Feel free to
- create you own simple codable model to decode to, if you don't need the full ones.
- extend api, if you need more.



