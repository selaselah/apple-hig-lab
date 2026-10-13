import SwiftUI

struct BackgroundColorsScreen: View {
    static let higURL = URL(string: "https://developer.apple.com/design/human-interface-guidelines/color")!
    @State private var darkPreview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionHeading(
                    eyebrow: "COLORS · BACKGROUND HIERARCHY",
                    title: "先选页面类型，再选背景层级",
                    detail: "圆角不是选择依据。普通内容页和分组列表页，各有一套从页面底色到内部区域的背景颜色。"
                )
                #if os(iOS)
                Picker("示例外观", selection: $darkPreview) {
                    Text("浅色").tag(false)
                    Text("深色").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                .accessibilityIdentifier("background-preview-appearance")

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 20) {
                        BackgroundFamilyPreview(grouped: false).frame(minWidth: 290)
                        BackgroundFamilyPreview(grouped: true).frame(minWidth: 290)
                    }
                    VStack(spacing: 20) {
                        BackgroundFamilyPreview(grouped: false)
                        BackgroundFamilyPreview(grouped: true)
                    }
                }
                .environment(\.colorScheme, darkPreview ? .dark : .light)
                .accessibilityIdentifier("background-family-comparison")
                #else
                LabCard {
                    Label("iOS / iPadOS 示例", systemImage: "ipad.and.iphone")
                    Text("这些 UIColor 名称属于 UIKit。在 iPhone 或 iPad 上运行，即可查看实际动态颜色；下方提供对应的 SwiftUI 代码。")
                        .foregroundStyle(.secondary)
                }
                #endif

                LabCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("‘设置’式页面怎么配？").font(.headline)
                        Text("整页底色 → systemGroupedBackground\n圆角 section → secondarySystemGroupedBackground\nsection 内再嵌一层 → tertiarySystemGroupedBackground")
                            .font(.callout).textSelection(.enabled)
                        Text("普通页面的圆角卡片则可以用 secondarySystemBackground。不要因为形状是圆角，就切换到 grouped 系列。")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                }
                LabCard {
                    DisclosureGroup("查看 SwiftUI 示例代码") {
                        SourceCodeBlock(title: "两套背景，分别配套使用", source: Self.source, identifier: "background-colors-source")
                            .padding(.top, 16)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 1100)
            .frame(maxWidth: .infinity)
        }
        .background(LabTheme.background)
        .navigationTitle("背景层级")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    static let source = """
    import SwiftUI

    // grouped = false：普通内容页
    // grouped = true：设置式分组页
    struct BackgroundExample: View {
        let grouped: Bool

        var body: some View {
            ZStack {
                Color(uiColor: grouped
                    ? .systemGroupedBackground
                    : .systemBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("内容区域").font(.headline)
                    Text("内部区域")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: grouped
                            ? .tertiarySystemGroupedBackground
                            : .tertiarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12))
                }
                .padding()
                .background(Color(uiColor: grouped
                    ? .secondarySystemGroupedBackground
                    : .secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 20))
                .padding()
            }
        }
    }
    """
}

#if os(iOS)
private struct BackgroundFamilyPreview: View {
    let grouped: Bool

    private var primary: Color {
        Color(uiColor: grouped ? .systemGroupedBackground : .systemBackground)
    }
    private var secondary: Color {
        Color(uiColor: grouped ? .secondarySystemGroupedBackground : .secondarySystemBackground)
    }
    private var tertiary: Color {
        Color(uiColor: grouped ? .tertiarySystemGroupedBackground : .tertiarySystemBackground)
    }
    private var family: String { grouped ? "SystemGroupedBackground" : "SystemBackground" }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Label(grouped ? "分组列表页" : "普通内容页", systemImage: grouped ? "list.bullet.rectangle" : "doc.text")
                    .font(.title3.bold())
                Text(grouped ? "像‘设置’一样，把内容分成几组" : "文章、详情等普通内容页面")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            token("① 页面底色", name: grouped ? "systemGroupedBackground" : "systemBackground")
            VStack(alignment: .leading, spacing: 20) {
                token(grouped ? "② 圆角 section" : "② 圆角内容卡片", name: "secondary" + family)
                Label(grouped ? "通知设置" : "阅读偏好", systemImage: grouped ? "bell.badge" : "text.book.closed")
                    .font(.headline)
                Divider()
                HStack {
                    Text("显示预览")
                    Spacer()
                    Text("始终").foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 10) {
                    token("③ 内部区域", name: "tertiary" + family)
                    Text("在第二层内容里，再嵌入一层。").font(.callout).foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(tertiary, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(18)
            .background(secondary, in: RoundedRectangle(cornerRadius: 20))
            Text("三个层级来自同一套背景颜色。")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(primary, in: RoundedRectangle(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26).strokeBorder(.primary.opacity(0.12), lineWidth: 1)
        }
    }

    private func token(_ title: String, name: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(name)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
    }
}
#endif

#Preview { NavigationStack { BackgroundColorsScreen() } }
