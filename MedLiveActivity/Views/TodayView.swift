import SwiftUI
import ActivityKit

struct TodayView: View {
    @ObservedObject var storage = StorageService.shared
    @State private var mensajeEstado: String = "Todas las dosis programadas para hoy"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header de Bienvenida / Resumen
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("HOY, \(Date().formatted(.dateTime.weekday(.wide).day().month()))")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text("Dosis Programadas")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Lista de Tarjetas de Medicamentos de Hoy
                    ForEach(storage.medicamentos) { med in
                        VStack(spacing: 12) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(uiColor: .tertiarySystemFill))
                                        .frame(width: 54, height: 54)

                                    Image(med.imagenNombre)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(med.nombre)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))

                                    HStack(spacing: 6) {
                                        Text(med.forma.rawValue)
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.12))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())

                                        Text(med.dosis)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                // Horario principal
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(med.horarios.first?.textoFormateado ?? "08:00 A.M.")
                                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                                        .foregroundColor(.orange)
                                    Text("\(med.unidadesRestantes) disp.")
                                        .font(.caption2)
                                        .foregroundColor(med.requiereRestock ? .red : .secondary)
                                }
                            }

                            Divider()

                            // Botones de Acción Rápida
                            HStack(spacing: 10) {
                                // Botón Marcar Tomada
                                Button {
                                    withAnimation {
                                        storage.marcarTomaRealizada(medicamentoId: med.id)
                                        mensajeEstado = "✓ Toma de \(med.nombre) registrada. Stock actualizado."
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Tomada")
                                    }
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color(red: 0.16, green: 0.76, blue: 0.38).opacity(0.2))
                                    .foregroundColor(Color(red: 0.16, green: 0.76, blue: 0.38))
                                    .clipShape(Capsule())
                                }

                                // Botón Live Normal (-10m)
                                Button {
                                    lanzarLiveActivity(med: med, modo: "normal")
                                } label: {
                                    Label("Live 10m", systemImage: "timer")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .clipShape(Capsule())
                                }

                                // Botón Live Urgente (Roja)
                                Button {
                                    lanzarLiveActivity(med: med, modo: "urgente")
                                } label: {
                                    Label("Urgente", systemImage: "exclamationmark.triangle.fill")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.15))
                                        .foregroundColor(.red)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(uiColor: .secondarySystemBackground))
                        )
                        .padding(.horizontal)
                    }

                    // Botón para cerrar alertas activas
                    Button(role: .destructive) {
                        cerrarTodasLasActividades()
                    } label: {
                        Label("Limpiar todas las Live Activities", systemImage: "xmark.circle")
                            .font(.footnote.bold())
                    }
                    .padding(.top, 8)

                    Text(mensajeEstado)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func lanzarLiveActivity(med: Medicamento, modo: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            mensajeEstado = "Live Activities no autorizadas en Ajustes."
            return
        }

        let fechaObjetivo = modo == "urgente" ? Date().addingTimeInterval(-900) : Date().addingTimeInterval(600)
        let horaTexto = med.horarios.first?.textoFormateado ?? "08:00 A.M."

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
            estadoTexto: modo == "urgente" ? "Atrasada" : "Toma en 10 min",
            horaProgramadaTexto: horaTexto,
            fechaToma: fechaObjetivo,
            modo: modo,
            unidadesRestantes: med.unidadesRestantes,
            minutosAtraso: modo == "urgente" ? 15 : 0
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            mensajeEstado = "Live Activity (\(modo.uppercased())) lanzada para \(med.nombre)."
        } catch {
            mensajeEstado = "Error al iniciar Live Activity: \(error.localizedDescription)"
        }
    }

    private func cerrarTodasLasActividades() {
        Task {
            for activity in Activity<MedicamentoAttributes>.activities {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    estadoTexto: "Cerrada",
                    horaProgramadaTexto: activity.attributes.horaProgramadaTexto,
                    fechaToma: activity.attributes.fechaToma
                )
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            await MainActor.run {
                mensajeEstado = "Todas las alertas de Live Activity fueron cerradas."
            }
        }
    }
}
