# EdgeControl

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

Herramienta gráfica de PowerShell para gestionar políticas del navegador Microsoft Edge a través del registro de Windows. Permite deshabilitar características no deseadas de Edge (IA, telemetría, funciones innecesarias) de forma sencilla y permanente.

## 🎯 Características

- **Interfaz gráfica intuitiva** con tema oscuro moderno
- **30 características** para deshabilitar en Edge (listado único)
- **Todos los interruptores activados por defecto**: apagas el de lo que quieras desactivar
- **Acciones rápidas**: "Activar todo" y "Desactivar todo"
- **Ejecución automática como administrador** cuando es necesario
- **Feedback visual** con barra de estado y colores indicadores
- **Ejecución directa desde GitHub** sin necesidad de descargar
- **Descripciones detalladas** para cada política

## 🚀 Ejecución

### Opción Recomendada - Ejecución Directa desde GitHub (Requiere Administrador)

Esta es la forma más rápida de ejecutar EdgeControl. Abre PowerShell como administrador y ejecuta:

```powershell
irm https://raw.githubusercontent.com/xdoofy92/EdgeControl/main/EdgeControl.ps1 | iex
```

> **📃 Nota**: Al ejecutar desde GitHub, el script se descargará y ejecutará automáticamente.

### Opción Alternativa - Ejecución Local

Si prefieres descargar el script primero:

```powershell
git clone https://github.com/xdoofy92/EdgeControl.git
cd EdgeControl
.\EdgeControl.ps1
```

### Solución de Problemas

Si obtienes un error de "ejecución de scripts deshabilitada", tienes dos opciones:

