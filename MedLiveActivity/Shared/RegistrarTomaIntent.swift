import Foundation
import AppIntents
import ActivityKit

public struct RegistrarTomaIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Marcar como tomada"
    public static var description = IntentDescription("Registra que la dosis del medicamento fue tomada y lo guarda en Salud")

    @Parameter(title: "Nombre del Medicamento")
    public var nombre: String

    public init() {}

    public init(nombre: String) {
        self.nombre = nombre
    }

    public func perform() async throws -> some IntentResult {
        // 1. Guardar en la base de datos de Apple Health
        await HealthKitManager.shared.registrarDosisTomada(nombre: self.nombre)

        // 2. Localizar y cerrar la Live Activity en la Dynamic Island y Lock Screen
        let activities = Activity<MedicamentoAttributes>.activities
        let ahora = Date().formatted(date: .omitted, time: .shortened)
        
        for activity in activities {
            if activity.attributes.nombre == self.nombre {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    estadoTexto: "Tomada a las \(ahora)",
                    horaProgramadaTexto: activity.attributes.horaProgramadaTexto
                )
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
        }
        return .result()
    }
}
