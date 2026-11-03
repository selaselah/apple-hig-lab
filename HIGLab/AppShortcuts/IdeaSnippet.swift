import SwiftUI
#if os(iOS)
import AppIntents

struct CaptureIdeaSnippetIntent: AppIntent {
    static var title: LocalizedStringResource = "记录灵感并显示结果"
    static var description = IntentDescription("记录一次灵感，并返回一张静态 Snippet 结果卡片。")
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let defaults = UserDefaults.standard
        let date = Date()
        let count = defaults.integer(forKey: "siri-demo-count") + 1
        defaults.set(count, forKey: "siri-demo-count")
        defaults.set(date.timeIntervalSince1970, forKey: "siri-demo-last-date")
        return .result(
            dialog: "已记录一个灵感。",
            view: IdeaSnippetView(count: count, date: date)
        )
    }
}
#endif

/// 同一视图用于系统 Snippet 与 App 内明确标记的预览。
struct IdeaSnippetView: View {
    let count: Int
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("灵感已记录", systemImage: "checkmark.circle.fill")
                .font(.headline)
            Text("累计 \(count) 个灵感")
                .font(.title2.bold())
            Text(date, format: .dateTime.month().day().hour().minute())
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview("静态 Snippet 内容") {
    IdeaSnippetView(count: 3, date: Date())
}
