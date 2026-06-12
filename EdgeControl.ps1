# Herramienta grafica para gestionar politicas de Microsoft Edge via registro de Windows
# Autor: xdoofy92 | https://github.com/xdoofy92

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ─── Auto-elevacion a administrador ─────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $PSCommandPath) {
        $url = "https://raw.githubusercontent.com/xdoofy92/EdgeControl/main/EdgeControl.ps1"
        $scriptContent = Invoke-RestMethod -Uri $url
        $tempFile = Join-Path $env:TEMP "EdgeControl_$([guid]::NewGuid().ToString('N')).ps1"
        $scriptContent | Out-File $tempFile -Encoding UTF8
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        exit
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# ─── Constantes ──────────────────────────────────────────────────────────────
$REG_PATH  = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$APP_TITLE = "EdgeControl - dprojects.org"

$DARK   = [Drawing.Color]::FromArgb(13, 13, 13)
$PANEL  = [Drawing.Color]::FromArgb(22, 22, 22)
$PANEL2 = [Drawing.Color]::FromArgb(30, 30, 30)
$BORDER = [Drawing.Color]::FromArgb(50, 50, 50)
$FG     = [Drawing.Color]::FromArgb(210, 210, 210)
$MUTED  = [Drawing.Color]::FromArgb(110, 110, 110)
$ACCENT = [Drawing.Color]::FromArgb(0, 120, 212)    # Azul Edge
$GREEN  = [Drawing.Color]::FromArgb(100, 210, 130)
$RED    = [Drawing.Color]::FromArgb(220, 90, 90)

$FONT_BODY   = [Drawing.Font]::new("Segoe UI", 9)
$FONT_SMALL  = [Drawing.Font]::new("Segoe UI", 7.5)
$FONT_LABEL  = [Drawing.Font]::new("Segoe UI", 7.5, [Drawing.FontStyle]::Bold)
$FONT_TITLE  = [Drawing.Font]::new("Segoe UI", 13, [Drawing.FontStyle]::Bold)
$FONT_HEADER = [Drawing.Font]::new("Segoe UI", 8, [Drawing.FontStyle]::Bold)

if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }

# ─── Politicas por categoria ──────────────────────────────────────────────────
# Formato: Nombre = @{ Key=clave registro; Val=valor desactivado; Opp=valor activado; T=tipo; Desc=descripcion }

