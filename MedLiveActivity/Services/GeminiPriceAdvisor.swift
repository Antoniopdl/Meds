import Foundation
import UIKit

public final class GeminiPriceAdvisor {
    public static let farmaciasObjetivo = [
        "Farmacias Guadalajara",
        "Farmacias del Ahorro",
        "Farmacias Benavides",
        "Costco",
        "Farmacon"
    ]

    /// Genera un prompt estructurado de alta precisión para comparar precios en las 5 farmacias elegidas por Antonio
    public static func generarPromptComparativo(medicamentos: [Medicamento]) -> String {
        let listaNombres = medicamentos.map { "\($0.nombre) (\($0.dosis))" }.joined(separator: ", ")
        let farmaciasTexto = farmaciasObjetivo.joined(separator: ", ")

        return """
        Actúa como un asistente farmacéutico experto en compras y ahorro en México.
        Necesito comparar el precio actual de los siguientes medicamentos:
        \(listaNombres)

        Por favor, investiga y compara los precios exclusivamente en las siguientes 5 cadenas de farmacias en México:
        - \(farmaciasTexto)

        Requisitos de la respuesta:
        1. Tabla comparativa con el precio estimado en cada farmacia para cada medicamento.
        2. Indica en cuál farmacia sale más barato comprar cada uno de forma individual y en combo.
        3. Menciona si alguna de estas cadenas ofrece promociones especiales (ej. programa de lealtad de Farmacias del Ahorro, días de descuento en Guadalajara, o precio de socio en Costco).
        4. Recomienda la opción más económica para resurtir mi tratamiento este mes.
        """
    }

    /// Copia el prompt al portapapeles y abre la app de Gemini o navegador
    public static func abrirGeminiConPrompt(prompt: String) {
        UIPasteboard.general.string = prompt

        // Intento 1: Deep link a Gemini web
        if let url = URL(string: "https://gemini.google.com/app") {
            UIApplication.shared.open(url)
        }
    }

    /// Abre búsqueda directa con filtro de farmacias
    public static func buscarPreciosEnNavegador(medicamento: Medicamento) {
        let consulta = "\(medicamento.nombre) precio farmacias guadalajara ahorro benavides costco farmacon"
        if let queryEncoded = consulta.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.google.com/search?q=\(queryEncoded)") {
            UIApplication.shared.open(url)
        }
    }
}
