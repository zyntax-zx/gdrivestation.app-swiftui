import SwiftUI

struct PlayerOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var screenHeight: CGFloat = 0

    private let maxCornerRadius: CGFloat = 36

    var body: some View {
        GeometryReader { geo in
            let maxDrag = screenHeight

            ZStack(alignment: .bottom) {
                Color.black.opacity(backgroundOpacity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(springAnimation) {
                            isPresented = false
                        }
                    }

                Group {
                    content()
                }
                .frame(width: geo.size.width, height: screenHeight)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: currentCornerRadius,
                        topTrailingRadius: currentCornerRadius
                    )
                )
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = lastOffset + value.translation.height
                            dragOffset = min(max(newOffset, 0), maxDrag)
                        }
                        .onEnded { value in
                            let newOffset = lastOffset + value.translation.height
                            let velocity = value.predictedEndTranslation.height - value.translation.height

                            let targetOffset: CGFloat
                            if velocity > 200 || newOffset > maxDrag * 0.4 {
                                targetOffset = maxDrag
                                isPresented = false
                            } else {
                                targetOffset = 0
                            }

                            withAnimation(springAnimation) {
                                dragOffset = targetOffset
                                lastOffset = targetOffset
                            }
                        }
                )
                .onAppear {
                    screenHeight = geo.size.height
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                withAnimation(springAnimation) {
                    dragOffset = 0
                    lastOffset = 0
                }
            } else {
                withAnimation(springAnimation) {
                    dragOffset = screenHeight
                }
            }
        }
    }

    private var currentCornerRadius: CGFloat {
        guard screenHeight > 0 else { return 0 }
        let progress = min(dragOffset / screenHeight, 1.0)
        if progress < 0.01 { return 0 }
        return min(28 + progress * 8, maxCornerRadius)
    }

    private var backgroundOpacity: Double {
        guard screenHeight > 0 else { return 1.0 }
        let progress = min(dragOffset / screenHeight, 1.0)
        return Double(1.0 - progress * 0.45)
    }

    private var springAnimation: Animation {
        DesignTokens.Animation.spring
    }
}
