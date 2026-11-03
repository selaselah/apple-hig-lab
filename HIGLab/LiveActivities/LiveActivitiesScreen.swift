import SwiftUI
#if os(iOS)
import ActivityKit
#endif

struct LiveActivitiesScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/live-activities")!
    @Environment(\.scenePhase) private var scenePhase
    @State private var minutes = 5
    @State private var errorMessage: String?
    #if os(iOS)
    @State private var activity: Activity<FocusActivityAttributes>?
    @State private var endDate = Date()
    @State private var isWorking = false
    #endif

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(eyebrow: "ACTIVITYKIT · LIVE ACTIVITIES", title: "离开 App，进度仍然可见",
                               detail: "启动一个真实的专注倒计时。锁屏和灵动岛展示同一项活动，App 内负责开始、更新和结束。")
                #if os(iOS)
                controls
                #else
                LabCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Pill(text: "请在 iPhone / iPad 启动")
                        Text("此项目的 ActivityKit 示例运行在 iOS App 中。Mac 目录保留说明和代码。")
                    }
                }
                #endif
                LabCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("到哪里看？").font(.headline)
                        Text("• 锁定 iPhone / iPad：在锁屏查看实时活动。\n• 支持灵动岛的 iPhone：返回主屏幕查看紧凑布局，长按展开；同时存在多项活动时，系统也可能使用最小布局。\n• 点活动打开 HIG Lab，回到本页加时或结束。")
                        Text("也可用快捷指令「开始专注倒计时」，或英文 Siri 短语 Start a focus timer in HIG Lab。该入口默认五分钟，已有活动时复用，不重复创建。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("倒计时更新 ≠ App 一直在后台运行").font(.headline)
                        Text("时间文字由系统根据结束时间刷新；「加 1 分钟」才会通过 ActivityKit 更新状态。计时归零后请点「结束并移除」：此本地示例没有服务器，也不承诺 App 挂起后自动结束活动。")
                        Text("实时活动是持续展示任务状态的功能，灵动岛是它的一种显示位置。iPad 可以查看锁屏活动，不具备 iPhone 的灵动岛。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    DisclosureGroup("查看开始 / 更新 / 结束代码") {
                        SourceCodeBlock(title: "ActivityKit 生命周期", source: Self.lifecycleSource,
                                        identifier: "live-activity-lifecycle-source").padding(.top, 16)
                    }
                }
                LabCard {
                    DisclosureGroup("查看锁屏与灵动岛代码") {
                        SourceCodeBlock(title: "Widget 扩展 · 两种显示位置", source: Self.widgetSource,
                                        identifier: "live-activity-widget-source").padding(.top, 16)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 LiveActivityIntent 代码") {
                        SourceCodeBlock(title: "让系统调用专注操作", source: Self.intentSource,
                                        identifier: "live-activity-intent-source").padding(.top, 16)
                    }
                }
                Link("Apple · ActivityKit 实现指南", destination: URL(string: "https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities")!)
            }
            .padding(24).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Live Activity · 专注倒计时")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refresh() }
        }
        .task(id: activity?.id) {
            guard let observed = activity else { return }
            for await state in observed.activityStateUpdates {
                if Task.isCancelled { return }
                if state == .dismissed || state == .ended { refresh() }
            }
        }
        .task(id: activity?.id) {
            guard let observed = activity else { return }
            for await content in observed.contentUpdates {
                if Task.isCancelled { return }
                endDate = content.state.endDate
            }
        }
        #endif
        .alert("无法更新实时活动", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("好") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }

    #if os(iOS)
    private var controls: some View {
        LabCard {
            VStack(alignment: .leading, spacing: 18) {
                if let activity {
                    Pill(text: "App 内内容预览 · 系统卡片在锁屏 / 灵动岛")
                    FocusActivityCard(title: activity.attributes.title,
                                      startDate: activity.attributes.startDate, endDate: endDate)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
                    ViewThatFits(in: .horizontal) {
                        HStack { updateButton(activity); endButton(activity) }
                        VStack(alignment: .leading) { updateButton(activity); endButton(activity) }
                    }
                    .disabled(isWorking)
                } else {
                    Label("尚未开始", systemImage: "timer").font(.headline)
                    Picker("专注时长", selection: $minutes) {
                        Text("1 分钟").tag(1)
                        Text("5 分钟").tag(5)
                        Text("25 分钟").tag(25)
                    }
                    .pickerStyle(.segmented)
                    Button("开始实时活动", systemImage: "play.fill") {
                        do {
                            try FocusActivities.start(minutes: minutes)
                            refresh()
                        } catch { errorMessage = error.localizedDescription }
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("start-live-activity")
                    Text("开始后将 App 放到后台或锁定设备，观察系统卡片。")
                        .font(.callout).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func updateButton(_ activity: Activity<FocusActivityAttributes>) -> some View {
        Button("加 1 分钟", systemImage: "plus") {
            isWorking = true
            Task { @MainActor in
                await FocusActivities.extend(activity)
                refresh()
                isWorking = false
            }
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("extend-live-activity")
    }

    private func endButton(_ activity: Activity<FocusActivityAttributes>) -> some View {
        Button("结束并移除", systemImage: "stop.fill", role: .destructive) {
            isWorking = true
            Task { @MainActor in
                await FocusActivities.end(activity)
                refresh()
                isWorking = false
            }
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("end-live-activity")
    }

    private func refresh() {
        activity = FocusActivities.current
        if let activity { endDate = activity.content.state.endDate }
    }
    #endif

    static let lifecycleSource = #"""
    import ActivityKit
    import Foundation

    // 放在 App 和 Widget 扩展都能编译的共享文件中。
    struct FocusActivityAttributes: ActivityAttributes {
        struct ContentState: Codable, Hashable {
            var endDate: Date
        }
        var title: String
        var startDate: Date
    }

    // App Info.plist: NSSupportsLiveActivities = YES
    // 从前台的用户操作中开始；实际项目还应检查已有活动，避免重复。
    let now = Date()
    let end = now.addingTimeInterval(5 * 60)
    if ActivityAuthorizationInfo().areActivitiesEnabled {
        let activity = try Activity.request(
            attributes: FocusActivityAttributes(title: "专注倒计时", startDate: now),
            content: ActivityContent(state: .init(endDate: end), staleDate: end),
            pushType: nil
        )

        // 加时（在 async 上下文中）：
        let extended = max(activity.content.state.endDate, Date()).addingTimeInterval(60)
        await activity.update(ActivityContent(
            state: .init(endDate: extended), staleDate: extended
        ))

        // 结束并从系统界面立即移除：
        await activity.end(nil, dismissalPolicy: .immediate)
    }
    // staleDate 只标记内容过期，不会自动结束活动。
    // App 重新启动后，可从 Activity<FocusActivityAttributes>.activities 恢复。
    """#

    static let widgetSource = #"""
    import ActivityKit
    import SwiftUI
    import WidgetKit

    // 放入 Widget Extension，并由其 @main WidgetBundle 包含。
    struct FocusLiveActivity: Widget {
        var body: some WidgetConfiguration {
            ActivityConfiguration(for: FocusActivityAttributes.self) { context in
                // 锁屏布局
                VStack(alignment: .leading) {
                    Label(context.attributes.title, systemImage: "timer")
                    Text(timerInterval: context.attributes.startDate...context.state.endDate,
                         countsDown: true).monospacedDigit()
                }.padding()
            } dynamicIsland: { context in
                DynamicIsland {
                    DynamicIslandExpandedRegion(.bottom) {
                        Text(timerInterval: context.attributes.startDate...context.state.endDate,
                             countsDown: true).font(.title.monospacedDigit())
                    }
                } compactLeading: {
                    Image(systemName: "timer")
                } compactTrailing: {
                    Text(timerInterval: context.attributes.startDate...context.state.endDate,
                         countsDown: true).monospacedDigit().frame(width: 48)
                } minimal: {
                    Image(systemName: "timer")
                }
            }
        }
    }
    // 系统根据场景选择紧凑 / 展开 / 最小布局。
    // Text(timerInterval:) 会自动刷新，无需每秒调用 activity.update。
    """#

    static let intentSource = #"""
    import AppIntents

    struct StartFocusIntent: LiveActivityIntent {
        static var title: LocalizedStringResource = "开始专注倒计时"
        static var openAppWhenRun: Bool = true

        @MainActor
        func perform() async throws -> some IntentResult & ProvidesDialog {
            // 使用本项目 FocusActivities 中的 ActivityKit 开始逻辑。
            try FocusActivities.start(minutes: 5)
            return .result(dialog: "专注实时活动已就绪。")
        }
    }
    // LiveActivityIntent 描述操作；ActivityKit 管理活动；WidgetKit 绘制 UI。
    // 在 HIGLabShortcuts 中注册 AppShortcut 后，系统可提供快捷调用入口。
    """#
}
