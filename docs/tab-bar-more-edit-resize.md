# iPad 窗口缩放后 More 出现 Edit 的说明

2026-10-13，在 iPad Pro 11-inch (M5) / iPadOS 27.0 模拟器上复现。

窗口缩小后出现 More 是系统正常的标签栏适配；已关闭的 Edit 再次出现，是 UIKit 在布局切换时重置编辑配置导致的。当前判断为疑似 UIKit 兼容性问题，暂不修复，保留案例行为以便后续观察。

## 复现步骤

1. 打开 **Tab Bars → More · 标签溢出 → 交互示例**。
2. 选择 **7 个**和**当前设备**，让窗口足够宽，顶部显示全部标签。
3. 缩小窗口，使系统切换到紧凑布局，底部显示 4 个标签和 More。
4. 打开 More，可看到 Edit；点击后能进入拖动排序界面。

直接使用「紧凑布局」创建示例时，More 没有 Edit。区别在于是否经历了从宽布局到紧凑布局的系统切换。

## 原因与证据

样例在设置标签页后执行 `customizableViewControllers = nil`，关闭经典 More 的排序编辑。临时诊断记录如下：

| 阶段 | customizableViewControllers | 结果 |
| --- | --- | --- |
| 宽窗口初始化并应用配置 | nil | 全部标签在顶部显示 |
| 缩小窗口，系统切换布局 | 全部 7 个页面 | More 出现 Edit |
| 窄窗口切换「5 个 → 7 个」，重新应用配置 | nil | More 的 Edit 消失 |

布局切换时，控制器实例没有改变。调用栈显示 UIKit 从 `traitCollectionDidChange:` 进入 `_updateLayoutForTraitCollection:`，再调用内部 `_setViewControllers:animated:`，把可编辑页面重置为全部页面。样例没有主动重新开启编辑。

Apple 文档说明，重新设置标签页会重置 `customizableViewControllers`，需要随后重新应用编辑限制。此次观察到的是系统因窗口布局切换在内部触发了这一重置。[Apple Tab Bar Controllers 文档](https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/ViewControllerCatalog/Chapters/TabBarControllers.html)

因此，这个现象不能仅解释为现代 iPad 标签栏的另一种定制入口；截图中的按钮就是经典 More 的 Edit。

## 当前处理

暂时搁置，未加入窗口缩放后的修复。临时诊断代码已撤掉，恢复正常构建。

后续修复方向是在系统完成横向 size class 切换后重新应用 `customizableViewControllers = nil`，并验证反复缩放时的行为。「5 个 → 7 个」已验证能恢复禁用状态，自动重应用的方案尚未实现或验证。本结论仅覆盖此次 iPadOS 27.0 复现，不推断其他系统版本。
