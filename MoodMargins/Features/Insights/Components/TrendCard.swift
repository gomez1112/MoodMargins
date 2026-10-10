import Charts
import SwiftUI

struct TrendCard: View {
    @Environment(\.diaryPalette) private var palette
    @Environment(\.layoutDirection) private var layoutDirection
    @ScaledMetric(relativeTo: .body) private var chartHeight = 240.0
    @ScaledMetric(relativeTo: .body) private var scaledAxisIconSize = 32.0
    var selectedRange: Int
    var series: [DailyMood]

    var body: some View {
        InsightPage(title: String(localized: "\(selectedRange)-day mood trend"), symbol: "chart.line.uptrend.xyaxis", rotation: -1) {
            if series.isEmpty {
                ContentUnavailableView {
                    Label("No entries in this range", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("Save a page to see your mood over time.")
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Chart {
                        ForEach(series) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Mood score", item.value),
                                series: .value("Consecutive days", item.segmentStart)
                            )
                            .foregroundStyle(palette.ink.opacity(0.55))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .interpolationMethod(.linear)
                            .accessibilityHidden(true)
                            PointMark(x: .value("Date", item.date), y: .value("Mood score", item.value))
                                .foregroundStyle(mood(for: item.value).tint)
                                .symbolSize(70)
                                .accessibilityLabel(item.date.formatted(date: .abbreviated, time: .omitted))
                                .accessibilityValue(MoodInsights.moodDescription(for: item.value))
                        }
                    }
                    .chartXScale(domain: MoodInsights.chartDateRange(days: selectedRange), range: .plotDimension(padding: 10))
                    .chartYScale(domain: 0.5...5.5)
                    .chartXAxis {
                        AxisMarks(values: MoodInsights.chartTickDates(days: selectedRange)) { value in
                            if selectedRange == 365 {
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day().year(.twoDigits), anchor: dateLabelAnchor(for: value), collisionResolution: .disabled)
                            } else {
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day(), anchor: dateLabelAnchor(for: value), collisionResolution: .disabled)
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) {
                            AxisGridLine().foregroundStyle(palette.ink.opacity(0.12))
                            AxisValueLabel(centered: true, collisionResolution: .disabled, horizontalSpacing: 8) {
                                Color.clear.frame(width: axisIconSize, height: axisIconSize)
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            if let anchor = proxy.plotFrame {
                                let plot = geometry[anchor]
                                ForEach(Mood.allCases) { mood in
                                    if let y = proxy.position(forY: Double(mood.rawValue)) {
                                        // Lottie needs a live view, rather than a rasterized axis label.
                                        MoodLottieIcon(mood: mood, size: axisIconSize)
                                            .position(x: layoutDirection == .rightToLeft ? plot.maxX + axisIconSize / 2 + 8 : plot.minX - axisIconSize / 2 - 8, y: plot.minY + y)
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                        }
                        .allowsHitTesting(false)
                    }
                    .chartLegend(.hidden)
                    .frame(height: min(chartHeight, 480))
                    .accessibilityLabel("Daily mood trend")
                    .accessibilityHint("Mood emojis run from Angry at the bottom to Laughing at the top.")
                    Text("Each point summarizes a day's mood. Gaps are days without a saved page.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var axisIconSize: CGFloat { min(scaledAxisIconSize, 48) }

    private func dateLabelAnchor(for value: AxisValue) -> UnitPoint {
        // Keep endpoint labels inside the plot, so the last date is never clipped.
        if value.index == 0 { return .topLeading }
        if value.index == value.count - 1 { return .topTrailing }
        return .top
    }

    private func mood(for value: Double) -> Mood {
        Mood(rawValue: min(max(Int(value.rounded()), 1), 5)) ?? .mourn
    }
}
