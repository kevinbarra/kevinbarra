<#
==============================================================================
  DIAGNOSTICO-PC.PS1  ·  Warzone competitivo (Kevin)
------------------------------------------------------------------------------
  QUE HACE: recopila la informacion clave de tu PC para hacer un analisis de
  optimizacion 100% personalizado (CPU/GPU, RAM y si EXPO esta activo, el
  Windows "Kernel OS" real, Secure Boot/TPM para el anti-cheat de Warzone,
  VBS, plan de energia, drivers, monitores, etc.).

  ES 100% SEGURO Y SOLO-LECTURA: no cambia NADA de tu sistema. Solo lee datos
  y los escribe en un .txt en tu Escritorio para que me lo pegues.

  COMO EJECUTARLO:
    1) Boton derecho en el menu Inicio  ->  "Terminal (Administrador)"
       (con admin sale mas info: Secure Boot, TPM y VBS).
    2) Pega y ejecuta esta linea para permitir el script solo en esta sesion:
         Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    3) Ve a la carpeta donde este el archivo, por ejemplo:
         cd $HOME\Downloads
    4) Ejecutalo:
         .\diagnostico-pc.ps1
    5) Se abrira/creara  reporte-warzone.txt  en tu Escritorio. Pegame TODO
       su contenido aqui en el chat.
==============================================================================
#>

$ErrorActionPreference = 'SilentlyContinue'

# --- Salida a consola Y a un archivo en el Escritorio -------------------------
$desktop = [Environment]::GetFolderPath('Desktop')
if ([string]::IsNullOrWhiteSpace($desktop)) { $desktop = $HOME }
$outFile = Join-Path $desktop 'reporte-warzone.txt'
$script:lines = New-Object System.Collections.Generic.List[string]

function W([string]$text = '') {
    $script:lines.Add($text)
    Write-Host $text
}
function Section([string]$title) {
    W ''
    W ('=' * 74)
    W ("  $title")
    W ('=' * 74)
}
function KV([string]$k, $v) {
    if ($null -eq $v -or "$v" -eq '') { $v = '(no disponible)' }
    W ("  {0,-26}: {1}" -f $k, $v)
}

# --- Admin? -------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

