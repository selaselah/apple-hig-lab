#if os(iOS)
import SwiftUI
import UIKit

struct NativeMoreTabDemo: UIViewControllerRepresentable {
    let count: Int
    let compact: Bool

    func makeUIViewController(context: Context) -> UITabBarController {
        let controller = UITabBarController()
        if #available(iOS 18.0, *) { controller.mode = .tabBar }
        // Reproduce a compact layout on iPad without drawing a custom More tab.
        if compact { controller.traitOverrides.horizontalSizeClass = .compact }
        controller.view.tintColor = UIColor(LabTheme.accent)
        configure(controller)
        return controller
    }

    func updateUIViewController(_ controller: UITabBarController, context: Context) {
        if controller.viewControllers?.count != count { configure(controller) }
    }

    private func configure(_ controller: UITabBarController) {
        let pages = DemoTab.all.prefix(count).enumerated().map { index, tab in
            let host = UIHostingController(rootView: TabDemoPage(tab: tab))
            host.title = tab.title
            let navigation = UINavigationController(rootViewController: host)
            navigation.tabBarItem = UITabBarItem(title: tab.title, image: UIImage(systemName: tab.symbol), tag: index)
            navigation.tabBarItem.accessibilityIdentifier = "demo-tab-\(tab.id)"
            return navigation
        }
        controller.setViewControllers(pages, animated: false)
        controller.moreNavigationController.tabBarItem.accessibilityIdentifier = "system-more-tab"
        // Hide Edit in the classic More list. This is not a global switch for
        // customization of the modern iPad tab bar (UITab.preferredPlacement).
        controller.customizableViewControllers = nil
        controller.selectedIndex = 0
    }
}
#endif

enum TabBarDemoSource {
    static let code = #"""
    #if os(iOS)
    import SwiftUI
    import UIKit

    struct MoreTabsDemo: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UITabBarController {
            let controller = UITabBarController()
            if #available(iOS 18.0, *) { controller.mode = .tabBar }
            // iOS 17+: use compact layout to reproduce overflow on iPad.
            controller.traitOverrides.horizontalSizeClass = .compact

            let titles = ["首页", "探索", "收藏", "消息", "下载", "历史", "设置"]
            let symbols = ["house.fill", "safari.fill", "star.fill",
                           "bubble.left.and.bubble.right.fill",
                           "arrow.down.circle.fill", "clock.fill", "gearshape.fill"]
            controller.viewControllers = titles.enumerated().map { index, title in
                let host = UIHostingController(rootView:
                    Text(title).font(.largeTitle).frame(maxWidth: .infinity, maxHeight: .infinity)
                )
                host.title = title
                let navigation = UINavigationController(rootViewController: host)
                navigation.tabBarItem = UITabBarItem(
                    title: title, image: UIImage(systemName: symbols[index]), tag: index
                )
                return navigation
            }
            // Disable the classic More editor, not all modern iPad customization.
            controller.customizableViewControllers = nil
            // Do not add moreNavigationController yourself.
            // The system creates More automatically when needed.
            return controller
        }

        func updateUIViewController(_ controller: UITabBarController, context: Context) {}
    }

    struct ExampleView: View {
        var body: some View { MoreTabsDemo() }
    }
    #endif
    """#
}
