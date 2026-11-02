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
        let activities = Activity<MedicamentoAttributes>.activities
        for activity in activities {
            if activity.attributes.nombre == self.nombre {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    horaTexto: "Tomado a las " + Date().formatted(date: .omitted, time: .shortened)
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
