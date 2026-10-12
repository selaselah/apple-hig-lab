import SwiftUI

enum GaugeKind: String, CaseIterable, Identifiable {
    case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity
    case accessoryCircular, accessoryCircularCapacity
    case linear, circular

    var id: String { rawValue }
    var title: String {
        switch self {
        case .automatic: "默认样式"
        case .linearCapacity: "线性容量"
        case .accessoryLinear: "线性位置"
        case .accessoryLinearCapacity: "紧凑线性容量"
        case .accessoryCircular: "环形位置"
        case .accessoryCircularCapacity: "环形容量"
        case .linear: "标准线性"
        case .circular: "标准环形"
        }
    }
    var api: String { self == .automatic ? ".automatic" : ".\(rawValue)" }
    var watchOSOnly: Bool { self == .linear || self == .circular }
    var availableOnCurrentPlatform: Bool {
        #if os(watchOS)
        true
        #else
        !watchOSOnly
        #endif
    }
    var accessory: Bool { rawValue.hasPrefix("accessory") }
    var note: String {
        switch self {
        case .automatic: "由平台选择默认呈现。在 iOS 上，它采用线性容量样式。"
        case .linearCapacity: "轨道从起点填充到当前值，适合电量、存储等容量信息。"
        case .accessoryLinear: "用标记定位当前值，保留完整轨道，适合温度等区间数据。"
        case .accessoryLinearCapacity: "以紧凑的填充轨道表达容量，适合信息密集的布局。"
        case .accessoryCircular: "用开口圆环与标记表达数值在范围中的位置。"
        case .accessoryCircularCapacity: "沿圆环填充容量，以中央标签补充当前数值。"
        case .linear: "watchOS 专属：在线性轨道上，用标记指示当前数值的位置。"
        case .circular: "watchOS 专属：在开口圆环上，用标记指示当前数值的位置。"
        }
    }
    var source: String {
        #"""
        Gauge(value: value, in: 0...100) {
            Text("电量")
        } currentValueLabel: {
            Text("\(Int(value))%")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("100")
        }
        .gaugeStyle(\#(api))
        .tint(.orange)
        """#
    }
}

/// Supported specimens use real Gauges; unavailable styles show a platform placeholder.
struct GaugeStyleExample: View {
    let kind: GaugeKind
    var value: Double = 64
    var range: ClosedRange<Double> = 0...100
    var title = "电量"
    var unit = "%"
    var labels = true
    var gradient = false
    var color: Color = LabTheme.accent

    private var gauge: some View {
        Gauge(value: value, in: range) {
            Text(title)
        } currentValueLabel: {
            if labels { Text("\(Int(value))\(unit)").monospacedDigit() }
        } minimumValueLabel: {
            if labels { Text("\(Int(range.lowerBound))") }
        } maximumValueLabel: {
            if labels { Text("\(Int(range.upperBound))") }
        }
    }

    @ViewBuilder private var styled: some View {
        switch kind {
        case .automatic: gauge.gaugeStyle(.automatic)
        case .linearCapacity: gauge.gaugeStyle(.linearCapacity)
        case .accessoryLinear: gauge.gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity: gauge.gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular: gauge.gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: gauge.gaugeStyle(.accessoryCircularCapacity)
        case .linear:
            #if os(watchOS)
            gauge.gaugeStyle(.linear)
            #else
            EmptyView()
            #endif
        case .circular:
            #if os(watchOS)
            gauge.gaugeStyle(.circular)
            #else
            EmptyView()
            #endif
        }
    }

    var body: some View {
        if kind.availableOnCurrentPlatform {
            liveGauge
        } else {
            VStack(spacing: 10) {
                Image(systemName: "applewatch").font(.title2)
                Text("当前平台不支持").font(.caption)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(.primary.opacity(0.025), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(kind.title)，watchOS only，当前平台不支持，仅展示占位")
            .accessibilityIdentifier("placeholder-\(kind.id)")
        }
    }

    private var liveGauge: some View {
        Group {
            if gradient {
                styled.tint(Gradient(colors: LabTheme.spectrum))
            } else {
                styled.tint(color)
            }
        }
        // Some styles omit visual labels; the semantic description remains complete.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("当前 \(Int(value))\(unit)，范围 \(Int(range.lowerBound)) 到 \(Int(range.upperBound))\(unit)")
        .accessibilityIdentifier("gauge-\(kind.id)")
    }
}
