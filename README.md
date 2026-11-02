# MedLiveActivity — Live Activities Interactivas para Medicamentos (iOS 17+)

Este proyecto te permite tener alertas persistentes de medicamentos en la **Dynamic Island** y en la **Pantalla de Bloqueo** con un botón interactivo de un solo toque ("Tomada"), sin necesidad de tener una Mac física.

---

## Estructura del Proyecto

```text
MedLiveActivity/
├── .github/workflows/
│   └── build.yml               <-- Workflow de GitHub Actions para compilar el .ipa en la nube
├── MedLiveActivity/            <-- App principal en SwiftUI
│   ├── ContentView.swift       <-- Interfaz para configurar medicamentos y probar alertas
│   ├── MedLiveActivityApp.swift<-- Entrypoint del ciclo de vida
│   ├── Info.plist              <-- Configuración con NSSupportsLiveActivities activo
│   └── Shared/
│       ├── MedicamentoAttributes.swift <-- Atributos de ActivityKit compartidos
│       └── RegistrarTomaIntent.swift   <-- AppIntent interactivo para el botón
├── MedLiveWidgets/             <-- Extensión de WidgetKit / Dynamic Island
│   ├── MedicamentoLiveActivity.swift   <-- Vistas de la Dynamic Island y Lock Screen
│   ├── MedLiveWidgetsBundle.swift      <-- Entrypoint del Widget
│   └── Info.plist
├── project.yml                 <-- Configuración de XcodeGen (genera el .xcodeproj automáticamente)
└── README.md
```

---

## Paso 1: Abrir la carpeta en VS Code

1. Abre **Visual Studio Code** en Windows.
2. Ve a **Archivo > Abrir carpeta...** y selecciona:
   `C:\Users\PC\.gemini\antigravity\scratch\MedLiveActivity`
3. Gracias a la extensión de Swift, tendrás resaltado de sintaxis y autocompletado.

---

## Paso 2: Subir el proyecto a GitHub

En la terminal de VS Code (PowerShell o Git Bash dentro de la carpeta):

```bash
git init
git add .
git commit -m "feat: Live Activities interactivas para medicamentos"
```

1. Ve a [GitHub](https://github.com) y crea un nuevo repositorio (puede ser público o privado, ej. `med-live-activity`).
2. Conecta tu repositorio local y sube los cambios:

```bash
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
git branch -M main
git push -u origin main
```

---

## Paso 3: Compilación automática del `.ipa` en GitHub Actions

1. En cuanto hagas el `git push`, ve a la pestaña **Actions** en tu repositorio de GitHub.
2. Verás ejecutándose el workflow **"Build & Package IPA"** sobre un entorno oficial macOS de Apple.
3. El proceso tomará entre 2 y 4 minutos.
4. Al finalizar con éxito, en la parte inferior de la corrida (*Artifacts*), verás el archivo:
   **`MedLiveActivity-IPA`** (un archivo `.zip` que contiene `MedLiveActivity.ipa`).
5. Descárgalo en tu computadora con Windows.

---

## Paso 4: Instalar en tu iPhone desde Windows (Sideloading)

Existen dos herramientas muy sencillas y gratuitas para instalar el `.ipa` desde Windows con tu Apple ID:

### Opción Recomendada: Sideloadly (Rápido y directo)
1. Descarga e instala [Sideloadly para Windows](https://sideloadly.io/).
2. Abre Sideloadly y conecta tu iPhone a tu PC con el cable USB (presiona "Confiar en esta computadora" en la pantalla de tu iPhone).
3. Arrastra el archivo `MedLiveActivity.ipa` dentro de la ventana de Sideloadly.
4. Escribe tu Apple ID y contraseña (Apple genera un certificado de desarrollador personal gratuito).
5. Haz clic en **Start**. En segundos, la app aparecerá en tu iPhone.

*(Nota la primera vez que instalas una app propia: Ve en tu iPhone a **Ajustes > General > VPN y gestión de dispositivos**, toca tu Apple ID y dale a "Confiar").*

---

## Paso 5: Cómo probar la Live Activity

1. Abre la app **PillPulse Live** en tu iPhone.
2. Verás tus 3 medicamentos registrados.
3. Pulsa el botón naranja **"Probar Isla"** junto a cualquiera de ellos.
4. Sal de la app o bloquea el teléfono:
   * **En la Dynamic Island:** Verás el icono del medicamento y el nombre abreviado. Al mantener presionada la isla, se despliega con el botón *"Confirmar Dosis Tomada"*.
   * **En la Pantalla de Bloqueo:** Tendrás la tarjeta persistente con el botón verde **"Tomada"**.
5. Al tocar el botón, se ejecuta el `AppIntent` en segundo plano y la actividad se cierra inmediatamente sin abrir la app.
