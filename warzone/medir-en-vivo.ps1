<#
==============================================================================
  MEDIR-EN-VIVO.PS1  - Telemetria en tiempo real para Warzone
------------------------------------------------------------------------------
  QUE HACE: mientras juegas, mide tu sistema "desde fuera" (sin tocar el juego)
  y al terminar te da un RESUMEN con conclusiones para saber por que vas a los
  FPS que vas: si estas GPU-bound (=> baja resolucion), si te falta VRAM, si hay
  throttle termico, o si el limite es la CPU.

  ==> 100% SEGURO PARA EL ANTI-CHEAT (Ricochet / Vanguard):
     - NO inyecta, NO hookea, NO lee la memoria de cod.exe.
     - Solo lee sensores del sistema: nvidia-smi (viene con tu driver) + las
       clases de rendimiento de Windows (WMI/CIM). Nada de esto toca al juego.
     - (Opcional -ConPresentMon: PresentMon de Intel, basado en ETW; tampoco
       inyecta. Solo se usa si TU pones el .exe junto a este script.)

  COMO USARLO:
    1) Abre Warzone y entra a una partida.
    2) Boton derecho en Inicio  ->  "Terminal (Administrador)".
    3) Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    4) cd $HOME\Downloads          (o donde tengas el script)
    5) .\medir-en-vivo.ps1                 (mide hasta que pulses ENTER)
       .\medir-en-vivo.ps1 -Minutos 25     (mide 25 min y para solo)
    6) Juega 1-2 partidas normales (deja la ventana de Terminal en 2do plano).
    7) Vuelve y pulsa ENTER. Se crea "resumen-vivo.txt" en el Escritorio.
       -> Pegame ese resumen en el chat.

  PARAMETROS:
    -Minutos <n>       Duracion fija en minutos (0 = hasta pulsar ENTER). Default 0.
    -IntervaloSeg <s>  Cada cuanto muestrea. Default 1.
    -ConPresentMon     Ademas captura FPS / 1% / 0.1% low (requiere PresentMon.exe
                       al lado del script; descargalo de
                       https://github.com/GameTechDev/PresentMon/releases ).
==============================================================================
#>
param(
    [int]$Minutos = 0,
    [double]$IntervaloSeg = 1.0,
    [switch]$ConPresentMon
)

$ErrorActionPreference = 'SilentlyContinue'
if ($IntervaloSeg -lt 0.25) { $IntervaloSeg = 0.25 }

# --- Rutas ---------------------------------------------------------------------
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$desktop   = [Environment]::GetFolderPath('Desktop'); if (-not $desktop) { $desktop = $HOME }
$csvFile   = Join-Path $desktop 'reporte-vivo-warzone.csv'
$sumFile   = Join-Path $desktop 'resumen-vivo.txt'
$pmCsv     = Join-Path $desktop 'presentmon-warzone.csv'

# --- Admin? --------------------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

# --- Localizar nvidia-smi ------------------------------------------------------
$nvsmi = $null
$c = Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
if ($c) { $nvsmi = $c.Source }
if (-not $nvsmi) {
    foreach ($p in @("$env:SystemRoot\System32\nvidia-smi.exe",
                     "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.exe")) {
        if (Test-Path $p) { $nvsmi = $p; break }
    }
}

# --- CPU: reloj base para calcular reloj efectivo ------------------------------
$cpuInfo   = Get-CimInstance Win32_Processor | Select-Object -First 1
$cpuName   = $cpuInfo.Name.Trim()
$cpuBaseMHz= [double]$cpuInfo.MaxClockSpeed
$osInfo    = Get-CimInstance Win32_OperatingSystem
$ramTotGB  = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 1)

# --- Detectar proceso del juego (solo informativo) -----------------------------
$gameNames = @('cod','ModernWarfare','ModernWarfareII','ModernWarfareIII','Warzone','BlackOps6','codbo6','bo6')
$game = Get-Process -ErrorAction SilentlyContinue | Where-Object { $gameNames -contains $_.Name } | Select-Object -First 1
$gameProcName = if ($game) { "$($game.Name).exe" } else { 'cod.exe' }

