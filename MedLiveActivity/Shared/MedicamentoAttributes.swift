import Foundation
import ActivityKit

public struct MedicamentoAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var fueTomado: Bool
        public var horaTexto: String

        public init(fueTomado: Bool, horaTexto: String) {
            self.fueTomado = fueTomado
            self.horaTexto = horaTexto
        }
    }

    public var nombre: String
    public var dosis: String
    public var icono: String

    public init(nombre: String, dosis: String, icono: String) {
        self.nombre = nombre
        self.dosis = dosis
        self.icono = icono
    }
}
