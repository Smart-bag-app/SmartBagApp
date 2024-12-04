import SwiftData

@Model
class Medication {
    var name: String
    var type: MedicationType
    var strenghtType: MedicationStrengthType
    var dosage: Int
    var schedules: [Schedule]
    var totalWeight: Double
    var compartment: Int?

    init(name: String,
         type: MedicationType,
         strenghtType: MedicationStrengthType,
         dosage: Int,
         schedules: [Schedule],
         totalWeight: Double,
         compartment: Int? = nil) {
        self.name = name
        self.type = type
        self.strenghtType = strenghtType
        self.dosage = dosage
        self.schedules = schedules
        self.totalWeight = totalWeight
        self.compartment = compartment
    }
}