Clear-Host
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host "  MEDIR EN VIVO - Warzone (telemetria segura, sin tocar el juego)" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ("  Admin        : {0}" -f $(if ($isAdmin) {'SI'} else {'NO (recomendado SI)'}))
Write-Host ("  CPU          : {0}  (base {1} MHz)" -f $cpuName, $cpuBaseMHz)
Write-Host ("  RAM total    : {0} GB" -f $ramTotGB)
Write-Host ("  nvidia-smi   : {0}" -f $(if ($nvsmi) {'OK'} else {'NO ENCONTRADO (faltaran datos de GPU!)'}))
Write-Host ("  Juego        : {0}" -f $(if ($game) {"detectado ($gameProcName)"} else {'no detectado aun (abre Warzone)'}))
Write-Host ("  Muestreo     : cada {0}s   -  {1}" -f $IntervaloSeg, $(if ($Minutos -gt 0) {"$Minutos min"} else {'hasta pulsar ENTER'}))
Write-Host ""

# --- PresentMon (opcional, opt-in) --------------------------------------------
$pm = $null
if ($ConPresentMon) {
    $found = Get-Command PresentMon*.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { $pm = $found.Source }
    if (-not $pm) {
        $local = Get-ChildItem -Path $scriptDir -Filter 'PresentMon*.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($local) { $pm = $local.FullName }
    }
    if (-not $pm) {
        Write-Host "  [PresentMon] No lo encontre junto al script. Bajalo de:" -ForegroundColor Yellow
        Write-Host "               https://github.com/GameTechDev/PresentMon/releases" -ForegroundColor Yellow
        Write-Host "               y ponlo en: $scriptDir . Sigo solo con telemetria de hardware." -ForegroundColor Yellow
        $ConPresentMon = $false
    }
}
$pmProc = $null
if ($ConPresentMon -and $pm) {
    if (Test-Path $pmCsv) { Remove-Item $pmCsv -Force -ErrorAction SilentlyContinue }
    # PresentMon 2.x usa dobles guiones; si tu build es 1.x, cambia a un solo guion.
    $pmArgs = @('--process_name', $gameProcName, '--output_file', "`"$pmCsv`"", '--stop_existing_session', '--no_console_stats')
    $pmProc = Start-Process -FilePath $pm -ArgumentList $pmArgs -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue
    Write-Host ("  [PresentMon] Capturando FPS de {0} -> {1}" -f $gameProcName, (Split-Path $pmCsv -Leaf)) -ForegroundColor Green
    Write-Host ""
}

# --- Preparar CSV --------------------------------------------------------------
'timestamp,seg,gpu_util,gpu_temp_C,gpu_clock_MHz,gpu_power_W,vram_used_MB,vram_total_MB,cpu_util,cpu_core_max,cpu_perf_pct,cpu_clock_MHz,ram_used_GB' |
    Out-File -FilePath $csvFile -Encoding UTF8 -Force

function Get-Num([string]$s) { $d = 0.0; if ([double]::TryParse(($s -replace '[^0-9\.\-]',''), [ref]$d)) { return $d } else { return $null } }

# --- Bucle de muestreo ---------------------------------------------------------
$samples = New-Object System.Collections.Generic.List[object]
$swTotal = [Diagnostics.Stopwatch]::StartNew()
Write-Host "  Midiendo...  (pulsa ENTER para terminar)" -ForegroundColor Green
Write-Host ""

$stop = $false
while (-not $stop) {
    $iter = [Diagnostics.Stopwatch]::StartNew()
    $now  = Get-Date
    $seg  = [int]$swTotal.Elapsed.TotalSeconds

    # ---- GPU (nvidia-smi) ----
    $gUtil=$null;$gTemp=$null;$gClk=$null;$gPow=$null;$vUsed=$null;$vTot=$null
    if ($nvsmi) {
        $line = & $nvsmi --query-gpu=utilization.gpu,temperature.gpu,clocks.current.graphics,power.draw,memory.used,memory.total --format=csv,noheader,nounits 2>$null | Select-Object -First 1
        if ($line) {
            $f = $line -split ','
            if ($f.Count -ge 6) {
                $gUtil=Get-Num $f[0]; $gTemp=Get-Num $f[1]; $gClk=Get-Num $f[2]
                $gPow =Get-Num $f[3]; $vUsed=Get-Num $f[4]; $vTot=Get-Num $f[5]
            }
        }
    }

    # ---- CPU (WMI perf, language-neutral) ----
    $cUtil=$null;$cCoreMax=$null;$cPerf=$null;$cClk=$null
    $proc = Get-CimInstance Win32_PerfFormattedData_Counters_ProcessorInformation -ErrorAction SilentlyContinue
    if ($proc) {
        $tot = $proc | Where-Object { $_.Name -eq '_Total' } | Select-Object -First 1
        if ($tot) {
            $cUtil = [double]$tot.PercentProcessorUtility
            $cPerf = [double]$tot.PercentProcessorPerformance
            $cClk  = [math]::Round($cpuBaseMHz * $cPerf / 100.0, 0)
        }
        $cores = $proc | Where-Object { $_.Name -notlike '*_Total*' }
        if ($cores) { $cCoreMax = [math]::Round((($cores | Measure-Object PercentProcessorUtility -Maximum).Maximum), 0) }
    }

    # ---- RAM ----
    $osC = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $ramUsedGB = if ($osC) { [math]::Round(($osC.TotalVisibleMemorySize - $osC.FreePhysicalMemory)/1MB, 1) } else { $null }

    # ---- Guardar ----
    $row = [pscustomobject]@{
        gpu_util=$gUtil; gpu_temp=$gTemp; gpu_clk=$gClk; gpu_pow=$gPow; vram=$vUsed; vramtot=$vTot
        cpu_util=$cUtil; cpu_core=$cCoreMax; cpu_perf=$cPerf; cpu_clk=$cClk; ram=$ramUsedGB
    }
    $samples.Add($row)
    ('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}' -f `
        $now.ToString('HH:mm:ss'), $seg, $gUtil, $gTemp, $gClk, $gPow, $vUsed, $vTot, $cUtil, $cCoreMax, $cPerf, $cClk, $ramUsedGB) |
        Add-Content -Path $csvFile -Encoding UTF8

    # ---- Linea en vivo ----
    $vramTxt = if ($vUsed -and $vTot) { "{0:N1}/{1:N1}GB" -f ($vUsed/1024),($vTot/1024) } else { '  -  ' }
    [Console]::Write(("`r  t={0,5}s | GPU {1,3}% {2,2}C {3,4}MHz {4,3}W | VRAM {5,-11} | CPU {6,3}% (max {7,3}%) {8,4}MHz | RAM {9,4:N1}GB    " -f `
        $seg, [int]$gUtil, [int]$gTemp, [int]$gClk, [int]$gPow, $vramTxt, [int]$cUtil, [int]$cCoreMax, [int]$cClk, $ramUsedGB))

    # ---- Condiciones de parada ----
    if ($Minutos -gt 0 -and $swTotal.Elapsed.TotalMinutes -ge $Minutos) { $stop = $true }
    try {
        if ([Console]::KeyAvailable) {
            $k = [Console]::ReadKey($true)
            if ($k.Key -eq 'Enter' -or $k.Key -eq 'Q' -or $k.Key -eq 'Escape') { $stop = $true }
        }
    } catch {}

    # ---- Ritmo ----
    if (-not $stop) {
        $rem = $IntervaloSeg - $iter.Elapsed.TotalSeconds
        if ($rem -gt 0) { Start-Sleep -Milliseconds ([int]($rem*1000)) }
    }
}
$swTotal.Stop()
[Console]::Write("`r" + (' ' * 110) + "`r")

# --- Parar PresentMon ----------------------------------------------------------
if ($pmProc) { try { $pmProc.CloseMainWindow() | Out-Null; Start-Sleep -Milliseconds 400; if (-not $pmProc.HasExited) { Stop-Process -Id $pmProc.Id -Force } } catch {} }

# --- Helpers de estadistica ----------------------------------------------------
function Vals($prop) { $samples | ForEach-Object { $_.$prop } | Where-Object { $_ -ne $null } }
function Avg($prop) { $v=@(Vals $prop); if ($v.Count){[math]::Round(($v|Measure-Object -Average).Average,1)}else{$null} }
function Max($prop) { $v=@(Vals $prop); if ($v.Count){[math]::Round(($v|Measure-Object -Maximum).Maximum,1)}else{$null} }
function Min($prop) { $v=@(Vals $prop); if ($v.Count){[math]::Round(($v|Measure-Object -Minimum).Minimum,1)}else{$null} }
function PctGE($prop,$thr) { $v=@(Vals $prop); if (-not $v.Count){return $null}; [math]::Round((($v|Where-Object {$_ -ge $thr}).Count / $v.Count)*100,0) }

$n = $samples.Count
$durMin = [math]::Round($swTotal.Elapsed.TotalMinutes,1)

# --- FPS desde PresentMon (best-effort) ---------------------------------------
$fpsAvg=$null;$fps1=$null;$fps01=$null;$fpsNote=$null
if ($ConPresentMon -and (Test-Path $pmCsv)) {
    try {
        $rows = Import-Csv $pmCsv
        if ($rows.Count -gt 10) {
            $col = ($rows[0].PSObject.Properties.Name | Where-Object { $_ -match 'BetweenPresents|FrameTime|BetweenDisplayChange|MsBetweenPresents' } | Select-Object -First 1)
            if ($col) {
                $ft = @($rows | ForEach-Object { [double]($_.$col) } | Where-Object { $_ -gt 0 } | Sort-Object -Descending)
                if ($ft.Count -gt 10) {
                    $mean = ($ft | Measure-Object -Average).Average
                    $fpsAvg = [math]::Round(1000/$mean,0)
                    $fps1   = [math]::Round(1000/$ft[[int][math]::Floor($ft.Count*0.01)],0)
                    $fps01  = [math]::Round(1000/$ft[[int][math]::Floor($ft.Count*0.001)],0)
                }
            } else { $fpsNote = 'PresentMon: no reconoci la columna de frametime (version distinta).' }
        } else { $fpsNote = 'PresentMon no capturo frames (nombre de proceso distinto a cod.exe?).' }
    } catch { $fpsNote = 'PresentMon: no pude leer el CSV.' }
}

# --- Construir resumen ---------------------------------------------------------
$L = New-Object System.Collections.Generic.List[string]
function A([string]$t='') { $L.Add($t) }

A '=============================================================='
A '  RESUMEN DE TELEMETRIA EN VIVO - WARZONE'
A '=============================================================='
A ("  Duracion medida : {0} min   -  {1} muestras" -f $durMin, $n)
A ("  CPU             : {0}" -f $cpuName)
A ("  RAM total       : {0} GB" -f $ramTotGB)
A ''
A '  --- GPU ------------------------------------------------------'
A ("  Uso GPU         : avg {0}%   -  minimo {1}%" -f (Avg 'gpu_util'), (Min 'gpu_util'))
A ("  % tiempo >=97%  : {0}%   (esto define GPU-bound)" -f (PctGE 'gpu_util' 97))
A ("  Temp GPU        : avg {0}C   -  max {1}C" -f (Avg 'gpu_temp'), (Max 'gpu_temp'))
A ("  Reloj GPU       : avg {0}MHz -  min {1}MHz" -f (Avg 'gpu_clk'), (Min 'gpu_clk'))
A ("  Consumo GPU     : avg {0}W   -  max {1}W" -f (Avg 'gpu_pow'), (Max 'gpu_pow'))
$vPeak = Max 'vram'; $vTotM = Max 'vramtot'
A ("  VRAM pico       : {0} MB de {1} MB   ({2}%)" -f $vPeak, $vTotM, $(if($vTotM){[math]::Round($vPeak/$vTotM*100,0)}else{'?'}))
A ''
A '  --- CPU / RAM ------------------------------------------------'
A ("  Uso CPU (total) : avg {0}%   -  max {1}%" -f (Avg 'cpu_util'), (Max 'cpu_util'))
A ("  Nucleo mas alto : max {0}%" -f (Max 'cpu_core'))
A ("  Reloj CPU efect.: avg {0}MHz -  max {1}MHz   (perf avg {2}%)" -f (Avg 'cpu_clk'), (Max 'cpu_clk'), (Avg 'cpu_perf'))
A ("  RAM en uso      : avg {0}GB  -  pico {1}GB de {2}GB" -f (Avg 'ram'), (Max 'ram'), $ramTotGB)
A ''
if ($fpsAvg) {
    A '  --- FPS (PresentMon) -----------------------------------------'
    A ("  FPS promedio    : {0}" -f $fpsAvg)
    A ("  1% low          : {0}" -f $fps1)
    A ("  0.1% low        : {0}" -f $fps01)
    A ''
} elseif ($fpsNote) {
    A ('  --- FPS ------------------------------------------------------')
    A ('  ' + $fpsNote + '  (usa el overlay in-game para los FPS.)')
    A ''
}

# --- Conclusiones automaticas --------------------------------------------------
A '  --- CONCLUSIONES ---------------------------------------------'
$gpuBoundPct = PctGE 'gpu_util' 97
$gpuAvg = Avg 'gpu_util'
if ($gpuBoundPct -ne $null) {
    if ($gpuBoundPct -ge 60) {
        A ("  * GPU-BOUND {0}% del tiempo -> tu limite es la GPU (RTX 3080 Ti a 4K)." -f $gpuBoundPct)
        A "    Palanca: baja la RESOLUCION DE SALIDA (1440p/1080p) o usa DLSS Performance."
        A "    Eso subira tus FPS; a 4K la 3080 Ti es el cuello, no la CPU."
    } elseif ($gpuAvg -ne $null -and $gpuAvg -lt 85) {
        A ("  * GPU NO saturada (avg {0}%, solo {1}% del tiempo >=97%)." -f $gpuAvg, $gpuBoundPct)
        A "    -> NO estas GPU-bound. Bajar resolucion casi NO subira FPS."
        A "    Sospechosos: cap de FPS activo, CPU-bound puntual (lobbies llenos),"
        A "    apps de fondo (Docker/SignalRGB+iCUE) o algun ajuste. Revisa el nucleo mas alto."
    } else {
        A ("  * Mixto: GPU-bound {0}% del tiempo (avg {1}%)." -f $gpuBoundPct, $gpuAvg)
        A "    En peleas probablemente GPU-bound; bajar resolucion ayudara en esos momentos."
    }
}
if ($vPeak -and $vTotM) {
    $vp = [math]::Round($vPeak/$vTotM*100,0)
    if ($vp -ge 95)     { A ("  * VRAM AL LIMITE ({0}%): puede causar stutter. Baja Texturas o resolucion." -f $vp) }
    elseif ($vp -ge 85) { A ("  * VRAM alta ({0}%): vigilala a 4K con Texturas High + Streaming OFF." -f $vp) }
    else                { A ("  * VRAM OK ({0}%): tienes margen." -f $vp) }
}
$coreMaxPeak = Max 'cpu_core'; $cpuAvg = Avg 'cpu_util'
if ($coreMaxPeak -ne $null -and $coreMaxPeak -ge 97) { A ("  * Un nucleo llego a {0}% -> posibles picos CPU-bound (normal en lobbies llenos)." -f $coreMaxPeak) }
if ($cpuAvg -ne $null -and $cpuAvg -lt 60)           { A ("  * CPU con holgura (avg {0}%): el 7800X3D no es tu cuello general." -f $cpuAvg) }
$gtMax = Max 'gpu_temp'; $gcMin = Min 'gpu_clk'; $gcAvg = Avg 'gpu_clk'
if ($gtMax -ne $null) {
    if ($gtMax -ge 84) { A ("  * GPU caliente (max {0}C). Revisa flujo de aire/curva de ventilador." -f $gtMax) }
    else               { A ("  * Temp GPU OK (max {0}C)." -f $gtMax) }
    if ($gcAvg -ne $null -and $gcMin -ne $null -and $gtMax -ge 80 -and $gcMin -lt ($gcAvg*0.9)) {
        A ("    Posible throttle: el reloj GPU cayo a {0}MHz (avg {1}MHz) con temp alta." -f $gcMin, $gcAvg)
    }
}
A "  * (Temp de CPU no la lee este script; si quieres verla usa HWiNFO64.)"
A ''
A '  --- QUE HACER AHORA ------------------------------------------'
A '  Pega este resumen (resumen-vivo.txt) en el chat y te digo la config'
A '  optima exacta para tu caso. CSV completo: reporte-vivo-warzone.csv'
A '=============================================================='

# --- Volcar ---------------------------------------------------------------------
$L | ForEach-Object { Write-Host $_ }
$L | Out-File -FilePath $sumFile -Encoding UTF8 -Force
Write-Host ''
Write-Host ("==> Resumen guardado en: {0}" -f $sumFile) -ForegroundColor Green
Write-Host ("==> Datos por segundo  : {0}" -f $csvFile) -ForegroundColor Green
try { Start-Process notepad.exe $sumFile } catch {}