Section 'REPORTE DE DIAGNOSTICO - WARZONE'
KV 'Generado'      (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
KV 'Ejecutado como admin' ($(if ($isAdmin) { 'SI' } else { 'NO (algunos datos saldran vacios: relanza como Administrador)' }))
KV 'Equipo'        $env:COMPUTERNAME
KV 'Usuario'       $env:USERNAME

# --- SISTEMA OPERATIVO (identificar el "Kernel OS") ---------------------------
Section 'SISTEMA OPERATIVO  (que es realmente el "Kernel OS")'
$os  = Get-CimInstance Win32_OperatingSystem
$cv  = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
KV 'Nombre'        $os.Caption
KV 'Version/Build' ("{0}  (build {1})" -f $os.Version, $os.BuildNumber)
KV 'DisplayVersion' (Get-ItemPropertyValue $cv 'DisplayVersion')          # 24H2 / 25H2
KV 'UBR (parche)'  (Get-ItemPropertyValue $cv 'UBR')
KV 'ProductName'   (Get-ItemPropertyValue $cv 'ProductName')
KV 'EditionID'     (Get-ItemPropertyValue $cv 'EditionID')
KV 'BuildLab'      (Get-ItemPropertyValue $cv 'BuildLabEx')
KV 'RegisteredOrg' (Get-ItemPropertyValue $cv 'RegisteredOrganization')   # pistas de ISO modificada
KV 'Instalado el'  $os.InstallDate
KV 'Ultimo arranque' $os.LastBootUpTime
KV 'Arquitectura'  $os.OSArchitecture

# --- CPU ----------------------------------------------------------------------
Section 'CPU'
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
KV 'Modelo'        $cpu.Name
KV 'Nucleos/Hilos' ("{0} nucleos / {1} hilos" -f $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors)
KV 'Reloj base'    ("{0} MHz" -f $cpu.MaxClockSpeed)
KV 'Socket'        $cpu.SocketDesignation

# --- GPU ----------------------------------------------------------------------
Section 'GPU (tarjeta grafica) y DRIVER'
foreach ($g in (Get-CimInstance Win32_VideoController)) {
    W ''
    KV 'Modelo'        $g.Name
    KV 'VRAM (aprox)'  ($(if ($g.AdapterRAM) { "{0:N0} MB" -f ($g.AdapterRAM/1MB) } else { '(usa GPU-Z para VRAM real)' }))
    KV 'Version driver' $g.DriverVersion
    KV 'Fecha driver'  $g.DriverDate
    KV 'Resolucion actual' ("{0} x {1} @ {2} Hz" -f $g.CurrentHorizontalResolution, $g.CurrentVerticalResolution, $g.CurrentRefreshRate)
}

# --- RAM  (clave: detectar si EXPO/perfil XMP esta activo) --------------------
Section 'RAM  (revisar si EXPO esta ACTIVO)'
$mem = Get-CimInstance Win32_PhysicalMemory
$totalGB = [math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB, 1)
KV 'RAM total'     ("{0} GB  ({1} modulos)" -f $totalGB, ($mem | Measure-Object).Count)
$i = 0
foreach ($m in $mem) {
    $i++
    $rated  = $m.Speed             # velocidad nominal del modulo (SPD/rated)
    $actual = $m.ConfiguredClockSpeed  # velocidad a la que corre AHORA
    W ''
    KV "Modulo $i"     ("{0} {1}" -f $m.Manufacturer, $m.PartNumber)
    KV '  Rated (kit)' ("{0} MT/s" -f $rated)
    KV '  Corriendo a' ("{0} MT/s" -f $actual)
    if ($actual -and $rated -and $actual -lt ($rated - 200)) {
        KV '  >>> AVISO'  "Corre por debajo de lo rated -> probablemente EXPO/XMP DESACTIVADO en BIOS"
    } elseif ($actual -and ($actual -le 4800)) {
        KV '  >>> AVISO'  "A 4800 o menos -> tipico de DDR5 SIN EXPO. Activa EXPO en BIOS."
    }
}

# --- PLACA / BIOS -------------------------------------------------------------
Section 'PLACA BASE / BIOS'
$bb = Get-CimInstance Win32_BaseBoard
$bios = Get-CimInstance Win32_BIOS
KV 'Placa'         ("{0} {1}" -f $bb.Manufacturer, $bb.Product)
KV 'BIOS version'  ($bios.SMBIOSBIOSVersion)
KV 'BIOS fecha'    ($bios.ReleaseDate)

# --- ANTI-CHEAT GATING: Secure Boot / TPM / UEFI / GPT ------------------------
Section 'ANTI-CHEAT (Ricochet exige Secure Boot + TPM 2.0)'
# Secure Boot
$sb = $null
try { $sb = Confirm-SecureBootUEFI } catch { $sb = $null }
if ($sb -eq $true)      { KV 'Secure Boot' 'ACTIVADO  (bien - requerido por Warzone)' }
elseif ($sb -eq $false) { KV 'Secure Boot' '>>> DESACTIVADO  (te bloquea Ranked/competitivo - ACTIVAR)' }
else                    { KV 'Secure Boot' '(no se pudo leer: relanza como Admin, o el equipo arranca en BIOS/Legacy)' }

# Modo de firmware UEFI vs Legacy
$fw = $env:firmware_type
if (-not $fw) { $fw = (Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType }
KV 'Modo firmware' ($(if ($fw) { $fw } else { '(desconocido)' }) + '  (necesita UEFI, no Legacy/BIOS/CSM)')

# TPM
$tpm = Get-Tpm
if ($tpm) {
    KV 'TPM presente'  $tpm.TpmPresent
    KV 'TPM activado'  $tpm.TpmEnabled
    KV 'TPM listo'     $tpm.TpmReady
} else {
    KV 'TPM' '(no se pudo leer: relanza como Admin)'
}
try {
    $tpm2 = Get-CimInstance -Namespace 'root/cimv2/security/microsofttpm' -ClassName Win32_Tpm
    KV 'TPM version spec' ($tpm2.SpecVersion)   # debe empezar por 2.0
} catch {}

# Disco del SO: GPT vs MBR (MBR bloquea Secure Boot)
try {
    $sysDisk = Get-Disk | Where-Object { $_.IsBoot -or $_.IsSystem } | Select-Object -First 1
    KV 'Estilo particion SO' ("{0}  (debe ser GPT, no MBR)" -f $sysDisk.PartitionStyle)
} catch {}

# --- VBS / INTEGRIDAD DE MEMORIA (la palanca real de FPS) ---------------------
Section 'VBS / INTEGRIDAD DE MEMORIA (Core Isolation)'
try {
    $dg = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace 'root/Microsoft/Windows/DeviceGuard'
    $vbsMap = @{ 0 = 'No habilitado'; 1 = 'Habilitado pero NO corriendo'; 2 = 'Habilitado y CORRIENDO' }
    KV 'VBS estado'    ($vbsMap[[int]$dg.VirtualizationBasedSecurityStatus])
    $running = @($dg.SecurityServicesRunning)
    KV 'HVCI/Memory Integrity' ($(if ($running -contains 2) { '>>> ACTIVADA (te cuesta ~5-15% FPS -> considera DESACTIVAR)' } else { 'Desactivada (bien para FPS)' }))
} catch { KV 'VBS' '(no se pudo leer)' }
$hvciReg = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' 'Enabled'
KV 'HVCI (registro)' ($(if ($hvciReg -eq 1) { 'Enabled=1 (activada)' } elseif ($hvciReg -eq 0) { 'Enabled=0 (desactivada)' } else { '(sin valor)' }))

# --- HAGS / GAME MODE / GAME BAR / GAME DVR -----------------------------------
Section 'WINDOWS: HAGS / Game Mode / Game Bar / DVR'
$hags = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode'
KV 'HAGS (HwSchMode)' ($(switch ($hags) { 2 { 'ACTIVADO (2)' } 1 { 'Desactivado (1)' } default { '(sin valor)' } }))
$gm = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\GameBar' 'AutoGameModeEnabled'
KV 'Game Mode' ($(if ($gm -eq 1) { 'Activado' } elseif ($gm -eq 0) { 'Desactivado' } else { '(por defecto)' }))
$dvr = Get-ItemPropertyValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled'
KV 'Game DVR' ($(if ($dvr -eq 0) { 'Desactivado (bien)' } elseif ($dvr -eq 1) { '>>> Activado (desactivar)' } else { '(por defecto)' }))

# --- PLAN DE ENERGIA ----------------------------------------------------------
Section 'PLAN DE ENERGIA'
$scheme = (powercfg /getactivescheme) 2>$null
KV 'Plan activo' ($(if ($scheme) { ($scheme -replace '^.*:\s*','').Trim() } else { '(no disponible)' }))
W '  (Recomendado: "Maximo rendimiento" o "Ultimate Performance")'

# --- DEFENDER -----------------------------------------------------------------
Section 'SEGURIDAD (Windows Defender)'
try {
    $mp = Get-MpComputerStatus
    KV 'Antivirus activo'  $mp.AntivirusEnabled
    KV 'Proteccion tiempo real' $mp.RealTimeProtectionEnabled
    KV 'Tamper Protection' $mp.IsTamperProtected
} catch { KV 'Defender' '>>> No responde: puede estar ELIMINADO por el Windows custom (riesgo de seguridad)' }

# --- DISCOS -------------------------------------------------------------------
Section 'ALMACENAMIENTO (Warzone debe ir en NVMe)'
try {
    foreach ($d in (Get-PhysicalDisk)) {
        KV $d.FriendlyName ("{0}  ·  {1:N0} GB  ·  Tipo bus: {2}" -f $d.MediaType, ($d.Size/1GB), $d.BusType)
    }
} catch {}
W ''
foreach ($v in (Get-Volume | Where-Object { $_.DriveLetter -and $_.FileSystem })) {
    KV ("Unidad " + $v.DriveLetter) ("{0:N0} GB libres de {1:N0} GB" -f ($v.SizeRemaining/1GB), ($v.Size/1GB))
}

# --- MONITORES (refrescos) ----------------------------------------------------
Section 'MONITORES (240 Hz principal / revisar el secundario a 60 Hz)'
foreach ($g in (Get-CimInstance Win32_VideoController | Where-Object { $_.CurrentRefreshRate })) {
    KV $g.Name ("{0} x {1} @ {2} Hz" -f $g.CurrentHorizontalResolution, $g.CurrentVerticalResolution, $g.CurrentRefreshRate)
}
W '  NOTA: Windows muestra el refresco por salida en Config > Sistema > Pantalla >'
W '  Pantalla avanzada. Confirma que el Samsung este a 240 Hz y sube el ASUS de 60 Hz'
W '  a su maximo real si lo soporta.'

# --- RICOCHET DRIVER ----------------------------------------------------------
Section 'DRIVER ANTI-CHEAT (atvi-brynhildr)'
$atvi = (driverquery 2>$null | Select-String -SimpleMatch 'atvi-brynhildr')
if ($atvi) { KV 'atvi-brynhildr' 'Presente (Ricochet cargado alguna vez)' }
else { W '  No aparece ahora mismo. Es NORMAL si Warzone esta cerrado (el driver solo carga con el juego abierto).' }

# --- APPS DE INICIO (bloat / overlays) ----------------------------------------
Section 'APPS DE INICIO (posibles overlays/bloat en 2do plano)'
try {
    $startup = Get-CimInstance Win32_StartupCommand | Select-Object -ExpandProperty Name -Unique
    KV 'Cantidad' (@($startup).Count)
    foreach ($s in ($startup | Select-Object -First 25)) { W "   - $s" }
} catch {}

# --- FIN ----------------------------------------------------------------------
Section 'FIN'
W '  Copia TODO este texto (o el archivo del Escritorio) y pegamelo en el chat.'
W '  Archivo guardado en:'
W "     $outFile"

# Guardar archivo
try {
    $script:lines | Out-File -FilePath $outFile -Encoding UTF8 -Force
    Write-Host ''
    Write-Host "==> Reporte guardado en: $outFile" -ForegroundColor Green
    try { Start-Process notepad.exe $outFile } catch {}
} catch {
    Write-Host "No se pudo guardar el archivo en $outFile : $_" -ForegroundColor Yellow
}
