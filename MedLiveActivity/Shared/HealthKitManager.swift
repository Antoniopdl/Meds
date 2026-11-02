import Foundation
import HealthKit

public final class HealthKitManager: @unchecked Sendable {
    public static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Solicita autorización al usuario para leer y escribir datos de salud
    public func solicitarPermisos() async -> Bool {
        guard isAvailable else { return false }

        var tiposParaLeer: Set<HKObjectType> = []
        var tiposParaEscribir: Set<HKSampleType> = []

        // Tipos estándar para compatibilidad amplia
        if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            tiposParaLeer.insert(mindfulType)
            tiposParaEscribir.insert(mindfulType)
        }

        do {
            try await healthStore.requestAuthorization(toShare: tiposParaEscribir, read: tiposParaLeer)
            return true
        } catch {
            print("Error al solicitar permisos de HealthKit: \(error.localizedDescription)")
            return false
        }
    }

    /// Registra en la base de datos de Salud que el medicamento fue tomado
    public func registrarDosisTomada(nombre: String, fecha: Date = Date()) async {
        guard isAvailable else { return }

        // En HealthKit, guardamos un registro con metadata del medicamento
        if let categoryType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            let metadata: [String: Any] = [
                HKMetadataKeySyncIdentifier: "MED-\(nombre)-\(fecha.timeIntervalSince1970)",
                "HKMedicationName": nombre,
                "HKMedicationTaken": true,
                "HKUserNote": "Medicamento \(nombre) marcado como tomado desde Live Activity"
            ]

            let sample = HKCategorySample(
                type: categoryType,
                value: 0,
                start: fecha,
                end: fecha.addingTimeInterval(60),
                metadata: metadata
            )

            do {
                try await healthStore.save(sample)
                print("Dosis de \(nombre) registrada exitosamente en Salud.")
            } catch {
                print("Error al guardar registro en Salud: \(error.localizedDescription)")
            }
        }
    }
}
