<div align="center">

# 🌐 EdgeControl

### Debloat de Microsoft Edge en un clic — desde una GUI con tema oscuro

*Adiós Copilot, Rewards, Shopping, telemetría y demás extras… sin tocar `regedit` a mano.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Edge](https://img.shields.io/badge/Edge-36_interruptores-0078D7?style=for-the-badge&logo=microsoftedge&logoColor=white)
[![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-3DA639?style=for-the-badge)](<LICENSE.txt>)

</div>

---

## ✨ ¿Qué es?

**EdgeControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Microsoft Edge** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

> 💡 **Gratuito y de código abierto**, bajo la [licencia MIT](<LICENSE.txt>). Puedes revisar el [código completo](<EdgeControl.ps1>), modificarlo y compartirlo. Desarrollado por [Daniel Rodriguez](https://xdoofy92.com/) · [DProjects](https://dprojects.org/).

---

## 🎛️ Cómo funciona

La app refleja el **estado real** de cada característica con un interruptor estilo switch:

| Estado | Aspecto | Significado |
|:------:|:--------|:------------|
| 🟢 **Encendido** | verde, texto normal | La característica está **activa** (valor por defecto del navegador) |
| ⚪ **Apagado** | gris, texto atenuado | Se **desactivará** al pulsar **Aplicar** (escribe la política en el registro) |

El contador de la cabecera (**`0 / 36 a Desactivar`**) te dice cuántas tienes marcadas para apagar. Al pulsar **Aplicar**, los cambios se guardan en:

```
HKLM:\SOFTWARE\Policies\Microsoft\Edge
```

> 🔁 Volver a **encender** un interruptor + **Aplicar** elimina la política → la característica regresa a su estado original.

### 🔘 Botones

| Botón | Acción |
|:------|:-------|
| **Activar todo** | Enciende todos los interruptores (estado por defecto) |
| **Desact. todo** | Los apaga todos → *debloat completo* en un clic |
| **Actualizar** | Relee el registro y refresca el estado actual |
| **Aplicar** | Guarda los cambios *(reinicia Edge para que surtan efecto)* |

---

## 🧩 Características que puedes desactivar

> 36 interruptores en un único listado, todos encendidos por defecto. Aquí los agrupamos por tema para que sea más fácil de leer.

### 🤖 IA y Copilot

| Característica | Qué apaga | Clave(s) de registro |
|:--------------|:----------|:------------------|
| Copilot (IA integrada) | Copilot/Discover: barra lateral, barra de URL y nueva pestaña | `HubsSidebarEnabled`, `Microsoft365CopilotChatIconEnabled`, `CopilotAddressBarSuggestionsEnabled`, `CopilotPageContext`, `CopilotNewTabPageEnabled` |
| IA generativa en búsqueda | Funciones generativas de IA en búsqueda | `GenAIDefaultSettings` |
| Imagen del día (fondo NTP) | Imagen de fondo del día en la pestaña nueva | `NewTabPageAllowedBackgroundTypes` |

### 🆕 Nueva pestaña y contenido

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Feed de noticias (NTP) | Noticias y contenido de Microsoft en la pestaña nueva | `NewTabPageContentEnabled` |
| Pantalla de bienvenida | Experiencia de bienvenida del primer inicio | `HideFirstRunExperience` |
| Sugerencias trending (URL) | Tendencias de Bing en la barra de direcciones | `AddressBarTrendingSuggestEnabled` |
| Sugerencias Work Search (URL) | Resultados de búsqueda laboral en la barra de URL | `AddressBarWorkSearchResultsEnabled` |

### 📡 Telemetría y diagnóstico

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Telemetría y diagnóstico | Envío de datos de uso y diagnóstico | `DiagnosticData` |
| Servicio de experimentación | Conexión al servicio de experimentos/configuración de Microsoft | `ExperimentationAndConfigurationServiceControl` |
| Comentarios/Feedback (diagnóstico) | Envío de comentarios y diagnósticos a Microsoft | `UserFeedbackAllowed` |
| Personalización de anuncios | Datos de navegación para personalizar anuncios | `PersonalizationReportingEnabled` |
| Actualización de componentes | Actualización automática de componentes internos | `ComponentUpdatesEnabled` |
| Mejorar búsqueda/navegación | Sugerencias de búsqueda (envían datos a Bing) | `SearchSuggestEnabled` |

### 🕵️ Privacidad y rastreo

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Seguimiento de navegación | Activa *Do Not Track* en todos los sitios | `ConfigureDoNotTrack` |
| Sincronización | Sincronización con cuenta Microsoft | `SyncDisabled` |
| Autocompletar formularios | Autocompletado de direcciones | `AutofillAddressEnabled` |
| Autocompletar tarjetas | Guardado de tarjetas de crédito | `AutofillCreditCardEnabled` |
| Consulta de métodos de pago | Permite a los sitios saber si tienes pagos guardados | `PaymentMethodQueryEnabled` |
| Bloquear cookies de terceros | Bloquea las cookies de seguimiento de terceros | `BlockThirdPartyCookies` |
| Predicción de red (prefetch) | Precarga de páginas y resolución DNS anticipada | `NetworkPredictionOptions` |
| Historial en sync | Guardado del historial de navegación | `SavingBrowserHistoryDisabled` |

### 👤 Inicio de sesión y cuentas

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Perfil no removible (MSA) | Perfil no removible con cuenta Microsoft | `NonRemovableProfileEnabled` |
| Forzar inicio de sesión | Inicio de sesión en el navegador | `BrowserSignin` |
| Compras y cupones | Asistente de compras integrado | `EdgeShoppingAssistantEnabled` |
| Microsoft Rewards | Recompensas de Microsoft en Edge | `ShowMicrosoftRewards` |

### 🧹 Funciones extra

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| Colecciones | Función de Colecciones | `EdgeCollectionsEnabled` |
| Juegos (Games menu) | Menú de juegos | `AllowGamesMenu` |
| Mini menú al seleccionar | Mini menú flotante al seleccionar texto | `QuickSearchShowMiniMenu` |
| Drop | Enviarte archivos/notas a ti mismo | `EdgeEDropEnabled` |
| Recomendaciones y Spotlight | Experiencias y recomendaciones de Microsoft | `SpotlightExperiencesAndRecommendationsEnabled` |
| Inicio rápido en segundo plano | Edge sigue en segundo plano para arrancar más rápido | `StartupBoostEnabled` |
| Barra/Widget web de Edge | Barra web (widget) de Edge con Bing | `WebWidgetAllowed` |

### 🔒 Seguridad y SmartScreen

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| SmartScreen | Filtro anti-phishing (envía URLs a Microsoft) | `SmartScreenEnabled` |
| SmartScreen descargas | Verificación SmartScreen en descargas | `SmartScreenForTrustedDownloadsEnabled` |
| Bloqueo de scareware | Bloqueo de scareware de Edge | `ScarewareBlockerProtectionEnabled` |
| Protección de contraseña | Monitoreo de contraseñas filtradas | `PasswordMonitorAllowed` |

> ⚠️ **Ojo con la última categoría.** Apagar SmartScreen, el bloqueo de scareware o el monitor de contraseñas **reduce tu protección**. Desactívalos solo si sabes lo que haces.

---

## 🚀 Obtención y uso

### Canales oficiales

Descarga el [script](<EdgeControl.ps1>) desde este repositorio o clona el proyecto. El código es visible y puedes revisarlo antes de ejecutarlo. Consulta también el [sitio oficial](https://dprojects.org/) y la web del [autor](https://xdoofy92.com/). No requiere instalador.

```powershell
git clone https://github.com/xdoofy92/EdgeControl.git
cd EdgeControl
```

### Revisar y ejecutar localmente

Revisa el [script](<EdgeControl.ps1>) con un editor de texto. Después abre PowerShell en la carpeta donde lo guardaste y ejecuta:

```powershell
.\EdgeControl.ps1
```

La licencia MIT permite usar, modificar y redistribuir el script, conservando el aviso de copyright y la licencia en las copias o partes sustanciales del software.

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Edge** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

Aplica estas opciones únicamente a scripts que hayas revisado y en los que confíes. Respeta las políticas de seguridad de tu organización.

**Permanente (usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Temporal (solo esta vez):**
```powershell
powershell -ExecutionPolicy Bypass -File .\EdgeControl.ps1
```

`RemoteSigned` es más segura que `Unrestricted`: permite scripts locales y scripts firmados de internet.

</details>

---

## ⚙️ Bajo el capó

- **Auto-elevación**: solicita privilegios de administrador automáticamente (necesarios para escribir en `HKLM`).
- **Interfaz**: Windows Forms con tema oscuro e interruptores dibujados a mano (anti-aliasing).
- **Tipo de valores**: todas las políticas se aplican como `DWord` (32 bits).
- **Reversible**: desmarcar y aplicar **elimina** la clave; no deja residuos.

---

## 🛡️ Seguridad y privacidad

- Solo toca claves bajo `HKLM\SOFTWARE\Policies\Microsoft\Edge`. **No** modifica otros navegadores ni el sistema.
- **No** recopila ni transmite ningún dato tuyo.
- ⚠️ La app solicita permisos de **administrador**. Verifica la procedencia y revisa el código de cualquier copia, incluidas las modificadas, antes de ejecutarla.
- Si se ejecuta sin archivo local, la auto-elevación puede descargar el script del repositorio. Prefiere descargarlo, revisarlo y ejecutarlo localmente para saber qué código estás ejecutando.

---

## 🤝 Colaborar

¿Una política nueva, un bug, una mejora de UI? Envía tus sugerencias mediante los canales de [DProjects](https://dprojects.org/) o del [autor](https://xdoofy92.com/).

Puedes abrir una incidencia, crear un fork y proponer cambios mediante un pull request. El código está disponible para estudiar, modificar y redistribuir bajo MIT, sin solicitar autorización adicional. Conserva el aviso de copyright y la licencia en las copias o partes sustanciales del software.

---

## 📄 Licencia y distribución

**Daniel Rodriguez (DProjects)** es el autor. Software **gratuito y de código abierto**, bajo la [licencia MIT](<LICENSE.txt>):

- Puedes usarlo con fines personales, profesionales y comerciales.
- Puedes examinar, copiar, modificar, combinar, publicar, distribuir, sublicenciar y vender copias del software.
- Debes conservar el aviso de copyright y el texto de la licencia en todas las copias o partes sustanciales del software.
- Se proporciona **«tal cual», sin garantías**, según los términos de MIT.
- Estos permisos incluyen el script y su código fuente; no se limitan a un instalador ni exigen distribuirlo sin modificaciones.
- Los componentes y marcas de terceros conservan sus propias licencias y derechos.

---

## 📝 Notas

- 🔄 **Reinicia Edge** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar).
- 🧪 Los nombres de política pueden variar entre versiones de Edge (`AllowGamesMenu` está marcada como *deprecada* por Microsoft, pero sigue funcionando).

---

<div align="center">

**[Licencia MIT](<LICENSE.txt>)** · Hecho por **[Daniel Rodriguez](https://xdoofy92.com/)** · **[DProjects](https://dprojects.org/)**

🔗 [Políticas de Microsoft Edge](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies) · [Repo de Edge](https://github.com/microsoft/edge)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
