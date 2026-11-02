import SwiftUI

struct HabitTrackerView: View {
    @ObservedObject var storage = StorageService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Tarjetas de Resumen y Racha
                    let adherenciaGeneral = HabitAnalytics.calcularAdherenciaGeneral(
                        medicamentos: storage.medicamentos,
                        registros: storage.registros
                    )
                    let tomasPorDia = storage.medicamentos.reduce(0) { $0 + $1.tomasPorDia }
                    let rachaDias = HabitAnalytics.calcularRachaDias(
                        registros: storage.registros,
                        tomasEsperadasPorDia: tomasPorDia
                    )

                    HStack(spacing: 14) {
                        // Tarjeta de Adherencia General
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Adherencia Mensual")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(adherenciaGeneral)")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                Text("%")
                                    .font(.title3.bold())
                                    .foregroundColor(.green)
                            }
                            Text("Consistencia excelente")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )

                        // Tarjeta de Racha Actual
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Racha Activa")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(rachaDias)")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                Text("días")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.secondary)
                            }
                            Text("Sin saltarte dosis")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                    }
                    .padding(.horizontal)

                    // 2. Historial Visual de Días (Últimas 2 Semanas)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Historial Diario (Últimos 14 días)")
                            .font(.headline)
                            .padding(.horizontal)

                        let dias = HabitAnalytics.diasUltimasSemanas(
                            medicamentos: storage.medicamentos,
                            registros: storage.registros,
                            dias: 14
                        )

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(dias) { dia in
                                    VStack(spacing: 8) {
                                        Text(dia.fechaTexto)
                                            .font(.caption2.bold())
                                            .foregroundColor(.secondary)

                                        ZStack {
                                            Circle()
                                                .fill(
                                                    dia.estado == .completo
                                                    ? Color.green.opacity(0.2)
                                                    : (dia.estado == .parcial ? Color.orange.opacity(0.2) : Color.gray.opacity(0.15))
                                                )
                                                .frame(width: 44, height: 44)

                                            Image(systemName: dia.estado == .completo ? "checkmark" : (dia.estado == .parcial ? "minus" : "xmark"))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(
                                                    dia.estado == .completo
                                                    ? Color.green
                                                    : (dia.estado == .parcial ? Color.orange : Color.secondary)
                                                )
                                        }

                                        Text("\(dia.tomasCompletadas)/\(dia.tomasEsperadas)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color(uiColor: .secondarySystemBackground))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // 3. Desglose Individual por Medicamento
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cumplimiento por Medicamento")
                            .font(.headline)
                            .padding(.horizontal)

                        let desglose = HabitAnalytics.desglosePorMedicamento(
                            medicamentos: storage.medicamentos,
                            registros: storage.registros
                        )

                        ForEach(desglose) { stat in
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: stat.forma.icono)
                                        .foregroundColor(.blue)
                                    Text(stat.nombre)
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text("\(stat.porcentajeAdherencia)%")
                                        .font(.subheadline.bold())
                                        .foregroundColor(stat.porcentajeAdherencia >= 85 ? .green : .orange)
                                }

                                ProgressView(value: Double(stat.porcentajeAdherencia), total: 100)
                                    .tint(stat.porcentajeAdherencia >= 85 ? .green : .orange)

                                HStack {
                                    Text("\(stat.totalTomasMes) tomas registradas")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Habit Tracker")
        }
    }
}
