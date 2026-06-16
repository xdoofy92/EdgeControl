# EdgeControl - Gestor grafico de politicas de Microsoft Edge via registro de Windows
# Autor: Daniel Rodriguez | https://xdoofy92.com

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ─── Auto-elevacion a administrador ──────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $PSCommandPath) {
        # Ejecucion remota (irm | iex): descargar y relanzar como admin
        $url = "https://raw.githubusercontent.com/xdoofy92/EdgeControl/main/EdgeControl.ps1"
        $scriptContent = ([string](Invoke-RestMethod -Uri $url)).TrimStart([char]0xFEFF)
        $tempFile = Join-Path $env:TEMP "EdgeControl_$([guid]::NewGuid().ToString('N')).ps1"
        [IO.File]::WriteAllText($tempFile, $scriptContent, (New-Object System.Text.UTF8Encoding($false)))
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        exit
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

# ─── Identidad de la app ─────────────────────────────────────────────────────
$REG_PATH  = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$APP_TITLE = "EdgeControl - dprojects.org"
$APP_NAME  = "EdgeControl"
$APP_SUB   = "Politicas de Microsoft Edge via registro"
$BROWSER   = "Microsoft Edge"

# ─── Paleta (compartida con BraveControl, solo cambia el acento) ──────────────
$BG       = [Drawing.Color]::FromArgb(17, 17, 20)
$CARD     = [Drawing.Color]::FromArgb(26, 26, 30)
$CARD2    = [Drawing.Color]::FromArgb(32, 32, 37)
$HOVER    = [Drawing.Color]::FromArgb(40, 40, 46)
$GRPBG    = [Drawing.Color]::FromArgb(22, 22, 26)
$BORDER   = [Drawing.Color]::FromArgb(46, 46, 54)
$FG       = [Drawing.Color]::FromArgb(232, 232, 236)
$MUTED    = [Drawing.Color]::FromArgb(140, 140, 150)
$GREEN    = [Drawing.Color]::FromArgb(86, 196, 138)
$RED      = [Drawing.Color]::FromArgb(232, 100, 100)
$TOG_OFF  = [Drawing.Color]::FromArgb(62, 62, 72)
$ACCENT   = [Drawing.Color]::FromArgb(0, 120, 212)     # Azul Edge
$ACC_HOV  = [Drawing.Color]::FromArgb(28, 140, 232)
$ACC_DWN  = [Drawing.Color]::FromArgb(0, 99, 177)

# ─── Tipografias ─────────────────────────────────────────────────────────────
$FONT_TITLE = [Drawing.Font]::new("Segoe UI", 15, [Drawing.FontStyle]::Bold)
$FONT_SUB   = [Drawing.Font]::new("Segoe UI Semibold", 8.5)
$FONT_BODY  = [Drawing.Font]::new("Segoe UI", 9.5)
$FONT_DESC  = [Drawing.Font]::new("Segoe UI", 7.75)
$FONT_BTN   = [Drawing.Font]::new("Segoe UI Semibold", 9)
$FONT_CNT   = [Drawing.Font]::new("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$FONT_STAT  = [Drawing.Font]::new("Segoe UI", 7.75)

# ─── Geometria ───────────────────────────────────────────────────────────────
$W_FORM = 462; $H_FORM = 632
$W_PANEL = 418
$W_ROW = 392; $X_ROW = 6; $H_ROW = 46
$TOG_W = 40; $TOG_H = 22
$X_TOG = $W_ROW - $TOG_W - 12
$X_TXT = 14
$W_TXT = $X_TOG - $X_TXT - 10

# Nota: NO creamos $REG_PATH al arrancar. La clave se crea solo cuando se aplica
# alguna politica (ver Set-Policies). Asi, tras pulsar "Default" la clave queda
# realmente eliminada y Edge no muestra "Administrado por su organizacion".

# ─── Caracteristicas (listado unico, estilo debloat) ─────────────────────────
# Logica: el toggle refleja el estado de la caracteristica.
#   ON  (verde) = activada (estado normal)        Off = valor "activado" / no configurada
#   OFF (gris)  = se desactivara al pulsar Aplicar  -> escribe Val en el registro
# Formato: Nombre = @{ Key; Val=valor desactivado; Opp=valor activado; T=tipo; Desc }
$POLICIES = [ordered]@{
    # Copilot: las politicas dedicadas (Microsoft365CopilotChatIconEnabled, etc.) SOLO aplican
    # a perfiles Entra ID (cuenta de trabajo/escuela), NO a cuentas Microsoft personales (MSA).
    # La unica clave que quita Copilot/Discover con cuenta personal es HubsSidebarEnabled = 0
    # (la barra lateral es donde vive Copilot). Por eso este toggle escribe varias claves a la vez.
    "Copilot (IA integrada)"              = @{ Desc = "Quita Copilot/Discover (barra lateral, barra URL y nueva pestana)"; KeySet = @(
        @{ Key = "HubsSidebarEnabled";                  Val = 0; Opp = 1; T = "DWord" }   # MSA + Entra: oculta la barra lateral con Copilot
        @{ Key = "Microsoft365CopilotChatIconEnabled";  Val = 0; Opp = 1; T = "DWord" }   # solo Entra: icono Copilot en barra de herramientas
        @{ Key = "CopilotAddressBarSuggestionsEnabled"; Val = 0; Opp = 1; T = "DWord" }   # solo Entra: sugerencias Copilot en barra URL
        @{ Key = "CopilotPageContext";                  Val = 0; Opp = 1; T = "DWord" }   # solo Entra: acceso de Copilot al contenido de la pagina
        @{ Key = "CopilotNewTabPageEnabled";            Val = 0; Opp = 1; T = "DWord" }   # solo Entra: pagina de nueva pestana de Copilot
    ) }
    "IA generativa en busqueda"           = @{ Key = "GenAIDefaultSettings";                  Val = 2; Opp = 1; T = "DWord"; Desc = "Funciones generativas de IA en busqueda" }
    "Feed de noticias (Nueva pestana)"    = @{ Key = "NewTabPageContentEnabled";              Val = 0; Opp = 1; T = "DWord"; Desc = "Feed de noticias y contenido de Microsoft en NTP" }
    "Imagen del dia (fondo NTP)"          = @{ Key = "NewTabPageAllowedBackgroundTypes";      Val = 1; Opp = 0; T = "DWord"; Desc = "Imagen de fondo del dia en la pestana nueva" }
    "Pantalla de bienvenida (1er inicio)" = @{ Key = "HideFirstRunExperience";                Val = 1; Opp = 0; T = "DWord"; Desc = "Experiencia de bienvenida al primer inicio" }
    "Sugerencias trending en barra URL"   = @{ Key = "AddressBarTrendingSuggestEnabled";      Val = 0; Opp = 1; T = "DWord"; Desc = "Tendencias de Bing en la barra de direcciones" }
    "Sugerencias Work Search (barra URL)" = @{ Key = "AddressBarWorkSearchResultsEnabled";    Val = 0; Opp = 1; T = "DWord"; Desc = "Resultados de busqueda laboral en barra URL" }
    "Telemetria y datos de diagnostico"   = @{ Key = "DiagnosticData";                        Val = 0; Opp = 2; T = "DWord"; Desc = "Envio de datos de uso y diagnostico" }
    "Personalizacion de anuncios/datos"   = @{ Key = "PersonalizationReportingEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Datos de navegacion para personalizar anuncios" }
    "Actualizacion de componentes"        = @{ Key = "ComponentUpdatesEnabled";               Val = 0; Opp = 1; T = "DWord"; Desc = "Actualizacion automatica de componentes internos" }
    "Mejorar busqueda/navegacion (datos)" = @{ Key = "SearchSuggestEnabled";                  Val = 0; Opp = 1; T = "DWord"; Desc = "Sugerencias de busqueda (envian datos a Bing)" }
    "Seguimiento de navegacion (Bing)"    = @{ Key = "ConfigureDoNotTrack";                   Val = 1; Opp = 0; T = "DWord"; Desc = "Do Not Track para todos los sitios" }
    "Sincronizacion de navegacion"        = @{ Key = "SyncDisabled";                          Val = 1; Opp = 0; T = "DWord"; Desc = "Sincronizacion con cuenta Microsoft" }
    "Autocompletar formularios"           = @{ Key = "AutofillAddressEnabled";                Val = 0; Opp = 1; T = "DWord"; Desc = "Autocompletado de direcciones" }
    "Autocompletar tarjetas"              = @{ Key = "AutofillCreditCardEnabled";             Val = 0; Opp = 1; T = "DWord"; Desc = "Guardado de tarjetas de credito" }
    "Historial de navegacion en sync"     = @{ Key = "SavingBrowserHistoryDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Guardado del historial de navegacion" }
    "Perfil no removible (MSA)"           = @{ Key = "NonRemovableProfileEnabled";            Val = 0; Opp = 1; T = "DWord"; Desc = "Perfil no removible con cuenta Microsoft" }
    "Forzar inicio de sesion"             = @{ Key = "BrowserSignin";                         Val = 0; Opp = 2; T = "DWord"; Desc = "Inicio de sesion en el navegador" }
    "Compras y cupones (Shopping)"        = @{ Key = "EdgeShoppingAssistantEnabled";          Val = 0; Opp = 1; T = "DWord"; Desc = "Asistente de compras integrado de Edge" }
    "Microsoft Rewards en Edge"           = @{ Key = "ShowMicrosoftRewards";                  Val = 0; Opp = 1; T = "DWord"; Desc = "Recompensas de Microsoft en Edge" }
    "Colecciones (Collections)"           = @{ Key = "EdgeCollectionsEnabled";                Val = 0; Opp = 1; T = "DWord"; Desc = "Funcion de Colecciones de Edge" }
    "Juegos (Games menu)"                 = @{ Key = "AllowGamesMenu";                        Val = 0; Opp = 1; T = "DWord"; Desc = "Menu de juegos en Edge" }
    "Mini menu al seleccionar texto"      = @{ Key = "QuickSearchShowMiniMenu";               Val = 0; Opp = 1; T = "DWord"; Desc = "Mini menu flotante al seleccionar texto" }
    "Drop (enviar archivos a ti mismo)"   = @{ Key = "EdgeEDropEnabled";                      Val = 0; Opp = 1; T = "DWord"; Desc = "Funcion Drop (enviarte archivos/notas)" }
    "SmartScreen (filtro anti-phishing)"  = @{ Key = "SmartScreenEnabled";                    Val = 0; Opp = 1; T = "DWord"; Desc = "SmartScreen (envio de URLs a Microsoft)" }
    "SmartScreen para descargas"          = @{ Key = "SmartScreenForTrustedDownloadsEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Verificacion SmartScreen en descargas" }
    "Bloqueo de scareware"                = @{ Key = "ScarewareBlockerProtectionEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Bloqueo de scareware de Edge" }
    "Proteccion de contrasena (online)"   = @{ Key = "PasswordMonitorAllowed";                Val = 0; Opp = 1; T = "DWord"; Desc = "Monitoreo de contrasenas filtradas" }
    # ── Telemetria y privacidad adicionales ──
    "Servicio de experimentacion"         = @{ Key = "ExperimentationAndConfigurationServiceControl"; Val = 0; Opp = 2; T = "DWord"; Desc = "Conexion al servicio de experimentos/configuracion de Microsoft" }
    "Comentarios/Feedback (diagnostico)"  = @{ Key = "UserFeedbackAllowed";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Envio de comentarios y diagnosticos a Microsoft" }
    "Recomendaciones y Spotlight"         = @{ Key = "SpotlightExperiencesAndRecommendationsEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Experiencias y recomendaciones de Microsoft" }
    "Inicio rapido en segundo plano"      = @{ Key = "StartupBoostEnabled";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Edge sigue en segundo plano para arrancar mas rapido" }
    "Barra/Widget web de Edge"            = @{ Key = "WebWidgetAllowed";                       Val = 0; Opp = 1; T = "DWord"; Desc = "Barra web (widget) de Edge con Bing" }
    "Prediccion de red (prefetch)"        = @{ Key = "NetworkPredictionOptions";               Val = 2; Opp = 0; T = "DWord"; Desc = "Precarga de paginas y resolucion DNS anticipada" }
    "Bloquear cookies de terceros"        = @{ Key = "BlockThirdPartyCookies";                 Val = 1; Opp = 0; T = "DWord"; Desc = "Bloquea cookies de seguimiento de terceros" }
    "Consulta de metodos de pago"         = @{ Key = "PaymentMethodQueryEnabled";              Val = 0; Opp = 1; T = "DWord"; Desc = "Permite a los sitios saber si tienes pagos guardados" }
}

# ─── Estado en memoria ───────────────────────────────────────────────────────
$script:state   = [ordered]@{}   # $true = caracteristica activada (toggle ON)
$script:labels  = [ordered]@{}
$script:toggles = [ordered]@{}
$script:total   = $POLICIES.Count

# ─── Helpers de registro ─────────────────────────────────────────────────────
function Get-PolicyState {
    param([string]$Key)
    try {
        $value = Get-ItemProperty -Path $REG_PATH -Name $Key -ErrorAction SilentlyContinue
        if ($null -ne $value) { return $value.$Key }
    } catch {}
    return $null
}

# Normaliza una politica a una lista de claves de registro.
# Soporta el formato simple (Key/Val/Opp/T) y el multi-clave (KeySet = @(...)).
# Nota: el campo se llama KeySet y no "Keys" porque .Keys colisiona con la propiedad
# nativa de las hashtables (devolveria los nombres de los campos, no el array).
# La primera clave es la "primaria": determina el estado mostrado en el toggle.
function Get-PolicyKeys {
    param($p)
    # El operador coma (,) evita que PowerShell desenvuelva un array de un solo
    # elemento al devolverlo (en cuyo caso [0] daria $null en el caso simple).
    if ($p.Contains('KeySet')) { return ,@($p['KeySet']) }
    return ,@(@{ Key = $p.Key; Val = $p.Val; Opp = $p.Opp; T = $p.T })
}

function Update-Counter {
    $off = ($script:state.Values | Where-Object { -not $_ }).Count
    $script:counter.Text = "$off / $script:total a Desactivar"
    $script:counter.ForeColor = if ($off -gt 0) { $ACCENT } else { $MUTED }
}

function Update-CurrentState {
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $primary = (Get-PolicyKeys $p)[0]
        $cur = Get-PolicyState -Key $primary.Key
        if ($cur -eq $primary.Val) {
            # Ya esta desactivada en el registro -> toggle OFF
            $script:state[$name] = $false
            $script:labels[$name].ForeColor = $MUTED
        } else {
            # Activada (no configurada o valor activado) -> toggle ON
            $script:state[$name] = $true
            $script:labels[$name].ForeColor = $FG
        }
        $script:toggles[$name].Invalidate()
    }
    Update-Counter
}

function Invoke-PolicyToggle {
    param([string]$Name)
    $script:state[$Name] = -not $script:state[$Name]
    $script:labels[$Name].ForeColor = if ($script:state[$Name]) { $FG } else { $MUTED }
    $script:toggles[$Name].Invalidate()
    Update-Counter
}

function Set-Policies {
    $disabled = 0; $fail = 0; $reenabled = 0
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $keys = Get-PolicyKeys $p
        $primary = $keys[0]
        $cur = Get-PolicyState -Key $primary.Key
        if (-not $script:state[$name]) {
            # Toggle OFF -> desactivar caracteristica (todas sus claves)
            if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }
            try {
                foreach ($k in $keys) { Set-ItemProperty -Path $REG_PATH -Name $k.Key -Value $k.Val -Type $k.T -Force }
                $disabled++
            } catch { $fail++ }
        } elseif ($cur -eq $primary.Val) {
            # Toggle ON y estaba desactivada -> reactivar (quitar todas sus claves)
            # SilentlyContinue: en multi-clave algunas pueden no existir y no debe contar como error
            try {
                foreach ($k in $keys) { Remove-ItemProperty -Path $REG_PATH -Name $k.Key -Force -ErrorAction SilentlyContinue }
                $reenabled++
            } catch { $fail++ }
        }
    }
    return $disabled, $fail, $reenabled
}

# ─── Helpers de UI ───────────────────────────────────────────────────────────
function New-Toggle {
    param([string]$Name, [int]$X, [int]$Y, [Drawing.Color]$BaseBg)
    $t = [Windows.Forms.Panel]::new()
    $t.Size     = [Drawing.Size]::new($TOG_W, $TOG_H)
    $t.Location = [Drawing.Point]::new($X, $Y)
    $t.BackColor = $BaseBg
    $t.Tag      = $Name
    $t.Cursor   = [Windows.Forms.Cursors]::Hand
    $t.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $on = [bool]$script:state[$s.Tag]
        $w = $s.Width; $h = $s.Height
        $col = if ($on) { $GREEN } else { $TOG_OFF }
        $path = New-Object Drawing.Drawing2D.GraphicsPath
        $path.AddArc(0, 0, $h, $h, 90, 180)
        $path.AddArc($w - $h, 0, $h, $h, 270, 180)
        $path.CloseFigure()
        $b = New-Object Drawing.SolidBrush($col)
        $g.FillPath($b, $path)
        $kd = $h - 6
        $kx = if ($on) { $w - $h + 3 } else { 3 }
        $wb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(245, 245, 245))
        $g.FillEllipse($wb, $kx, 3, $kd, $kd)
        $b.Dispose(); $wb.Dispose(); $path.Dispose()
    })
    return $t
}

