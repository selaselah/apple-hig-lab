import SwiftUI
#if os(macOS)
import AppKit
#endif

enum LevelIndicatorKind: String, CaseIterable, Identifiable {
    case continuous, discrete, tiered, relevancy
    var id: String { rawValue }
    var title: String {
        switch self {
        case .continuous: "连续容量"
        case .discrete: "离散容量"
        case .tiered: "分层阈值"
        case .relevancy: "相关度"
        }
    }
    var styleName: String {
        switch self {
        case .continuous, .tiered: ".continuousCapacity"
        case .discrete: ".discreteCapacity"
        case .relevancy: ".relevancy"
        }
    }
    var api: String { self == .tiered ? "drawsTieredCapacityLevels = true" : styleName }
    var detail: String {
        switch self {
        case .continuous: "以连续填充展示大范围数值，整条填充根据阈值切换颜色。"
        case .discrete: "每一格代表 10 个单位，只填充完整格；按当前等级统一着色。"
        case .tiered: "同一条容量指示器分段显示绿色、黄色和红色，对比整条变色。"
        case .relevancy: "以阴影条表示相关程度，适合比较搜索结果；HIG 建议谨慎使用。"
        }
    }
    var maximum: Double { self == .discrete ? 10 : 100 }
    func displayValue(_ value: Double) -> Double { self == .discrete ? floor(value / 10) : value }

    #if os(macOS)
    var style: NSLevelIndicator.Style {
        switch self {
        case .continuous, .tiered: .continuousCapacity
        case .discrete: .discreteCapacity
        case .relevancy: .relevancy
        }
    }
    #endif

    var appKitSource: String {
        """
        import AppKit

        let indicator = NSLevelIndicator()
        indicator.isEditable = false
        indicator.levelIndicatorStyle = \(styleName)
        indicator.minValue = 0
        indicator.maxValue = \(Int(maximum))
        indicator.warningValue = \(maximum * 0.6)
        indicator.criticalValue = \(maximum * 0.85)
        indicator.drawsTieredCapacityLevels = \(self == .tiered)
        indicator.fillColor = .systemGreen
        indicator.warningFillColor = .systemYellow
        indicator.criticalFillColor = .systemRed
        indicator.doubleValue = \(self == .discrete ? "floor(72.0 / 10)" : "72")
        // Add indicator to your AppKit view and provide layout constraints.
        """
    }

    var swiftUISource: String {
        #"""
        #if os(macOS)
        import SwiftUI
        import AppKit

        struct LevelIndicatorDemo: View {
            @State private var value = 72.0

            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    Text("当前数值：\(Int(value)) / 100")
                    NativeIndicator(value: \#(self == .discrete ? "floor(value / 10)" : "value"))
                        .frame(height: 28)
                    Slider(value: $value, in: 0...100, step: 1) {
                        Text("调节数值")
                    }
                }
                .padding()
            }
        }

        private struct NativeIndicator: NSViewRepresentable {
            let value: Double

            func makeNSView(context: Context) -> NSLevelIndicator {
                let indicator = NSLevelIndicator()
                indicator.isEditable = false
                return indicator
            }

