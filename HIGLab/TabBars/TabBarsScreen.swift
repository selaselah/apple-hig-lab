import SwiftUI

struct DemoTab: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let detail: String

    static let all: [DemoTab] = [
        .init(id: "home", title: "首页", symbol: "house.fill", detail: "最近更新和常用内容"),
        .init(id: "explore", title: "探索", symbol: "safari.fill", detail: "发现感兴趣的新内容"),
        .init(id: "favorites", title: "收藏", symbol: "star.fill", detail: "收藏的文章和文件"),
        .init(id: "messages", title: "消息", symbol: "bubble.left.and.bubble.right.fill", detail: "通知与对话"),
        .init(id: "downloads", title: "下载", symbol: "arrow.down.circle.fill", detail: "保存到本地的内容"),
        .init(id: "history", title: "历史", symbol: "clock.fill", detail: "之前访问过的内容"),
        .init(id: "settings", title: "设置", symbol: "gearshape.fill", detail: "账号与应用偏好")
    ]
}

struct TabBarsScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/tab-bars")!
    @State private var showDemo = false
    @State private var showCode = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                SectionHeading(eyebrow: "COMPONENTS / TAB BARS", title: "放不下的标签，去了哪里？", detail: "观察 iOS / iPadOS 的原生 More：当标签栏无法展示全部内容时，末尾出现更多入口，剩余标签放进单独的列表。")
                LabCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Label("More · 标签溢出", systemImage: "ellipsis.circle.fill").font(.title2.bold())
                            Spacer()
                            Pill(text: "iOS / iPadOS")
                        }
                        Text("示例提供 7 个业务标签。默认使用紧凑布局，前 4 个直接可见，「下载、历史、设置」进入系统 More 列表。")
                            .font(.body).foregroundStyle(.secondary)
                        #if os(iOS)
                        Button { showDemo = true } label: {
                            Label("打开交互示例", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("open-tab-demo")
                        #else
                        Pill(text: "iOS / iPadOS only", color: .secondary)
                        Text("在 HIGLab iOS Scheme 中打开此案例。Mac 版本提供说明和实现代码。")
                            .font(.callout).foregroundStyle(.secondary)
                        #endif
                        Button { showCode = true } label: {
                            Label("查看实现代码", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier("tab-demo-code")
                    }
                }
                LabCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("试着这样操作").font(.headline)
                        Text("1. 打开示例，点标签栏末尾的 More／更多。\n2. 在系统列表中选择「下载」，进入对应页面。\n3. 把标签数改为 4 或 5，观察 More 消失。\n4. 切换「当前设备布局」，对比 iPad 宽布局的呈现。")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                LabCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("HIG：避免标签溢出", systemImage: "lightbulb").font(.headline)
                        Text("被收进 More 的内容需要多一步才能到达，也更难被发现。这个案例用于观察系统行为；设计实际导航时，应优先减少标签，或在适合的平台使用侧边栏。")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text("More 的出现取决于系统版本、布局和可用空间。新版本 iPad 的常规布局可以在顶部显示更多标签，不一定出现 More。示例的紧凑布局让这个行为便于观察。")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Link("阅读 Apple HIG · Tab bars", destination: Self.higURL).font(.footnote)
            }
            .padding(24)
            .frame(maxWidth: 1000)
            .frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("Tab Bars")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showDemo) { TabBarDemoContainer() }
        #endif
        .sheet(isPresented: $showCode) { TabBarCodeSheet() }
    }
}

#if os(iOS)
struct TabBarDemoContainer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var count = 7
    @State private var compact = true

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("More · 系统标签溢出").font(.headline)
                    Spacer()
                    Button("完成") { dismiss() }.accessibilityIdentifier("close-tab-demo")
                }
                HStack(spacing: 20) {
                    Picker("标签数", selection: $count) {
                        Text("4 个").tag(4)
                        Text("5 个").tag(5)
                        Text("7 个").tag(7)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("tab-count")
                    Picker("布局", selection: $compact) {
                        Text("紧凑布局").tag(true)
                        Text("当前设备").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("tab-layout")
                }
                Text(compact ? "7 个标签时：前 4 个 + 系统 More。点击 More 查看其余页面。" : "由系统按当前设备布局决定呈现；iPad 宽布局可能在顶部显示全部标签。")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(.horizontal, 20).padding(.top, 16)
            NativeMoreTabDemo(count: count, compact: compact)
                .id(compact)
                .frame(maxWidth: compact ? 440 : .infinity, maxHeight: .infinity)
                .background(LabTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 20 : 0))
                .overlay {
                    if compact {
                        RoundedRectangle(cornerRadius: 20).strokeBorder(.primary.opacity(0.08), lineWidth: 1)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LabTheme.background)
    }
}

struct TabDemoPage: View {
    let tab: DemoTab

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: tab.symbol).font(.system(size: 44)).foregroundStyle(LabTheme.accent)
                Text(tab.title).font(.largeTitle.bold()).accessibilityIdentifier("demo-page-\(tab.id)")
                Text(tab.detail).font(.body).foregroundStyle(.secondary)
                Divider()
                Text("这是「\(tab.title)」标签的独立页面。底部标签栏由系统管理，页面切换不会变成一个操作按钮。")
                    .font(.callout).foregroundStyle(.secondary)
                if ["downloads", "history", "settings"].contains(tab.id) {
                    Label("标签溢出时，此页面可以从 More 列表进入。", systemImage: "ellipsis.circle")
                        .font(.callout).foregroundStyle(LabTheme.accent)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(uiColor: .systemBackground))
    }
}
#endif

struct TabBarCodeSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Pill(text: "iOS / iPadOS · UIKit")
                    Text("More 由 UITabBarController 自动生成。只配置业务页面，不手动添加 More 控制器。示例使用紧凑 size class，便于在 iPad 上重现。")
                        .font(.callout).foregroundStyle(.secondary)
                    SourceCodeBlock(title: "完整 SwiftUI 桥接示例", source: TabBarDemoSource.code, identifier: "tab-demo-source")
                    Link("More navigation controller 文档", destination: URL(string: "https://developer.apple.com/documentation/uikit/uitabbarcontroller/morenavigationcontroller")!)
                }.padding(24)
            }
            .navigationTitle("More · 实现代码")
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
