import SwiftUI

struct SnippetsScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/snippets")!
    @AppStorage("siri-demo-count") private var count = 0
    @AppStorage("siri-demo-last-date") private var lastDate = 0.0
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(eyebrow: "APP INTENTS · SNIPPETS", title: "执行完，给你一张结果卡片",
                               detail: "Siri 提示卡教你怎么说；Snippet 则在操作完成后，展示结果。本例返回静态 SwiftUI 视图。")
                LabCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Pill(text: "App 内预览 · 非 Siri 系统浮层")
                        if lastDate > 0 {
                            IdeaSnippetView(count: count, date: Date(timeIntervalSince1970: lastDate))
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
                        } else {
                            ContentUnavailableView("还没有记录", systemImage: "lightbulb",
                                                   description: Text("执行一次操作，查看返回卡片的内容。"))
                        }
                        #if os(iOS)
                        Button("记录灵感并预览结果", systemImage: "plus") {
                            Task {
                                do { _ = try await CaptureIdeaSnippetIntent().perform() }
                                catch { errorMessage = error.localizedDescription }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("capture-idea-snippet")
                        #else
                        Text("此项目的 App Intent 注册在 iOS App 中，请在 iPhone / iPad 体验系统调用。")
                            .foregroundStyle(.secondary)
                        #endif
                    }
                }
                LabCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("在系统中看结果").font(.headline)
                        Text("1. 在「快捷指令」中找到 HIG Lab 的「记录灵感并显示结果」，添加到快捷指令并运行。")
                        Text("2. 或对配置了英文 Siri 的设备说：Capture an idea with a snippet in HIG Lab。")
                        Text("3. Intent 返回上方同一个视图，由调用它的系统界面决定如何呈现。App 内按钮只演示操作与卡片内容，不会弹出 Siri。")
                        Text("不同系统入口可能不展示自定义视图；Apple 的文档也提示 Siri AI 可能不显示 IntentDialog / ShowsSnippetView。此例不包含交互式 Snippet。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 Snippet 返回代码") {
                        SourceCodeBlock(title: "AppIntent → SwiftUI 结果视图", source: Self.source,
                                        identifier: "snippet-source").padding(.top, 16)
                    }
                }
                Link("Apple · 静态与交互式 Snippet", destination: URL(string: "https://developer.apple.com/documentation/appintents/displaying-static-and-interactive-snippets")!)
            }
            .padding(24).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Snippet · 结果卡片")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .alert("操作未完成", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("好") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    static let source = #"""
    import AppIntents
    import SwiftUI

    struct CaptureIdeaSnippetIntent: AppIntent {
        static var title: LocalizedStringResource = "记录灵感并显示结果"
        static var openAppWhenRun: Bool = false

        @MainActor
        func perform() async throws
          -> some IntentResult & ProvidesDialog & ShowsSnippetView {
            let defaults = UserDefaults.standard
            let date = Date()
            let count = defaults.integer(forKey: "siri-demo-count") + 1
            defaults.set(count, forKey: "siri-demo-count")
            defaults.set(date.timeIntervalSince1970, forKey: "siri-demo-last-date")
            return .result(dialog: "已记录一个灵感。", view:
                VStack(alignment: .leading, spacing: 12) {
                    Label("灵感已记录", systemImage: "checkmark.circle.fill")
                    Text("累计 \(count) 个灵感").font(.title2.bold())
                    Text(date, format: .dateTime.hour().minute())
                }.padding()
            )
        }
    }
    // 直接调用 perform() 不会自动展示 Siri 浮层。
    // 由 Siri / 快捷指令等系统入口调用时，系统接收并呈现结果。
    """#
}