function New-Button {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H, [switch]$Primary)
    $b = [Windows.Forms.Button]::new()
    $b.Text      = $Text
    $b.Location  = [Drawing.Point]::new($X, $Y)
    $b.Size      = [Drawing.Size]::new($W, $H)
    $b.Font      = $FONT_BTN
    $b.FlatStyle = "Flat"
    $b.Cursor    = [Windows.Forms.Cursors]::Hand
    if ($Primary) {
        $b.BackColor = $ACCENT
        $b.ForeColor = [Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
        $b.FlatAppearance.MouseOverBackColor = $ACC_HOV
        $b.FlatAppearance.MouseDownBackColor = $ACC_DWN
    } else {
        $b.BackColor = $CARD2
        $b.ForeColor = $FG
        $b.FlatAppearance.BorderSize  = 1
        $b.FlatAppearance.BorderColor = $BORDER
        $b.FlatAppearance.MouseOverBackColor = $HOVER
        $b.FlatAppearance.MouseDownBackColor = $CARD
    }
    return $b
}

# ─── Ventana ─────────────────────────────────────────────────────────────────
$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.ClientSize      = [Drawing.Size]::new($W_FORM, $H_FORM)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $BG
$form.ForeColor       = $FG
$form.Font            = $FONT_BODY
$form.MaximizeBox     = $false
$form.FormBorderStyle = "FixedDialog"

