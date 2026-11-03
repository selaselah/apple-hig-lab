import SwiftUI

@main
struct HIGLabApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView()
                .tint(LabTheme.accent)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 650)
                #endif
        }
    }
}

enum LabTheme {
    static let accent = Color(red: 0.76, green: 0.25, blue: 0.12)
    static let spectrum: [Color] = [.blue, .cyan, .green, .yellow, .orange, .red]

    static var background: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static var surface: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }
}

enum GaugePage: String, CaseIterable, Identifiable, Hashable {
    case overview = "概览"
    case styles = "样式图鉴"
    case scenarios = "场景演示"
    case guidelines = "设计要点"
    case levels = "Level Indicators"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .styles: "circle.lefthalf.filled"
        case .scenarios: "slider.horizontal.3"
        case .guidelines: "text.book.closed"
        case .levels: "chart.bar.fill"
        }
    }
}

enum CatalogPage: Hashable {
    case gauge(GaugePage)
    case tabBars
    case backgroundColors
    case darkBackgrounds
    case vibrancy
    case siriTips
    case snippets
    case liveActivities

    var documentationURL: URL {
        switch self {
        case .gauge: GaugeScreen.higURL
        case .tabBars: TabBarsScreen.higURL
        case .backgroundColors: BackgroundColorsScreen.higURL
        case .darkBackgrounds: DarkBackgroundsScreen.higURL
        case .vibrancy: VibrancyScreen.higURL
        case .siriTips: SiriTipsScreen.higURL
        case .snippets: SnippetsScreen.higURL
        case .liveActivities: LiveActivitiesScreen.higURL
        }
    }
}

struct CatalogView: View {
    @State private var selection: CatalogPage? = .gauge(.overview)
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("siri-demo-open") private var openSiriDemo = false
    @AppStorage("live-activity-demo-open") private var openLiveActivityDemo = false

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HIG LAB").font(.title2.bold()).tracking(2)
                        Text("原生组件 · 交互案例").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 18)
                    .listRowBackground(Color.clear)
                    .accessibilityElement(children: .combine)
                }
                Section("Gauges · 仪表") {
                    ForEach(GaugePage.allCases) { page in
                        NavigationLink(value: CatalogPage.gauge(page)) {
                            HStack {
                                Label(page.rawValue, systemImage: page.symbol)
                                if page == .levels {
                                    Text("macOS").font(.caption2).foregroundStyle(.secondary)
                                }
                            }.padding(.vertical, 5)
                        }
                        .accessibilityIdentifier("nav-\(page.id)")
                    }
                }
                Section("Tab Bars · 标签栏") {
                    NavigationLink(value: CatalogPage.tabBars) {
                        Label("More · 标签溢出", systemImage: "ellipsis.circle")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-tab-bars")
                }
                Section("Colors · 颜色") {
                    NavigationLink(value: CatalogPage.backgroundColors) {
                        Label("背景层级", systemImage: "square.3.layers.3d")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-background-colors")
                    NavigationLink(value: CatalogPage.darkBackgrounds) {
                        Label("Base / Elevated", systemImage: "square.2.layers.3d")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-dark-backgrounds")
                    NavigationLink(value: CatalogPage.vibrancy) {
                        Label("Vibrancy · 材质文字", systemImage: "textformat")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-vibrancy")
                }
                Section("App Shortcuts · 快捷操作") {
                    NavigationLink(value: CatalogPage.siriTips) {
                        Label("Siri 提示卡片", systemImage: "mic.badge.plus")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-siri-tips")
                    NavigationLink(value: CatalogPage.snippets) {
                        Label("Snippet · 结果卡片", systemImage: "rectangle.bubble")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-snippets")
                    NavigationLink(value: CatalogPage.liveActivities) {
                        Label("Live Activity · 专注", systemImage: "timer")
                            .padding(.vertical, 5)
                    }
                    .accessibilityIdentifier("nav-live-activities")
                }
                Section {
                    Label("更多 HIG 组件，逐步加入", systemImage: "square.stack.3d.up")
                        .font(.caption).foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("组件目录")
            .navigationSplitViewColumnWidth(min: 230, ideal: 250, max: 300)
        } detail: {
            detail
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Picker("外观", selection: $appearance) {
                                Text("跟随系统").tag("system")
                                Text("浅色").tag("light")
                                Text("深色").tag("dark")
                            }
                            Divider()
                            Link("Apple HIG · 当前组件", destination: (selection ?? .gauge(.overview)).documentationURL)
                        } label: {
                            Label("外观与文档", systemImage: "circle.lefthalf.filled")
                        }
                        .accessibilityIdentifier("appearance-menu")
                    }
                }
        }
        .preferredColorScheme(appearance == "system" ? nil : appearance == "dark" ? .dark : .light)
        .onChange(of: openSiriDemo) { _, shouldOpen in
            if shouldOpen {
                selection = .siriTips
                openSiriDemo = false
            }
        }
        .onAppear {
            if openSiriDemo || ProcessInfo.processInfo.arguments.contains("-siri-tip-demo") {
                selection = .siriTips
                openSiriDemo = false
            }
            if ProcessInfo.processInfo.arguments.contains("-snippets-demo") {
                selection = .snippets
            }
            if openLiveActivityDemo || ProcessInfo.processInfo.arguments.contains("-live-activity-demo") {
                selection = .liveActivities
                openLiveActivityDemo = false
            }
        }
        .onChange(of: openLiveActivityDemo) { _, shouldOpen in
            if shouldOpen {
                selection = .liveActivities
                openLiveActivityDemo = false
            }
        }
        .onOpenURL { url in
            if url.scheme == "higlab", url.host == "live-activity" {
                selection = .liveActivities
            }
        }
    }

    @ViewBuilder private var detail: some View {
        switch selection ?? .gauge(.overview) {
        case .gauge(let page): GaugeScreen(page: page)
        case .tabBars: TabBarsScreen()
        case .backgroundColors: BackgroundColorsScreen()
        case .darkBackgrounds: DarkBackgroundsScreen()
        case .vibrancy: VibrancyScreen()
        case .siriTips: SiriTipsScreen()
        case .snippets: SnippetsScreen()
        case .liveActivities: LiveActivitiesScreen()
        }
    }
}

#Preview { CatalogView() }
