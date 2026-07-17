# Roadmap: subir GPU + exprimir la PC al máximo (gaming-only)

**Tu equipo:** Ryzen 7 7800X3D · RTX 3080 Ti (12 GB) · 32 GB DDR5-6000 EXPO · B650 AORUS ELITE AX V2 (PCIe 4.0 x16) · WD SN770 NVMe · Samsung 4K OLED 240 Hz + ASUS 1080p 60 Hz.
**Perfil:** competitivo, PC **casi solo gaming** (dev en Mac). Objetivo: **máximo aprovechamiento + plan de GPU**.

---

## 1) Veredicto rápido

1. **No esperes ~2 años a la RTX 60.** Está lejísimos y su lanzamiento será caro/escaso. **Compra una 50-series ahora** y reevalúa Rubin en 2027 sin estar atado.
2. **Tu plataforma ya está 100% lista** para cualquier GPU nueva — incluida la **fuente** (850 W Gold ✅). Cero bloqueantes.
3. **Tu 3080 Ti es el cuello a 4K** — por eso usas DLSS Ultra Performance (720p internos). Una 50-series te quita ese compromiso de golpe.
4. **Al ser gaming-only, desbloqueamos FPS extra hoy:** VBS/hypervisor OFF + quitar Docker del inicio (ver script `aplicar-ajustes-gaming.ps1`).

---

## 2) La decisión de GPU: ¿esperar la 6080 o comprar ya?

### El dato duro sobre la RTX 60 (Rubin)
- **No está ni anunciada oficialmente.** Los leaks serios apuntan a **2H 2027, y con la escasez de DRAM probablemente late 2027 / inicios 2028.**
- Ganancia estimada: **~+30-35% raster** y **hasta 2x en path tracing** vs 50-series. VRAM esperada: 6080 ≈ 20 GB.
- Traducción: esperar la 6080 = **~1.5-2 años más con la 3080 Ti** + comprar en un lanzamiento con **precios inflados y stock malo** (histórico + DRAM).

### Tu plataforma NO es límite (buenas noticias)
| Componente | ¿Aguanta una 6080/6090? | Nota |
|---|---|---|
| **7800X3D** | ✅ Sí, de sobra | No hace de cuello a 4K ni con lo más top. El mejor CPU gaming que puedes tener para esto. |
| **B650 (PCIe 4.0 x16)** | ✅ Sí | Una GPU PCIe 5.0 pierde **<2-3%** en 4.0 x16. Irrelevante. |
| **32 GB DDR5-6000 EXPO** | ✅ Sí | Perfecta para X3D. Nada que tocar. |
| **PSU** | ✅ 850 W Gold (MSI A850GF) | Suficiente para 5070 Ti/5080/6080 (ver §3). |

**Conclusión:** cuando cambies GPU **solo cambias la GPU**. Cero upgrades extra — ni fuente, ni CPU, ni RAM, ni placa.

### Comparativa (órdenes de magnitud a 4K, Warzone varía por modo)
| GPU | Raster relativo | Warzone 4K **nativo** aprox. | VRAM | TGP | Disponible |
|---|---|---|---|---|---|
| **RTX 3080 Ti** (tuya) | referencia | ~85-100 fps | 12 GB | 350 W | ya |
| **RTX 5070 Ti** | +50-70% | ~130-160 fps | 16 GB | ~300 W | **ahora** |
| **RTX 5080** | +70-90% | ~155-185 fps | 16 GB | ~360 W | **ahora** |
| **RTX 5090** | +160-200% | ~210-250 fps | 32 GB | ~575 W | ahora (caro) |
| **RTX 6080** (leak) | ~+30-35% sobre 5080 | ~200-240 fps | ~20 GB | ? | ~2027+ |

*Con DLSS Quality (no Ultra Performance) todas suben muchísimo y mantienen nitidez. La clave para ti: dejar de comprimir a 720p internos.*

### Mi recomendación (precio/rendimiento), reflejando tu propia preferencia
Dijiste **"6080 ideal, si no 6070 Ti"** — apliquémoslo a lo que **sí puedes comprar ya**:

- **Ruta A — mejor valor (mi favorita para ti):** **RTX 5070 Ti ahora** → salto enorme desde la 3080 Ti, mueve tu 4K240 con DLSS Quality a 200+ fps y 1440p nativo sobradísimo. Barata relativa. Y en 2027 decides con calma si saltas a una 6070 Ti/6080.
- **Ruta B — "compro fuerte y me olvido":** **RTX 5080 ahora** → más cabeza para 4K más nativo; te puedes **saltar la 60-series** por completo un buen tiempo.
- **Esperar la 6080:** solo tiene sentido si estás cómodo **2 años más** con la 3080 Ti (DLSS UP) y aguantas los precios de 2027. Para un competitivo con panel 4K240 premium, es mucho tiempo desaprovechándolo.

> **En una frase:** compra **5070 Ti (valor) o 5080 (fuerza)** en los próximos meses; disfrutas tu OLED 4K240 **ya**, no en 2028, y no pierdes la opción de Rubin más adelante. Revisa **precios reales** al momento de comprar — si un 5080 está a mal precio, la 5070 Ti casi siempre es la jugada inteligente.