# ── Cabecera ──
$header = [Windows.Forms.Panel]::new()
$header.Size      = [Drawing.Size]::new($W_FORM, 62)
$header.Location  = [Drawing.Point]::new(0, 0)
$header.BackColor = $CARD
$form.Controls.Add($header)

# -- Logo oficial de Microsoft Edge (PNG oficial de Wikimedia Commons embebido en Base64 -> PictureBox) --
$LOGO_B64 = "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"
$logo = [Windows.Forms.PictureBox]::new()
$logo.Size      = [Drawing.Size]::new(36, 36)
$logo.Location  = [Drawing.Point]::new(16, 13)
$logo.BackColor = $CARD
$logo.SizeMode  = [Windows.Forms.PictureBoxSizeMode]::Zoom
$logo.Image     = [Drawing.Image]::FromStream([IO.MemoryStream]::new([Convert]::FromBase64String($LOGO_B64)))
$header.Controls.Add($logo)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = $APP_NAME
$lblTitle.Font      = $FONT_TITLE
$lblTitle.ForeColor = $FG
$lblTitle.Location  = [Drawing.Point]::new(60, 8)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = $APP_SUB
$lblSub.Font      = $FONT_SUB
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(62, 39)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)

$script:counter = [Windows.Forms.Label]::new()
$script:counter.Size      = [Drawing.Size]::new(180, 24)
$script:counter.Location  = [Drawing.Point]::new($W_FORM - 196, 19)
$script:counter.Font      = $FONT_CNT
$script:counter.ForeColor = $MUTED
$script:counter.TextAlign = "MiddleRight"
$header.Controls.Add($script:counter)

