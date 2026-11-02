import WidgetKit
import SwiftUI
import ActivityKit

struct MedicamentoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MedicamentoAttributes.self) { context in
            let modo = context.state.modo

            // ==========================================
            // VISTA PANTALLA DE BLOQUEO (Apple HIG Liquid Glass)
            // ==========================================
            VStack(alignment: .leading, spacing: 12) {
                // 1. Fila Superior: Insignias de Estado
                HStack {
                    if modo == "urgente" {
                        HStack(spacing: 5) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Text("⚠️ TOMA ATRASADA")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4.5)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                    } else if modo == "compra" {
                        HStack(spacing: 5) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.amberOrYellow)
                            Text("📦 REABASTECER")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.amberOrYellow)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4.5)
                        .background(Color.yellow.opacity(0.2))
                        .clipShape(Capsule())
                    } else {
                        HStack(spacing: 5) {
                            Image(systemName: "timer")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Toma en ")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                            Text(context.attributes.fechaToma, style: .timer)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.18))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: modo == "compra" ? "shippingbox.fill" : "clock.fill")
                            .font(.system(size: 11))
                            .foregroundColor(modo == "urgente" ? .white : .cyan)
                        Text(modo == "compra" ? "Quedan \(context.state.unidadesRestantes)" : context.attributes.horaProgramadaTexto)
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
                            .fill(Color.white.opacity(modo == "urgente" ? 0.18 : 0.08))
                            .frame(width: 56, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
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
                                .foregroundColor(Color.white.opacity(0.9))

                            Text("•")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.4))

                            Text(context.attributes.tipo)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(modo == "urgente" ? .yellow : .cyan)
                        }
                    }

                    Spacer()
                }

                // 3. Fila Inferior: Botón de Acción
                Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                    HStack(spacing: 8) {
                        Image(systemName: modo == "compra" ? "cart.badge.plus" : "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(modo == "compra" ? "Abrir Farmacias en PillPulse" : (modo == "urgente" ? "Tomar ahora (Urgente)" : "Marcar como tomada"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(
                        modo == "urgente" ? Color.red : (modo == "compra" ? Color.blue : Color(red: 0.16, green: 0.76, blue: 0.38))
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        modo == "urgente"
                        ? Color(red: 0.60, green: 0.08, blue: 0.12).opacity(0.95)
                        : (modo == "compra" ? Color(red: 0.12, green: 0.18, blue: 0.30).opacity(0.95) : Color.black.opacity(0.88))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        modo == "urgente" ? Color.red.opacity(0.7) : Color.white.opacity(0.25),
                                        Color.white.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
            )

        } dynamicIsland: { context in
            let modo = context.state.modo

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
                        Text(modo == "compra" ? "Comprar" : context.attributes.horaProgramadaTexto)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(modo == "urgente" ? .red : .orange)

                        if modo == "compra" {
                            Text("Quedan \(context.state.unidadesRestantes)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                        } else {
                            Text(context.attributes.fechaToma, style: .timer)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(modo == "urgente" ? .red : .cyan)
                        }
                    }
                    .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: RegistrarTomaIntent(nombre: context.attributes.nombre)) {
                        HStack(spacing: 8) {
                            Image(systemName: modo == "compra" ? "cart.fill" : "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text(modo == "compra" ? "Revisar Farmacias" : (modo == "urgente" ? "Tomar Ahora" : "Confirmar Toma"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(
                            modo == "urgente" ? Color.red : (modo == "compra" ? Color.blue : Color(red: 0.16, green: 0.76, blue: 0.38))
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                }
            } compactLeading: {
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                if modo == "urgente" {
                    Text("⚠️")
                        .font(.system(size: 11))
                } else if modo == "compra" {
                    Text("📦 \(context.state.unidadesRestantes)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                } else {
                    Text(context.attributes.fechaToma, style: .timer)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
            } minimal: {
                Image(context.attributes.imagenNombre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
        }
    }
}

extension Color {
    static var amberOrYellow: Color {
        Color(red: 1.0, green: 0.75, blue: 0.1)
    }
}
