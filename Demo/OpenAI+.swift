//
//  Tools+.swift
//  Demo
//
//  Created by Alexey Nenastev on 19.6.24..
//

import OpenAI

extension String {
  struct OpenAI {
    static let gpt_4o_2024_05_13 = "gpt-4o-2024-05-13"
  }
}

extension Tool.Function {

  static func getAnalysis() throws -> Tool.Function {
    try Tool.Function(name: "get_analysis",
                      description: "Provide technical analysis",
                      parameters: """
{
    "type": "object",
    "properties": {
      "analysis": {
        "type": "object",
        "properties": {
          "ticker": {
            "type": "string",
            "description": "Stock ticker symbol"
          },
          "timeframe": {
            "type": "string",
            "description": "Time frame of the analysis"
          },
          "text": {
            "type": "string",
            "description": "Detailed text of the analysis"
          },
          "conclusion": {
            "type": "string",
            "description": "Conclusion of the analysis"
          }
        },
        "required": [
          "ticker",
          "timeframe",
          "info",
          "conclusion"
        ]
      },
      "strategies": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "info": {
              "type": "string",
              "description": "Text of the strategy"
            },
            "sl": {
              "type": "number",
              "description": "Level of stop loss price"
            },
            "tp": {
              "type": "number",
              "description": "Level of take profit price"
            },
            "open": {
              "type": "number",
              "description": "Level of opening position price"
            }
          },
          "required": [
            "info",
            "sl",
            "tp",
            "open"
          ]
        }
      }
    },
    "required": [
      "analysis",
      "strategies"
    ]
  }
""")
  }
}


extension ToolCall {
  struct GetAnalysis: Codable {
    let analysis: Analysis
    let strategies: [Strategy]?
  }
}

struct Analysis: Codable {
  let ticker: String
  let fimeFrame: String
  let conclusion: String
  let text: String

  public enum CodingKeys: String, CodingKey {
    case fimeFrame = "timeframe"
    case text
    case ticker, conclusion
  }
}

struct Strategy: Codable, Hashable {
  let takeProfit: Double
  let open: Double
  let stopLoss: Double
  let info: String

  public enum CodingKeys: String, CodingKey {
    case takeProfit = "tp"
    case stopLoss = "sl"
    case open, info
  }
}
