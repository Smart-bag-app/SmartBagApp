import SwiftUI
import UserNotifications

struct MedicationScheduleInput {
    let name: String
    let type: MedicationType
    let strengthType: MedicationStrengthType
    let strengthValue: Int
    let totalWeight: Double
}

struct MedicationScheduleView: View {
    let input: MedicationScheduleInput
    @Environment(\.modelContext) private var modelContext
    @State private var schedules: [Schedule] = []
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 100))
                .padding(.top, 50)
            
            Text("Quando você vai tomar isso?")
                .font(.title)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 50)
                .overlay(
                    HStack {
                        Text("Frequência")
                        Spacer()
                        Button(action: {
                            // Ação do botão
                        }) {
                            Text("Todos os dias")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                )
            
            Text("Horários")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            
            // Lista de horários
            List {
                ForEach(schedules.indices, id: \.self) { index in
                    ScheduleRow(schedule: $schedules[index])
                        .swipeActions {
                            Button(action: {
                                self.deleteSchedule(at: index)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                .contentShape(Rectangle())

                Button(action: {
                    self.addSchedule()
                }) {
                    HStack {
                        Spacer()
                        Text("Adicionar Horário")
                            .foregroundColor(Color.blue)
                        Spacer()
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                .contentShape(Rectangle())
            }
            .listStyle(PlainListStyle())
            
            Button(action: { saveMedication() }) {
                Text("Salvar")
                    .foregroundColor(schedules.isEmpty ? .gray : .white)
                    .padding()
                    .background((schedules.isEmpty ? Color.gray.opacity(0.2) : .blue))
                    .cornerRadius(10)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.horizontal)
            .disabled(schedules.isEmpty)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(input.name).font(.headline)
                    Text(getSubtitle()).font(.subheadline)
                }
            }
        }
    }

    private func getSubtitle() -> String {
        return "\(input.type.rawValue), \(input.strengthValue) \(input.strengthType.name)"
    }

    // Função para adicionar um novo horário à lista
    private func addSchedule() {
        schedules.append(Schedule())
    }
    
    // Função para deletar um horário da lista
    private func deleteSchedule(at index: Int) {
        schedules.remove(at: index)
    }
    
    private func handleNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, failure in
            if success {
                schedules.forEach { schedule in
                    let content = UNMutableNotificationContent()
                    content.title = "Hora de tomar \(input.name)"
                    content.subtitle = "Voce deve tomar apenas a dose de \(input.strengthValue)"
                    content.sound = UNNotificationSound.defaultCritical

                    var dateInfo = DateComponents()
                    dateInfo.hour = Calendar.current.component(.hour, from: schedule.date)
                    dateInfo.minute = Calendar.current.component(.minute, from: schedule.date)
                
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo,
                                                                repeats: true)

                    let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: content,
                                                        trigger: trigger)

                    UNUserNotificationCenter.current().add(request)
                }
            } else if let error = failure {
                print(error.localizedDescription)
            } else {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                print("vish")
            }
        }
    }
    private func saveMedication() {
        handleNotification()
        let medication = Medication(name: input.name,
                                    type: input.type,
                                    strenghtType: input.strengthType,
                                    dosage: input.strengthValue,
                                    schedules: schedules, 
                                    totalWeight: input.totalWeight)
        modelContext.insert(medication)
        isPresented = false
    }
}

struct ScheduleRow: View {
    @Binding var schedule: Schedule
    
    var body: some View {
        HStack {
            DatePicker("",
                       selection: $schedule.date,
                       displayedComponents: .hourAndMinute)
                .labelsHidden()
                .padding()
                .onAppear {
                    UIDatePicker.appearance().minuteInterval = 5
                }
            
            Spacer()
            
            TextField("Doses", text: $schedule.dose)
                .padding(.trailing)
                .keyboardType(.numberPad)
            
            Text("dose(s)")
                .padding(.trailing)
        }
    }
}

struct Schedule: Hashable, Codable {
    var date = Date()
    var dose = "1"
}

struct MedicationScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationScheduleView(input: MedicationScheduleInput(name: "Dorflex",
                                                              type: .capsule,
                                                              strengthType: .g,
                                                              strengthValue: 5, 
                                                              totalWeight: 10),
                               isPresented: .constant(true))
    }
}
