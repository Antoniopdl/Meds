import SwiftUI
import ActivityKit

struct ItemMedicamento: Identifiable {
    let id = UUID()
    var nombre: String
    var dosis: String
    var icono: String
    var hora: String
}

struct ContentView: View {
    @State private var medicamentos: [ItemMedicamento] = [
        ItemMedicamento(nombre: "Medicamento 1", dosis: "1 pastilla (500mg)", icono: "pills.fill", hora: "08:00 AM"),
        ItemMedicamento(nombre: "Medicamento 2", dosis: "1 cápsula", icono: "cross.vial.fill", hora: "02:00 PM"),
        ItemMedicamento(nombre: "Medicamento 3", dosis: "2 gotas", icono: "drop.fill", hora: "09:00 PM")
    ]
    
    @State private var estadoMensaje: String = "Listo para lanzar alertas"

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Tus 3 Medicamentos")) {
                    ForEach($medicamentos) { $med in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: med.icono)
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                TextField("Nombre", text: $med.nombre)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(med.hora)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                TextField("Dosis", text: $med.dosis)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    lanzarLiveActivity(para: med)
                                } label: {
                                    Label("Probar Isla", systemImage: "play.circle.fill")
                                        .font(.caption.bold())
                                }
                                .buttonStyle(.bordered)
                                .tint(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Control de Actividades en Vivo")) {
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
            .navigationTitle("PillPulse Live")
        }
    }

    private func lanzarLiveActivity(para med: ItemMedicamento) {
        // Verificar si el dispositivo soporta Live Activities
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            estadoMensaje = "Las Live Activities están deshabilitadas en Ajustes de iOS."
            return
        }

        let attributes = MedicamentoAttributes(
            nombre: med.nombre,
            dosis: med.dosis,
            icono: med.icono
        )
        
        let initialState = MedicamentoAttributes.ContentState(
            fueTomado: false,
            horaTexto: "Programado para " + med.hora
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            estadoMensaje = "Live Activity iniciada para \(med.nombre) (ID: \(activity.id.prefix(6))...)"
        } catch {
            estadoMensaje = "Error al iniciar: \(error.localizedDescription)"
        }
    }

    private func cerrarTodasLasActividades() {
        Task {
            for activity in Activity<MedicamentoAttributes>.activities {
                let finalState = MedicamentoAttributes.ContentState(
                    fueTomado: true,
                    horaTexto: "Cerrada manualmente"
                )
                await activity.end(
                    ActivityContent(state: finalState, staleDate: nil),
                    dismissalPolicy: .immediate
                )
            }
            await MainActor.run {
                estadoMensaje = "Se cerraron todas las alertas activas."
            }
        }
    }
}

#Preview {
    ContentView()
}
