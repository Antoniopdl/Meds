import Foundation

public struct ResumenHabitoDia: Identifiable {
    public var id: String { fechaTexto }
    public var fecha: Date
    public var fechaTexto: String
    public var tomasEsperadas: Int
    public var tomasCompletadas: Int

    public var porcentajeCumplimiento: Double {
        guard tomasEsperadas > 0 else { return 1.0 }
        return Double(tomasCompletadas) / Double(tomasEsperadas)
    }

    public var estado: EstadoDia {
        if tomasCompletadas >= tomasEsperadas && tomasEsperadas > 0 {
            return .completo
        } else if tomasCompletadas > 0 {
            return .parcial
        } else {
            return .sinTomas
        }
    }

    public enum EstadoDia {
        case completo
        case parcial
        case sinTomas
    }
}

public struct EstadisticaMedicamento: Identifiable {
    public var id: UUID
    public var nombre: String
    public var forma: FormaMedicamento
    public var porcentajeAdherencia: Int
    public var totalTomasMes: Int
}

public final class HabitAnalytics {
    public static func calcularAdherenciaGeneral(medicamentos: [Medicamento], registros: [RegistroToma], diasAtras: Int = 30) -> Int {
        guard !medicamentos.isEmpty else { return 100 }

        let calendar = Calendar.current
        guard let fechaInicio = calendar.date(byAdding: .day, value: -diasAtras, to: Date()) else { return 100 }

        let registrosRecientes = registros.filter { $0.fechaHora >= fechaInicio }
        let tomasEsperadasDiarias = medicamentos.reduce(0) { $0 + $1.tomasPorDia }
        let totalEsperado = tomasEsperadasDiarias * diasAtras

        guard totalEsperado > 0 else { return 100 }
        let porcentaje = (Double(registrosRecientes.count) / Double(totalEsperado)) * 100.0
        return min(100, Int(porcentaje))
    }

    public static func calcularRachaDias(registros: [RegistroToma], tomasEsperadasPorDia: Int) -> Int {
        guard tomasEsperadasPorDia > 0, !registros.isEmpty else { return 0 }

        let calendar = Calendar.current
        var racha = 0
        var diaComparar = calendar.startOfDay(for: Date())

        for _ in 0..<60 {
            let inicioDia = diaComparar
            guard let finDia = calendar.date(byAdding: .day, value: 1, to: inicioDia) else { break }

            let tomasDia = registros.filter { $0.fechaHora >= inicioDia && $0.fechaHora < finDia }.count
            if tomasDia >= tomasEsperadasPorDia {
                racha += 1
                guard let diaAnterior = calendar.date(byAdding: .day, value: -1, to: diaComparar) else { break }
                diaComparar = diaAnterior
            } else {
                break
            }
        }
        return racha
    }

    public static func desglosePorMedicamento(medicamentos: [Medicamento], registros: [RegistroToma]) -> [EstadisticaMedicamento] {
        let calendar = Calendar.current
        guard let inicioMes = calendar.date(byAdding: .day, value: -30, to: Date()) else { return [] }
        let registrosMes = registros.filter { $0.fechaHora >= inicioMes }

        return medicamentos.map { med in
            let tomasMed = registrosMes.filter { $0.medicamentoId == med.id }.count
            let esperadas = med.tomasPorDia * 30
            let porcentaje = esperadas > 0 ? min(100, Int((Double(tomasMed) / Double(esperadas)) * 100.0)) : 100

            return EstadisticaMedicamento(
                id: med.id,
                nombre: med.nombre,
                forma: med.forma,
                porcentajeAdherencia: porcentaje,
                totalTomasMes: tomasMed
            )
        }
    }

    public static func diasUltimasSemanas(medicamentos: [Medicamento], registros: [RegistroToma], dias: Int = 14) -> [ResumenHabitoDia] {
        let calendar = Calendar.current
        let hoy = calendar.startOfDay(for: Date())
        var resultado: [ResumenHabitoDia] = []

        let tomasEsperadasDia = medicamentos.reduce(0) { $0 + $1.tomasPorDia }

        for offset in (0..<dias).reversed() {
            guard let fecha = calendar.date(byAdding: .day, value: -offset, to: hoy),
                  let finDia = calendar.date(byAdding: .day, value: 1, to: fecha) else { continue }

            let tomas = registros.filter { $0.fechaHora >= fecha && $0.fechaHora < finDia }.count
            let formatter = DateFormatter()
            formatter.dateFormat = "E d"
            formatter.locale = Locale(identifier: "es_MX")

            resultado.append(
                ResumenHabitoDia(
                    fecha: fecha,
                    fechaTexto: formatter.string(from: fecha),
                    tomasEsperadas: tomasEsperadasDia,
                    tomasCompletadas: tomas
                )
            )
        }
        return resultado
    }
}