            func updateNSView(_ indicator: NSLevelIndicator, context: Context) {
                indicator.levelIndicatorStyle = \#(styleName)
                indicator.minValue = 0
                indicator.maxValue = \#(Int(maximum))
                indicator.warningValue = \#(maximum * 0.6)
                indicator.criticalValue = \#(maximum * 0.85)
                indicator.drawsTieredCapacityLevels = \#(self == .tiered)
                indicator.fillColor = .systemGreen
                indicator.warningFillColor = .systemYellow
                indicator.criticalFillColor = .systemRed
                indicator.doubleValue = value
                indicator.setAccessibilityLabel("\#(self == .relevancy ? "相关度" : "容量")，当前 \(Int(value))，范围 0 到 \#(Int(maximum))")
            }
        }
        #endif
        """#
    }
}

#if os(macOS)

struct NativeLevelIndicator: NSViewRepresentable {
    let style: NSLevelIndicator.Style
    let value: Double
    var maximum = 100.0
    var tiered = false

    func makeNSView(context: Context) -> NSLevelIndicator {
        let view = NSLevelIndicator()
        view.isEditable = false
        return view
    }

    func updateNSView(_ view: NSLevelIndicator, context: Context) {
        view.levelIndicatorStyle = style
        view.minValue = 0
        view.maxValue = maximum
        view.warningValue = maximum * 0.6
        view.criticalValue = maximum * 0.85
        view.drawsTieredCapacityLevels = tiered
        view.fillColor = .systemGreen
        view.warningFillColor = .systemYellow
        view.criticalFillColor = .systemRed
        view.doubleValue = value
        view.setAccessibilityLabel("\(style == .relevancy ? "相关度" : "容量")，当前 \(Int(value))，范围 0 到 \(Int(maximum))")
    }
}

struct LevelIndicatorsView: View {
    @State private var value = 72.0
    @State private var code: LevelIndicatorKind?
    private var status: String { value > 85 ? "临界" : value > 60 ? "警告" : "正常" }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeading(eyebrow: "MACOS / APPKIT", title: "Mac 专属的原生指示器", detail: "Gauge 之外，AppKit 还提供 NSLevelIndicator。分层阈值是容量样式的一种配置；相关度是独立样式。")
            LabCard {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("容量 \(Int(value)) / 100").font(.title2.bold()).monospacedDigit()
                            .accessibilityIdentifier("level-value")
                        Spacer()
                        Pill(text: status, color: value > 85 ? .red : value > 60 ? .orange : .green)
                    }
                    Slider(value: $value, in: 0...100, step: 1) { Text("调节容量") }
                    HStack {
                        Button("正常 25") { value = 25 }
                        Button("警告 72") { value = 72 }
                        Button("临界 95") { value = 95 }
                    }.buttonStyle(.bordered)
                    Text("示例阈值：超过 60 为警告，超过 85 为临界。离散案例按 10 格取整。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                ForEach(LevelIndicatorKind.allCases) { kind in
                    example(kind)
                }
            }
            Link("NSLevelIndicator 开发文档", destination: URL(string: "https://developer.apple.com/documentation/appkit/nslevelindicator")!)
        }
        .sheet(item: $code) { LevelIndicatorCodeSheet(kind: $0) }
    }

    private func example(_ kind: LevelIndicatorKind) -> some View {
        LabCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(kind.title).font(.headline)
                Text(kind.api).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                Text(kind.detail).font(.subheadline).foregroundStyle(.secondary)
                    .frame(minHeight: 44, alignment: .top)
                NativeLevelIndicator(style: kind.style, value: kind.displayValue(value), maximum: kind.maximum, tiered: kind == .tiered)
                    .frame(height: 28)
                Button { code = kind } label: {
                    Label("查看实现代码", systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("level-code-\(kind.id)")
            }
        }
    }
}
#else
struct LevelIndicatorsView: View {
    @State private var code: LevelIndicatorKind?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LabCard {
                VStack(alignment: .leading, spacing: 12) {
                    Pill(text: "macOS only", color: .secondary)
                    Text("这些案例使用 AppKit 的 NSLevelIndicator。").font(.headline)
                    Text("在 Xcode 中选择 HIGLabMac Scheme，按 ⌘R 查看真实控件与阈值交互。当前平台展示占位。")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                ForEach(LevelIndicatorKind.allCases) { kind in
                    LabCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(kind.title).font(.headline)
                                Spacer()
                                Pill(text: "macOS only", color: .secondary)
                            }
                            Text(kind.api).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                            VStack(spacing: 10) {
                                Image(systemName: "macwindow").font(.title2)
                                Text("当前平台不支持").font(.caption)
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(.primary.opacity(0.025), in: RoundedRectangle(cornerRadius: 12))
                            Text(kind.detail).font(.subheadline).foregroundStyle(.secondary)
                                .frame(minHeight: 44, alignment: .top)
                            Button { code = kind } label: {
                                Label("查看实现代码", systemImage: "chevron.left.forwardslash.chevron.right")
                                    .font(.caption.weight(.medium))
                            }
                            .buttonStyle(.borderless)
                            .accessibilityIdentifier("level-code-\(kind.id)")
                        }
                    }
                }
            }
            Link("NSLevelIndicator 开发文档", destination: URL(string: "https://developer.apple.com/documentation/appkit/nslevelindicator")!)
        }
        .sheet(item: $code) { LevelIndicatorCodeSheet(kind: $0) }
    }
}
#endif
