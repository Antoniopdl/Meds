import Foundation
import HealthKit
import UIKit

public final class HealthKitManager: @unchecked Sendable {
    public static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Solicita autorización al usuario para leer y escribir datos de salud
    @MainActor
    public func solicitarPermisos() async -> Bool {
        guard isAvailable else { return false }

        var tiposParaLeer: Set<HKObjectType> = []
        var tiposParaEscribir: Set<HKSampleType> = []

        // 1. Tipos reconocidos por la app Salud que disparan la pantalla nativa de permisos
        if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            tiposParaLeer.insert(mindfulType)
            tiposParaEscribir.insert(mindfulType)
        }
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            tiposParaLeer.insert(stepType)
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            tiposParaLeer.insert(sleepType)
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
                print("Dosis de \(nombre) registrada en Salud.")
            } catch {
                print("Error al guardar registro en Salud: \(error.localizedDescription)")
            }
        }
    }

    /// Abre los Ajustes de Salud si el usuario ya vio el modal y necesita activar permisos manualmente
    @MainActor
    public func abrirAjustesDeSalud() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
