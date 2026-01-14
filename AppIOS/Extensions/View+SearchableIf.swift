import SwiftUI

extension View {
    @ViewBuilder
    func searchableIf(isPresented: Binding<Bool>, text: Binding<String>) -> some View {
        if isPresented.wrappedValue {
            // displayMode: .always keeps it visible while active. 
            // Since we conditionally apply it, it shouldn't exist when inactive.
            self.searchable(text: text, isPresented: isPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Cerca spese...")
        } else {
            self
        }
    }
}