# Franja de acento bajo la cabecera
$accentStrip = [Windows.Forms.Panel]::new()
$accentStrip.Size      = [Drawing.Size]::new($W_FORM, 2)
$accentStrip.Location  = [Drawing.Point]::new(0, 62)
$accentStrip.BackColor = $ACCENT
$form.Controls.Add($accentStrip)

# ── Panel scrollable con scrollbar oscuro personalizado (todo negro) ──
$SBW       = [Windows.Forms.SystemInformation]::VerticalScrollBarWidth  # ancho del scrollbar nativo (se oculta)
$VBAR_W    = 8                                                          # ancho de nuestro scrollbar
$TRACK_COL = $BG                                                        # pista/fondo: negro
$THUMB_COL = [Drawing.Color]::FromArgb(64, 64, 72)                      # pulgar en reposo
$THUMB_HOV = [Drawing.Color]::FromArgb(98, 98, 110)                     # pulgar en hover/arrastre

# Contenedor que recorta el scrollbar nativo del panel
$scrollHost = [Windows.Forms.Panel]::new()
$scrollHost.Location  = [Drawing.Point]::new(16, 74)
$scrollHost.Size      = [Drawing.Size]::new($W_PANEL, 474)
$scrollHost.BackColor = $CARD
$form.Controls.Add($scrollHost)

