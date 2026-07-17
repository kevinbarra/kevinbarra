<#
==============================================================================
  APLICAR-AJUSTES-GAMING.PS1  -  Optimizacion "gaming-only" (reversible)
------------------------------------------------------------------------------
  QUE HACE: aplica los ajustes de rendimiento que TIENEN SENTIDO en una PC
  casi solo para gaming (tu caso: programas en Mac). Es INTERACTIVO: pregunta
  antes de CADA cambio, guarda el valor anterior y genera un script para
  revertir todo (revertir-ajustes.ps1 en tu Escritorio).

  QUE NO HACE:
    - NO toca el juego ni el anti-cheat (Ricochet/Vanguard). Solo cambia
      ajustes de Windows.
    - NO quita Secure Boot, TPM ni nada que necesite Warzone para lanzar.
    - NO borra apps de inicio por su cuenta (eso lo haces tu a mano en el
      Administrador de tareas; te lo recuerda al final).

  CAMBIOS QUE OFRECE (uno por uno, tu decides s/n):
    1) VBS / hypervisor OFF ....... ~5-15% FPS en juegos CPU-bound.
                                    (Desactiva Hyper-V/WSL2/Docker: aqui no los usas.)
    2) HAGS ON .................... Programacion de GPU por hardware (ayuda a Reflex).
    3) Game Mode ON .............. Prioriza el juego en primer plano.
    4) Plan Ultimate Performance .. Sin core parking/downclocks.

  COMO USARLO (requiere Administrador):
    1) Boton derecho en Inicio -> "Terminal (Administrador)".
    2) Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    3) cd $HOME\Downloads
    4) .\aplicar-ajustes-gaming.ps1
    5) Responde s/n a cada cambio. Reinicia al terminar (el VBS lo pide).
  REVERTIR: ejecuta  .\revertir-ajustes.ps1  (se crea en tu Escritorio).
==============================================================================
#>

$ErrorActionPreference = 'SilentlyContinue'

# --- Requiere admin ------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: abre la Terminal como ADMINISTRADOR y vuelve a ejecutarlo." -ForegroundColor Red
    return
}

$desktop = [Environment]::GetFolderPath('Desktop'); if (-not $desktop) { $desktop = $HOME }
$revFile = Join-Path $desktop 'revertir-ajustes.ps1'
$revLines = New-Object System.Collections.Generic.List[string]
$revLines.Add('# revertir-ajustes.ps1 - restaura el estado previo a aplicar-ajustes-gaming.ps1')
$revLines.Add('# Ejecutar en Terminal (Administrador). Reinicia al terminar.')
$revLines.Add('$ErrorActionPreference = "SilentlyContinue"')

function Ask([string]$q) {
    Write-Host ""
    Write-Host $q -ForegroundColor Cyan
    $r = Read-Host "   Aplicar? (s/n)"
    return ($r -match '^[sSyY]')
}
function Rev([string]$line) { $revLines.Add($line) }

Clear-Host
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  AJUSTES GAMING (reversibles) - responde s/n a cada uno" -ForegroundColor Cyan
Write-Host "  Se creara revertir-ajustes.ps1 en tu Escritorio." -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

# =============================================================================
# 1) VBS / hypervisor OFF
# =============================================================================
if (Ask "1) Desactivar VBS / hypervisor (Core Isolation)?  -> ~5-15% FPS. Desactiva Hyper-V/WSL2/Docker (aqui no los usas).") {
    # Estado previo del hypervisorlaunchtype
    $bcd = bcdedit /enum '{current}' 2>$null | Select-String 'hypervisorlaunchtype'
    $prevHv = if ($bcd) { ($bcd -replace '.*hypervisorlaunchtype\s+','').Trim() } else { 'Auto' }
    if (-not $prevHv) { $prevHv = 'Auto' }

    # Backup reg DeviceGuard
    $dgPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard'
    $prevVbs  = (Get-ItemProperty $dgPath -Name 'EnableVirtualizationBasedSecurity' -EA SilentlyContinue).EnableVirtualizationBasedSecurity
    $hvciPath = "$dgPath\Scenarios\HypervisorEnforcedCodeIntegrity"
    $prevHvci = (Get-ItemProperty $hvciPath -Name 'Enabled' -EA SilentlyContinue).Enabled

    # Aplicar
    bcdedit /set hypervisorlaunchtype off | Out-Null
    if (-not (Test-Path $dgPath)) { New-Item -Path $dgPath -Force | Out-Null }
    New-ItemProperty -Path $dgPath -Name 'EnableVirtualizationBasedSecurity' -PropertyType DWord -Value 0 -Force | Out-Null
    if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
    New-ItemProperty -Path $hvciPath -Name 'Enabled' -PropertyType DWord -Value 0 -Force | Out-Null

    # Revert
    Rev "bcdedit /set hypervisorlaunchtype $prevHv | Out-Null"
    if ($null -ne $prevVbs)  { Rev "New-ItemProperty -Path '$dgPath' -Name 'EnableVirtualizationBasedSecurity' -PropertyType DWord -Value $prevVbs -Force | Out-Null" }
    else                     { Rev "Remove-ItemProperty -Path '$dgPath' -Name 'EnableVirtualizationBasedSecurity' -EA SilentlyContinue" }
    if ($null -ne $prevHvci) { Rev "New-ItemProperty -Path '$hvciPath' -Name 'Enabled' -PropertyType DWord -Value $prevHvci -Force | Out-Null" }
    else                     { Rev "Remove-ItemProperty -Path '$hvciPath' -Name 'Enabled' -EA SilentlyContinue" }

    Write-Host "   OK: VBS/hypervisor desactivado (efecto tras REINICIAR)." -ForegroundColor Green
} else { Write-Host "   Saltado." -ForegroundColor DarkGray }

