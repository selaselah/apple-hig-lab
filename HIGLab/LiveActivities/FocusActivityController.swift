#if os(iOS)
import ActivityKit
import AppIntents
import Foundation

@MainActor
enum FocusActivities {
    static var current: Activity<FocusActivityAttributes>? {
        Activity<FocusActivityAttributes>.activities.first {
            $0.activityState == .active || $0.activityState == .stale
        }
    }

    @discardableResult
    static func start(minutes: Int) throws -> Activity<FocusActivityAttributes> {
        // 重复点击或从 Siri 再次调用，复用当前活动。
        if let current { return current }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw FocusActivityError.notAuthorized
        }
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(minutes * 60))
        return try Activity.request(
            attributes: FocusActivityAttributes(title: "专注倒计时", startDate: now),
            content: ActivityContent(state: .init(endDate: end), staleDate: end),
            pushType: nil
        )
    }

    static func extend(_ activity: Activity<FocusActivityAttributes>) async {
        let end = max(activity.content.state.endDate, Date()).addingTimeInterval(60)
        await activity.update(ActivityContent(state: .init(endDate: end), staleDate: end))
    }

    static func end(_ activity: Activity<FocusActivityAttributes>) async {
        await activity.end(nil, dismissalPolicy: .immediate)
    }
}

enum FocusActivityError: LocalizedError {
    case notAuthorized
    var errorDescription: String? {
        "当前设备不允许 HIG Lab 显示实时活动。请检查系统设置中的实时活动权限。"
    }
}

struct StartFocusIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "开始专注倒计时"
    static var description = IntentDescription("启动或恢复一个五分钟的专注实时活动。")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        try FocusActivities.start(minutes: 5)
        UserDefaults.standard.set(true, forKey: "live-activity-demo-open")
        return .result(dialog: "专注实时活动已就绪。")
    }
}
#endif
