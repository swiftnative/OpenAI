//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import XCTest
import UIKit
import URLConfig
@testable import OpenAI

final class AssistantTests: XCTestCase {

  override func setUpWithError() throws {
    #warning("Provide you api_key for use")
    URLRequest.Config.OpenAI.apiKey = "<API_KEY>"
  }

  func testFiles() async throws {
    let image = UIImage(named: "chart",
                        in: Bundle(for: AssistantTests.self),
                        with: nil)

    guard let data = image?.jpegData(compressionQuality: .greatestFiniteMagnitude) else {
      XCTFail("Can't get data image")
      return
    }

    let requestFile = URLRequest.File(name: "chart.jpeg",
                                      data: data,
                                      mimeType: "image/jpeg")

    let uploadRequest = OpenAI.Files.upload(file: requestFile, purpose: "assistants")

    let file: File = try await URLSession.shared.response(for: uploadRequest).decode()

    let listRequest = OpenAI.Files.list
    let files: List<File> = try await URLSession.shared.response(for: listRequest).decode()

    XCTAssertTrue(files.data.contains(where: {$0.id == file.id}))

    let retrieveRequest = OpenAI.Files.retrieve(fileID: file.id)
    let retrievedFile: File = try await URLSession.shared.response(for: retrieveRequest).decode()

    XCTAssertEqual(file, retrievedFile)

    let deleteRequest = OpenAI.Files.delete(fileID: file.id)
    let deleted: DeletionStatus = try await URLSession.shared.response(for: deleteRequest).decode()

    XCTAssertEqual(file.id, deleted.id)

    let retrievedResponce = try await URLSession.shared.response(for: retrieveRequest)
    XCTAssertEqual(retrievedResponce.status, .notFound)
  }


  func testThreads() async throws {

    let imageFile = ImageFileContent(imageFile: .init(fileId: "file-TwISAP4lQ7kTazatFXRkGJiw"))
    let message = Message(role: .assistant,
                          content: .array([.imageFile(imageFile)]))

    let createThreadBody = ThreadRequest(messages: [message])
    let createThread = OpenAI.Threads.create(createThreadBody)
    let thread: OpenAI.Thread = try await URLSession.shared.response(for: createThread).decode()

    let retrieveThread = OpenAI.Threads.retrieve(threadID: thread.id)
    let retrievedThread: OpenAI.Thread = try await URLSession.shared.response(for: retrieveThread).decode()

    XCTAssertEqual(thread.id, retrievedThread.id)

    let deleteThread = OpenAI.Threads.delete(threadID: thread.id)
    let deleted: DeletionStatus = try await URLSession.shared.response(for: deleteThread).decode()

    XCTAssertEqual(thread.id, deleted.id)

    let response = try await URLSession.shared.response(for: retrieveThread)
    XCTAssertEqual(response.status, .notFound)
  }

  func testRuns() async throws {
    let fileID = "file-TwISAP4lQ7kTazatFXRkGJiw"
    let assistantID = "asst_Zon0dOeJY6dfSdujUB5k5oxC"

    let imageFile = ImageFileContent(imageFile: .init(fileId: fileID))
    let message = Message(role: .user,
                          content: .array([.imageFile(imageFile)]))

    let createThreadBody = ThreadRequest(messages: [message])
    let createThread = OpenAI.Threads.create(createThreadBody)
    let thread: OpenAI.Thread = try await URLSession.shared.response(for: createThread).decode()


    let createRunBody = RunRequest(assistantId: assistantID,
                                   additionalInstructions: "Language: Russian",
                                   responseFormat: .object(.jsonObject),
                                   toolChoice: .required)

    let createRun = OpenAI.Runs.create(threadID: thread.id, createRunBody)
    var run: Run = try await URLSession.shared.response(for: createRun).decode()


    let getRun = OpenAI.Runs.retrieve(threadID: thread.id, runID: run.id)

    while [.inProgress, .queued].contains(run.status) {
      try await Task.sleep(nanoseconds: 1_000_000_000)
      run = try await URLSession.shared.response(for: getRun).decode()
    }

    guard let requiredAction = run.requiredAction,
          case RequiredAction.submitToolOutputs(let calls) = requiredAction,
          let call = calls.toolCalls.first,
          case ToolCall.function(let functionCall) = call else {
      XCTFail("No required action")
      return
    }

    print(functionCall.function.arguments)
    XCTAssertEqual(functionCall.function.name, "get_analysis")

    let submitOutputBody = SubmitToolOutputRequest(toolOutputs: [ToolOutput(toolCallID: functionCall.id,
                                                                            output: "success: true")])
    let submitOutput = OpenAI.Runs.sumbitToolOutput(threadID: thread.id,
                                                    runID: run.id,
                                                    submitOutputBody)

    run = try await URLSession.shared.response(for: submitOutput).decode()

  }
}
