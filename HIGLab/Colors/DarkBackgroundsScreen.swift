import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DarkBackgroundsScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/dark-mode")!
    @State private var showingDemo = false
    @State private var darkPreview = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(
                    eyebrow: "COLORS · INTERFACE LEVEL",
                    title: "同一个颜色，两种界面层级",
                    detail: "Base 用于基础界面；Elevated 用于浮在上面的界面。深色模式下，Elevated 背景通常更亮，让前后层次更容易分辨。"
                )
                #if os(iOS)
                BackgroundAppearancePicker(darkPreview: $darkPreview)
                Button {
                    showingDemo = true
                } label: {
                    Label("打开主页面与 Sheet 演示", systemImage: "rectangle.on.rectangle")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("open-dark-background-demo")

                Text("色板对比 · 使用所选外观和标准对比度，分别解析 Base / Elevated；不是两个真实窗口。")
                    .font(.callout).foregroundStyle(.secondary)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        ResolvedBackgroundPalette(elevated: false, darkPreview: darkPreview).frame(minWidth: 280)
                        ResolvedBackgroundPalette(elevated: true, darkPreview: darkPreview).frame(minWidth: 280)
                    }
                    VStack(spacing: 16) {
                        ResolvedBackgroundPalette(elevated: false, darkPreview: darkPreview)
                        ResolvedBackgroundPalette(elevated: true, darkPreview: darkPreview)
                    }
                }
                .environment(\.colorScheme, darkPreview ? .dark : .light)
                #else
                LabCard {
                    Label("iOS / iPadOS 示例", systemImage: "ipad.and.iphone")
                    Text("这里演示 UIKit 的界面层级和动态背景色。请在 iPhone 或 iPad 上运行交互示例；下方代码可复制到 iOS target。")
                        .foregroundStyle(.secondary)
                }
                #endif
                LabCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("别把两个维度混在一起").font(.headline)
                        Text("Base / Elevated：整个界面的呈现层级。\nPrimary / Secondary / Tertiary：同一界面内的背景层级。")
                        Text("两边使用完全相同的三个颜色名称。不要为了让 Sheet 变亮，手动把 systemBackground 换成 secondarySystemBackground。颜色值由当前系统决定。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 SwiftUI 示例代码") {
                        SourceCodeBlock(title: "主页面和 Sheet 复用同一内容", source: Self.source, identifier: "dark-backgrounds-source")
                            .padding(.top, 16)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 1100)
            .frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Base / Elevated")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingDemo) {
            DarkBackgroundLiveDemo(darkPreview: $darkPreview)
                .preferredColorScheme(darkPreview ? .dark : .light)
        }
        #endif
    }

    static let source = """
    import SwiftUI

    // 在 iOS App 的根页面展示此 View。
    struct BackgroundLevelExample: View {
        @State private var showSheet = false
        @State private var dark = true

        var body: some View {
            NavigationStack {
                VStack {
                    Toggle("深色模式", isOn: $dark).padding()
                    BackgroundSurface()
                }
                .toolbar {
                    Button("打开 Sheet") { showSheet = true }
                }
            }
            .preferredColorScheme(dark ? .dark : .light)
            .sheet(isPresented: $showSheet) {
                VStack {
                    Toggle("深色模式", isOn: $dark).padding()
                    BackgroundSurface() // 完全相同的内容和颜色
                }
                .preferredColorScheme(dark ? .dark : .light)
                .presentationDetents([.medium, .large])
            }
        }
    }

    struct BackgroundSurface: View {
        var body: some View {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 24) {
                    Text("systemBackground")
                    VStack(alignment: .leading, spacing: 24) {
                        Text("secondarySystemBackground")
                        Text("tertiarySystemBackground")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(uiColor: .tertiarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .padding(24)
            }
        }
    }
    // 不设置 userInterfaceLevel，也不使用固定 RGB。
    // 系统根据页面的呈现环境解析动态颜色。
    """
}

#if os(iOS)
private struct BackgroundAppearancePicker: View {
    @Binding var darkPreview: Bool

    var body: some View {
        Picker("示例外观", selection: $darkPreview) {
            Text("Light · 浅色").tag(false)
            Text("Dark · 深色").tag(true)
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 340)
        .accessibilityIdentifier("level-preview-appearance")
    }
}

