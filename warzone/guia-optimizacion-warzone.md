# Guía de optimización · Warzone competitivo

**Perfil:** Ryzen X3D · 32 GB RAM · Samsung 4K OLED 240 Hz (principal) + ASUS 1080p 60 Hz (secundario) · Windows custom "Kernel OS"
**Objetivo:** máximos FPS estables + mínima latencia, sin arriesgar el acceso a Ranked.

> **Lo primero:** ejecuta `diagnostico-pc.ps1` (mismo repo) y pégame el `reporte-warzone.txt`.
> Con eso confirmo tu estado real (sobre todo Secure Boot y si EXPO está activo) y cierro
> el análisis 100 % personalizado. Mientras tanto, esta guía ya está adaptada a tu equipo.

---

## TL;DR — mi recomendación con criterio

| # | Tema | Veredicto |
|---|------|-----------|
| 1 | **Windows custom vs Windows 11 oficial** | **Cámbiate a Windows 11 oficial limpio (24H2).** En tu equipo el debloat no da FPS reales y el "Kernel OS" te puede estar **bloqueando Ranked** por el anti-cheat. |
| 2 | **Tu Game Latency 11–15 ms** | **Ya es de élite.** No la persigas; trabaja la *estabilidad* de frametimes. |
| 3 | **Mayor FPS gratis que quizá no usas** | **EXPO en la BIOS.** Sin él tu DDR5 va a 4800 en vez de ~6000. Es lo #1 a verificar. |
| 4 | **Monitor secundario 60 Hz** | Causa microstutter real. Fix: **Pantalla Completa Exclusiva** + subir su Hz + mover Discord/navegador al principal. |
| 5 | **Resolución competitiva en el OLED** | El estirado 4:3 por panel **no funciona** aquí (DSC). Usa **4K + DLSS** o 1080p/1440p nativo. |

---

## 1) La decisión de Windows: "Kernel OS" vs Windows 11 oficial

**Recomendación: migra a Windows 11 oficial (24H2) limpio y aféinalo.** No por moda —
por tres motivos concretos y verificados con fuentes 2025–2026:

### a) El motivo decisivo es el ANTI-CHEAT, no los FPS
Desde la **Temporada 05 (agosto 2025)** y ya **obligatorio en Warzone desde la S01
(diciembre 2025)**, Ricochet **exige TPM 2.0 + Secure Boot** y lo verifica **en la nube**
(Microsoft Azure Attestation) — no es un chequeo local que se pueda "engañar".

- Si tu "Kernel OS" tiene **Secure Boot desactivado**, arranca en **Legacy/CSM** o el disco
  es **MBR**, obtienes **"Failed Attestation Status"** y te mandan a una **pool restringida
  (solo Battle Royale Casual)** con **Ranked/competitivo bloqueado**. Desde la **S04
  (junio 2026)** esto se aplica de forma activa, no solo como aviso.
- **Ojo:** "Failed Attestation" **NO es un baneo** (eso es solo para trampas confirmadas);
  es un estado de *no cumplimiento*. Pero para ti, competitivo, **te deja fuera de lo que
  importa**.
- **Verifícalo YA:** `msinfo32` → "Estado de arranque seguro = Activado" y "Modo de BIOS =
  UEFI"; y `tpm.msc` → TPM 2.0 presente. O usa el **Asistente de Attestation** oficial de
  Activision. El script te lo reporta automáticamente.

### b) En TU equipo, el debloat no da FPS reales
En un rig **X3D + 32 GB**, el debloat *"no sube FPS de forma medible"*; su único beneficio
(frametimes algo más estables por quitar picos de telemetría) se **reproduce al 100 % en
Windows oficial**. Las cifras marketinianas tipo "217→365 FPS" de estas ISOs están
**desmentidas**. El ahorro de RAM del debloat solo importa en equipos con ≤8 GB — no es tu
caso.

### c) La única palanca real de rendimiento a nivel SO es un clic en Windows oficial
Lo que de verdad cuesta FPS es **VBS / Integridad de memoria (Core Isolation)**: ~5–15 %
en juegos CPU-bound como Warzone. Y eso se **desactiva con un clic en Windows 11 oficial**
— no necesitas una ISO custom para ganarlo.

