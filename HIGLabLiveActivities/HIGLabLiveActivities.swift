import ActivityKit
import SwiftUI
import WidgetKit

@main
struct HIGLabLiveActivities: WidgetBundle {
    var body: some Widget {
        FocusLiveActivity()
    }
}

struct FocusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            FocusActivityCard(title: context.attributes.title,
                              startDate: context.attributes.startDate,
                              endDate: context.state.endDate)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
                .foregroundStyle(.white)
                .widgetURL(URL(string: "higlab://live-activity"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label("专注", systemImage: "timer").foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endDate, style: .time).foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(timerInterval: context.attributes.startDate...context.state.endDate, countsDown: true)
                        .font(.largeTitle.monospacedDigit())
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("专注剩余时间")
                        .padding(.vertical, 8)
                }
            } compactLeading: {
                Image(systemName: "timer").foregroundStyle(.orange)
            } compactTrailing: {
                Text(timerInterval: context.attributes.startDate...context.state.endDate, countsDown: true)
                    .monospacedDigit().frame(width: 48)
                    .accessibilityLabel("专注剩余时间")
            } minimal: {
                Image(systemName: "timer").foregroundStyle(.orange)
            }
            .widgetURL(URL(string: "higlab://live-activity"))
            .keylineTint(.orange)
        }
    }
}

private let previewStart = Date()
private let previewAttributes = FocusActivityAttributes(title: "专注倒计时", startDate: previewStart)

#Preview("锁屏", as: .content, using: previewAttributes) {
    FocusLiveActivity()
} contentStates: {
    FocusActivityAttributes.ContentState(endDate: previewStart.addingTimeInterval(300))
}

#Preview("灵动岛 · 紧凑", as: .dynamicIsland(.compact), using: previewAttributes) {
    FocusLiveActivity()
} contentStates: {
    FocusActivityAttributes.ContentState(endDate: previewStart.addingTimeInterval(300))
}

#Preview("灵动岛 · 展开", as: .dynamicIsland(.expanded), using: previewAttributes) {
    FocusLiveActivity()
} contentStates: {
    FocusActivityAttributes.ContentState(endDate: previewStart.addingTimeInterval(300))
}

#Preview("灵动岛 · 最小", as: .dynamicIsland(.minimal), using: previewAttributes) {
    FocusLiveActivity()
} contentStates: {
    FocusActivityAttributes.ContentState(endDate: previewStart.addingTimeInterval(300))
}
