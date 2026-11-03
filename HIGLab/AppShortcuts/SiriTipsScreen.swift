import SwiftUI
#if os(iOS)
import AppIntents
#endif

struct SiriTipsScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/app-shortcuts")!
    @State private var tipVisible = true
    @State private var style = "automatic"
    @State private var errorMessage: String?
    @AppStorage("siri-demo-count") private var count = 0
    @AppStorage("siri-demo-last-date") private var lastDate = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(
                    eyebrow: "APP SHORTCUTS · SIRI TIP",
                    title: "让系统教用户怎么说",
                    detail: "SiriTipUIView 显示调用快捷操作的语音短语。下面是真实 UIKit 控件，提示文案和关闭按钮由系统提供。"
                )
                #if os(iOS)
                LabCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Label("灵感速记", systemImage: "lightbulb").font(.title3.bold())
                        Text("记录一次灵感，保存次数与最近时间。也可以在「快捷指令」App 的 HIG Lab 操作中运行。")
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline) {
                            Text("已记录 \(count) 个灵感")
                                .font(.headline)
                                .accessibilityIdentifier("siri-idea-count")
                            Spacer()
                            Button("记录灵感", systemImage: "plus") {
                                Task {
                                    do { _ = try await CaptureIdeaIntent().perform() }
                                    catch { errorMessage = error.localizedDescription }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("capture-idea")
                        }
                        if lastDate > 0 {
                            Text("最近记录：\(Date(timeIntervalSince1970: lastDate).formatted(date: .abbreviated, time: .standard))")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Divider()
                        NativeSiriTip(style: tipStyle, isPresented: $tipVisible)
                            .frame(maxWidth: .infinity)
                        if !tipVisible {
                            Text("提示已关闭；快捷操作仍然可用。")
                                .font(.callout).foregroundStyle(.secondary)
                                .accessibilityIdentifier("siri-tip-dismissed")
                        }
                    }
                }
                LabCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("观察系统样式").font(.headline)
                        Picker("提示卡片样式", selection: $style) {
                            Text("自动").tag("automatic")
                            Text("浅色").tag("light")
                            Text("深色").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("siri-tip-style")
                        Button("重新显示提示", systemImage: "arrow.counterclockwise") {
                            tipVisible = true
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("restore-siri-tip")
                        Text("点提示卡片的 × 关闭，再用此按钮恢复。自动样式跟随页面外观，可在右上角切换。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                #else
                LabCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Pill(text: "iOS / iPadOS · UIKit")
                        Text("SiriTipUIView 请在 iPhone 或 iPad 上体验。下方保留可复制的接入代码。")
                    }
                }
                #endif
                LabCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("提示卡片 ≠ 执行按钮").font(.headline)
                        Text("卡片教用户如何通过 Siri 调用；上面的「记录灵感」按钮才直接执行同一个 Intent。卡片不负责录音或识别语音。")
                        Text("本示例的触发短语为英文：Capture an idea in HIG Lab。语音调用还取决于设备上的 Siri 设置；模拟器主要用于观察控件和验证操作逻辑。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 UIKit 接入代码") {
                        SourceCodeBlock(title: "真实 SiriTipUIView", source: Self.uiKitSource, identifier: "siri-tip-uikit-source")
                            .padding(.top, 16)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 App Intent 与 App Shortcut") {
                        SourceCodeBlock(title: "操作 + 系统入口", source: Self.intentSource, identifier: "siri-tip-intent-source")
                            .padding(.top, 16)
                    }
                }
                Link("Apple · SiriTipUIView", destination: URL(string: "https://developer.apple.com/documentation/appintents/siritipuiview")!)
            }
            .padding(24)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Siri 提示卡片")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("操作未完成", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("好") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    #if os(iOS)
    private var tipStyle: SiriTipViewStyle {
        switch style {
        case "light": .light
        case "dark": .dark
        default: .automatic
        }
    }
    #endif

    static let uiKitSource = """
    import UIKit
    import AppIntents

    // 在 UIViewController.viewDidLoad 中：
    let tip = SiriTipUIView(style: .automatic)
    tip.setIntent(intent: CaptureIdeaIntent())
    tip.allowsDismissal = true
    tip.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tip)
    NSLayoutConstraint.activate([
        tip.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        tip.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        tip.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
    ])

    // 点系统的关闭按钮后，isPresented 会变为 false（支持 KVO）。
    // 需要恢复时：tip.isPresented = true
    // SwiftUI 项目可用 UIViewRepresentable 桥接，见 NativeSiriTip.swift。
    // 或直接用 SiriTipView(intent: CaptureIdeaIntent(), isVisible: $visible)。
    """

    static let intentSource = #"""
    import AppIntents
    import Foundation

    struct CaptureIdeaIntent: AppIntent {
        static var title: LocalizedStringResource = "记录灵感"
        static var openAppWhenRun: Bool = true

        @MainActor
        func perform() async throws -> some IntentResult & ProvidesDialog {
            let defaults = UserDefaults.standard
            defaults.set(Date().timeIntervalSince1970, forKey: "siri-demo-last-date")
            defaults.set(defaults.integer(forKey: "siri-demo-count") + 1,
                         forKey: "siri-demo-count")
            return .result(dialog: "已记录一个灵感。")
        }
    }

    struct HIGLabShortcuts: AppShortcutsProvider {
        static var appShortcuts: [AppShortcut] {
            AppShortcut(
                intent: CaptureIdeaIntent(),
                phrases: ["Capture an idea in \(.applicationName)"],
                shortTitle: "记录灵感",
                systemImageName: "lightbulb"
            )
        }
    }
    // Intent 必须出现在 AppShortcut 中，系统提示才能找到关联短语。
    """#
}
