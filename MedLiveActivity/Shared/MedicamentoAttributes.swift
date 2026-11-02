import Foundation
import ActivityKit

public struct MedicamentoAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var fueTomado: Bool
        public var estadoTexto: String
        public var horaProgramadaTexto: String

        public init(fueTomado: Bool, estadoTexto: String, horaProgramadaTexto: String) {
            self.fueTomado = fueTomado
            self.estadoTexto = estadoTexto
            self.horaProgramadaTexto = horaProgramadaTexto
        }
    }

    public var nombre: String
    public var dosis: String
    public var tipo: String
    public var imagenNombre: String
    public var iconoFallback: String
    public var horaProgramadaTexto: String

    public init(
        nombre: String,
        dosis: String,
        tipo: String,
        imagenNombre: String,
        iconoFallback: String = "pills.fill",
        horaProgramadaTexto: String
    ) {
        self.nombre = nombre
        self.dosis = dosis
        self.tipo = tipo
        self.imagenNombre = imagenNombre
        self.iconoFallback = iconoFallback
        self.horaProgramadaTexto = horaProgramadaTexto
    }
}
