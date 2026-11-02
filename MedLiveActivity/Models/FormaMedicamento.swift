import Foundation

public enum FormaMedicamento: String, Codable, CaseIterable, Identifiable {
    case pastilla = "Pastilla oral"
    case capsula = "Cápsula"
    case topico = "Uso tópico / Spray"
    case gotas = "Gotas"
    case inyeccion = "Inyección"
    case inhalador = "Inhalador"
    case jarabe = "Jarabe / Solución"

    public var id: String { rawValue }

    public var icono: String {
        switch self {
        case .pastilla: return "pill.fill"
        case .capsula: return "capsule.fill"
        case .topico: return "drop.fill"
        case .gotas: return "eyedropper.halffull"
        case .inyeccion: return "syringe.fill"
        case .inhalador: return "wind"
        case .jarabe: return "cross.vial.fill"
        }
    }
}
