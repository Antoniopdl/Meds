import SwiftUI

struct MedicationsListView: View {
    @ObservedObject var storage = StorageService.shared
    @State private var mostrandoCrear: Bool = false
    @State private var medicamentoAEditar: Medicamento?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Tus Medicamentos Registrados")) {
                    ForEach(storage.medicamentos) { med in
                        Button {
                            medicamentoAEditar = med
                        } label: {
                            HStack(spacing: 14) {
                                Image(med.imagenNombre)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(med.nombre)
                                        .font(.headline)
                                        .foregroundColor(.primary)

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

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(med.horarios.first?.textoFormateado ?? "")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.orange)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let med = storage.medicamentos[index]
                            storage.eliminarMedicamento(id: med.id)
                        }
                    }
                }
            }
            .navigationTitle("Medicamentos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoCrear = true
                    } label: {
                        Label("Agregar", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoCrear) {
                AddMedicationSheet()
            }
            .sheet(item: $medicamentoAEditar) { med in
                AddMedicationSheet(medicamentoAEditar: med)
            }
        }
    }
}
