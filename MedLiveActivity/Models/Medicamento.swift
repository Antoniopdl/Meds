import Foundation

public struct HorarioToma: Identifiable, Codable, Equatable {
    public var id: UUID
    public var hora: Int       // 0-23
    public var minuto: Int     // 0-59

    public init(id: UUID = UUID(), hora: Int, minuto: Int) {
        self.id = id
        self.hora = hora
        self.minuto = minuto
    }

    public var textoFormateado: String {
        let periodo = hora >= 12 ? "P.M." : "A.M."
        let hora12 = hora == 0 ? 12 : (hora > 12 ? hora - 12 : hora)
        return String(format: "%02d:%02d %@", hora12, minuto, periodo)
    }

    public func proximaFechaToma() -> Date {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hora
        comps.minute = minuto
        comps.second = 0

        guard let fechaHoy = calendar.date(from: comps) else { return Date() }
        if fechaHoy < Date() {
            return calendar.date(byAdding: .day, value: 1, to: fechaHoy) ?? fechaHoy
        }
        return fechaHoy
    }
}

public struct Medicamento: Identifiable, Codable, Equatable {
    public var id: UUID
    public var nombre: String
    public var dosis: String
    public var forma: FormaMedicamento
    public var imagenNombre: String
    public var horarios: [HorarioToma]

    // Control de Inventario
    public var totalPorCaja: Int          // Ej. 30 pastillas o 100 ml
    public var unidadesRestantes: Int     // Ej. 18 pastillas actuales
    public var umbralAlertaDias: Int      // Avisar cuando falten X días (default: 5)
    public var fechaUltimaToma: Date?

    public init(
        id: UUID = UUID(),
        nombre: String,
        dosis: String,
        forma: FormaMedicamento,
        imagenNombre: String,
        horarios: [HorarioToma],
        totalPorCaja: Int = 30,
        unidadesRestantes: Int = 30,
        umbralAlertaDias: Int = 5,
        fechaUltimaToma: Date? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.dosis = dosis
        self.forma = forma
        self.imagenNombre = imagenNombre
        self.horarios = horarios
        self.totalPorCaja = totalPorCaja
        self.unidadesRestantes = unidadesRestantes
        self.umbralAlertaDias = umbralAlertaDias
        self.fechaUltimaToma = fechaUltimaToma
    }

    /// Dosis que se toman por día según la lista de horarios
    public var tomasPorDia: Int {
        max(1, horarios.count)
    }

    /// Días de tratamiento que quedan según las unidades en stock
    public var diasRestantesSuministro: Int {
        unidadesRestantes / tomasPorDia
    }

    /// Determina si el medicamento está en nivel crítico de inventario
    public var requiereRestock: Bool {
        diasRestantesSuministro <= umbralAlertaDias
    }
}
