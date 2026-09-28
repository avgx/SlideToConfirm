import SwiftUI

/// Generic slide-to-confirm control. No domain names — callers supply the title.
/// Callers own side effects such as haptics inside `action`.
public struct SlideToConfirm: View {
    public var title: String
    public var isEnabled: Bool
    public var isBusy: Bool
    public var action: () async -> Void

    @State private var dragOffset: CGFloat = 0

    private let thumbSize: CGFloat = 52
    private let horizontalInset: CGFloat = 4
    private let completeThreshold: CGFloat = 0.85

    /// Localized title for a slide control that opens a relay.
    public static var slideToOpenTitle: String {
        String(localized: "slide-to-open", bundle: .module)
    }

    public init(
        title: String,
        isEnabled: Bool = true,
        isBusy: Bool = false,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isBusy = isBusy
        self.action = action
    }

    public var body: some View {
        GeometryReader { geo in
            let maxOffset = max(0, geo.size.width - thumbSize - horizontalInset * 2)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(canInteract ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .opacity(titleOpacity(maxOffset: maxOffset))
                    .allowsHitTesting(false)

                Capsule()
                    .fill(.tint)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        if isBusy {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .offset(x: min(dragOffset, maxOffset) + horizontalInset)
                    .highPriorityGesture(
                        dragGesture(maxOffset: maxOffset),
                        including: canInteract ? .all : .none
                    )
            }
        }
        .frame(height: thumbSize + horizontalInset * 2)
        .opacity(canInteract || isBusy ? 1 : 0.55)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            guard canInteract else { return }
            Task {
                await action()
                reset()
            }
        }
    }

    private var canInteract: Bool {
        isEnabled && !isBusy
    }

    private func titleOpacity(maxOffset: CGFloat) -> Double {
        let progress = maxOffset == 0 ? 0 : Double(min(dragOffset, maxOffset) / maxOffset)
        return 1 - min(progress * 1.4, 1)
    }

    private func dragGesture(maxOffset: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard canInteract else { return }
                let raw = value.translation.width
                if raw < 0 {
                    dragOffset = 0
                } else if raw <= maxOffset {
                    dragOffset = raw
                } else {
                    dragOffset = maxOffset
                }
            }
            .onEnded { _ in
                guard canInteract else {
                    reset()
                    return
                }
                let progress = maxOffset > 0 ? dragOffset / maxOffset : 0
                if progress >= completeThreshold {
                    Task { await complete(maxOffset: maxOffset) }
                } else {
                    reset()
                }
            }
    }

    private func complete(maxOffset: CGFloat) async {
        dragOffset = maxOffset
        await action()
        reset()
    }

    private func reset() {
        withAnimation(.spring(duration: 0.28)) {
            dragOffset = 0
        }
    }
}

#Preview {
    SlideToConfirm(title: SlideToConfirm.slideToOpenTitle) {
        try? await Task.sleep(nanoseconds: 400_000_000)
    }
    .padding()
}
