import SwiftUI

struct AddMedicationSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var storage = StorageService.shared

    var medicamentoAEditar: Medicamento?

    @State private var nombre: String = ""
    @State private var dosis: String = ""
    @State private var forma: FormaMedicamento = .pastilla
    @State private var horaSeleccionada: Date = Date()
    @State private var totalPorCaja: Int = 30
    @State private var unidadesRestantes: Int = 30
    @State private var umbralAlertaDias: Int = 5
    @State private var imagenSeleccionada: String = "sertex"

    let opcionesImagenes = ["tradea", "sertex", "minoxidil"]

    init(medicamentoAEditar: Medicamento? = nil) {
        self.medicamentoAEditar = medicamentoAEditar
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información General")) {
                    TextField("Nombre comercial o compuesto", text: $nombre)
                    TextField("Dosis (ej. 27 mg, 1 ml, 1 pastilla)", text: $dosis)

                    Picker("Forma farmacéutica", selection: $forma) {
                        ForEach(FormaMedicamento.allCases) { f in
                            Label(f.rawValue, systemImage: f.icono).tag(f)
                        }
                    }
                }

                Section(header: Text("Horario de Toma")) {
                    DatePicker("Hora habitual", selection: $horaSeleccionada, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Inventario y Empaque")) {
                    Stepper("Unidades por caja: \(totalPorCaja)", value: $totalPorCaja, in: 1...300)
                    Stepper("Unidades actuales: \(unidadesRestantes)", value: $unidadesRestantes, in: 0...300)
                    Stepper("Avisar cuando falten: \(umbralAlertaDias) días", value: $umbralAlertaDias, in: 1...30)
                }

                Section(header: Text("Foto / Icono de la Caja")) {
                    HStack(spacing: 16) {
                        ForEach(opcionesImagenes, id: \.self) { img in
                            VStack {
                                Image(img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(4)
                                    .background(imagenSeleccionada == img ? Color.blue.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(imagenSeleccionada == img ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                Text(img.capitalized)
                                    .font(.caption2)
                            }
                            .onTapGesture {
                                imagenSeleccionada = img
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(medicamentoAEditar == nil ? "Nuevo Medicamento" : "Editar Medicamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardar()
                        dismiss()
                    }
                    .disabled(nombre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let med = medicamentoAEditar {
                    self.nombre = med.nombre
                    self.dosis = med.dosis
                    self.forma = med.forma
                    self.totalPorCaja = med.totalPorCaja
                    self.unidadesRestantes = med.unidadesRestantes
                    self.umbralAlertaDias = med.umbralAlertaDias
                    self.imagenSeleccionada = med.imagenNombre

                    if let h = med.horarios.first {
                        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                        comps.hour = h.hora
                        comps.minute = h.minuto
                        self.horaSeleccionada = Calendar.current.date(from: comps) ?? Date()
                    }
                }
            }
        }
    }

    private func guardar() {
        let cal = Calendar.current
        let hora = cal.component(.hour, from: horaSeleccionada)
        let minuto = cal.component(.minute, from: horaSeleccionada)
        let horario = HorarioToma(hora: hora, minuto: minuto)

        if let medExistente = medicamentoAEditar {
            var medActualizado = medExistente
            medActualizado.nombre = nombre
            medActualizado.dosis = dosis
            medActualizado.forma = forma
            medActualizado.horarios = [horario]
            medActualizado.totalPorCaja = totalPorCaja
            medActualizado.unidadesRestantes = unidadesRestantes
            medActualizado.umbralAlertaDias = umbralAlertaDias
            medActualizado.imagenNombre = imagenSeleccionada
            storage.actualizarMedicamento(medActualizado)
        } else {
            let nuevoMed = Medicamento(
                nombre: nombre,
                dosis: dosis,
                forma: forma,
                imagenNombre: imagenSeleccionada,
                horarios: [horario],
                totalPorCaja: totalPorCaja,
                unidadesRestantes: unidadesRestantes,
                umbralAlertaDias: umbralAlertaDias
            )
            storage.agregarMedicamento(nuevoMed)
        }
    }
}
