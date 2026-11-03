#if os(iOS)
import AppIntents
import SwiftUI
import UIKit

/// Embeds the real UIKit component, including its system-owned close button.
struct NativeSiriTip: UIViewRepresentable {
    let style: SiriTipViewStyle
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator { Coordinator(isPresented: $isPresented) }

    func makeUIView(context: Context) -> SiriTipUIView {
        let view = SiriTipUIView(style: style)
        view.setIntent(intent: CaptureIdeaIntent())
        view.allowsDismissal = true
        view.isPresented = isPresented
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        context.coordinator.observation = view.observe(\.isPresented, options: [.new]) { [weak coordinator = context.coordinator] _, change in
            guard let value = change.newValue else { return }
            Task { @MainActor in
                coordinator?.isPresented.wrappedValue = value
            }
        }
        return view
    }

    func updateUIView(_ view: SiriTipUIView, context: Context) {
        context.coordinator.isPresented = $isPresented
        view.style = style
        if view.isPresented != isPresented { view.isPresented = isPresented }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: SiriTipUIView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        return uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }

    static func dismantleUIView(_ uiView: SiriTipUIView, coordinator: Coordinator) {
        coordinator.observation?.invalidate()
    }

    final class Coordinator {
        var isPresented: Binding<Bool>
        var observation: NSKeyValueObservation?
        init(isPresented: Binding<Bool>) { self.isPresented = isPresented }
    }
}
#endif
