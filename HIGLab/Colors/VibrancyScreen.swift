import SwiftUI

struct VibrancyScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/materials")!
    @State private var dark = true
    @State private var backdrop = 0
    @State private var thickness = 1

    private var material: Material {
        switch thickness {
        case 0: .thinMaterial
        case 2: .thickMaterial
        default: .regularMaterial
        }
    }

    private var colors: [Color] {
        switch backdrop {
        case 1: [.indigo, .blue, .cyan]
        case 2: [.pink, .purple, .teal]
        default: [.brown, .orange, .yellow]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(
                    eyebrow: "COLORS · MATERIAL & VIBRANCY",
                    title: "让文字与背后的材质一起变化",
                    detail: "切换暖色、冷色背景，观察系统次要文字的色调。另一组使用显式灰度颜色作对照；Primary 通常仍接近黑或白。"
                )
                LabCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("示例外观", selection: $dark) {
                            Text("Light · 浅色").tag(false)
                            Text("Dark · 深色").tag(true)
                        }
                        .accessibilityIdentifier("vibrancy-appearance")
                        Picker("背后颜色", selection: $backdrop) {
                            Text("暖色").tag(0)
                            Text("冷色").tag(1)
                            Text("多彩").tag(2)
                        }
                        .accessibilityIdentifier("vibrancy-backdrop")
                        Picker("材质厚度", selection: $thickness) {
                            Text("Thin").tag(0)
                            Text("Regular").tag(1)
                            Text("Thick").tag(2)
                        }
                        .accessibilityIdentifier("vibrancy-thickness")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)
                }

                VStack(alignment: .leading, spacing: 24) {
                    Text("同一块材质 · 两种前景绘制方式")
                        .font(.headline)
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 28) {
                            vibrantColumn.frame(minWidth: 210)
                            fixedColumn.frame(minWidth: 210)
                        }
                        VStack(alignment: .leading, spacing: 28) {
                            vibrantColumn
                            Divider()
                            fixedColumn
                        }
                    }
                    Divider()
                    Text("指定红色的文字")
                        .font(.title3.bold())
                        .foregroundStyle(.red)
                    Text(".foregroundStyle(.red) · 自定义颜色退出 Vibrancy")
                        .font(.caption.monospaced())
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(material, in: RoundedRectangle(cornerRadius: 28))
                .padding(28)
                .background {
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .environment(\.colorScheme, dark ? .dark : .light)
                .accessibilityIdentifier("vibrancy-preview")

                Text("系统组使用 .primary / .secondary / .tertiary / .quaternary 层级样式。对照组是手动指定的不透明灰度颜色，供观察渲染差异，并非要求两组初始亮度完全相同。材质、外观和背景都会影响最终效果。")
                    .font(.callout).foregroundStyle(.secondary)
                Text("如果效果不明显，可试试 Thin；系统的‘降低透明度’等辅助功能设置也可能改变材质表现。这里演示的是 SwiftUI Material，并非专门的 Liquid Glass API。")
                    .font(.callout).foregroundStyle(.secondary)
                LabCard {
                    DisclosureGroup("查看 SwiftUI 示例代码") {
                        SourceCodeBlock(title: "Material + 系统层级前景", source: Self.source, identifier: "vibrancy-source")
                            .padding(.top, 16)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 1100)
            .frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Vibrancy · 材质上的文字")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var vibrantColumn: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("系统层级 · Vibrancy").font(.subheadline.bold())
            sample("Primary").foregroundStyle(.primary)
            sample("Secondary").foregroundStyle(.secondary)
            sample("Tertiary").foregroundStyle(.tertiary)
            sample("Quaternary").foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fixedColumn: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("显式灰度 · 无 Vibrancy").font(.subheadline.bold())
            sample("Primary 对照").foregroundStyle(dark ? Color.white : Color.black)
            sample("Secondary 对照").foregroundStyle(Color(white: dark ? 0.65 : 0.45))
            sample("Tertiary 对照").foregroundStyle(Color(white: dark ? 0.5 : 0.6))
            sample("Quaternary 对照").foregroundStyle(Color(white: dark ? 0.4 : 0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sample(_ title: String) -> some View {
        Label(title, systemImage: "textformat")
            .font(.title3.weight(.semibold))
            .fixedSize(horizontal: false, vertical: true)
    }

    static let source = """
    import SwiftUI

    struct VibrancyExample: View {
        var body: some View {
            ZStack {
                // 换成蓝色 / 青色，观察次要文字的色调变化。
                LinearGradient(colors: [.orange, .yellow],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)

                VStack(alignment: .leading, spacing: 24) {
                    Text("主要文字").foregroundStyle(.primary)
                    Text("次要说明").foregroundStyle(.secondary)
                    Text("第三级说明").foregroundStyle(.tertiary)
                    Text("第四级说明").foregroundStyle(.quaternary)
                    Divider()
                    Text("固定灰色对照")
                        .foregroundStyle(Color(white: 0.6))
                    Text("指定红色")
                        .foregroundStyle(.red)
                }
                .font(.title2)
                .padding(32)
                .background(.regularMaterial,
                            in: RoundedRectangle(cornerRadius: 24))
                .padding(24)
            }
            .preferredColorScheme(.dark) // 也可以改成 .light
        }
    }
    """
}

#Preview { NavigationStack { VibrancyScreen() } }
