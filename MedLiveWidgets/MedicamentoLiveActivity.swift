import WidgetKit
import SwiftUI
import ActivityKit

struct MedicamentoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MedicamentoAttributes.self) { context in
            // Vista en Pantalla de Bloqueo y Banner
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: context.attributes.icono)
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(context.attributes.nombre)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Dosis: \(context.attributes.dosis)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Botón interactivo directo sin abrir la app
                Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                        Text("Tomada")
                    }
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(16)
            .activityBackgroundTint(Color(uiColor: .systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                // Estado Expandido (mantener pulsada la Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.attributes.icono)
                            .foregroundColor(.blue)
                        Text(context.attributes.nombre)
                            .font(.headline)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.dosis)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Confirmar Dosis Tomada")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            } compactLeading: {
                // Lado izquierdo de la píldora en Dynamic Island
                Image(systemName: context.attributes.icono)
                    .foregroundColor(.orange)
            } compactTrailing: {
                // Lado derecho de la píldora en Dynamic Island
                Text(context.attributes.nombre.prefix(4))
                    .font(.caption2.bold())
                    .foregroundColor(.primary)
            } minimal: {
                // Cuando hay múltiples Live Activities activas
                Image(systemName: context.attributes.icono)
                    .foregroundColor(.orange)
            }
        }
    }
}
