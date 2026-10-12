import SwiftUI

struct GaugeScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/gauges")!
    let page: GaugePage
    @State private var value = 64.0
    @State private var gradient = false
    @State private var labels = true
    @State private var code: GaugeKind?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicType

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: dynamicType.isAccessibilitySize ? 320 : 280), spacing: 16, alignment: .top)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                header
                switch page {
                case .overview:
                    playground
                    gallery
                    overviewFooter
                case .styles:
                    playground
                    gallery
                case .scenarios:
                    GaugeScenariosView()
                case .guidelines:
                    GaugeGuidelinesView()
                case .levels:
                    LevelIndicatorsView()
                }
                HStack(spacing: 6) {
                    Image(systemName: "book.closed")
                    Link("阅读 Apple HIG · Gauges", destination: Self.higURL)
                }.font(.footnote).padding(.bottom, 10)
            }
            .padding(.horizontal, 24).padding(.vertical, 28)
            .frame(maxWidth: 1180)
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier("gauge-scroll")
        .background(LabTheme.background)
        .navigationTitle("Gauges")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $code) { CodeSheet(kind: $0) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COMPONENTS / GAUGES")
                    .font(.caption.weight(.semibold)).tracking(2).foregroundStyle(LabTheme.accent)
                Spacer()
                Pill(text: "01")
            }
            Text(page == .overview ? "让数值，一目了然。" : page.rawValue)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text(headerDetail)
                .font(.body).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var headerDetail: String {
        switch page {
        case .overview: "Gauge 将一个具体数值放进有限范围。探索系统样式，观察位置与容量如何表达不同含义。"
        case .styles: "八个内置样式选项：六个可运行示例，以及两个 watchOS 专属占位。调节数值，对比当前平台的原生呈现。"
        case .scenarios: "从区间位置到容量占比，为每种数据选择合适的表达。所有数值均为可调节的演示数据。"
        case .guidelines: "把 HIG 的建议放进实际界面：清晰标签、有含义的颜色，以及完整的辅助功能描述。"
        case .levels: "macOS 原生 NSLevelIndicator：连续容量、离散容量、分层阈值与相关度。"
        }
    }

    private var playground: some View {
        LabCard {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 32) {
                    heroGauge.frame(width: 230)
                    Divider().frame(height: 190)
                    controls.frame(minWidth: 290)
                }
                VStack(spacing: 24) {
                    heroGauge
                    Divider()
                    controls
                }
            }
        }
    }

    private var heroGauge: some View {
        VStack(spacing: 18) {
            Text("LIVE PREVIEW").font(.caption2.weight(.semibold)).tracking(1.5).foregroundStyle(.secondary)
            GaugeStyleExample(kind: .accessoryCircular, value: value, labels: labels, gradient: gradient)
                .scaleEffect(2.1)
                .frame(width: 180, height: 150)
            Text("环形位置 · 原生控件放大展示").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("试着改变一个数值").font(.headline)
                    Text("下方可用样式同步更新").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 12)
                Text("\(Int(value))%")
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .monospacedDigit().foregroundStyle(LabTheme.accent)
                    .accessibilityIdentifier("live-value")
            }
            Slider(value: $value, in: 0...100, step: 1) {
                Text("演示数值")
            } minimumValueLabel: { Text("0").font(.caption) }
              maximumValueLabel: { Text("100").font(.caption) }
                .accessibilityIdentifier("demo-slider")
            HStack(spacing: 10) {
                ForEach([0, 50, 100], id: \.self) { preset in
                    Button("\(preset)%") {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { value = Double(preset) }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("preset-\(preset)")
                }
                Spacer(minLength: 0)
                Button { value = 64; gradient = false; labels = true } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered).accessibilityLabel("重置演示")
                .accessibilityIdentifier("reset-demo")
            }
            Toggle("语义渐变色", isOn: $gradient).accessibilityIdentifier("gradient-toggle")
            Toggle("显示数值与端点", isOn: $labels).accessibilityIdentifier("labels-toggle")
            Text("Slider 用于调节演示数据；Gauge 本身只读。隐藏视觉标签时，仍保留完整的辅助功能描述。")
                .font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }

    private var gallery: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeading(eyebrow: "STYLE ATLAS", title: "八个选项，按平台查看", detail: "6 个可运行示例 · 2 个 watchOS 专属占位。automatic 在 iOS 上与 linearCapacity 外观相同。")
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(GaugeKind.allCases) { kind in
                    LabCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(kind.title).font(.headline)
                                Spacer()
                                if kind.accessory { Pill(text: "Accessory") }
                                if kind.watchOSOnly { Pill(text: "watchOS only", color: .secondary) }
                            }
                            Text(kind.api).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                            GaugeStyleExample(kind: kind, value: value, labels: labels, gradient: gradient)
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                            Text(kind.note).font(.subheadline).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(minHeight: 58, alignment: .top)
                            Button { code = kind } label: {
                                Label("查看 SwiftUI 代码", systemImage: "chevron.left.forwardslash.chevron.right")
                                    .font(.caption.weight(.medium))
                            }
                            .buttonStyle(.borderless)
                            .accessibilityIdentifier("code-\(kind.id)")
                        }
                    }
                }
            }
        }
    }

    private var overviewFooter: some View {
        LabCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("先分清位置，再表达容量", systemImage: "lightbulb")
                    .font(.headline).foregroundStyle(LabTheme.accent)
                Text("温度关心的是当前值在冷暖区间中的位置；电量关心的是已占用的容量。标签说明含义，颜色提供线索。")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text("从目录进入「场景演示」和「设计要点」，继续探索。macOS 工程还包含 Level Indicator 专属案例。")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
