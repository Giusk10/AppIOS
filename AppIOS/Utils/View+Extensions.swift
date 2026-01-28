import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var animatableData: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: animatableData))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.default) {
                        animatableData = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animatableData = 0
                        trigger = false
                    }
                }
            }
    }
}

extension View {
    func shake(_ trigger: Binding<Bool>) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }
}
