import SwiftUI
import UIKit

struct NativeKeypadButton: View {
    let text: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.gray.opacity(0.3) : Color(UIColor.systemGray5))
                    .frame(width: 75, height: 75)

                Text(text)
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