**Opción 1 - Cambiar política de ejecución (permanente para el usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Opción 2 - Ejecución temporal con Bypass:**
```powershell
powershell -ExecutionPolicy Bypass -File .\EdgeControl.ps1
```

> **⚠️ Nota**: La política `RemoteSigned` permite ejecutar scripts locales y scripts descargados de internet que estén firmados. Es más segura que `Unrestricted`.

## 🔐 Políticas Disponibles

### IA y Copilot

| Política | Descripción |
|----------|-------------|
| Copilot (IA integrada) | Quita el icono de Copilot de la barra de herramientas |
| Copilot en barra de direcciones | Elimina sugerencias de Copilot en la barra de URL |
| IA generativa en búsqueda | Bloquea funciones generativas de IA en búsqueda |
| Imagen del día (fondo NTP) | Desactiva la imagen de fondo del día en la pestaña nueva |

### Nueva pestaña y contenido

| Política | Descripción |
|----------|-------------|
| Feed de noticias (Nueva pestaña) | Bloquea el feed de noticias y contenido de Microsoft en NTP |
| Pantalla de bienvenida (1er inicio) | Oculta la experiencia de bienvenida al primer inicio |
| Sugerencias trending en barra URL | Elimina tendencias de Bing en la barra de direcciones |
| Sugerencias Work Search (barra URL) | Elimina resultados de búsqueda laboral en barra URL |

### Telemetría y diagnóstico

| Política | Descripción |
|----------|-------------|
| Telemetría y datos de diagnóstico | Desactiva el envío de datos de uso y diagnóstico |
| Personalización de anuncios/datos | No envía datos de navegación para personalizar anuncios/servicios |
| Actualización de componentes | Bloquea la actualización automática de componentes internos |
| Mejorar búsqueda/navegación (datos) | Desactiva sugerencias de búsqueda (envían datos a Bing) |

### Privacidad y rastreo

| Política | Descripción |
|----------|-------------|
| Seguimiento de navegación (Bing) | Activa Do Not Track para todos los sitios |
| Sincronización de navegación | Desactiva la sincronización con cuenta Microsoft |
| Autocompletar formularios | Desactiva el autocompletado de direcciones |
| Autocompletar tarjetas | Desactiva el guardado de tarjetas de crédito |
| Historial de navegación en sync | Impide que Edge guarde el historial de navegación |

### Inicio de sesión y cuentas

| Política | Descripción |
|----------|-------------|
| Perfil no removible (MSA) | Evita perfiles no removibles con cuenta Microsoft |
| Forzar inicio de sesión | Desactiva el inicio de sesión en el navegador |
| Compras y cupones (Shopping) | Desactiva el asistente de compras integrado de Edge |
| Microsoft Rewards en Edge | Oculta las Recompensas de Microsoft en Edge |

### Funciones innecesarias

| Política | Descripción |
|----------|-------------|
| Barra lateral (Edge Sidebar) | Desactiva la barra lateral con apps de Edge |
| Colecciones (Collections) | Desactiva la función de Colecciones de Edge |
| Juegos (Games menu) | Desactiva el menú de juegos en Edge |
| Mini menú al seleccionar texto | Desactiva el mini menú flotante al seleccionar texto |
| Drop (enviar archivos a ti mismo) | Desactiva la función Drop (enviarte archivos/notas) |

### Seguridad y SmartScreen

| Política | Descripción |
|----------|-------------|
| SmartScreen (filtro anti-phishing) | Desactiva SmartScreen (envío de URLs a Microsoft) |
| SmartScreen para descargas | Desactiva verificación SmartScreen en descargas |
| Bloqueo de scareware | Desactiva el bloqueo de scareware de Edge |
| Protección de contraseña (online) | Desactiva el monitoreo de contraseñas filtradas |

## 📖 Uso

> Todos los interruptores vienen **activados** (estado por defecto del navegador). Apagas el de lo que quieras desactivar.

### Desactivar características

1. **Apaga** el interruptor de las características que quieras deshabilitar
2. Haz clic en el botón **"Aplicar"**
3. Reinicia el navegador Microsoft Edge para que los cambios surtan efecto

### Reactivar Características

1. **Enciende** de nuevo el interruptor de lo que quieras volver a activar
2. Haz clic en el botón **"Aplicar"** (elimina la política del registro)
3. Reinicia el navegador Microsoft Edge para que los cambios surtan efecto

### Activar / Desactivar todo

- **"Activar todo"**: enciende todos los interruptores (estado por defecto)
- **"Desactivar todo"**: los apaga todos (debloat completo); luego pulsa **"Aplicar"**

### Actualizar Estado

1. Haz clic en el botón **"Actualizar"** para refrescar el estado actual de las políticas según el registro

## ⚙️ Detalles Técnicos

### Registro de Windows

El script modifica las políticas de Edge en la siguiente ruta del registro:

```
HKLM:\SOFTWARE\Policies\Microsoft\Edge
```

### Tipos de Políticas

Todas las políticas se aplican como valores `DWord` (32-bit) en el registro de Windows.

### Estructura del Script

- **Auto-elevación**: Solicita privilegios de administrador automáticamente
- **Interfaz gráfica**: Utiliza Windows Forms con tema oscuro personalizado
- **Gestión de políticas**: Funciones para aplicar y eliminar políticas del registro
- **Validación**: Manejo de errores y feedback al usuario
- **Organización por categorías**: Políticas agrupadas funcionalmente

### Indicadores Visuales

- **Verde**: Política activa (deshabilitada según configuración)
- **Rojo**: Política con valor diferente al esperado
- **Gris**: Política no configurada (valor por defecto)

## 🛡️ Seguridad

- El script solo modifica claves de registro específicas de Microsoft Edge
- No realiza cambios en otros navegadores o aplicaciones
- No recopila ni transmite datos personales
- Las políticas se aplican a nivel de sistema (HKLM)

## 🤝 Contribuir

Las contribuciones son bienvenidas. Puedes:

1. Fork el repositorio
2. Crear una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abrir un Pull Request

## 📝 Notas Importantes

- **Reinicio requerido**: Microsoft Edge debe reiniciarse después de aplicar políticas
- **Permanencia**: Las políticas persisten hasta que se eliminen manualmente
- **Compatibilidad**: Las políticas pueden variar entre versiones de Edge
- **Backup**: Se recomienda exportar la configuración antes de hacer cambios
- **Administrador**: Se requieren privilegios de administrador para modificar el registro

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🔗 Enlaces

- [Repositorio de Microsoft Edge](https://github.com/microsoft/edge)
- [Documentación de políticas de Microsoft Edge](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies)

## 👤 Autor

**xdoofy92** - [GitHub](https://github.com/xdoofy92)

## ⭐ Si te gusta este proyecto

Considera darle una estrella ⭐ al repositorio para apoyar su desarrollo.
