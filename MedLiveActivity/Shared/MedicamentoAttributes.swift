import Foundation
import ActivityKit

public struct MedicamentoAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var fueTomado: Bool
        public var estadoTexto: String
        public var horaProgramadaTexto: String
        public var fechaToma: Date
        public var modo: String // "normal", "urgente", "compra"
        public var unidadesRestantes: Int
        public var minutosAtraso: Int

        public init(
            fueTomado: Bool,
            estadoTexto: String,
            horaProgramadaTexto: String,
            fechaToma: Date,
            modo: String = "normal",
            unidadesRestantes: Int = 0,
            minutosAtraso: Int = 0
        ) {
            self.fueTomado = fueTomado
            self.estadoTexto = estadoTexto
            self.horaProgramadaTexto = horaProgramadaTexto
            self.fechaToma = fechaToma
            self.modo = modo
            self.unidadesRestantes = unidadesRestantes
            self.minutosAtraso = minutosAtraso
        }
    }

    public var nombre: String
    public var dosis: String
    public var tipo: String
    public var imagenNombre: String
    public var iconoFallback: String
    public var horaProgramadaTexto: String
    public var fechaToma: Date

    public init(
        nombre: String,
        dosis: String,
        tipo: String,
        imagenNombre: String,
        iconoFallback: String = "pills.fill",
        horaProgramadaTexto: String,
        fechaToma: Date
    ) {
        self.nombre = nombre
        self.dosis = dosis
        self.tipo = tipo
        self.imagenNombre = imagenNombre
        self.iconoFallback = iconoFallback
        self.horaProgramadaTexto = horaProgramadaTexto
        self.fechaToma = fechaToma
    }
}
