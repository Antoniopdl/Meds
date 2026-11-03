import Foundation
import Combine

@MainActor
public final class StorageService: ObservableObject {
    public static let shared = StorageService()

    @Published public var medicamentos: [Medicamento] = []
    @Published public var registros: [RegistroToma] = []

    private let fileManager = FileManager.default
    private let medicamentosFileName = "medicamentos_data.json"
    private let registrosFileName = "registros_tomas.json"

    private init() {
        cargarDatos()
    }

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var medicamentosURL: URL {
        documentsDirectory.appendingPathComponent(medicamentosFileName)
    }

    private var registrosURL: URL {
        documentsDirectory.appendingPathComponent(registrosFileName)
    }

    // MARK: - Carga y Guardado
    public func cargarDatos() {
        // Cargar Medicamentos
        if let data = try? Data(contentsOf: medicamentosURL),
           let meds = try? JSONDecoder().decode([Medicamento].self, from: data) {
            self.medicamentos = meds
        } else {
            // Inicializar con los 3 medicamentos reales de Antonio
            self.medicamentos = [
                Medicamento(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
                    nombre: "Tradea (Metilfenidato)",
                    dosis: "Pastilla 27 mg",
                    forma: .pastilla,
                    imagenNombre: "tradea",
                    horarios: [HorarioToma(hora: 8, minuto: 29)],
                    totalPorCaja: 30,
                    unidadesRestantes: 24,
                    umbralAlertaDias: 5
                ),
                Medicamento(
                    id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                    nombre: "Minoxidil",
                    dosis: "Tópico 5%",
                    forma: .topico,
                    imagenNombre: "minoxidil",
                    horarios: [HorarioToma(hora: 20, minuto: 50)],
                    totalPorCaja: 60,
                    unidadesRestantes: 45,
                    umbralAlertaDias: 7
                ),
                Medicamento(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
                    nombre: "Sertex (Sertralina)",
                    dosis: "Pastilla 50 mg",
                    forma: .pastilla,
                    imagenNombre: "sertex",
                    horarios: [HorarioToma(hora: 22, minuto: 30)],
                    totalPorCaja: 28,
                    unidadesRestantes: 19,
                    umbralAlertaDias: 5
                )
            ]
            guardarMedicamentos()
        }

        // Cargar Registros Históricos
        if let data = try? Data(contentsOf: registrosURL),
           let logs = try? JSONDecoder().decode([RegistroToma].self, from: data) {
            self.registros = logs
        } else {
            self.registros = []
        }
    }

    public func guardarMedicamentos() {
        if let data = try? JSONEncoder().encode(medicamentos) {
            try? data.write(to: medicamentosURL)
        }
    }

    public func guardarRegistros() {
        if let data = try? JSONEncoder().encode(registros) {
            try? data.write(to: registrosURL)
        }
    }

    // MARK: - CRUD Medicamentos
    public func agregarMedicamento(_ med: Medicamento) {
        medicamentos.append(med)
        guardarMedicamentos()
    }

    public func actualizarMedicamento(_ med: Medicamento) {
        if let index = medicamentos.firstIndex(where: { $0.id == med.id }) {
            medicamentos[index] = med
            guardarMedicamentos()
        }
    }

    public func eliminarMedicamento(id: UUID) {
        medicamentos.removeAll(where: { $0.id == id })
        guardarMedicamentos()
    }

    // MARK: - Registro de Toma e Inventario
    public func marcarTomaRealizada(medicamentoId: UUID, fecha: Date = Date()) {
        guard let index = medicamentos.firstIndex(where: { $0.id == medicamentoId }) else { return }

        // 1. Descontar 1 unidad del inventario
        if medicamentos[index].unidadesRestantes > 0 {
            medicamentos[index].unidadesRestantes -= 1
        }
        medicamentos[index].fechaUltimaToma = fecha
        guardarMedicamentos()

        // 2. Guardar registro en el Habit Tracker
        let nuevoRegistro = RegistroToma(
            medicamentoId: medicamentoId,
            medicamentoNombre: medicamentos[index].nombre,
            fechaHora: fecha,
            fueAtrasada: false,
            minutosDiferencia: 0
        )
        registros.append(nuevoRegistro)
        guardarRegistros()
    }

    public func reabastecerStock(medicamentoId: UUID, cantidad: Int) {
        if let index = medicamentos.firstIndex(where: { $0.id == medicamentoId }) {
            medicamentos[index].unidadesRestantes += cantidad
            guardarMedicamentos()
        }
    }

    public func fueTomadoHoy(medicamentoId: UUID) -> Bool {
        let calendar = Calendar.current
        let hoy = calendar.startOfDay(for: Date())
        return registros.contains { reg in
            reg.medicamentoId == medicamentoId &&
            calendar.startOfDay(for: reg.fechaHora) == hoy
        }
    }
}