# Panel real con AutoScroll; más ancho para que su scrollbar nativo quede fuera (recortado por el host)
$scrollPanel = [Windows.Forms.Panel]::new()
$scrollPanel.Location   = [Drawing.Point]::new(0, 0)
$scrollPanel.Size       = [Drawing.Size]::new($W_PANEL + $SBW, 474)
$scrollPanel.BackColor  = $CARD
$scrollPanel.AutoScroll = $true
$scrollHost.Controls.Add($scrollPanel)

# Pista del scrollbar (negra) y pulgar (gris oscuro)
$vbar = [Windows.Forms.Panel]::new()
$vbar.Size      = [Drawing.Size]::new($VBAR_W, 474)
$vbar.Location  = [Drawing.Point]::new($W_PANEL - $VBAR_W, 0)
$vbar.BackColor = $TRACK_COL
$scrollHost.Controls.Add($vbar)
$vbar.BringToFront()

$vthumb = [Windows.Forms.Panel]::new()
$vthumb.Size      = [Drawing.Size]::new($VBAR_W, 40)
$vthumb.Location  = [Drawing.Point]::new(0, 0)
$vthumb.BackColor = $THUMB_COL
$vthumb.Cursor    = [Windows.Forms.Cursors]::Hand
$vbar.Controls.Add($vthumb)

