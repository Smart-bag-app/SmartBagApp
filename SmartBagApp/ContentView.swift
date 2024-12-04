import SwiftUI
import SwiftData
import UserNotifications
import CocoaMQTT

struct ContentView: View {
    @State private var selectedSegment = 0
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            Picker("", selection: $selectedSegment) {
                Text("Meus medicamentos").tag(0)
                Text("Compartimentos").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedSegment == 0 {
                MyMedicationsView(modelContext: modelContext)
            } else {
                SmartBagStatusView()
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