### Qué mantener y qué tocar (regla de oro)
| Ajuste | Estado | Por qué |
|--------|--------|---------|
| **Secure Boot** | ✅ **ON** | Obligatorio para Warzone. No afecta FPS. |
| **TPM 2.0** | ✅ **ON** | Obligatorio para Warzone. |
| **Windows Defender** | ✅ **ON** | Su ausencia debilita el perfil de seguridad y puede romper el arranque del driver anti-cheat. |
| **VBS / Integridad de memoria** | ❌ **OFF** | ~5–15 % FPS. Seguro para el anti-cheat (no lo requiere). |

> **Matiz honesto:** si el diagnóstico muestra que tu "Kernel OS" **ya tiene Secure Boot ON,
> pasa attestation y no rompió servicios/Defender**, entonces reinstalar es *opcional* — bastaría
> con desactivar VBS y aplicar los ajustes de abajo. Si Secure Boot está **OFF**, ese es el
> **motivo decisivo** para instalar Windows 11 oficial limpio.

**Sobre 24H2 vs 25H2:** 25H2 = **mismo rendimiento** que 24H2 (mismo código). No esperes FPS
por el salto de versión. **24H2** es el objetivo estable; hubo reportes de estabilidad en
early-25H2, así que no saltes a lo más nuevo a mitad de temporada sin necesidad.

**Si reinstalas (checklist rápido):**
1. USB oficial con **Media Creation Tool** de Microsoft (no ISOs de terceros).
2. En BIOS: **UEFI + Secure Boot ON + TPM ON**, disco **GPT**.
3. Tras instalar: activa **EXPO** (sección 2), drivers limpios, y aplica Tiers 2–3.
4. Debloat *ligero y reversible* si quieres (Win11Debloat de Raphire u O&O ShutUp10++):
   solo telemetría/apps de inicio. **Nunca** toques Defender, Secure Boot, WMI ni Windows Update.

---

## 2) BIOS y RAM — Tier 1 (el mayor FPS "gratis")

- **EXPO ON** (en placas ASUS: *"EXPO I"*). **Es lo primero.** Sin EXPO, tu DDR5 corre a
  **4800 MT/s con timings flojos** en vez de sus **~6000 CL30**, y los X3D escalan
  muchísimo con RAM rápida → puede ser un salto de **doble dígito en 1 % lows**.
  *(El script te dice si estás corriendo por debajo de lo rated.)*
- **Resizable BAR ON** — recomendado y de bajo riesgo con RTX 40/50.
- **PBO / Curve Optimizer (opcional, avanzado):**
  - **9800X3D:** desbloqueado → PBO + **Curve Optimizer −20 a −30** (más frío, algo más de boost).
  - **7800X3D:** multiplicador bloqueado → solo **Curve Optimizer negativo** (−20 a −30) para bajar temps.
  - Aplica **conservador y haz stress-test** (la inestabilidad puede tardar horas en salir).
    Mantén **SoC ≤ 1.3 V** (el AGESA nuevo ya lo hace) para evitar el problema histórico de voltaje en X3D.

---

## 3) Latencia y NVIDIA — Tier 1

Tu **Game Latency 11–15 ms ya es de élite** (es latencia de render/sistema con Reflex
activo, no el ping; el suelo competitivo es <20 ms). **No la persigas** — busca
**consistencia de frametimes / 1 % lows**, que se *siente* más en las peleas.

- **NVIDIA Reflex = Activado + Boost** en Warzone. Es la palanca de latencia #1 y además
  auto-limita los FPS un poco por debajo del refresco.
  *(Nota: Reflex 2 / Frame Warp **aún NO está en Warzone** a mediados de 2026 — no lo esperes aquí.)*
- **Stack sin tearing y con mínima latencia (config Blur Busters):**
  - **G-Sync/VRR = ON** (driver).
  - **V-Sync = ON pero SOLO en el panel de NVIDIA** (actúa de red de seguridad dentro de la ventana VRR).
  - **V-Sync = OFF dentro de Warzone.**
  - **Cap de FPS ~225–233** (o deja que Reflex cape ~224). Meta: **GPU por debajo de ~97 %**
    para que no se forme cola de render.
- **Panel de NVIDIA / NVIDIA App (perfil Warzone):**
  - Modo de energía = **Máximo rendimiento**.
  - Low Latency Mode = **On** (no *Ultra*; Reflex in-game manda).
  - Max Frame Rate = **225** (tope de seguridad global).
- **DLSS Frame Generation = OFF** para competitivo (añade 1–2 frames de latencia; se siente
  "flotante"). Si algún día lo activas, **Reflex debe seguir ON** o sumas 20–40 ms.