$script:vDrag = $false
$script:vDragStartY = 0
$script:vDragStartScrolled = 0

function Update-VScroll {
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    if ($view -le 0 -or $content -le $view) { $vbar.Visible = $false; return }
    $vbar.Visible = $true
    $trackH = $vbar.Height
    $thumbH = [int][math]::Max(28, [math]::Round($trackH * $view / $content))
    if ($thumbH -gt $trackH) { $thumbH = $trackH }
    $maxScroll = $content - $view
    $scrolled  = - $scrollPanel.AutoScrollPosition.Y
    if ($scrolled -lt 0) { $scrolled = 0 } elseif ($scrolled -gt $maxScroll) { $scrolled = $maxScroll }
    $thumbY = if ($maxScroll -gt 0) { [int][math]::Round(($trackH - $thumbH) * $scrolled / $maxScroll) } else { 0 }
    if ($vthumb.Height -ne $thumbH) { $vthumb.Height = $thumbH }
    if ($vthumb.Top    -ne $thumbY) { $vthumb.Top    = $thumbY }
}

$vthumb.Add_MouseEnter({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_HOV } })
$vthumb.Add_MouseLeave({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_COL } })
$vthumb.Add_MouseDown({
    $script:vDrag = $true
    $script:vDragStartY = [Windows.Forms.Cursor]::Position.Y
    $script:vDragStartScrolled = - $scrollPanel.AutoScrollPosition.Y
    $vthumb.BackColor = $THUMB_HOV
})
$vthumb.Add_MouseUp({
    $script:vDrag = $false
    $vthumb.BackColor = $THUMB_COL
})
$vthumb.Add_MouseMove({
    if (-not $script:vDrag) { return }
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    $maxScroll = $content - $view
    if ($maxScroll -le 0) { return }
    $denom = $vbar.Height - $vthumb.Height
    if ($denom -le 0) { return }
    $dy = [Windows.Forms.Cursor]::Position.Y - $script:vDragStartY
    $newScrolled = $script:vDragStartScrolled + [int][math]::Round($dy * $maxScroll / $denom)
    if ($newScrolled -lt 0) { $newScrolled = 0 } elseif ($newScrolled -gt $maxScroll) { $newScrolled = $maxScroll }
    $scrollPanel.AutoScrollPosition = [Drawing.Point]::new(0, $newScrolled)
    Update-VScroll
})

