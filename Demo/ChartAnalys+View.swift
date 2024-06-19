//
// Created by Alexey Nenastyev on 8.6.24.
// Copyright © 2023 Alexey Nenastyev (github.com/alexejn). All Rights Reserved.

import SwiftUI
import Observation
import OpenAI

struct ChartAnalysView: View {
  @State var chart = ChartAnalysModel()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Image("chart")
          .resizable()
          .aspectRatio(contentMode: .fit)


        if let analysis = chart.analysis {
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text(analysis.analysis.ticker)
              Text(analysis.analysis.fimeFrame)
            }
            .font(.title)

            VStack(alignment: .leading) {
              Text("Analysis")
                .font(.title2)
              Text(analysis.analysis.text)
              Text(analysis.analysis.conclusion)
                .font(.headline)
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
          .padding()
        }

        Spacer()
      }
      .buttonStyle(.bordered)
    }

    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        if chart.inProgress {
          ProgressView()
        } else {
          Button {
            Task {
              await chart.analyse()
            }
          } label: {
            Text("Analyse")
          }
        }
      }
    }
  }
}

#Preview {
  ChartAnalysView(chart: .init(analysis: .sample))
}


extension ToolCall.GetAnalysis {
  static var sample: Self {
    let analysis = Analysis(ticker: "BTCUSD",
                            fimeFrame: "15M",
                            conclusion: "Conclusion",
                            text: "It's sample analysis")

    let strategy = Strategy(takeProfit: 66900,
                            open: 66890,
                            stopLoss: 66870,
                            info: "Some stategy")

    return .init(analysis: analysis,
                 strategies: [strategy])
  }
}
