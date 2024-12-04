import SwiftUI

struct MedicationStrengthInput {
    let name: String
    let type: MedicationType
}

enum MedicationStrengthType: Codable {
    case mg
    case g
    case ml

    var name: String {
        switch self {
        case .mg:
            return "mg"
        case .g:
            return "g"
        case .ml:
            return "ml"
        }
    }
}

struct MedicationStrengthView: View {
    let input: MedicationStrengthInput
    let units: [MedicationStrengthType] = [.mg, .g, .ml]
    @State private var selectedUnit: MedicationStrengthType?
    @State private var dosage: String = ""
    @State private var weight: String = "" // Novo estado para o peso
    @State private var isNavigationActive: Bool = false
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Image(systemName: "pills")
                    .font(.system(size: 100))
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Escolha a dosagem")
                    .font(.title)
                    .padding(.top, 20)
    
                TextField("Insira a dosagem", text: $dosage)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text("Escolha uma unidade")
                    .font(.title)
                    .padding(.top, 20)
                
                // Usar LazyVStack em vez de List
                LazyVStack {
                    ForEach(units, id: \.self) { unit in
                        HStack {
                            Text(unit.name)
                            
                            Spacer()
                            
                            if selectedUnit == unit {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .background(Color.gray.opacity(0.2))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedUnit = unit
                        }
                    }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("Insira o peso total do medicamento")
                        .font(.title)
                        .padding(.top, 20)
                    
                    Text("Você pode encontrar essa informação na embalagem da medicação")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("Insira o peso total", text: $weight)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }

                NavigationLink(destination: MedicationScheduleView(input: getInput(),
                                                                   isPresented: $isPresented),
                               isActive: $isNavigationActive) { }

                Button(action: { saveMedicationType() }) {
                    Text("Próximo")
                        .foregroundColor(selectedUnit == nil || dosage.isEmpty || weight.isEmpty ? .gray : .white)
                        .padding()
                        .background((selectedUnit == nil || dosage.isEmpty || weight.isEmpty ? Color.gray.opacity(0.2) : .blue))
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
                .disabled(selectedUnit == nil || dosage.isEmpty || weight.isEmpty)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(input.name) // Adiciona o título de navegação
        .navigationBarTitleDisplayMode(.inline) // Define o título no modo inline
    }
    
    private func saveMedicationType() {
        isNavigationActive = !(selectedUnit == nil || dosage.isEmpty || weight.isEmpty)
        print("Dosagem: \(dosage), Unidade: \(selectedUnit), Peso: \(weight)")
    }

    private func getInput() -> MedicationScheduleInput {
        MedicationScheduleInput(name: input.name,
                                type: input.type,
                                strengthType: selectedUnit ?? .g,
                                strengthValue: Int(dosage) ?? 0,
                                totalWeight: Double(weight) ?? 0)
    }
}

struct MedicationStrengthView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationStrengthView(input: MedicationStrengthInput(name: "Dorflex",
                                                              type: .capsule),
                               isPresented: .constant(true))
    }
}