# El thumb se sincroniza con la rueda y el arrastre nativo via timer + evento Scroll
$scrollPanel.Add_Scroll({ Update-VScroll })
$vtimer = [Windows.Forms.Timer]::new()
$vtimer.Interval = 60
$vtimer.Add_Tick({ Update-VScroll })
$vtimer.Start()
$form.Add_FormClosed({ $vtimer.Stop(); $vtimer.Dispose() })

$yGlobal = 8

# ── Filas de caracteristicas (listado unico) ──
$i = 0
foreach ($name in $POLICIES.Keys) {
    $p = $POLICIES[$name]
    $rowBg = if (($i % 2) -eq 0) { $CARD } else { $CARD2 }
    $i++
    $script:state[$name] = $true   # por defecto activada (ON)

    $row = [Windows.Forms.Panel]::new()
    $row.Size      = [Drawing.Size]::new($W_ROW, $H_ROW)
    $row.Location  = [Drawing.Point]::new($X_ROW, $yGlobal)
    $row.BackColor = $rowBg
    $row.Cursor    = [Windows.Forms.Cursors]::Hand
    $scrollPanel.Controls.Add($row)

    $lbl = [Windows.Forms.Label]::new()
    $lbl.Text      = $name
    $lbl.Location  = [Drawing.Point]::new($X_TXT, 7)
    $lbl.Size      = [Drawing.Size]::new($W_TXT, 17)
    $lbl.ForeColor = $FG
    $lbl.Font      = $FONT_BODY
    $lbl.BackColor = [Drawing.Color]::Transparent
    $lbl.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($lbl)
    $script:labels[$name] = $lbl

    $desc = [Windows.Forms.Label]::new()
    $desc.Text      = $p.Desc
    $desc.Location  = [Drawing.Point]::new($X_TXT, 25)
    $desc.Size      = [Drawing.Size]::new($W_TXT, 14)
    $desc.ForeColor = $MUTED
    $desc.Font      = $FONT_DESC
    $desc.BackColor = [Drawing.Color]::Transparent
    $desc.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($desc)

    $tog = New-Toggle $name $X_TOG ([int](($H_ROW - $TOG_H) / 2)) $rowBg
    $row.Controls.Add($tog)
    $script:toggles[$name] = $tog

    $keyList = ((Get-PolicyKeys $p) | ForEach-Object { $_.Key }) -join ", "
    $tt = [Windows.Forms.ToolTip]::new()
    $tt.SetToolTip($lbl,  "Clave: $keyList")
    $tt.SetToolTip($desc, "Clave: $keyList")

    # Click -> alternar
    $capture = $name
    $onClick = { Invoke-PolicyToggle $capture }.GetNewClosure()
    $row.Add_Click($onClick)
    $lbl.Add_Click($onClick)
    $desc.Add_Click($onClick)
    $tog.Add_Click($onClick)

    # Hover de fila
    $baseBg = $rowBg
    $onEnter = {
        $row.BackColor = $HOVER
        $tog.BackColor = $HOVER
        $tog.Invalidate()
    }.GetNewClosure()
    $onLeave = {
        $pt = $row.PointToClient([Windows.Forms.Cursor]::Position)
        if (-not $row.ClientRectangle.Contains($pt)) {
            $row.BackColor = $baseBg
            $tog.BackColor = $baseBg
            $tog.Invalidate()
        }
    }.GetNewClosure()
    $row.Add_MouseEnter($onEnter);  $row.Add_MouseLeave($onLeave)
    $lbl.Add_MouseEnter($onEnter);  $lbl.Add_MouseLeave($onLeave)
    $desc.Add_MouseEnter($onEnter); $desc.Add_MouseLeave($onLeave)
    $tog.Add_MouseEnter($onEnter);  $tog.Add_MouseLeave($onLeave)

    $yGlobal += $H_ROW + 2
}

