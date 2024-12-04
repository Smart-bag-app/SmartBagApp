import SwiftUI
import SwiftData

struct SetupMedicationView: View {
    let medication: Medication
    
    @State private var presenter: SetupMedicationPresenter
    @State private var selectedCompartiment: String = ""
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            switch presenter.viewState {
            case .loading:
                VStack {
                    Text("Conectando com a sua Smart Medicine Box...")
                    ProgressView()
                }
            case .ready:
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(maxHeight: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Text("Medicamento a ser vinculado")
                                    .font(.headline)
                                Text(medication.name)
                            }
                            .padding()
                        )
                        .padding()
                        .shadow(radius: 4)

                    Text("Selecione um compartimento:")
                        .font(.headline)
                        .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(presenter.availableCompartiments, id: \.self) { compartiment in
                            RadioButton(
                                id: "\(compartiment)",
                                label: "\(compartiment)",
                                isSelected: $selectedCompartiment,
                                callback: radioSelected
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding()

                    Button(action: { confirmSelection() }) {
                        Text("Confirmar seleção")
                            .foregroundColor(selectedCompartiment.isEmpty ? .gray : .white)
                            .padding()
                            .background((selectedCompartiment.isEmpty ? Color.gray.opacity(0.2) : .blue))
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.horizontal)
                    .disabled(selectedCompartiment.isEmpty)

                    Spacer()
                }
            }
        }
        .onDisappear {
            print("onDisappear")
        }
        .onAppear {
            presenter.loadData()
        }
    }
    
    private func radioSelected(id: String) {
        selectedCompartiment = id
    }

    private func confirmSelection() {
        presenter.updateMedication(medication: medication,
                                   selectedCompartiment: selectedCompartiment) {
            isPresented.toggle()
        }
    }
    
    init(modelContext: ModelContext,
         medication: Medication,
         isPresented: Binding<Bool>) {
        let presenter = SetupMedicationPresenter(modelContext: modelContext)
        _presenter = State(initialValue: presenter)
        _isPresented = isPresented
        self.medication = medication
    }
}

struct RadioButton: View {
    let id: String
    let label: String
    @Binding var isSelected: String
    var callback: (String) -> ()

    var body: some View {
        Button(action: {
            isSelected = id
            callback(id)
        }) {
            HStack {
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isSelected == id ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected == id ? .accentColor : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
//#Preview {
//    SetupMedicationView(medication: Medication(name: "Name",
//                                               type: .capsule,
//                                               strenghtType: .g,
//                                               dosage: 5,
//                                               schedules: [],
//                                               compartment: nil))
//}
