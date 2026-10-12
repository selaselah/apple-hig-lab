import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct LabCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LabTheme.surface, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(.primary.opacity(0.055), lineWidth: 1)
            }
    }
}

struct SectionHeading: View {
    let eyebrow: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow).font(.caption.weight(.semibold)).tracking(1.5).foregroundStyle(LabTheme.accent)
            Text(title).font(.title2.bold())
            Text(detail).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Pill: View {
    let text: String
    var color: Color = LabTheme.accent
    var body: some View {
        Text(text).font(.caption.weight(.medium))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .foregroundStyle(color)
            .background(color.opacity(0.09), in: Capsule())
    }
}

struct CodeSheet: View {
    let kind: GaugeKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if kind.watchOSOnly {
                        Pill(text: "watchOS only", color: .secondary)
                        Text("此代码仅适用于 watchOS target，当前平台展示占位。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    Text(kind.note).foregroundStyle(.secondary)
                    Text("把此片段放入 View 的 body，并用 @State private var value = 64.0 定义数值。")
                        .font(.callout)
                    SourceCodeBlock(title: "SwiftUI", source: kind.source, identifier: "swiftui-source")
                    Link("SwiftUI Gauge 文档", destination: URL(string: "https://developer.apple.com/documentation/swiftui/gauge")!)
                }.padding(24)
            }
            .navigationTitle(kind.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } }
            }
        }
        .frame(minWidth: 320, minHeight: 400)
    }
}

struct SourceCodeBlock: View {
    let title: String
    let source: String
    let identifier: String
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button {
                    #if os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(source, forType: .string)
                    #else
                    UIPasteboard.general.string = source
                    #endif
                    copied = true
                } label: {
                    Label(copied ? "已复制" : "复制代码", systemImage: copied ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("copy-\(identifier)")
            }
            Text(source)
                .accessibilityIdentifier(identifier)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LabTheme.background, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct LevelIndicatorCodeSheet: View {
    let kind: LevelIndicatorKind
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Pill(text: "macOS only · AppKit", color: .secondary)
                    Text(kind.detail).foregroundStyle(.secondary)
                    Text("这是独立的 NSLevelIndicator 控件。可先查看 AppKit 配置，或复制下面的完整 SwiftUI 桥接示例到 macOS target。")
                        .font(.callout)
                    SourceCodeBlock(title: "AppKit 配置", source: kind.appKitSource, identifier: "level-appkit-source")
                    SourceCodeBlock(title: "完整 SwiftUI 示例", source: kind.swiftUISource, identifier: "level-swiftui-source")
                    Link("NSLevelIndicator 文档", destination: URL(string: "https://developer.apple.com/documentation/appkit/nslevelindicator")!)
                }.padding(24)
            }
            .navigationTitle(kind.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } }
            }
        }
        #if os(macOS)
        .frame(width: 720, height: 620)
        #else
        .frame(minWidth: 320, minHeight: 400)
        #endif
    }
}