- **Ratón:** **1000 Hz** es el estándar competitivo. 2000–4000 Hz es aceptable; **evita
  8000 Hz** en Warzone (consume ~2–3 % de un núcleo y compite con el motor CPU-heavy → puede
  empeorar tus 1 % lows por <1 ms teórico).

---

## 4) Monitor OLED 4K 240 — Tier 1–2

- **Conéxión y modo:** DisplayPort 1.4, acepta **DSC** (su latencia es <0.001 ms, invisible).
  Confirma **3840×2160 @ 240 Hz** en Windows **y** en Warzone.
- **OSD del monitor:** **Game Mode ON**, **FreeSync/VRR ON**, y **VRR Control ON**
  (mata el *flicker* de VRR típico de OLED en escenas oscuras).
- **Panel de NVIDIA:** G-Sync Compatible ON para este monitor, **Rango dinámico de salida =
  Completo (0–255)** (si va en Limitado, los negros se lavan y pierdes visibilidad en
  sombras donde se esconden enemigos).
- **SDR, no HDR** para competitivo: más consistente, no aplasta el detalle en sombras y no
  cuesta FPS. Usa un perfil **Gaming SDR** calibrado.
- **BFI / ELMB = OFF:** baja el brillo ~50 %, añade ~1 frame de lag y desactiva VRR. La
  respuesta OLED (~0.03 ms) ya te da claridad de sobra.

### Resolución competitiva (importante en este panel)
Como el OLED usa **DSC** para 4K@240, **NVIDIA deja en gris las resoluciones personalizadas,
DSR y DLDSR** → **el truco del estirado 4:3 (1440×1080) por panel NO funciona** aquí sin
perder los 240 Hz. Opciones reales:
1. **4K nativo + DLSS Super Resolution (Quality/Balanced), Frame Gen OFF** → la opción más
   limpia en tu X3D + RTX 40/50, mantiene nitidez y sube FPS.
2. **Bajar a 1440p o 1080p nativo dentro del juego** para máximos FPS (los pros suelen tirar
   a 1080p). El OLED reescala 4K→1080p de forma limpia.
3. **No** sacrifiques 240 Hz solo por forzar 4:3 estirado.
*(El estirado, cuando se puede, no lo marca el anti-cheat — pero aquí el DSC lo impide.)*

---

## 5) Fix del monitor secundario a 60 Hz — Tier 2

El **microstutter por refrescos mixtos (240 + 60) sigue vivo en Windows 11 24H2**. Aunque
60 divide limpio en 240, el problema es el compositor **DWM/MPO/VRR**. En orden de impacto:

1. **Pantalla Completa Exclusiva en Warzone** — evita el DWM por completo. Es el **fix #1** y
   además da menor latencia y +5–15 % FPS. Si la opción "desaparece", desactiva *Modo Enfocado*
   y overlays (Discord/GeForce/Steam) o fuérzala con **Alt+Enter**.
2. **Sube el ASUS a su Hz real:** en *Config > Sistema > Pantalla > Pantalla avanzada*, comprueba
   si es un panel de 60 Hz real o uno de 75/144 Hz que Windows dejó en 60. Súbelo.
3. **Contenido dinámico al principal:** mueve Discord (vídeo), navegador con vídeo, OBS, YouTube al
   OLED, y **desactiva la aceleración por hardware** en Chrome/Firefox/Discord.
4. **Si persiste, desactiva MPO:** `HKLM\SOFTWARE\Microsoft\Windows\Dwm` → `OverlayTestMode`
   (DWORD) = **5**; en 24H2 añade también `OverlayMinFPS` = **0** y reinicia. *(En tu "Kernel OS"
   verifica que DWM y estas claves existan.)*
5. **Diagnóstico:** desconecta/desactiva el secundario un rato; si el stutter desaparece, era el
   compositor.

---

## 6) Ajustes in-game de Warzone — Tier 2

- **Modo de pantalla:** **Pantalla Completa Exclusiva** (no Borderless).
- **V-Sync in-game:** OFF · **Reflex:** Activado + Boost.
- **Límites de FPS separados:** Juego **~233** · Menú **60** · Fuera de foco **30**
  (baja calor, *coil whine* y libera el 2º monitor).
- **Texturas:** **Resolución de textura = Alta** · **On-Demand Texture Streaming = OFF**
  (tienes 32 GB + VRAM de sobra; cargar local evita hitching). Mantén el uso de VRAM < ~90 %.
