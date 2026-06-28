//
//  TrendCard.swift
//  MoodMargins
//
//  Created by Gerard Gomez on 6/27/26.
//

import Charts
import SwiftUI

struct TrendCard: View {
    @Binding var selectedRange: Int
    let series: [DailyMood]

    private var xDomain: ClosedRange<Int> {
        0...max(series.count - 1, 1)
    }

    private var yAxisValues: [Int] {
        Mood.allCases.map(\.rawValue)
    }

    var body: some View {
        InsightPage(title: "\(selectedRange)-day mood ribbon", symbol: "chart.line.uptrend.xyaxis", rotation: -1.0) {
            VStack(spacing: 8) {
                Chart {
                    ForEach(series) { item in
                        LineMark(
                            x: .value("Day", item.id),
                            y: .value("Mood", item.value)
                        )
                        .foregroundStyle(PastelTheme.ink.opacity(0.38))
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    }

                    ForEach(series) { item in
                        PointMark(
                            x: .value("Day", item.id),
                            y: .value("Mood", item.value)
                        )
                        .foregroundStyle(mood(for: item.value).tint)
                        .symbol {
                            Circle()
                                .strokeBorder(PastelTheme.paper, lineWidth: 3)
                                .background(Circle().fill(mood(for: item.value).tint))
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .chartXScale(domain: xDomain)
                .chartYScale(domain: 0.5...5.5)
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading, values: yAxisValues) { _ in
                        AxisGridLine()
                            .foregroundStyle(PastelTheme.ink.opacity(0.08))
                        AxisValueLabel(
                            centered: true,
                            collisionResolution: .disabled,
                            offsetsMarks: true,
                            horizontalSpacing: 8
                        ) {
                            Color.clear
                                .frame(width: 34, height: 34)
                        }
                    }
                }
                .chartLegend(.hidden)
                .chartOverlay { chartProxy in
                    GeometryReader { geometry in
                        if let plotFrameAnchor = chartProxy.plotFrame {
                            let plotFrame = geometry[plotFrameAnchor]
                            ForEach(Mood.allCases) { mood in
                                if let yPosition = chartProxy.position(forY: Double(mood.rawValue)) {
                                    MoodLottieIcon(mood: mood, size: 34)
                                        .frame(width: 34, height: 34)
                                        .position(
                                            x: plotFrame.minX - 25,
                                            y: plotFrame.minY + yPosition
                                        )
                                }
                            }
                        }
                    }
                }
                .frame(height: 210)

                if let first = series.first, let last = series.last {
                    HStack {
                        Text(first.date, format: .dateTime.month(.abbreviated).day())
                        Spacer()
                        Text(last.date, format: .dateTime.month(.abbreviated).day())
                    }
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func mood(for value: Double) -> Mood {
        Mood(rawValue: min(max(Int(value.rounded()), Mood.angry.rawValue), Mood.laughing.rawValue)) ?? .wink
    }
}

#Preview {
    let viewModel = InsightsViewModel()

    TrendCard(
        selectedRange: .constant(viewModel.selectedRange),
        series: viewModel.trendSeries(for: MoodEntry.samples)
    )
}
