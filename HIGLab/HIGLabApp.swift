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

enum GaugePage: String, CaseIterable, Identifiable {
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

struct CatalogView: View {
    @State private var selection: GaugePage? = .overview
    @AppStorage("appearance") private var appearance = "system"

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
                        NavigationLink(value: page) {
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
                Section {
                    Label("更多 HIG 组件，逐步加入", systemImage: "square.stack.3d.up")
                        .font(.caption).foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("组件目录")
            .navigationSplitViewColumnWidth(min: 230, ideal: 250, max: 300)
        } detail: {
            GaugeScreen(page: selection ?? .overview)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Picker("外观", selection: $appearance) {
                                Text("跟随系统").tag("system")
                                Text("浅色").tag("light")
                                Text("深色").tag("dark")
                            }
                            Divider()
                            Link("Apple HIG · Gauges", destination: GaugeScreen.higURL)
                        } label: {
                            Label("外观与文档", systemImage: "circle.lefthalf.filled")
                        }
                        .accessibilityIdentifier("appearance-menu")
                    }
                }
        }
        .preferredColorScheme(appearance == "system" ? nil : appearance == "dark" ? .dark : .light)
    }
}

#Preview { CatalogView() }
