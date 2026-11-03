#if os(iOS)
import AppIntents
import Foundation

struct CaptureIdeaIntent: AppIntent {
    static var title: LocalizedStringResource = "记录灵感"
    static var description = IntentDescription("在 HIG Lab 中记录一次灵感，保存次数与最近时间。")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults.standard
        defaults.set(Date().timeIntervalSince1970, forKey: "siri-demo-last-date")
        defaults.set(defaults.integer(forKey: "siri-demo-count") + 1, forKey: "siri-demo-count")
        defaults.set(true, forKey: "siri-demo-open")
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
        AppShortcut(
            intent: CaptureIdeaSnippetIntent(),
            phrases: ["Capture an idea with a snippet in \(.applicationName)"],
            shortTitle: "记录灵感并显示结果",
            systemImageName: "rectangle.bubble"
        )
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: ["Start a focus timer in \(.applicationName)"],
            shortTitle: "开始专注倒计时",
            systemImageName: "timer"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .orange
}
#endif
