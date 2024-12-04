import SwiftUI

struct MedicationNameView: View {
    @State private var medicationName: String = ""
    @State private var isNavigationActive: Bool = false
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "pills")
                    .font(.system(size: 100))
                    .padding(.bottom, 20)
        
                Text("Nome do medicamento")
                    .font(.title)
                    .padding()
                    .fontWeight(.bold)

                TextField("Adicione o nome do medicamento", text: $medicationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: MedicationTypeView(input: getInput(),
                                                               isPresented: $isPresented),
                               isActive: $isNavigationActive) { }

                Button(action: { saveMedicationName() }) {
                    Text("Próximo")
                        .foregroundColor(medicationName.isEmpty ? .gray : .white)
                        .padding()
                        .background((medicationName.isEmpty ? Color.gray.opacity(0.2) : .blue))
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
                .disabled(medicationName.isEmpty)
            }
        }
    }
    
    private func saveMedicationName() {
        isNavigationActive = !medicationName.isEmpty
        print("Nome do medicamento salvo: \(medicationName)")
    }
    
    private func getInput() -> MedicationTypeInput {
        MedicationTypeInput(name: medicationName)
    }
}

struct MedicationNameView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationNameView(isPresented: .constant(true))
    }
}
