import SwiftUI

struct GaugeGuidelinesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            principle(number: "01", title: "标签要简洁，也要完整", symbol: "textformat", detail: "说明测量对象、当前数值、单位和范围端点。即使某个样式没有显示所有标签，辅助功能仍需要这些信息。") {
                GaugeStyleExample(kind: .linearCapacity, value: 64, title: "剩余电量")
                Text("剩余电量 · 当前 64% · 范围 0–100%")
                    .font(.caption).foregroundStyle(.secondary)
            }
            principle(number: "02", title: "让渐变表达数据含义", symbol: "paintpalette", detail: "温度可以从蓝色过渡到红色。对单一容量数据，统一色彩通常更直接。颜色之外，保留可读的数值与单位。") {
                GaugeStyleExample(kind: .accessoryLinear, value: 22, range: -10...40,
                                  title: "室外温度", unit: "°C", gradient: true)
                Text("−10°C → 40°C · 寒冷到炎热").font(.caption).foregroundStyle(.secondary)
            }
            principle(number: "03", title: "选择位置标记或容量填充", symbol: "gauge.with.dots.needle.67percent", detail: "标准位置样式用标记指出数值在轨道上的位置；容量样式填充到当前值。根据测量对象选择表达方式。") {
                GaugeStyleExample(kind: .accessoryLinear, value: 64, title: "范围位置")
                GaugeStyleExample(kind: .linearCapacity, value: 64, title: "剩余容量")
            }
            principle(number: "04", title: "理解平台边界", symbol: "macbook.and.iphone", detail: "HIG 支持 iOS、iPadOS、macOS、watchOS 和 visionOS 的 Gauge；tvOS 不支持。Accessory 呈现适合呼应复杂功能或锁屏 Widget 的视觉语言。") {
                Text("本工程实现 iPhone / iPad 与 macOS。macOS target 另外展示 NSLevelIndicator；没有包含 watchOS、visionOS 或 Widget extension。")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            LabCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("辅助功能检查", systemImage: "accessibility").font(.headline)
                    Text("所有 Gauge 提供测量对象、当前值与完整范围的 VoiceOver 描述；布局支持 Dynamic Type 和系统深色模式；数值预设动画遵循「减少动态效果」。")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("可在系统设置中开启 VoiceOver 或增大文字，检查当前示例。以上设计要点为 HIG 的中文摘要与工程实现说明。")
                        .font(.caption).foregroundStyle(.secondary)
                    Link("查看 Apple 原文", destination: GaugeScreen.higURL)
                }
            }
        }
    }

    private func principle<Content: View>(number: String, title: String, symbol: String,
                                          detail: String, @ViewBuilder content: () -> Content) -> some View {
        LabCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Text(number).font(.system(.title2, design: .rounded, weight: .bold)).foregroundStyle(LabTheme.accent)
                    VStack(alignment: .leading, spacing: 8) {
                        Label(title, systemImage: symbol).font(.headline)
                        Text(detail).font(.subheadline).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Divider()
                content()
            }
        }
    }
}
