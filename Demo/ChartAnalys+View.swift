//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import Observation
import OpenAI
import MarkdownUI

struct ChartAnalysView: View {
  @State var chart = ChartAnalysModel()
  let image = UIImage(named: "chart")!

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fit)

        VStack{

          if let dataKB = chart.dataKB {
            LabeledContent("Data, KB", value: dataKB, format: .number)
          }

          if chart.inProgress {
            ProgressView()
          }

          LabeledContent("Duration", value: chart.duration, format: .number.precision(.fractionLength(2)))

          if let usage = chart.usage {
            LabeledContent("Completion", value: "\(usage.completionTokens)")
            LabeledContent("Prompt", value: "\(usage.promptTokens)")
            LabeledContent("Total", value: "\(usage.totalTokens)")
          }

          if let analysis = chart.analysisStructured {
            VStack(alignment: .leading, spacing: 10) {

              VStack(alignment: .leading) {
                Text("Analysis")
                  .font(.title2)
                Markdown(analysis.analysis.text)
              }

              if let strategies = analysis.strategies {
                Text("Strategies")
                  .font(.title2)
                ForEach(strategies.indices, id: \.self) { index in
                  let strategy = strategies[index]
                  VStack(alignment: .leading, spacing: 2) {
                    Text(strategy.info)
                    LabeledContent("Open", value: "\(strategy.open)")
                    LabeledContent("TakeProfit", value: "\(strategy.takeProfit)")
                    LabeledContent("StopLoss", value: "\(strategy.stopLoss)")
                  }
                }
              }
            }
          }

          if let string = chart.analysisString {

            Markdown(string)
          }

          Spacer()
        }
        .padding(.horizontal)
      }
      .buttonStyle(.bordered)
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        Button {
          Task {
            await chart.analyseFucntionCall(image: image)
          }
        } label: {
          Text("Analyse(Structured)")
        }
        .disabled(chart.inProgress)
      }

      ToolbarItem(placement: .bottomBar) {
        Button {
          Task {
            await chart.analyseHTML(image: image)
          }
        } label: {
          Text("Analyse(String)")
        }
        .disabled(chart.inProgress)
      }
    }
  }
}

#Preview {
  ChartAnalysView(chart: .init(analysis: .sample))
}


extension ToolCall.GetAnalysis {
  static var sample: Self {
    let analysis = Analysis(text: "It's sample analysis")

    let strategy = Strategy(takeProfit: 66900,
                            open: 66890,
                            stopLoss: 66870,
                            info: "Some stategy")

    return .init(analysis: analysis,
                 strategies: [strategy])
  }
}
