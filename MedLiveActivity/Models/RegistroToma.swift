import Foundation

public struct RegistroToma: Identifiable, Codable, Equatable {
    public var id: UUID
    public var medicamentoId: UUID
    public var medicamentoNombre: String
    public var fechaHora: Date
    public var fueAtrasada: Bool
    public var minutosDiferencia: Int

    public init(
        id: UUID = UUID(),
        medicamentoId: UUID,
        medicamentoNombre: String,
        fechaHora: Date = Date(),
        fueAtrasada: Bool = false,
        minutosDiferencia: Int = 0
    ) {
        self.id = id
        self.medicamentoId = medicamentoId
        self.medicamentoNombre = medicamentoNombre
        self.fechaHora = fechaHora
        self.fueAtrasada = fueAtrasada
        self.minutosDiferencia = minutosDiferencia
    }
}
