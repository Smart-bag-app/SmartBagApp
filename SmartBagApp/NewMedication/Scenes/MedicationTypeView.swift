import SwiftUI

struct MedicationTypeInput {
    let name: String
}

enum MedicationType: String, Codable {
    case capsule = "Comprimido"
    case liquid = "Líquido"
}

struct MedicationTypeView: View {
    let input: MedicationTypeInput
    let types: [MedicationType] = [.capsule, .liquid]
    @State private var selectedType: MedicationType?
    @State private var isNavigationActive: Bool = false
    @Binding var isPresented: Bool

    var body: some View {
            VStack {
                Image(systemName: "pills") // Ícone do medicamento
                    .font(.system(size: 100))
                    .padding(.top, 50)
                
                Text("Escolha um tipo de medicamento") // Título
                    .font(.title)
                    .padding(.top, 20)
                
                List {
                    ForEach(types, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                                
                            Spacer()
        
                            if selectedType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.2))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedType = type
                        }
                    }
                }
                .padding()
                .listStyle(PlainListStyle())

                NavigationLink(destination: MedicationStrengthView(input: getInput(),
                                                                   isPresented: $isPresented),
                               isActive: $isNavigationActive) { }

                Button(action: { saveMedicationType() }) {
                    Text("Próximo")
                        .foregroundColor(selectedType == nil ? .gray : .white)
                        .padding()
                        .background((selectedType == nil ? Color.gray.opacity(0.2) : .blue))
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
                .disabled(selectedType == nil)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(input.name)
                            .font(.headline)
                    }
                }
            }
    }

    private func getInput() -> MedicationStrengthInput {
        MedicationStrengthInput(name: input.name,
                                type: selectedType ?? .capsule)
    }

    private func saveMedicationType() {
        isNavigationActive = selectedType != nil
        print("Tipo do medicamento salvo: \(selectedType)")
    }
}

struct MedicationTypeView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationTypeView(input: MedicationTypeInput(name: "Dorflex"),
                           isPresented: .constant(true))
    }
}
