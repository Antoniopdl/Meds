import Foundation
import AppIntents
import ActivityKit

public struct RegistrarTomaIntent: LiveActivityIntent {
    public static var title: LocalizedStringResource = "Marcar como tomada"
    public static var description = IntentDescription("Registra que la dosis del medicamento fue tomada")

    @Parameter(title: "Nombre del Medicamento")
    public var nombre: String

    public init() {}

    public init(nombre: String) {
        self.nombre = nombre
    }

    public func perform() async throws -> some IntentResult {
        let ahora = Date().formatted(date: .omitted, time: .shortened)

        // 1. Inmediatamente cerrar la actividad en la pantalla
        for activity in Activity<MedicamentoAttributes>.activities {
            if activity.attributes.nombre == self.nombre || self.nombre.isEmpty {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    estadoTexto: "Tomada a las \(ahora)",
                    horaProgramadaTexto: activity.attributes.horaProgramadaTexto,
                    fechaToma: activity.attributes.fechaToma
                )
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
        }

        // 2. Registrar en segundo plano en Salud sin bloquear la interfaz
        Task.detached {
            await HealthKitManager.shared.registrarDosisTomada(nombre: self.nombre)
        }

        return .result()
    }
}
