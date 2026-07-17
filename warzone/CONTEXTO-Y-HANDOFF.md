# Contexto y handoff — Optimización PC Warzone (Kevin)

> **Para el siguiente agente/chat:** este documento tiene TODO lo que ya se investigó y midió.
> El usuario juega **Warzone competitivo** en una **PC solo-gaming** (programa en una Mac aparte).
> Repo con scripts y guías ya creados: **GitHub `kevinbarra/kevinbarra`, rama
> `claude/warzone-pc-optimization-0o16us`, carpeta `warzone/`**.

---

## 1) Hardware (confirmado por diagnóstico)

| Componente | Detalle |
|---|---|
| **CPU** | Ryzen 7 **7800X3D** (8c/16t, AM5). Boost ~4.7 GHz, sano. |
| **GPU** | **RTX 3080 Ti — 12 GB** reales (Windows/WMI reporta mal "4 GB", ignorar). Driver ~591.86 (ene 2026). |
| **RAM** | **32 GB** DDR5 (2×16 G.Skill F5-6000J3636F16G, 6000 CL36). **EXPO ACTIVO** (corre a 6000). ✅ |
| **Placa** | Gigabyte **B650 AORUS ELITE AX V2**. BIOS **F21 (ene 2024) — VIEJA, actualizar**. Slot GPU **PCIe 4.0 x16**. |
| **PSU** | **MSI MPG A850GF, 850 W 80+ Gold**. Sin 12VHPWR nativo (usa adaptador). Suficiente para 5070 Ti/5080/6080. ✅ |
| **Disco** | WD **SN770 1 TB NVMe** (206 GB libres de 931). |
| **Monitor 1** | Samsung **4K OLED 240 Hz** (usa **DSC** → resoluciones personalizadas de NVIDIA salen en gris; VRR/G-Sync Compatible, FreeSync Premium Pro). |
| **Monitor 2** | ASUS **1080p 60 Hz**. |

## 2) Sistema operativo ("Kernel OS")

- **Windows 11 IoT Enterprise LTSC 25H2** (build 26200, UBR 7462) — **ISO custom debloateada** (RegisteredOrg = `discord.gg/k3rnalyze`).
- Corre como cuenta **Administrator** (built-in). **Defender no responde** (probablemente eliminado). **Windows Update bloqueado** (`wumgr` en inicio).
- **Anti-cheat OK:** Secure Boot ON, TPM 2.0 ON, UEFI, disco GPT → **pasa attestation de Ricochet** (no está bloqueado de Ranked).
- **VBS habilitado y corriendo**, pero HVCI/Memory Integrity OFF. **HAGS sin valor**. Game Mode por defecto. Game DVR OFF. Plan **Ultimate Performance activo**.
- **Bloat en inicio (17 apps):** Docker Desktop (innecesario aquí), **SignalRGB + iCUE (ambos)**, Steam/Epic/EA/Riot/Brave/Spotify, Voicemeeter, Riot Vanguard.

## 3) Juego y config actual

- **Warzone versión Xbox app / Game Pass** (¡importante! config en carpeta protegida, difícil de hallar).
- Usa **resolución STRETCHED** a "4K" en pantalla completa.
- Usa **DLSS Ultra Performance (modelo Transformer)** → render interno 720p.
- **La config `.cst` NO apareció** en `Documentos\Call of Duty\players` ni en `%LOCALAPPDATA%\Packages`. Falta buscar en `C:\XboxGames`, la carpeta de datos del paquete de la Xbox app, o `Documentos` real (puede estar redirigido).

## 4) Telemetría medida en vivo (12.9 min, partida real)

- **GPU-bound 89% del tiempo** (GPU avg 95.4 %, ≥97 % el 89 %) → **el cuello es la GPU a 4K**, no la CPU.
- **VRAM pico 11.2 / 12 GB (91 %)** → al límite, riesgo de stutter. ⚠️
- GPU **fría (73 °C)**, clocks avg 1737 MHz, power **239 W avg / 294 W pico** (de 350 W) → posible power limit capado o carga ligera de DLSS UP; **revisar Power Limit en MSI Afterburner (poner 100 %)**.
- **CPU avg 65 %** (picos 100 % en lobbies llenos), boost 4.7 GHz → sobrado, no es el cuello.
- **RAM en uso ~23.7 GB** (Docker + launchers la inflan).
- **FPS ~110–140** a 4K DLSS UP. **Game Latency 11–15 ms** (élite; es latencia de render, no ping).

