import SwiftUI
import SwiftData
import UserNotifications
import CocoaMQTT
// smart medicine box
// falar de iot, iot e health, o que é importante de conceitos para o entendimento do trabalho em si
//

struct MyMedicationsViewModel: Identifiable {
    enum Status {
        case full(String)
        case medium(String)
        case alert(String)
        
        func get() -> String {
            switch self {
            case .full(let value):
                return value
            case .medium(let value):
                return value
            case .alert(let value):
                return value
            }
        }
    }

    let id = UUID()
    let medicationName: String
    let medicationDescription: String
    let schedules: [String]
    var compartiment: Int?
    var weight: String?
    var associatedMedication: Medication
    let status: Status
}

struct MyMedicationsView: View {
    @State private var showingMedicationNameView = false

    @State private var showingSetupView = false

    @State private var presenter: MyMedicationsPresenter

    var body: some View {
        NavigationSplitView {
            VStack {
                switch presenter.viewState {
                case .loading:
                    VStack {
                        Text("Conectando com a sua Smart Medicine Box...")
                        ProgressView()
                    }
                case .ready:
                    List {
                        ForEach(Array(presenter.viewModel.enumerated()), id: \.element.id) { index, viewModel in
                            VStack(alignment: .leading) {
                                Text(viewModel.medicationName)
                                    .font(.headline)

                                Text(viewModel.medicationDescription)

                                Spacer()

                                Text("Horarios")
                                    .font(.headline)

                                ForEach(viewModel.schedules, id: \.self) { schedule in
                                    HStack {
                                        Text(schedule)
                                    }
                                }
                                
                                Spacer()

                                Text("Compartimento")
                                    .font(.headline)

                                HStack {
                                    if let compartment = viewModel.compartiment {
                                        Text("\(compartment)")
                                    } else {
                                        Text("Não configurado")
                                            .font(.headline)
                                            .foregroundStyle(Color.red.opacity(0.8))
                                        
                                        Button(action: {
                                            presenter.disconnect()
                                            showingSetupView.toggle()
                                        }) {
                                            Text("Configurar")
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                                        }
                                        .sheet(isPresented: $showingSetupView, onDismiss: {
                                            presenter.loadData()
                                        }, content: {
                                            SetupMedicationView(modelContext: presenter.modelContext,
                                                                medication: viewModel.associatedMedication,
                                                                isPresented: $showingSetupView)
                                        })
                                    }
                                }
                
                                Spacer()
                        
                                Text("Peso")
                                    .font(.headline)
                                Text(viewModel.weight ?? "N/A")
                                Text(viewModel.status.get())
                                    .font(.caption)

                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(backgroundColor(status: viewModel.status))
                            .cornerRadius(16)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(PlainListStyle())
                    .toolbar {
                        ToolbarItem {
                            Button(action: {
                                presenter.disconnect()
                                showingMedicationNameView.toggle()
                            }) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showingMedicationNameView, onDismiss: {
                        presenter.loadData()
                    }, content: {
                        MedicationNameView(isPresented: $showingMedicationNameView)
                    })
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onDisappear {
            presenter.disconnect()
        }
        .onAppear {
            presenter.loadData()
        }
    }

    init(modelContext: ModelContext) {
        let presenter = MyMedicationsPresenter(modelContext: modelContext)
        _presenter = State(initialValue: presenter)
    }

    private func backgroundColor(status: MyMedicationsViewModel.Status) -> some View {
        switch status {
        case .full:
            return Color.green.opacity(0.2)
        case .medium:
            return Color.yellow.opacity(0.2)
        case .alert:
            return Color.red.opacity(0.2)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            presenter.modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                presenter.modelContext.delete(presenter.medications[index])
            }
        }
    }
}

//#Preview {
//    MyMedicationsView()
//}