*(Extra: vigila el mercado de 2ª mano — una 4080 Super o 4090 usada a buen precio también son opciones muy válidas frente a 50-series nueva.)*

---

## 3) PSU — ✅ RESUELTO: tienes de sobra

Tu fuente es una **MSI MPG A850GF → 850 W, 80 PLUS Gold**. Es una unidad de **calidad** y
**más que suficiente** para el salto:

| GPU objetivo | ¿Tu 850 W Gold sirve? | Nota de conector |
|---|---|---|
| RTX 5070 Ti (~300 W) | ✅ **De sobra** | Usa el adaptador 8-pin→12VHPWR que viene con la GPU |
| RTX 5080 (~360 W) | ✅ **Cómoda** (headroom amplio) | Ídem, con el adaptador incluido |
| RTX 5090 (~575 W) | ⚠️ Al mínimo justo (NVIDIA pide 850 W) | Funciona, pero sin margen; no es tu objetivo |
| RTX 6080 (2027, TBD) | ✅ Muy probablemente sí | Ideal usar el adaptador/cable nativo que traiga |

**Detalle:** la MPG A850GF (serie ~2020) es ATX 2.x, así que **no trae conector 12VHPWR nativo**
— pero eso **no es problema**: toda 50-series incluye su **adaptador 8-pin → 12VHPWR** en la caja.
Enchufas 2-3 cables PCIe de 8 pines al adaptador y listo. (Si algún día pasas a una 5090/6090 de
mucho consumo, ahí sí valoraría una fuente ATX 3.1 con 12V-2x6 nativo — pero para 5070 Ti/5080 tu
850 W Gold es la pareja perfecta.)

**Veredicto:** ✅ fuente lista. Ya **no tienes ningún bloqueante** para comprar una 5070 Ti o 5080.

---

## 4) Maximizar AHORA (desbloqueado por ser gaming-only)

Como aquí **no programas** (eso es en el Mac), podemos ir a por todo. Lo automatiza el script **`aplicar-ajustes-gaming.ps1`** (interactivo y reversible):

| Ajuste | Qué hace | Por qué en tu caso |
|---|---|---|
| **VBS / hypervisor OFF** | Quita la capa de virtualización de seguridad | **~5-15% FPS** en CPU-bound. Antes no convenía por Docker; ya no lo necesitas aquí. |
| **Quitar Docker del inicio** | Deja de arrancar solo | Bloat puro en esta PC (lo usas en Mac). *(Se hace a mano en Administrador de tareas.)* |
| **HAGS ON** | Programación de GPU por hardware | Ayuda a Reflex; en tu reporte estaba sin valor. |
| **Game Mode ON** | Prioriza el juego | Estaba "por defecto"; lo fijamos. |
| **Plan Ultimate Performance** | Sin core parking/downclocks | Ya lo tenías activo ✅ (el script lo verifica). |

**A mano (no por script, para no tocar arranque a ciegas):**
- **Inicio:** deja **un solo** software RGB (SignalRGB **o** iCUE, no ambos), y quita launchers que no uses (EA/Epic/Riot/Brave/Spotify) del arranque.
- **BIOS F21 (ene 2024) → última:** AGESA nuevo mejora estabilidad de RAM y el 7800X3D.
- **Resolución/DLSS:** deja **Ultra Performance** y usa **DLSS Performance/Quality** (ver §5).

---

## 5) Con tu 3080 Ti actual (mientras compras)

- **Sube el preset de DLSS:** a 4K, **UP (720p) → Performance (1080p) o Quality (1440p)**. A 4K el coste de FPS entre presets es chico (manda el pase de salida 4K) pero **ganas mucha nitidez** para spotear. Usa el overlay: si te sobra FPS sobre tu cap con GPU <97%, sube preset.
- **Corre `medir-en-vivo.ps1`** 1-2 partidas y pásame el resumen → te digo el preset/resolución exactos y si hay throttle o techo de VRAM.
- Mantén **Reflex On+Boost**, **G-Sync + V-Sync (solo driver)**, **cap ~225**, **texturas High + Streaming OFF**, **motion blur/DoF/film grain OFF**.

---

## 6) Sobre el "Kernel OS" (para tener en cuenta)

Al ser gaming-only, el riesgo de seguridad del custom baja (no hay datos sensibles aquí). Pero **cuenta Administrator + sin Defender + Vanguard/Ricochet** sigue siendo motivo de fragilidad. **El cambio de GPU es el momento natural para una instalación limpia** (Windows 11 oficial o IoT LTSC oficial + debloat ligero): rendimiento idéntico, sin depender de una ISO de un Discord, con Defender y updates. Opcional, pero recomendable hacerlo "de una" cuando abras el gabinete para la GPU.

---

### Fuentes (2026)
Tom's Hardware / KitGuru / Notebookcheck / TechPowerUp (RTX 60 "Rubin" 2H 2027, +30-35% raster, DRAM) · Newegg / TechBuddy / PC Game Check (5070 Ti vs 5080 vs 5090 para 4K/1440p 2026) · Gigabyte (B650 AORUS ELITE AX V2 = PCIe 4.0 x16).
