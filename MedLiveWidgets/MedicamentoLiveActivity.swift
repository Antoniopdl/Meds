import WidgetKit
import SwiftUI
import ActivityKit

struct MedicamentoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MedicamentoAttributes.self) { context in
            // ==========================================
            // VISTA PANTALLA DE BLOQUEO (Apple HIG Layout)
            // ==========================================
            VStack(alignment: .leading, spacing: 12) {
                // 1. Fila Superior: Cuenta Regresiva Real + Hora de la toma
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "timer")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Toma en ")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                        
                        // Cuenta regresiva real nativa de Apple
                        Text(context.attributes.fechaToma, style: .timer)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.18))
                    .clipShape(Capsule())

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.cyan)
                        Text(context.attributes.horaProgramadaTexto)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Capsule())
                }

                // 2. Fila Central: Imagen real + Nombre y Dosis
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 56, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                            )

                        Image(context.attributes.imagenNombre)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.nombre)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 6) {
                            Text(context.attributes.dosis)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.85))

                            Text("•")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.4))

                            Text(context.attributes.tipo)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.cyan)
                        }
                    }

                    Spacer()
                }

                // 3. Fila Inferior: Botón Limpio Verde que cierra de inmediato
                Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Marcar como tomada")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(
                        Color(red: 0.16, green: 0.76, blue: 0.38)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black.opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.06)],
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
                // Estado Expandido
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 12) {
                        Image(context.attributes.imagenNombre)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(context.attributes.nombre)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("\(context.attributes.dosis) • \(context.attributes.tipo)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(context.attributes.horaProgramadaTexto)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        
                        // Cuenta regresiva en la isla
                        Text(context.attributes.fechaToma, style: .timer)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Confirmar Toma (Salud)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(Color(red: 0.16, green: 0.76, blue: 0.38))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                }
            } compactLeading: {
                // Miniatura del medicamento
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                // Cuenta regresiva compacta o hora
                Text(context.attributes.fechaToma, style: .timer)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            } minimal: {
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
}
