import SwiftUI
import ActivityKit
import HealthKit
import UIKit

struct ItemMedicamento: Identifiable {
    let id = UUID()
    var nombre: String
    var dosis: String
    var tipo: String
    var imagenNombre: String
    var horaProgramada: String
    var hora: Int
    var minuto: Int
}

struct ContentView: View {
    @State private var medicamentos: [ItemMedicamento] = [
        ItemMedicamento(
            nombre: "Tradea (Metilfenidato)",
            dosis: "Pastilla 27 mg",
            tipo: "Pastilla oral",
            imagenNombre: "tradea",
            horaProgramada: "08:29 A.M.",
            hora: 8,
            minuto: 29
        ),
        ItemMedicamento(
            nombre: "Minoxidil",
            dosis: "Tópico 5%",
            tipo: "Uso tópico",
            imagenNombre: "minoxidil",
            horaProgramada: "08:50 P.M.",
            hora: 20,
            minuto: 50
        ),
        ItemMedicamento(
            nombre: "Sertex (Sertralina)",
            dosis: "Pastilla 50 mg",
            tipo: "Pastilla oral",
            imagenNombre: "sertex",
            horaProgramada: "10:30 P.M.",
            hora: 22,
            minuto: 30
        )
    ]

    @State private var healthKitConectado: Bool = false
    @State private var estadoMensaje: String = "Listo para probar alertas y cuenta regresiva"

    var body: some View {
        NavigationStack {
            List {
                // SECCIÓN: TUS 3 MEDICAMENTOS REALES (Horarios sincronizados)
                Section(header: Text("Tus 3 Medicamentos (Sincronizados con Salud)")) {
                    ForEach($medicamentos) { $med in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(uiColor: .tertiarySystemFill))
                                        .frame(width: 48, height: 48)

                                    Image(med.imagenNombre)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(med.nombre)
                                        .font(.headline)

                                    HStack(spacing: 6) {
                                        Text(med.tipo)
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())

                                        Text(med.dosis)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()
                            }

                            HStack {
                                Label(med.horaProgramada, systemImage: "clock.fill")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)

                                Spacer()

                                Button {
                                    lanzarLiveActivityPrueba(para: med)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "timer")
                                        Text("Probar 10m")
                                    }
                                    .font(.caption.bold())
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.indigo)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                // SECCIÓN: INTEGRACIÓN CON APPLE HEALTH Y ATAJOS
                Section(header: Text("Conexión con Apple Health")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nota sobre la privacidad de Apple:")
                            .font(.caption.bold())
                            .foregroundColor(.primary)

                        Text("Apple restringe la lectura directa de su base de datos nativa de medicamentos a apps sideloaded sin certificado de pago. La forma oficial y 100% nativa de sincronizar tomas en segundo plano es mediante Atajos (Shortcuts).")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button {
                            abrirAjustesDelSistema()
                        } label: {
                            HStack {
                                Image(systemName: "gear")
                                Text("Abrir Ajustes de la App en el iPhone")
                            }
                            .font(.subheadline.bold())
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }

                // SECCIÓN: CONTROL
                Section(header: Text("Control de Alertas")) {
                    Button(role: .destructive) {
                        cerrarTodasLasActividades()
                    } label: {
                        Label("Finalizar todas las alertas activas", systemImage: "xmark.circle")
                    }
                }

                Section(header: Text("Estado")) {
                    Text(estadoMensaje)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("PillPulse Liquid")
        }
    }

    private func abrirAjustesDelSistema() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Lanza la Live Activity en modo prueba exactamente con 10 minutos de cuenta regresiva en vivo
    private func lanzarLiveActivityPrueba(para med: ItemMedicamento) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            estadoMensaje = "Live Activities no autorizadas en Ajustes de iOS."
            return
        }

        // 10 minutos exactos en el futuro para que el temporizador cuente regresivamente 09:59...
        let fechaObjetivo = Date().addingTimeInterval(600)

        let attributes = MedicamentoAttributes(
            nombre: med.nombre,
            dosis: med.dosis,
            tipo: med.tipo,
            imagenNombre: med.imagenNombre,
            horaProgramadaTexto: med.horaProgramada,
            fechaToma: fechaObjetivo
        )

        let initialState = MedicamentoAttributes.ContentState(
            fueTomado: false,
            estadoTexto: "Toma en 10 min",
            horaProgramadaTexto: med.horaProgramada,
            fechaToma: fechaObjetivo
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            estadoMensaje = "Live Activity iniciada para \(med.nombre) con cuenta regresiva de 10 min."
        } catch {
            estadoMensaje = "Error: \(error.localizedDescription)"
        }
    }

    private func cerrarTodasLasActividades() {
        Task {
            for activity in Activity<MedicamentoAttributes>.activities {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    estadoTexto: "Descartada",
                    horaProgramadaTexto: activity.attributes.horaProgramadaTexto,
                    fechaToma: activity.attributes.fechaToma
                )
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            await MainActor.run {
                estadoMensaje = "Todas las alertas fueron cerradas."
            }
        }
    }
}

#Preview {
    ContentView()
}