$GROUPS = [ordered]@{

    "IA y Copilot" = [ordered]@{
        "Copilot (IA integrada)"              = @{ Key = "CopilotEnabled";                           Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el asistente Copilot de Edge" }
        "Copilot en barra de direcciones"     = @{ Key = "CopilotAddressBarSuggestionsEnabled";      Val = 0; Opp = 1; T = "DWord"; Desc = "Elimina sugerencias de Copilot en la barra de URL" }
        "IA generativa en busqueda"           = @{ Key = "GenAIDefaultSettings";                     Val = 2; Opp = 1; T = "DWord"; Desc = "Bloquea funciones generativas de IA en busqueda" }
        "Imagen del dia (fondo NTP)"          = @{ Key = "NewTabPageAllowedBackgroundTypes";         Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva la imagen de fondo del dia en la pestana nueva" }
    }

    "Nueva pestana y contenido" = [ordered]@{
        "Feed de noticias (Nueva pestana)"    = @{ Key = "NewTabPageContentEnabled";                 Val = 0; Opp = 1; T = "DWord"; Desc = "Bloquea el feed de noticias y contenido de Microsoft en NTP" }
        "Pantalla de bienvenida (1er inicio)" = @{ Key = "HideFirstRunExperience";                   Val = 1; Opp = 0; T = "DWord"; Desc = "Oculta la experiencia de bienvenida al primer inicio" }
        "Sugerencias trending en barra URL"   = @{ Key = "AddressBarTrendingSuggestEnabled";         Val = 0; Opp = 1; T = "DWord"; Desc = "Elimina tendencias de Bing en la barra de direcciones" }
        "Sugerencias Work Search (barra URL)" = @{ Key = "AddressBarWorkSearchResultsEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Elimina resultados de busqueda laboral en barra URL" }
    }

    "Telemetria y diagnostico" = [ordered]@{
        "Telemetria y datos de diagnostico"   = @{ Key = "DiagnosticData";                           Val = 0; Opp = 2; T = "DWord"; Desc = "Desactiva el envio de datos de uso y diagnostico" }
        "Personalizacion de anuncios/datos"   = @{ Key = "PersonalizationReportingEnabled";          Val = 0; Opp = 1; T = "DWord"; Desc = "No envia datos de navegacion para personalizar anuncios/servicios" }
        "Actualizacion de componentes"        = @{ Key = "ComponentUpdatesEnabled";                  Val = 0; Opp = 1; T = "DWord"; Desc = "Bloquea la actualizacion automatica de componentes internos" }
        "Mejorar busqueda/navegacion (datos)" = @{ Key = "SearchSuggestEnabled";                     Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva sugerencias de busqueda (envian datos a Bing)" }
    }

    "Privacidad y rastreo" = [ordered]@{
        "Seguimiento de navegacion (Bing)"    = @{ Key = "ConfigureDoNotTrack";                      Val = 1; Opp = 0; T = "DWord"; Desc = "Activa Do Not Track para todos los sitios" }
        "Sincronizacion de navegacion"        = @{ Key = "SyncDisabled";                             Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva la sincronizacion con cuenta Microsoft" }
        "Autocompletar formularios"           = @{ Key = "AutofillAddressEnabled";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el autocompletado de direcciones" }
        "Autocompletar tarjetas"              = @{ Key = "AutofillCreditCardEnabled";                Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el guardado de tarjetas de credito" }
        "Historial de navegacion en sync"     = @{ Key = "SavingBrowserHistoryDisabled";             Val = 1; Opp = 0; T = "DWord"; Desc = "Impide que Edge guarde el historial de navegacion" }
    }

    "Inicio de sesion y cuentas" = [ordered]@{
        "Perfil no removible (MSA)"           = @{ Key = "NonRemovableProfileEnabled";               Val = 0; Opp = 1; T = "DWord"; Desc = "Evita perfiles no removibles con cuenta Microsoft" }
        "Forzar inicio de sesion"             = @{ Key = "BrowserSignin";                            Val = 0; Opp = 2; T = "DWord"; Desc = "Desactiva el inicio de sesion en el navegador" }
        "Compras y cupones (Shopping)"        = @{ Key = "EdgeShoppingAssistantEnabled";             Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el asistente de compras integrado de Edge" }
        "Microsoft Rewards en Edge"           = @{ Key = "ShowMicrosoftRewards";                     Val = 0; Opp = 1; T = "DWord"; Desc = "Oculta las Recompensas de Microsoft en Edge" }
    }

    "Funciones innecesarias" = [ordered]@{
        "Barra lateral (Edge Sidebar)"        = @{ Key = "HubsSidebarEnabled";                      Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la barra lateral con apps de Edge" }
        "Colecciones (Collections)"           = @{ Key = "EdgeCollectionsEnabled";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la funcion de Colecciones de Edge" }
        "Juegos (Games menu)"                 = @{ Key = "AllowGamesMenu";                           Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el menu de juegos en Edge" }
        "Mini menu al seleccionar texto"      = @{ Key = "MiniMenuEnabled";                          Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el mini menu flotante al seleccionar texto" }
        "Drop (enviar archivos a ti mismo)"   = @{ Key = "EdgeEDropEnabled";                         Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la funcion Drop (enviarte archivos/notas)" }
    }

    "Seguridad y SmartScreen" = [ordered]@{
        "SmartScreen (filtro anti-phishing)"  = @{ Key = "SmartScreenEnabled";                       Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva SmartScreen (envio de URLs a Microsoft)" }
        "SmartScreen para descargas"          = @{ Key = "SmartScreenForTrustedDownloadsEnabled";    Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva verificacion SmartScreen en descargas" }
        "Bloqueo de scareware"                = @{ Key = "ScarewareBlockerProtectionEnabled";        Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el bloqueo de scareware de Edge" }
        "Proteccion de contrasena (online)"   = @{ Key = "PasswordMonitorAllowed";                   Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el monitoreo de contrasenas filtradas" }
    }
}

# ─── Helpers ─────────────────────────────────────────────────────────────────
function New-FlatButton {
    param([string]$Text, [Drawing.Point]$Pos, [Drawing.Size]$Size, [Drawing.Color]$Fg)
    $btn = [Windows.Forms.Button]::new()
    $btn.Text      = $Text
    $btn.Location  = $Pos
    $btn.Size      = $Size
    $btn.Font      = $FONT_BODY
    $btn.FlatStyle = "Flat"
    $btn.ForeColor = $Fg
    $btn.BackColor = [Drawing.Color]::FromArgb(32, 32, 32)
    $btn.FlatAppearance.BorderColor            = $BORDER
    $btn.FlatAppearance.BorderSize             = 1
    $btn.FlatAppearance.MouseOverBackColor     = [Drawing.Color]::FromArgb(45, 45, 45)
    $btn.FlatAppearance.MouseDownBackColor     = [Drawing.Color]::FromArgb(18, 18, 18)
    $btn.Cursor = [Windows.Forms.Cursors]::Hand
    return $btn
}

function Get-PolicyState {
    param([string]$Key)
    try {
        $value = Get-ItemProperty -Path $REG_PATH -Name $Key -ErrorAction SilentlyContinue
        if ($null -ne $value) { return $value.$Key }
    } catch {}
    return $null
}

function Update-CurrentState {
    foreach ($group in $GROUPS.Keys) {
        foreach ($name in $GROUPS[$group].Keys) {
            $p = $GROUPS[$group][$name]
            $currentValue = Get-PolicyState -Key $p.Key
            $cb  = $script:checks[$name]
            $lbl = $script:labels[$name]
            if ($currentValue -eq $p.Val) {
                $cb.Checked      = $true
                $lbl.ForeColor   = $GREEN
            } elseif ($null -eq $currentValue) {
                $cb.Checked      = $false
                $lbl.ForeColor   = $FG
            } else {
                $cb.Checked      = $false
                $lbl.ForeColor   = $RED
            }
        }
    }
}

function Set-Policies {
    $ok = 0; $fail = 0; $removed = 0
    foreach ($group in $GROUPS.Keys) {
        foreach ($name in $GROUPS[$group].Keys) {
            $p = $GROUPS[$group][$name]
            $isChecked    = $script:checks[$name].Checked
            $currentValue = Get-PolicyState -Key $p.Key
            if ($isChecked) {
                try {
                    Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force
                    $ok++
                } catch { $fail++ }
            } elseif ($currentValue -eq $p.Val) {
                try {
                    Remove-ItemProperty -Path $REG_PATH -Name $p.Key -Force -ErrorAction Stop
                    $removed++
                } catch { $fail++ }
            }
        }
    }
    return $ok, $fail, $removed
}

# ─── Construccion de UI ───────────────────────────────────────────────────────
$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.Size            = [Drawing.Size]::new(420, 600)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $DARK
$form.ForeColor       = $FG
$form.Font            = $FONT_BODY
$form.MaximizeBox     = $false
$form.FormBorderStyle = "FixedDialog"

# ── Header ──
$header = [Windows.Forms.Panel]::new()
$header.Size      = [Drawing.Size]::new(420, 48)
$header.Location  = [Drawing.Point]::new(0, 0)
$header.BackColor = $PANEL
$form.Controls.Add($header)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = "EdgeControl"
$lblTitle.Font      = [Drawing.Font]::new("Segoe UI", 13, [Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $ACCENT
$lblTitle.Location  = [Drawing.Point]::new(20, 12)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = "Politicas de Microsoft Edge via registro"
$lblSub.Font      = [Drawing.Font]::new("Segoe UI", 8)
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(145, 18)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)


# Separador cabecera
$sepTop = [Windows.Forms.Panel]::new()
$sepTop.Size      = [Drawing.Size]::new(386, 1)
$sepTop.Location  = [Drawing.Point]::new(16, 58)
$sepTop.BackColor = $BORDER
$form.Controls.Add($sepTop)

# ── Panel scrollable de politicas ──
$scrollPanel = [Windows.Forms.Panel]::new()
$scrollPanel.Location   = [Drawing.Point]::new(16, 60)
$scrollPanel.Size       = [Drawing.Size]::new(386, 420)
$scrollPanel.BackColor  = $PANEL
$scrollPanel.AutoScroll = $true
$form.Controls.Add($scrollPanel)

$script:checks = [ordered]@{}
$script:labels = [ordered]@{}
$script:descs  = [ordered]@{}

$yGlobal = 10

foreach ($group in $GROUPS.Keys) {

    # ── Cabecera de grupo ──
    $groupPanel = [Windows.Forms.Panel]::new()
    $groupPanel.Size      = [Drawing.Size]::new(370, 26)
    $groupPanel.Location  = [Drawing.Point]::new(8, $yGlobal)
    $groupPanel.BackColor = [Drawing.Color]::FromArgb(26, 26, 26)
    $scrollPanel.Controls.Add($groupPanel)

    $grpLine = [Windows.Forms.Panel]::new()
    $grpLine.Size      = [Drawing.Size]::new(3, 26)
    $grpLine.Location  = [Drawing.Point]::new(0, 0)
    $grpLine.BackColor = $ACCENT
    $groupPanel.Controls.Add($grpLine)

    $grpLabel = [Windows.Forms.Label]::new()
    $grpLabel.Text      = $group.ToUpper()
    $grpLabel.Font      = $FONT_HEADER
    $grpLabel.ForeColor = $ACCENT
    $grpLabel.Location  = [Drawing.Point]::new(12, 5)
    $grpLabel.AutoSize  = $true
    $groupPanel.Controls.Add($grpLabel)

    $yGlobal += 30

    foreach ($name in $GROUPS[$group].Keys) {
        $p = $GROUPS[$group][$name]

        # Fila alternante
        $rowBg = if (($script:checks.Count % 2) -eq 0) { $PANEL } else { $PANEL2 }
        $row = [Windows.Forms.Panel]::new()
        $row.Size      = [Drawing.Size]::new(370, 40)
        $row.Location  = [Drawing.Point]::new(8, $yGlobal)
        $row.BackColor = $rowBg
        $scrollPanel.Controls.Add($row)

        # Checkbox
        $cb = [Windows.Forms.CheckBox]::new()
        $cb.Text      = ""
        $cb.Location  = [Drawing.Point]::new(10, 11)
        $cb.Size      = [Drawing.Size]::new(18, 18)
        $cb.FlatStyle = "Flat"
        $cb.Cursor    = [Windows.Forms.Cursors]::Hand
        $cb.Tag       = $name
        $cb.Add_CheckedChanged({
            $n = $this.Tag
            $script:labels[$n].ForeColor = if ($this.Checked) { $GREEN } else { $FG }
        }.GetNewClosure())
        $row.Controls.Add($cb)
        $script:checks[$name] = $cb

        # Nombre de la politica
        $lbl = [Windows.Forms.Label]::new()
        $lbl.Text      = $name
        $lbl.Location  = [Drawing.Point]::new(34, 6)
        $lbl.Size      = [Drawing.Size]::new(320, 16)
        $lbl.ForeColor = $FG
        $lbl.Font      = $FONT_BODY
        $lbl.Cursor    = [Windows.Forms.Cursors]::Hand
        $lbl.Tag       = $name
        $lbl.Add_Click({ $script:checks[$this.Tag].Checked = !$script:checks[$this.Tag].Checked }.GetNewClosure())
        $row.Controls.Add($lbl)
        $script:labels[$name] = $lbl

        # Descripcion corta
        $desc = [Windows.Forms.Label]::new()
        $desc.Text      = $p.Desc
        $desc.Location  = [Drawing.Point]::new(34, 24)
        $desc.Size      = [Drawing.Size]::new(350, 14)
        $desc.ForeColor = $MUTED
        $desc.Font      = $FONT_SMALL
        $row.Controls.Add($desc)
        $script:descs[$name] = $desc

        # Clave del registro (tooltip)
        $tt = [Windows.Forms.ToolTip]::new()
        $tt.SetToolTip($lbl, "Clave: $($p.Key)")
        $tt.SetToolTip($desc, "Clave: $($p.Key)")

        $yGlobal += 42
    }

    $yGlobal += 6  # Espacio entre grupos
}

# Separador inferior
$sepBottom = [Windows.Forms.Panel]::new()
$sepBottom.Size      = [Drawing.Size]::new(386, 1)
$sepBottom.Location  = [Drawing.Point]::new(16, 480)
$sepBottom.BackColor = $BORDER
$form.Controls.Add($sepBottom)

# ── Botones ──
$btnSelectAll = New-FlatButton "Sel. todo"  ([Drawing.Point]::new(60,  500)) ([Drawing.Size]::new(90, 30)) ([Drawing.Color]::FromArgb(140, 140, 140))
$btnApply     = New-FlatButton "Aplicar"    ([Drawing.Point]::new(160, 500)) ([Drawing.Size]::new(90, 30)) $GREEN
$btnReset     = New-FlatButton "Deselect."  ([Drawing.Point]::new(260, 500)) ([Drawing.Size]::new(90, 30)) $RED
$form.Controls.AddRange(@($btnSelectAll, $btnApply, $btnReset))

# Barra de estado
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 540)
$script:status.Size      = [Drawing.Size]::new(386, 16)
$script:status.ForeColor = $MUTED
$script:status.Font      = [Drawing.Font]::new("Segoe UI", 7.5)
$script:status.Text      = "Listo."
$form.Controls.Add($script:status)

# ── Cargar estado inicial ──
Update-CurrentState

# ── Eventos de botones ──
$btnSelectAll.Add_Click({
    foreach ($cb in $script:checks.Values) { $cb.Checked = $true }
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las politicas seleccionadas."
})

$btnReset.Add_Click({
    foreach ($cb in $script:checks.Values) { $cb.Checked = $false }
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Seleccion limpiada."
})

$btnApply.Add_Click({
    $ok, $fail, $removed = Set-Policies
    Update-CurrentState
    $msg = "Aplicadas $ok politicas"
    if ($removed -gt 0) { $msg += ", eliminadas $removed" }
    if ($fail -gt 0)    { $msg += ", $fail errores" }
    $msg += ". Reinicia Microsoft Edge para que surtan efecto."
    $script:status.ForeColor = $GREEN
    $script:status.Text = $msg
})

[void]$form.ShowDialog()