private struct ResolvedBackgroundPalette: View {
    let elevated: Bool
    let darkPreview: Bool
    private var traits: UITraitCollection {
        UITraitCollection { traits in
            traits.userInterfaceStyle = darkPreview ? .dark : .light
            traits.userInterfaceLevel = elevated ? .elevated : .base
            traits.accessibilityContrast = .normal
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("\(darkPreview ? "Dark" : "Light") · \(elevated ? "Elevated" : "Base")").font(.title3.bold())
            Text(darkPreview
                 ? (elevated ? "浮起的界面 · 背景更亮" : "基础界面 · 背景更暗")
                 : (elevated ? "浮起的界面 · 颜色不一定改变" : "基础界面 · 比较同名颜色"))
                .font(.subheadline).foregroundStyle(.secondary)
            swatch("systemBackground", .systemBackground)
            swatch("secondarySystemBackground", .secondarySystemBackground)
            swatch("tertiarySystemBackground", .tertiarySystemBackground)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: UIColor.systemBackground.resolvedColor(with: traits)),
                    in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24).strokeBorder(.primary.opacity(0.2))
        }
    }

    private func swatch(_ name: String, _ color: UIColor) -> some View {
        let resolved = color.resolvedColor(with: traits)
        return VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: resolved))
                .frame(height: 48)
                .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(.primary.opacity(0.15)) }
            Text(name).font(.system(.caption, design: .monospaced))
                .fixedSize(horizontal: false, vertical: true)
            Text(resolved.rgbDescription).font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct DarkBackgroundLiveDemo: View {
    @Binding var darkPreview: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showingSheet = false

    var body: some View {
        NavigationStack {
            LiveBackgroundSurface(isSheet: false, darkPreview: $darkPreview)
                .navigationTitle("主页面")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("完成") { dismiss() }
                            .accessibilityIdentifier("close-dark-background-demo")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("打开 Sheet") { showingSheet = true }
                            .accessibilityIdentifier("show-elevated-sheet")
                    }
                }
        }
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                LiveBackgroundSurface(isSheet: true, darkPreview: $darkPreview)
                    .navigationTitle("Sheet · 相同的颜色代码")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("关闭") { showingSheet = false }
                                .accessibilityIdentifier("close-elevated-sheet")
                        }
                    }
            }
            .preferredColorScheme(darkPreview ? .dark : .light)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

private struct LiveBackgroundSurface: View {
    let isSheet: Bool
    @Binding var darkPreview: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(isSheet ? "对照主页面，观察层级与色值" : "先观察底色，再打开 Sheet")
                    .font(.title2.bold())
                Text("下方读数来自此界面的 UIKit traitCollection。这里没有手动指定 Base 或 Elevated。")
                    .font(.callout).foregroundStyle(.secondary)
                BackgroundAppearancePicker(darkPreview: $darkPreview)
                Text(darkPreview ? "深色：Elevated 背景通常更亮。" : "浅色：界面层级仍会改变，但同名背景色可能相同。")
                    .font(.callout).foregroundStyle(.secondary)
                InterfaceLevelReadout(identifier: isSheet ? "sheet-interface-level" : "page-interface-level")
                    .frame(height: 58)
                Text("① systemBackground").font(.system(.callout, design: .monospaced))
                VStack(alignment: .leading, spacing: 24) {
                    Text("② secondarySystemBackground")
                    Text("③ tertiarySystemBackground")
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .font(.system(.callout, design: .monospaced))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
                Text("Sheet 外面的页面还会被系统遮罩压暗；请结合层级读数和前页色板判断，不要只比较遮罩下的颜色。")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: 800, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

// 只读取所在界面的实际 traits，不覆盖层级，也不把解析结果用于页面背景。
private struct InterfaceLevelReadout: UIViewRepresentable {
    let identifier: String

    func makeUIView(context: Context) -> LevelLabel {
        let label = LevelLabel()
        label.accessibilityIdentifier = identifier
        return label
    }

    func updateUIView(_ uiView: LevelLabel, context: Context) { uiView.refresh() }

    final class LevelLabel: UILabel {
        override init(frame: CGRect) {
            super.init(frame: frame)
            numberOfLines = 0
            font = .preferredFont(forTextStyle: .footnote)
            adjustsFontForContentSizeCategory = true
            textColor = .label
            registerForTraitChanges([UITraitUserInterfaceLevel.self, UITraitUserInterfaceStyle.self,
                                     UITraitAccessibilityContrast.self]) { (view: LevelLabel, _: UITraitCollection) in
                view.refresh()
            }
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override func didMoveToWindow() { super.didMoveToWindow(); refresh() }

        func refresh() {
            let level = traitCollection.userInterfaceLevel == .elevated ? "Elevated" : "Base"
            let style = traitCollection.userInterfaceStyle == .dark ? "Dark" : "Light"
            let color = UIColor.systemBackground.resolvedColor(with: traitCollection)
            text = "实际环境：\(style) · \(level)\nsystemBackground：\(color.rgbDescription)"
        }
    }
}

private extension UIColor {
    var rgbDescription: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return "非 RGB 颜色" }
        return String(format: "#%02X%02X%02X", Int((r * 255).rounded()), Int((g * 255).rounded()), Int((b * 255).rounded()))
    }
}
#endif

#Preview { NavigationStack { DarkBackgroundsScreen() } }