# =============================================================================
# 2) HAGS ON
# =============================================================================
if (Ask "2) Activar HAGS (Programacion de GPU acelerada por hardware)?") {
    $gp = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
    $prev = (Get-ItemProperty $gp -Name 'HwSchMode' -EA SilentlyContinue).HwSchMode
    New-ItemProperty -Path $gp -Name 'HwSchMode' -PropertyType DWord -Value 2 -Force | Out-Null
    if ($null -ne $prev) { Rev "New-ItemProperty -Path '$gp' -Name 'HwSchMode' -PropertyType DWord -Value $prev -Force | Out-Null" }
    else                 { Rev "Remove-ItemProperty -Path '$gp' -Name 'HwSchMode' -EA SilentlyContinue" }
    Write-Host "   OK: HAGS = ON (efecto tras REINICIAR)." -ForegroundColor Green
} else { Write-Host "   Saltado." -ForegroundColor DarkGray }

# =============================================================================
# 3) Game Mode ON
# =============================================================================
if (Ask "3) Activar Game Mode de Windows?") {
    $gb = 'HKCU:\SOFTWARE\Microsoft\GameBar'
    if (-not (Test-Path $gb)) { New-Item -Path $gb -Force | Out-Null }
    $prev = (Get-ItemProperty $gb -Name 'AutoGameModeEnabled' -EA SilentlyContinue).AutoGameModeEnabled
    New-ItemProperty -Path $gb -Name 'AutoGameModeEnabled' -PropertyType DWord -Value 1 -Force | Out-Null
    if ($null -ne $prev) { Rev "New-ItemProperty -Path '$gb' -Name 'AutoGameModeEnabled' -PropertyType DWord -Value $prev -Force | Out-Null" }
    else                 { Rev "Remove-ItemProperty -Path '$gb' -Name 'AutoGameModeEnabled' -EA SilentlyContinue" }
    Write-Host "   OK: Game Mode = ON." -ForegroundColor Green
} else { Write-Host "   Saltado." -ForegroundColor DarkGray }

# =============================================================================
# 4) Plan Ultimate Performance
# =============================================================================
if (Ask "4) Activar plan de energia 'Ultimate Performance'?") {
    $prevScheme = ((powercfg /getactivescheme) -replace '^.*:\s*([0-9a-fA-F-]+).*$','$1').Trim()
    $ult = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    powercfg -duplicatescheme $ult | Out-Null
    powercfg /setactive $ult | Out-Null
    if ($prevScheme -match '^[0-9a-fA-F-]{36}$') { Rev "powercfg /setactive $prevScheme | Out-Null" }
    Write-Host "   OK: Ultimate Performance activo." -ForegroundColor Green
} else { Write-Host "   Saltado." -ForegroundColor DarkGray }

# =============================================================================
# Guardar script de reversion
# =============================================================================
$revLines.Add('Write-Host "Revertido. Reinicia el equipo para aplicar VBS/HAGS." -ForegroundColor Green')
$revLines | Out-File -FilePath $revFile -Encoding UTF8 -Force

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  LISTO. Reinicia el equipo para que VBS/HAGS surtan efecto." -ForegroundColor Green
Write-Host "  Para deshacer TODO:  .\revertir-ajustes.ps1  (en el Escritorio)" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  RECORDATORIO (a mano, Administrador de tareas > Inicio):" -ForegroundColor Yellow
Write-Host "   - Desactiva Docker Desktop del inicio (aqui no lo usas)." -ForegroundColor Yellow
Write-Host "   - Deja UN solo software RGB (SignalRGB o iCUE)." -ForegroundColor Yellow
Write-Host "   - Quita launchers que no uses del arranque (EA/Epic/Riot/Brave/Spotify)." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Verifica despues con:  .\medir-en-vivo.ps1  (compara 1% lows antes/despues)." -ForegroundColor Cyan
