import SwiftUI
import ActivityKit
import HealthKit

struct ItemMedicamento: Identifiable {
    let id = UUID()
    var nombre: String
    var dosis: String
    var tipo: String
    var imagenNombre: String
    var horaProgramada: String
}

struct ContentView: View {
    @State private var medicamentos: [ItemMedicamento] = [
        ItemMedicamento(
            nombre: "Sertex (Sertralina)",
            dosis: "1 pastilla (50mg)",
            tipo: "Pastilla oral",
            imagenNombre: "sertex",
            horaProgramada: "08:00 A.M."
        ),
        ItemMedicamento(
            nombre: "Tradea (Metilfenidato)",
            dosis: "1 pastilla (10mg)",
            tipo: "Pastilla oral",
            imagenNombre: "tradea",
            horaProgramada: "02:00 P.M."
        ),
        ItemMedicamento(
            nombre: "Minoxidil",
            dosis: "Aplicación tópica",
            tipo: "Uso tópico",
            imagenNombre: "minoxidil",
            horaProgramada: "09:00 P.M."
        )
    ]

    @State private var healthKitConectado: Bool = false
    @State private var estadoMensaje: String = "Listo para lanzar alertas Live Activity"

    var body: some View {
        NavigationStack {
            List {
                // SECCIÓN: INTEGRACIÓN APPLE HEALTH
                Section(header: Text("Sincronización con Apple Health")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Base de Datos de Salud")
                                    .font(.headline)
                                Text(healthKitConectado ? "Permisos solicitados • Registro activo" : "Toca conectar para activar permisos en Salud")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button(healthKitConectado ? "Activo" : "Conectar") {
                                conectarSalud()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(healthKitConectado ? .green : .blue)
                        }

                        // Acceso directo a Ajustes si iOS ya procesó la primera solicitud
                        Button {
                            HealthKitManager.shared.abrirAjustesDeSalud()
                        } label: {
                            HStack {
                                Image(systemName: "gear")
                                Text("Ver permisos en Ajustes del iPhone / Salud")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // SECCIÓN: TUS 3 MEDICAMENTOS REALES
                Section(header: Text("Tus Medicamentos (Aviso 10 min antes)")) {
                    ForEach($medicamentos) { $med in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 12) {
                                // Imagen transparente
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
                                    TextField("Nombre", text: $med.nombre)
                                        .font(.headline)

                                    HStack(spacing: 6) {
                                        Text(med.tipo)
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())

                                        TextField("Dosis", text: $med.dosis)
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
                                    lanzarLiveActivity(para: med)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "sparkles")
                                        Text("Probar Live (-10m)")
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

                // SECCIÓN: AUTOMATIZACIÓN Y CONTROL
                Section(header: Text("Automatización y Control")) {
                    Button {
                        programarTodasLasAlertas()
                    } label: {
                        Label("Activar las 3 alertas (10 min antes)", systemImage: "bell.badge.fill")
                            .font(.subheadline.bold())
                    }
                    .tint(.purple)

                    Button(role: .destructive) {
                        cerrarTodasLasActividades()
                    } label: {
                        Label("Finalizar todas las alertas en pantalla", systemImage: "xmark.circle")
                    }
                }

                Section(header: Text("Estado del Sistema")) {
                    Text(estadoMensaje)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("PillPulse Liquid")
        }
    }

    private func conectarSalud() {
        Task {
            let ok = await HealthKitManager.shared.solicitarPermisos()
            await MainActor.run {
                self.healthKitConectado = ok
                self.estadoMensaje = ok ? "Permisos solicitados. Si no viste el diálogo, revisa en Ajustes > Salud." : "HealthKit no disponible."
            }
        }
    }

    private func lanzarLiveActivity(para med: ItemMedicamento) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            estadoMensaje = "Live Activities no autorizadas en Ajustes de iOS."
            return
        }

        let attributes = MedicamentoAttributes(
            nombre: med.nombre,
            dosis: med.dosis,
            tipo: med.tipo,
            imagenNombre: med.imagenNombre,
            horaProgramadaTexto: med.horaProgramada
        )

        let initialState = MedicamentoAttributes.ContentState(
            fueTomado: false,
            estadoTexto: "Toma en 10 min",
            horaProgramadaTexto: med.horaProgramada
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            estadoMensaje = "Live Activity Liquid Glass activa para \(med.nombre)"
        } catch {
            estadoMensaje = "Error: \(error.localizedDescription)"
        }
    }

    private func programarTodasLasAlertas() {
        for med in medicamentos {
            lanzarLiveActivity(para: med)
        }
        estadoMensaje = "Se activaron las 3 alertas de medicamentos."
    }

    private func cerrarTodasLasActividades() {
        Task {
            for activity in Activity<MedicamentoAttributes>.activities {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    estadoTexto: "Descartada",
                    horaProgramadaTexto: activity.attributes.horaProgramadaTexto
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
