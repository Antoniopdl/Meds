import SwiftUI
import ActivityKit

struct InventoryView: View {
    @ObservedObject var storage = StorageService.shared
    @State private var promptCopiado: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Sección: Comparador Inteligente de Farmacias con Gemini
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .font(.title3)
                            Text("Comparador de Precios con Gemini")
                                .font(.headline)
                        }

                        Text("Compara en vivo entre tus 5 farmacias de confianza:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Pills de las 5 farmacias exactas solicitadas por Antonio
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(GeminiPriceAdvisor.farmaciasObjetivo, id: \.self) { farmacia in
                                    Text(farmacia)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.12))
                                        .foregroundColor(.purple)
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        // Botón Copiar Prompt y Abrir Gemini
                        Button {
                            let prompt = GeminiPriceAdvisor.generarPromptComparativo(medicamentos: storage.medicamentos)
                            GeminiPriceAdvisor.abrirGeminiConPrompt(prompt: prompt)
                            promptCopiado = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                promptCopiado = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: promptCopiado ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                Text(promptCopiado ? "¡Prompt Copiado! Abriendo Gemini..." : "Comparar Precios en Gemini (1 Toque)")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    .padding(.horizontal)

                    // 2. Sección: Monitoreo de Cajas y Pastillas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Inventario de Medicamentos")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(storage.medicamentos) { med in
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(med.imagenNombre)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(med.nombre)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                        Text("Suministro restante: \(med.diasRestantesSuministro) días")
                                            .font(.caption.bold())
                                            .foregroundColor(med.requiereRestock ? .red : .orange)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(med.unidadesRestantes) / \(med.totalPorCaja)")
                                            .font(.headline)
                                        Text(med.forma == .topico ? "ml / dosis" : "pastillas")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                // Barra de Progreso de Stock
                                ProgressView(value: Double(med.unidadesRestantes), total: Double(max(1, med.totalPorCaja)))
                                    .tint(med.requiereRestock ? .red : .green)

                                Divider()

                                HStack(spacing: 10) {
                                    // Botón Reabastecer (+Caja)
                                    Button {
                                        storage.reabastecerStock(medicamentoId: med.id, cantidad: med.totalPorCaja)
                                    } label: {
                                        Label("+1 Caja", systemImage: "plus.circle")
                                            .font(.caption.bold())
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)

                                    Spacer()

                                    // Botón Activar Alerta de Compra en Dynamic Island
                                    Button {
                                        lanzarLiveActivityCompra(med: med)
                                    } label: {
                                        Label("Alerta Compra", systemImage: "cart.fill")
                                            .font(.caption.bold())
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.amberOrYellow)

                                    // Búsqueda Directa en Google
                                    Button {
                                        GeminiPriceAdvisor.buscarPreciosEnNavegador(medicamento: med)
                                    } label: {
                                        Image(systemName: "magnifyingglass")
                                            .font(.caption.bold())
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Inventario & Precios")
        }
    }

    private func lanzarLiveActivityCompra(med: Medicamento) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = MedicamentoAttributes(
            nombre: med.nombre,
            dosis: med.dosis,
            tipo: med.forma.rawValue,
            imagenNombre: med.imagenNombre,
            horaProgramadaTexto: "Comprar",
            fechaToma: Date().addingTimeInterval(3600)
        )

        let initialState = MedicamentoAttributes.ContentState(
            fueTomado: false,
            estadoTexto: "Quedan \(med.unidadesRestantes) unidades",
            horaProgramadaTexto: "Comprar",
            fechaToma: Date().addingTimeInterval(3600),
            modo: "compra",
            unidadesRestantes: med.unidadesRestantes
        )

        do {
            let _ = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Error al lanzar Live Activity de Compra: \(error)")
        }
    }
}