# ── Botonera ──
$btnY = 560; $btnH = 36
$btnDefault    = New-Button "Default"      16  $btnY 92  $btnH
$btnEnableAll  = New-Button "Activar todo"  116 $btnY 92  $btnH
$btnDisableAll = New-Button "Desact. todo"  216 $btnY 92  $btnH
$btnApply      = New-Button "Aplicar"       316 $btnY 118 $btnH -Primary
$form.Controls.AddRange(@($btnDefault, $btnEnableAll, $btnDisableAll, $btnApply))

# ── Barra de estado ──
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 606)
$script:status.Size      = [Drawing.Size]::new($W_PANEL, 18)
$script:status.ForeColor = $MUTED
$script:status.Font      = $FONT_STAT
$script:status.Text      = ""
$form.Controls.Add($script:status)

# ── Estado inicial ──
Update-CurrentState

# ── Eventos ──
$btnEnableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $true
        $script:labels[$n].ForeColor = $FG
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las caracteristicas activadas."
})

$btnDisableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $false
        $script:labels[$n].ForeColor = $MUTED
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas marcadas para desactivar."
})

$btnDefault.Add_Click({
    # Elimina por completo la clave de politicas de Edge -> vuelve todo a sus
    # valores predeterminados y Edge deja de aparecer "Administrado por su organizacion".
    try {
        if (Test-Path $REG_PATH) { Remove-Item $REG_PATH -Recurse -Force -ErrorAction Stop }
        Update-CurrentState
        $script:status.ForeColor = $GREEN
        $script:status.Text = "Politicas eliminadas. Reinicia $BROWSER; ya no saldra administrado por su organizacion."
    } catch {
        $script:status.ForeColor = $RED
        $script:status.Text = "No se pudieron eliminar las politicas: $($_.Exception.Message)"
    }
})

$btnApply.Add_Click({
    $disabled, $fail, $reenabled = Set-Policies
    Update-CurrentState
    $msg = "$disabled desactivadas"
    if ($reenabled -gt 0) { $msg += ", $reenabled reactivadas" }
    if ($fail -gt 0)      { $msg += ", $fail errores" }
    $msg += ". Reinicia $BROWSER para que surtan efecto."
    $script:status.ForeColor = if ($fail -gt 0) { $RED } else { $GREEN }
    $script:status.Text = $msg
})

# Refresco inicial del scrollbar personalizado una vez mostrado el formulario
$form.Add_Shown({ Update-VScroll })

[void]$form.ShowDialog()