- **Claridad:** Motion Blur (mundo y arma) OFF · Profundidad de campo OFF · Film Grain 0 ·
  **Anti-aliasing = SMAA T2X** (o **DLAA** a 4K si te sobra GPU) · **Frame Generation OFF**.
- **Shaders:** deja **Shader Cache ON** y **re-cachea tras cada parche y cada driver nuevo**
  (evita el *traversal stutter* de las primeras partidas). En NVIDIA: Shader Cache = 10 GB/Ilimitado
  en tu NVMe del sistema.
- **Render Worker Count:** déjalo en automático; si lo tocas, iguálalo a los **núcleos físicos (8)**,
  nunca más.

---

## 7) Windows (aplica igual en oficial o custom) — Tier 2

- **Game Mode = ON.**
- **HAGS (Programación de GPU acelerada por hardware) = ON** — en RTX 40/50 favorece a Reflex y
  baja algo de overhead (el coste de ~1 GB de VRAM no te afecta con GPU de gama alta).
- **Plan de energía = Ultimate Performance** (evita *core parking* y downclocks; es el mayor
  anti-microstutter en X3D). Actívalo:
  `powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61` y selecciónalo.
- **Apaga** Xbox Game Bar, Game DVR y "grabar en segundo plano".
- **VBS / Integridad de memoria = OFF** (manteniendo Secure Boot + TPM + Defender ON).
- **Variable Refresh Rate = ON** en *Config > Juegos > Gráficos*.

---

## 8) Mantenimiento

- **Driver NVIDIA Game Ready por temporada** de CoD (usa el "clean install" del instalador).
- **DDU (en Modo Seguro)** solo ante regresiones (stutter/crashes tras varios drivers, cambio de
  GPU o mantenimiento anual) — **no** en cada update.
- **Warzone en NVMe** con espacio libre (reduce *streaming stutter* y acelera cargas).
- Tras un driver nuevo, si baja el rendimiento, **rueda atrás una versión**: hubo temporadas con
  combos driver+parche que metieron caídas.

---

## 9) Cómo medir que mejoró (no te fíes solo de la latencia)

1. Aplica **una cosa por vez** (empieza por EXPO y el stack de Reflex/VRR).
2. Mira el **overlay** o **PresentMon**: fíjate en **1 % / 0.1 % lows y la curva de frametimes**
   en peleas reales, no en el menú.
3. Si un ajuste **mete stutter**, **revártelo**. "Más FPS de media" con peor 1 % low se siente peor.
4. Tu **11–15 ms de Game Latency** es tu línea base de élite: consérvala, no la degrades por perseguir números.

### Medición en vivo (script `medir-en-vivo.ps1`)
Para no adivinar, corre **`medir-en-vivo.ps1`** (mismo repo) durante 1–2 partidas. Es
**anti-cheat seguro** (no inyecta ni toca el juego; solo lee `nvidia-smi` + contadores WMI).
Al terminar te da un **resumen con conclusiones**: % de tiempo **GPU-bound**, VRAM pico,
temperaturas/clocks (¿throttle?), carga de CPU y núcleo más alto, y si tu límite es la GPU
(→ bajar resolución) o algo que la frena. Uso:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\medir-en-vivo.ps1               # mide hasta pulsar ENTER
.\medir-en-vivo.ps1 -Minutos 25   # mide 25 min y para solo
.\medir-en-vivo.ps1 -ConPresentMon  # además FPS/1%/0.1% low (requiere PresentMon.exe al lado)
```

---

### Fuentes (verificadas, 2025–2026)
Activision Support (TPM 2.0 + Secure Boot; Ricochet overview) · Call of Duty blog (Ricochet S01 dic-2025,
S04 jun-2026) · NVIDIA (Reflex; Reflex 2/Frame Warp) · Blur Busters (G-Sync 101; multi-monitor 24H2) ·
Tom's Hardware / Neowin (coste de VBS) · Phoronix / TechRadar / Hardware Unboxed (24H2 vs 25H2) ·
TFTCentral / RTINGS (Samsung QD-OLED 4K 240; DSC; VRR Control) · Microsoft Learn (Azure Attestation; HVCI).

*Investigación: workflow de 8 agentes · 160 búsquedas/fetch · verificación adversarial en los 3 puntos críticos (anti-cheat / Secure Boot / rendimiento).*
