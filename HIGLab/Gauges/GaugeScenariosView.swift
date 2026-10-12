import SwiftUI

struct GaugeScenariosView: View {
    @State private var temperature = 22.0
    @State private var battery = 64.0
    @State private var storage = 96.0

    private var batteryColor: Color { battery <= 20 ? .red : .green }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SectionHeading(eyebrow: "01 / POSITION", title: "温度 · 在范围中的位置", detail: "冷暖渐变表达区间语义，当前值与单位让颜色有明确含义。")
            LabCard {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .firstTextBaseline) {
                        Label("室外温度", systemImage: "thermometer.medium").font(.headline)
                        Spacer()
                        Text("\(Int(temperature))°C").font(.title2.bold()).monospacedDigit()
                            .accessibilityIdentifier("temperature-value")
                    }
                    GaugeStyleExample(kind: .accessoryLinear, value: temperature, range: -10...40,
                                      title: "室外温度", unit: "°C", gradient: true)
                    HStack {
                        Text("−10°C · 寒冷")
                        Spacer()
                        Text("40°C · 炎热")
                    }.font(.caption).foregroundStyle(.secondary)
                    Slider(value: $temperature, in: -10...40, step: 1) { Text("调节温度") }
                        .accessibilityIdentifier("temperature-slider")
                    HStack {
                        Button("寒冷 −5°C") { temperature = -5 }.accessibilityIdentifier("temperature-cold")
                        Button("适宜 22°C") { temperature = 22 }
                        Button("炎热 38°C") { temperature = 38 }.accessibilityIdentifier("temperature-hot")
                    }.buttonStyle(.bordered)
                }
            }
            SectionHeading(eyebrow: "02 / CAPACITY", title: "电量 · 还剩多少", detail: "填充表达剩余容量。低电量同时显示文字提示，避免只依赖红色。")
            LabCard {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Label("设备电量", systemImage: battery <= 20 ? "battery.25percent" : "battery.75percent").font(.headline)
                        Spacer()
                        Text(battery <= 20 ? "低电量" : "电量充足")
                            .font(.subheadline.weight(.medium)).foregroundStyle(batteryColor)
                            .accessibilityIdentifier("battery-status")
                    }
                    GaugeStyleExample(kind: .linearCapacity, value: battery, title: "剩余电量", color: batteryColor)
                    Slider(value: $battery, in: 0...100, step: 1) { Text("调节电量") }
                    HStack {
                        Button("低电量 15%") { battery = 15 }.accessibilityIdentifier("battery-low")
                        Button("满电 100%") { battery = 100 }.accessibilityIdentifier("battery-full")
                    }.buttonStyle(.bordered)
                    Text("示例阈值：≤ 20% 为低电量。这里的数值和阈值仅用于演示。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            SectionHeading(eyebrow: "03 / COMPACT", title: "存储 · 紧凑的容量概览", detail: "Accessory 样式延续复杂功能的视觉语言，可以用于需要紧凑信息的界面。")
            LabCard {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 24) {
                        GaugeStyleExample(kind: .accessoryCircularCapacity, value: storage,
                                          range: 0...256, title: "已用存储", unit: " GB", color: .indigo)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("已用 \(Int(storage)) GB").font(.headline).monospacedDigit()
                            Text("总容量 256 GB · 剩余 \(256 - Int(storage)) GB")
                                .font(.subheadline).foregroundStyle(.secondary)
                                .accessibilityIdentifier("storage-remaining")
                        }
                    }
                    GaugeStyleExample(kind: .accessoryLinearCapacity, value: storage,
                                      range: 0...256, title: "已用存储", unit: " GB", color: .indigo)
                    Slider(value: $storage, in: 0...256, step: 1) { Text("调节已用存储") }
                    Text("这是 App 内的样式示例。真正的锁屏 Widget 还需要 WidgetKit extension。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}
