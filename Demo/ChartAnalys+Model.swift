//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.


import SwiftUI
import Observation
import OpenAI

@Observable
final class ChartAnalysModel {

  var inProgress: Bool = false
  var analysisStructured: ToolCall.GetAnalysis?
  var analysisString: String?
  var usage: ChatCompletion.Usage?
  var dataKB: Int?
  var duration: Double = 0

  init(analysis: ToolCall.GetAnalysis? = nil ) {
    self.analysisStructured = analysis
  }

  func clear() {
    usage = nil
    analysisString = nil
    analysisStructured = nil
    dataKB = nil
    duration = 0
  }

  func analyseFucntionCall(image: UIImage) async {
    clear()
    inProgress = true

    do {
      /// Build Request
      let start = CFAbsoluteTimeGetCurrent()
      let data = image.jpegData(compressionQuality: 1)!
      let base64Image = data.base64EncodedString(options: .lineLength64Characters)
      self.dataKB = data.count / 1024
      let userImageUrlContent = ImageUrlContent(url: "data:image/jpeg;base64,{\(base64Image)}").contentPart
      let userTextContent = TextContent("Output Language: Russian").contentPart

      let userMesage = ChatCompletionRequest.UserMessage(userImageUrlContent, userTextContent)
      let systemMessage = ChatCompletionRequest.SystemMessage(content: "You are a useful assistant for analyzing the price chart of trading instruments and conducting technical analysis. Your task is to conduct a technical analysis based on the data provided by the chart of the instrument and additional indicators. Such an analysis should include: detection of support and resistance lines, various candlestick and price patterns, explanations of what the indicators signal, and so on. In the end, you should make a conclusion about a possible price movement and offer several options for opening positions with a description of the entry price, stop loss and take profit levels. Output: Json. Call once func get_analysis")

      let function = try Tool.Function.getAnalysis()

      let createCompletionBody = ChatCompletionRequest(model: .OpenAI.gpt_4o_2024_05_13,
                                                       messages: [.system(systemMessage),
                                                                  .user(userMesage)
                                                       ],
                                                       tools: [.function(function)],
                                                       toolChoice: .function(name: function.name))

      let createCompletion = OpenAI.Chat.completion(createCompletionBody)

      /// Make Call
      let response = try await URLSession.shared.response(for: createCompletion)

      self.duration = CFAbsoluteTimeGetCurrent() - start
      /// Hadle Response
      let completion: ChatCompletion = try response.decode()

      guard let toolCall = completion.choices.first?.message.toolCalls?.first,
            case ToolCall.function(let function) = toolCall else {
        throw AnalysisError.NoFunctionCall
      }

      let analysis: ToolCall.GetAnalysis = try function.decodeArguments()
      self.analysisStructured = analysis
      self.usage = completion.usage
      inProgress = false
    } catch {
      inProgress = false
      print("Error \(error)")
    }
  }

  func analyseHTML(image: UIImage) async {
    clear()
    inProgress = true

    do {
      let start = CFAbsoluteTimeGetCurrent()
      let data = image.jpegData(compressionQuality: 1)!
      let base64Image = data.base64EncodedString(options: .lineLength64Characters)
      self.dataKB = data.count / 1024
      let userImageUrlContent = ImageUrlContent(url: "data:image/jpeg;base64,{\(base64Image)}").contentPart
      let userTextContent = TextContent("Output Language: Russian").contentPart

      let userMesage = ChatCompletionRequest.UserMessage(userImageUrlContent, userTextContent)
      let systemMessage = ChatCompletionRequest.SystemMessage(content: "You are a useful assistant for analyzing the price chart of trading instruments and conducting technical analysis. Your task is to conduct a technical analysis based on the data provided by the chart of the instrument and additional indicators. Such an analysis should include: detection of support and resistance lines, various candlestick and price patterns, explanations of what the indicators signal, and so on. In the end, you should make a conclusion about a possible price movement and offer several options for opening positions with a description of the entry price, stop loss and take profit levels.")

      let function = try Tool.Function.getAnalysis()

      let createCompletionBody = ChatCompletionRequest(model: .OpenAI.gpt_4o_2024_05_13,
                                                       messages: [.system(systemMessage),
                                                                  .user(userMesage)])

      let createCompletion = OpenAI.Chat.completion(createCompletionBody)

      /// Make Call
      let response = try await URLSession.shared.response(for: createCompletion)

      self.duration = CFAbsoluteTimeGetCurrent() - start
      /// Hadle Response
      let completion: ChatCompletion = try response.decode()

      guard let message = completion.choices.first?.message,
            let content = message.content else {
        throw AnalysisError.NoMassage
      }

      self.analysisString = content
      self.usage = completion.usage
      inProgress = false
    } catch {
      inProgress = false
      print("\(error)")
    }
  }
}


enum AnalysisError: Error {
  case NoFunctionCall
  case NoMassage
}

