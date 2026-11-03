import Foundation
import AppIntents
import ActivityKit

public enum MedicamentoOpcion: String, AppEnum {
    case auto = "Auto"
    case tradea = "Tradea"
    case minoxidil = "Minoxidil"
    case sertex = "Sertex"

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Medicamento"

    public static var caseDisplayRepresentations: [MedicamentoOpcion: DisplayRepresentation] = [
        .auto: DisplayRepresentation(title: "Auto (Próxima dosis)", subtitle: "Detecta según la hora de la toma"),
        .tradea: DisplayRepresentation(title: "Tradea (Metilfenidato)", subtitle: "08:29 A.M. - Pastilla 27 mg"),
        .minoxidil: DisplayRepresentation(title: "Minoxidil", subtitle: "08:50 P.M. - Tópico 5%"),
        .sertex: DisplayRepresentation(title: "Sertex (Sertralina)", subtitle: "10:30 P.M. - Pastilla 50 mg")
    ]
}

public struct LanzarAlertaDosisIntent: AppIntent {
    public static var title: LocalizedStringResource = "Lanzar Alerta de Medicamento"
    public static var description = IntentDescription("Activa la Live Activity en la Dynamic Island y Pantalla de Bloqueo para la dosis correspondiente.")

    // Permite que Atajos ejecute la acción en segundo plano SIN desbloquear el teléfono
    public static var openAppWhenRun: Bool = false

    @Parameter(title: "Medicamento", default: .auto)
    public var medicamento: MedicamentoOpcion

    @Parameter(title: "Modo Urgente (Roja)", default: false)
    public var urgente: Bool

    public init() {
        self.medicamento = .auto
        self.urgente = false
    }

    public init(medicamento: MedicamentoOpcion, urgente: Bool = false) {
        self.medicamento = medicamento
        self.urgente = urgente
    }

    public func perform() async throws -> some IntentResult {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return .result()
        }

        let medSeleccionado = await obtenerMedicamentoObjetivo(opcion: medicamento)
        guard let med = medSeleccionado else { return .result() }

        // Evitar duplicar si ya hay una Live Activity activa para este medicamento
        let yaExiste = Activity<MedicamentoAttributes>.activities.contains {
            $0.attributes.nombre == med.nombre
        }
        guard !yaExiste else { return .result() }

        let modoStr = urgente ? "urgente" : "normal"
        let calendar = Calendar.current
        var fechaObjetivo = urgente ? Date().addingTimeInterval(-900) : Date().addingTimeInterval(600)
        let horaTexto = med.horarios.first?.textoFormateado ?? "08:00 A.M."

        if !urgente, let primerHorario = med.horarios.first {
            var comp = calendar.dateComponents([.year, .month, .day], from: Date())
            comp.hour = primerHorario.hora
            comp.minute = primerHorario.minuto
            comp.second = 0
            if let fechaReal = calendar.date(from: comp) {
                fechaObjetivo = fechaReal
            }
        }

        let attributes = MedicamentoAttributes(
            nombre: med.nombre,
            dosis: med.dosis,
            tipo: med.forma.rawValue,
            imagenNombre: med.imagenNombre,
            horaProgramadaTexto: horaTexto,
            fechaToma: fechaObjetivo
        )

        let initialState = MedicamentoAttributes.ContentState(
            fueTomado: false,
            estadoTexto: urgente ? "Atrasada" : "Toma en 10 min",
            horaProgramadaTexto: horaTexto,
            fechaToma: fechaObjetivo,
            modo: modoStr,
            unidadesRestantes: med.unidadesRestantes,
            minutosAtraso: urgente ? 15 : 0
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Error al lanzar Live Activity desde Atajos: \(error)")
        }

        return .result()
    }

    @MainActor
    private func obtenerMedicamentoObjetivo(opcion: MedicamentoOpcion) -> Medicamento? {
        let lista = StorageService.shared.medicamentos.isEmpty ? [
            Medicamento(
                nombre: "Tradea (Metilfenidato)",
                dosis: "Pastilla 27 mg",
                forma: .pastilla,
                imagenNombre: "tradea",
                horarios: [HorarioToma(hora: 8, minuto: 29)],
                totalPorCaja: 30,
                unidadesRestantes: 24
            ),
            Medicamento(
                nombre: "Minoxidil",
                dosis: "Tópico 5%",
                forma: .topico,
                imagenNombre: "minoxidil",
                horarios: [HorarioToma(hora: 20, minuto: 50)],
                totalPorCaja: 60,
                unidadesRestantes: 45
            ),
            Medicamento(
                nombre: "Sertex (Sertralina)",
                dosis: "Pastilla 50 mg",
                forma: .pastilla,
                imagenNombre: "sertex",
                horarios: [HorarioToma(hora: 22, minuto: 30)],
                totalPorCaja: 28,
                unidadesRestantes: 19
            )
        ] : StorageService.shared.medicamentos

        switch opcion {
        case .tradea:
            return lista.first { $0.nombre.localizedCaseInsensitiveContains("Tradea") }
        case .minoxidil:
            return lista.first { $0.nombre.localizedCaseInsensitiveContains("Minoxidil") }
        case .sertex:
            return lista.first { $0.nombre.localizedCaseInsensitiveContains("Sertex") }
        case .auto:
            let calendar = Calendar.current
            let ahora = Date()
            let horaActual = calendar.component(.hour, from: ahora)
            let minutoActual = calendar.component(.minute, from: ahora)
            let minutosDesdeMedianoche = (horaActual * 60) + minutoActual

            var mejorMed: Medicamento? = nil
            var menorDiferencia = Int.max

            for med in lista {
                // Si ya fue tomado hoy, ignorar
                if StorageService.shared.fueTomadoHoy(medicamentoId: med.id) {
                    continue
                }

                if let h = med.horarios.first {
                    let minutosMed = (h.hora * 60) + h.minuto
                    let diff = minutosMed - minutosDesdeMedianoche
                    // Ventana entre -5 min y +25 min
                    if diff >= -5 && diff <= 25 {
                        let distancia = abs(diff - 10)
                        if distancia < menorDiferencia {
                            menorDiferencia = distancia
                            mejorMed = med
                        }
                    }
                }
            }

            return mejorMed ?? lista.first
        }
    }
}

public struct PillPulseShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LanzarAlertaDosisIntent(medicamento: .auto),
            phrases: [
                "Activar alerta de medicamento en \(.applicationName)",
                "Iniciar próxima pastilla en \(.applicationName)"
            ],
            shortTitle: "Activar Próxima Dosis",
            systemImageName: "timer"
        )
    }
}
