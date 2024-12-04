import Foundation

enum SmartBagStatusViewState {
    case loading
    case ready
}

final class SmartBagStatusPresenter: ObservableObject {
    @Published var medications: [SmartBagStatusViewModel] = []
    @Published var viewState: SmartBagStatusViewState

    private let mqqtManager: MQTTManager
    
    init(mqqtManager: MQTTManager = MQTTManager()) {
        self.mqqtManager = mqqtManager
        viewState = .loading
        mqqtManager.delegate = self
    }

    private func setup() {
        mqqtManager.subscribe(topic: "smartBag/status/all")
    }
}

extension SmartBagStatusPresenter {
    func disconnect() {
        mqqtManager.disconnect()
    }
    
    func loadData() {
        viewState = .loading
        mqqtManager.connect()
    }
}

extension SmartBagStatusPresenter: MQTTManagerDelegate {
    func didConnectAck() {
        print("### Presenter didDisconnect")
        setup()
    }
    
    func didDisconnect() {
        print("### Presenter didDisconnect")
    }

    func receivedMessage(topic: String, message: String?) {
        print("### Presenter receivedMessage")
        print("### Topic \(topic)")
        print("### Message \(message)")

        viewState = .ready

        guard let jsonString = message else { return }

        if let data = jsonString.data(using: .utf8) {
            do {
                let items = try JSONDecoder().decode([SmartBagStatusViewModel].self, from: data)
                print("Modelos convertidos com sucesso:", items)
                medications = items
            } catch {
                print("Erro ao decodificar JSON:", error.localizedDescription)
            }
        }
    }
}