## 5) Conclusiones y decisiones ya tomadas

1. **El techo de FPS es la GPU (3080 Ti a 4K) + límite de VRAM.** No la CPU.
2. **Config a aplicar ahora:** bajar la **resolución de SALIDA a ~1440p** (arregla FPS **y** VRAM a la vez), manteniendo stretched si el usuario quiere modelos anchos. Alternativa: 4K + **DLSS Performance** (no Ultra) + **Texture Streaming ON**.
   - ⚠️ **CORRECCIÓN importante:** a 4K con VRAM al 91 %, **Texture Streaming debe ir ON** (antes se recomendó OFF asumiendo VRAM libre; la medición lo desmiente).
3. **PC gaming-only desbloquea:** **VBS/hypervisor OFF** (~5-15 % FPS), quitar **Docker** del inicio, **HAGS ON**, **Game Mode ON**. → script `aplicar-ajustes-gaming.ps1` (reversible).
4. **Ajustes de latencia:** Reflex **On+Boost**, G-Sync/VRR ON, V-Sync ON solo en driver (OFF in-game), **cap ~225**, motion blur/DoF/film grain OFF.
5. **Windows:** el custom pasa anti-cheat, así que reinstalar **no es urgente**, pero se recomienda instalación **oficial limpia** cuando cambie de GPU (Defender ausente, cuenta Administrator, ISO de terceros).
6. **GPU upgrade:** el usuario quiere **RTX 6080** (o 6070 Ti). Pero la RTX 60 "Rubin" es **~2H 2027+**. **Recomendación: comprar 50-series ahora** (5080 o 5070 Ti), no esperar 2 años. En México: 5070 Ti escasa, **5080 ~29,000 MXN** (precio justo local; mayorista TUF ~34k). Amazon US **ZOTAC 5080 $1,249** aterriza ~26k MXN con importación (depósito de Amazon Global, sin sorpresas), pero garantía local es más fácil. **RX 9070 XT** = alternativa de valor. USD/MXN ~17.5.
7. **Nota:** la versión **Xbox/Game Pass** es más restrictiva para Fullscreen Exclusive/tweaks; **Battle.net o Steam** son preferibles para competitivo.

## 6) TAREAS PENDIENTES (lo que debe hacer el siguiente agente)

1. **Encontrar la config de Warzone (Game Pass)** y mostrar: resolución de pantalla, resolución de render, relación de aspecto, modo de pantalla. Buscar `.cst` en `C:\XboxGames`, la carpeta del paquete Xbox, y `Documentos\Call of Duty\players` (Documentos puede estar redirigido).
2. **Determinar si el stretched sale a 4K** (causa del 91 % de VRAM) o a menor resolución, y **aplicar la config óptima** (salida ~1440p, stretched conservado, Reflex On+Boost, VRR, cap 225; Texture Streaming ON si se queda a 4K).
3. **Revisar Power Limit en MSI Afterburner** → 100 %.
4. **Aplicar `warzone/aplicar-ajustes-gaming.ps1`** (VBS off, HAGS on, Game Mode on — reversible) y quitar **Docker** del inicio + dejar un solo software RGB.
5. Recomendar compra de GPU según precios del momento (5080 vs 5070 Ti vs 9070 XT).

## 7) Archivos ya en el repo (`warzone/`)

- `diagnostico-pc.ps1` — diagnóstico de sistema (ya ejecutado).
- `medir-en-vivo.ps1` — telemetría en vivo (ya ejecutado).
- `aplicar-ajustes-gaming.ps1` — ajustes gaming reversibles (**pendiente de ejecutar**).
- `guia-optimizacion-warzone.md` / `.html` — guía completa.
- `roadmap-gpu-y-maximizar.md` — estrategia de upgrade de GPU.
