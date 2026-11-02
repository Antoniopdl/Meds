import WidgetKit
import SwiftUI
import ActivityKit

struct MedicamentoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MedicamentoAttributes.self) { context in
            // ==========================================
            // VISTA PANTALLA DE BLOQUEO / LIQUID GLASS
            // ==========================================
            HStack(spacing: 14) {
                // Contenedor Glass con la imagen del medicamento
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                        .frame(width: 58, height: 58)

                    Image(context.attributes.imagenNombre)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Información del Medicamento y Horario
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(context.attributes.nombre)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Text("\(context.attributes.dosis) • \(context.attributes.tipo)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.75))
                        .lineLimit(1)

                    // Badge de hora estilo Liquid Glass
                    HStack(spacing: 4) {
                        Image(systemName: "clock.badge.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.cyan)
                        Text("Toma: \(context.attributes.horaProgramadaTexto)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("• En 10 min")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2.5)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.6)
                    )
                }

                Spacer()

                // Botón "Tomada" con efecto Liquid Glass Verde
                Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                        Text("Tomada")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.80, blue: 0.44).opacity(0.95),
                                Color(red: 0.12, green: 0.65, blue: 0.35).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.5), Color.white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.green.opacity(0.35), radius: 8, x: 0, y: 3)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
            )

        } dynamicIsland: { context in
            // ==========================================
            // VISTA DYNAMIC ISLAND
            // ==========================================
            DynamicIsland {
                // Estado Expandido (mantener pulsada la isla)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 10) {
                        Image(context.attributes.imagenNombre)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.nombre)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text(context.attributes.tipo)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.attributes.horaProgramadaTexto)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text(context.attributes.dosis)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Confirmar Toma (Registrar en Salud)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.80, blue: 0.44),
                                    Color(red: 0.12, green: 0.65, blue: 0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Icono/Miniatura del medicamento en la pastilla izquierda
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())
            } compactTrailing: {
                // Hora en la pastilla derecha
                Text(context.attributes.horaProgramadaTexto)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
            } minimal: {
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
            }
        }
    }
}
