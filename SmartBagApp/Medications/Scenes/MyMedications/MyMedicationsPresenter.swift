import Foundation
import SwiftUI
import SwiftData

enum MyMedicationsViewState {
    case loading
    case ready
}

extension MyMedicationsView {
    @Observable
    class MyMedicationsPresenter {
        var viewState: SmartBagStatusViewState
        var modelContext: ModelContext
        var medications: [Medication] = [Medication]()
        var currentSmartBagCompartiments = [SmartBagStatusViewModel]()

        var viewModel: [MyMedicationsViewModel] = [MyMedicationsViewModel]()

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
        
        private func handleMedications() {
            do {
                let fetchDescriptor = FetchDescriptor<Medication>(sortBy: [SortDescriptor(\.compartment,
                                                                                           order: .forward)])
                medications = try modelContext.fetch(fetchDescriptor)

                viewModel = medications.map {
                    let weight = makeWeight(smartBagCompartiments: currentSmartBagCompartiments,
                                            medication: $0)

                    let status = makeStatus(smartBagCompartiments: currentSmartBagCompartiments,
                                            medication: $0)

                    return MyMedicationsViewModel(medicationName: $0.name,
                                                  medicationDescription: "\($0.type.rawValue), \($0.dosage) \($0.strenghtType.name)",
                                                  schedules: makeSchedules(schedules: $0.schedules),
                                                  compartiment: $0.compartment,
                                                  weight: weight, 
                                                  associatedMedication: $0, 
                                                  status: status)
                }
                
            } catch {
                print("Fetch failed")
            }
        }

        private func makeWeight(smartBagCompartiments: [SmartBagStatusViewModel],
                                medication: Medication) -> String? {
            guard let compartimentMatched = smartBagCompartiments.first(where: {
                $0.compartment == medication.compartment
            }) else { return nil }

            return "\(compartimentMatched.weight)\(medication.strenghtType.name) restante de um total de \(medication.totalWeight)\(medication.strenghtType.name)"
        }

        private func makeSchedules(schedules: [Schedule]) -> [String] {
            schedules.map { schedule in
                "Horário: \(time(from: schedule.date) ?? "N/A") Dose: \(schedule.dose)"
            }
        }

        private func makeStatus(smartBagCompartiments: [SmartBagStatusViewModel],
                                medication: Medication) -> MyMedicationsViewModel.Status {
            guard let compartimentMatched = smartBagCompartiments.first(where: {
                $0.compartment == medication.compartment
            }) else { return .alert("N/A") }

            let percentage = (Double(compartimentMatched.weight) / medication.totalWeight) * 100
                
            switch percentage {
            case 0..<30:
                return .alert("\(percentage)% do medicamento restante")
            case 30..<60:
                return .medium("\(percentage)% do medicamento restante")
            default:
                return .full("\(percentage)% do medicamento restante")
            }
        }

        private func time(from date: Date) -> String? {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            if let hour = components.hour, let minute = components.minute {
                return String(format: "%02d:%02d", hour, minute)
            }
            return nil
        }
    }
}


extension MyMedicationsView.MyMedicationsPresenter {
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

extension MyMedicationsView.MyMedicationsPresenter: MQTTManagerDelegate {
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

        guard let jsonString = message else { return }

        if let data = jsonString.data(using: .utf8) {
            do {
                let items = try JSONDecoder().decode([SmartBagStatusViewModel].self, from: data)
                viewState = .ready
                currentSmartBagCompartiments = items
                handleMedications()
            } catch {
                print("Erro ao decodificar JSON:", error.localizedDescription)
            }
        }
    }
}
