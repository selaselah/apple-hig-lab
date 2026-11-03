#if os(iOS)
import ActivityKit
import SwiftUI

struct FocusActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
    }

    var title: String
    var startDate: Date
}

struct FocusActivityCard: View {
    let title: String
    let startDate: Date
    let endDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "timer").font(.headline)
            Text("剩余时间").font(.caption).foregroundStyle(.secondary)
            Text(timerInterval: startDate...endDate, countsDown: true)
                .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                .accessibilityLabel("专注剩余时间")
            Text("目标结束：\(endDate, format: .dateTime.hour().minute())")
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
#endif
