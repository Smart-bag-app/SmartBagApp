import SwiftUI

struct SmartBagStatusView: View {
    @ObservedObject var presenter = SmartBagStatusPresenter()

    var body: some View {
        VStack {
            switch presenter.viewState {
            case .loading:
                VStack {
                    Text("Conectando com a sua Smart Medicine Box...")
                    ProgressView()
                }
            case .ready:
                List {
                    ForEach(presenter.medications, id: \.id) { medication in
                        VStack(alignment: .leading) {
                            Text("Compartimento: \(medication.compartment)")
                                .font(.headline)

                            Text("Peso: \(medication.weight) gramas")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
            }
        }
        .onDisappear {
            presenter.disconnect()
        }
        .onAppear {
            presenter.loadData()
        }
    }
}

#Preview {
    SmartBagStatusView()
}
