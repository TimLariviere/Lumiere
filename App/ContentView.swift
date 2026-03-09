import SwiftUI
import Core
import Auth

struct ContentView: View {
    @State var userId: String? = nil
    
    var body: some View {
        ServerSelectionView()
    }
}

#Preview {
    ContentView()
}
