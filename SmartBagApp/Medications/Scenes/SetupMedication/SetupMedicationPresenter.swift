import Foundation
import SwiftUI
import SwiftData

enum SetupMedicationViewState {
    case loading
    case ready
}

extension SetupMedicationView {
    @Observable
    class SetupMedicationPresenter {
        var viewState: SmartBagStatusViewState
        var modelContext: ModelContext
        
        var availableCompartiments = [Int]()
        
        private let mqqtManager: MQTTManager
        
        init(modelContext: ModelContext,
             mqqtManager: MQTTManager = MQTTManager()) {
            self.modelContext = modelContext
            self.mqqtManager = mqqtManager
            viewState = .loading
            mqqtManager.delegate = self
        }

        private func setup() {
            mqqtManager.subscribe(topic: "smartBag/status/all")
        }
        
        private func handleMedications(smartBagCompartiments: [SmartBagStatusViewModel]) {
            do {
                let medications = try modelContext.fetch(FetchDescriptor<Medication>())
                print("### medications", medications)
                print("### smartBagCompartiments", smartBagCompartiments)
                
                let linkedCompartiments = Set<Int>(medications.compactMap { $0.compartment })
                let smartBagCompartiments = Set<Int>(smartBagCompartiments.map { $0.compartment })
                let compartimentsToUse = Array(smartBagCompartiments.subtracting(linkedCompartiments))
                availableCompartiments = compartimentsToUse.sorted { $0 < $1 }
            } catch {
                print("Fetch failed")
            }
        }
    }
}


extension SetupMedicationView.SetupMedicationPresenter {
    func disconnect() {
        mqqtManager.disconnect()
    }
    
    func updateMedication(medication: Medication,
                          selectedCompartiment: String,
                          completion: () -> Void) {
        medication.compartment = Int(selectedCompartiment)
        completion()
    }
    
    func loadData() {
        viewState = .loading
        mqqtManager.connect()
    }
}

extension SetupMedicationView.SetupMedicationPresenter: MQTTManagerDelegate {
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

        disconnect()

        guard let jsonString = message else { return }

        if let data = jsonString.data(using: .utf8) {
            do {
                let items = try JSONDecoder().decode([SmartBagStatusViewModel].self, from: data)
                handleMedications(smartBagCompartiments: items)
            } catch {
                print("Erro ao decodificar JSON:", error.localizedDescription)
            }
        }
    }
}
