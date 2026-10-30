# El secreto de los mágicos — Registro de Progreso

Juego/app educativo en Godot 4.7 sobre lengua de signos y accesibilidad para público infantil y juvenil.  
Diseño responsive (PC y móvil), pantalla completa, navegación lineal con botones Anterior/Siguiente.

---

## 1. Flujo de Navegación Global

```
Main (Portal de entrada)
  │
  ▼
01. Introducción ──▶ 02. Presentación ──▶ 03. Inicio del viaje
  │
  ▼
[BLOQUE DE RETOS PEDAGÓGICOS - 5 pts c/u | Marcador y Tabla 2x4 activos]
  04. Braille (Formar "CASIMIRO" con glifos braille)
  05. Gallaudet (Trivia sobre la universidad en EEUU)
  06. Helen Keller (Deletrear "ESTIBALIZ" con manos dactilológicas en palma)
  07. Edison (Trivia sobre la sordera de Thomas Edison)
  08. Historia LSE (Trivia sobre la antigüedad milenaria de los signos)
  09. Animales (Trivia sobre la danza de las abejas)
  10. Inventores (Trivia sobre el teléfono de texto TTY)
  11. Implante Coclear (Minijuego en 3 etapas: Micrófono ➔ Imán ➔ Caracol/Cerebro)
  │
  ▼
[DESENLACE Y CIERRE - Marcador de puntos conservado]
  12. Cierre del viaje
  14. Dactológico (Lámina interactiva del abecedario)
  15. Final (Créditos MagicSign + Enlaces + Botón "Volver a Main")
```

---

## 2. Arquitectura de Componentes y Módulos Compartidos

### Singletons y Autoloads
- **`EstadoJuego.gd`** (`res://EstadoJuego.gd`):
  - Autoload registrado en `project.godot`.
  - Administra los 8 retos pedagógicos (`enum EstadoReto { PENDIENTE=0, ACIERTO=1, FALLO=2 }`).
  - Otorga **5 puntos** por cada acierto y **0 puntos** por fallo. Puntuación máxima: **40 puntos**.
  - Emite señales reactivas: `puntos_actualizados(puntos_totales)` y `reto_actualizado(indice_reto, estado)`.
  - Persistencia automática en almacenamiento local del usuario: `user://progreso_magicos.json`.
  - Métodos disponibles: `registrar_acierto(idx)`, `registrar_fallo(idx)`, `obtener_estado(idx)`, `obtener_puntos_totales()`, `guardar_progreso()`, `cargar_progreso()`, `reiniciar_progreso()`.

### Interfaz Superior y Tabla de Progreso
- **`MarcadorPuntos.tscn` / `MarcadorPuntos.gd`**:
  - Badge visual en la esquina superior derecha (`⭐ X pts`).
  - Animación pop elástica con `Tween` cada vez que se suman puntos.
  - Botón `"📊 Retos"` que abre la tabla de progreso en cualquier momento.
  - Instanciado en las escenas **4, 5, 6, 7, 8, 9, 10, 11, 12, Dactológico (14) y Final (15)**.
- **`TablaProgreso.tscn` / `TablaProgreso.gd`**:
  - Implementado como **`CanvasLayer` (capa 30)** para garantizar renderizado a pantalla completa independiente del árbol de nodos local.
  - **Cuadrícula de 2 filas × 4 columnas (8 casillas)**:
    - *Fila 1*: 1. Braille | 2. Gallaudet | 3. Sordociegos | 4. Edison
    - *Fila 2*: 5. Historia LSE | 6. Animales | 7. Inventores | 8. Implante (IC)
  - Marcadores visuales por celda:
    - **`V` (verde brillante con fondo esmeralda)**: Reto superado (+5 pts).
    - **`X` (rojo con fondo carmesí)**: Reto fallado / en curso (0 pts).
    - **`—` (gris neutro)**: Reto aún no intentado.
  - Resumen inferior: `Puntos de premios: X / 40 ⭐`.
  - Botón de cierre grande `"✖ Cerrar"` y cierre por toque en fondo oscurecido.

### Sistema de Recompensas y Retroalimentación
- **`Premio.tscn` / `Premio.gd`**:
  - Ícono de regalo interactivo con pulso flotante en la parte inferior de las escenas 4 a 11.
  - Al pulsar el regalo, evalúa si el reto ya ha sido superado o abre el interactivo correspondiente (`JuegoArrastrarLetras`, `MinijuegoIC` o `Cuestion`).
  - Popup de victoria: Postal dorada "GANADO" (`premios/Agrupar.png`), rayos giratorios (`premios/rayos.png`), partículas de estrellas (`premios/estrella5.png`), destellos (`destello4.png`) y chispas.
- **`Fallo.tscn` / `Fallo.gd`**:
  - Modal amigable y no punitivo con animación de rebote y fondo oscurecido.
  - Textos de aliento para niños: *"¡Casi casi!", "¡No te preocupes, los exploradores aprenden practicando!"*.
  - Muestra pista pedagógica personalizada según el reto fallado.
  - Botón grande `"🔄 Probar otra vez"` que devuelve al jugador al desafío sin penalizaciones ni bloqueos.

### Minijuegos e Interactivos Específicos
- **`JuegoArrastrarLetras.tscn` / `JuegoArrastrarLetras.gd`**:
  - Minijuego de emparejar letras del abecedario inferior (A-Z) en las casillas objetivo superiores.
  - Doble modalidad de interacción táctil/ratón:
    1. *Arrastrar y soltar (Drag & Drop)*.
    2. *Toque / Clic directo* (seleccionar casilla y tocar letra, o viceversa).
  - **Escena 4 (Braille)**: Objetivo **CASIMIRO**. Muestra glifos Braille Unicode bajo cada letra.
  - **Escena 6 (Helen Keller)**: Objetivo **ESTIBALIZ**. Botones con texturas HD de manos dactilológicas en palma (`6/sordociegos/*.png`).
- **`MinijuegoIC.tscn` / `MinijuegoIC.gd` (Escena 11 - Implante Coclear)**:
  - Desafío pedagógico interactivo en 3 fases secuenciales para explicar cómo viaja el sonido:
    1. *Paso 1 (Parte Exterior)*: El procesador y micrófono detrás de la oreja 🦻.
    2. *Paso 2 (Transmisión)*: El imán y la antena que envían señales a través de la piel 🧲⚡.
    3. *Paso 3 (Parte Interior)*: El caracol (la cóclea) con electrodos que conectan con el nervio y el cerebro 🐚🧠.
  - Diagrama de progreso iluminado en tiempo real: `Micrófono ➔ Imán ➔ Caracol ➔ Cerebro`.
  - Efecto de superpoder ¡BOOM! y victoria al completar los 3 pasos.
- **`Cuestion.tscn` / `Cuestion.gd`**:
  - Cuestionario modal con preguntas temáticas para las escenas 5, 7, 8, 9 y 10.
  - Botones grandes con íconos, resaltado verde en acierto, apertura automática de `Premio` (+5 pts) o `Fallo` (0 pts) según la respuesta.

### Navegación y UI Base
- **`Navegacion.gd`**: Control de avance/retroceso lineal en cada escena.
- **`NumeroPagina.tscn` / `NumeroPagina.gd`**: Indicador visual de página en esquina superior derecha (01 a 15).
- **`TogglePanel.gd`**: Botón conmutador para abrir/cerrar paneles auxiliares.

---

## 3. Resumen de Retos por Escena (4 a 11)

| Escena | Tema | Reto / Mecánica | Palabra / Pregunta | Solución Correcta | Puntos |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **04** | Braille | Arrastrar letras A-Z con Braille | Formar **CASIMIRO** | C-A-S-I-M-I-R-O (⠉⠁⠎⠊⠍⠊⠗⠕) | +5 pts |
| **05** | Gallaudet | Cuestionario modal | ¿Dónde está la Universidad de Gallaudet? | **Estados Unidos (EEUU) 🇺🇸** | +5 pts |
| **06** | Helen Keller | Arrastrar manos táctiles A-Z | Deletrear **ESTIBALIZ** | E-S-T-I-B-A-L-I-Z (alfabeto en palma) | +5 pts |
| **07** | Thomas Edison | Cuestionario modal | La persona que inventó la bombilla, ¿era oyente o sorda? | **Era sorda (o con dificultad auditiva) 🦻** | +5 pts |
| **08** | Historia LSE | Cuestionario modal | ¿Hace cuánto existía ya la Lengua de Signos? | **Hace más de 2.000 años** | +5 pts |
| **09** | Animales | Cuestionario modal | ¿Cómo se comunican las abejas para avisar de las flores? | **Con un baile o danza especial 🐝💃** | +5 pts |
| **10** | Inventores | Cuestionario modal | ¿Qué inventó Robert Weitbrecht para hablar por teléfono? | **El TTY (teléfono para mensajes de texto) 📠** | +5 pts |
| **11** | Implante IC | Minijuego en 3 pasos | El viaje del sonido hasta el cerebro | 1: Micrófono ➔ 2: Imán ➔ 3: Caracol (cóclea) | +5 pts |

---

## 4. Registro de Correcciones y Depuración

- **Corrección de encuadre de la Tabla de Retos (`TablaProgreso.tscn`)**:
  - *Problema*: `TablaProgreso` estaba anidada como nodo hijo de `MarcadorPuntos` (que mide 195×46 px en la esquina superior derecha), lo que provocaba que la tarjeta de la tabla se renderizara con desplazamiento fuera del marco de la pantalla (cortada a la derecha).
  - *Solución*: Se rediseñó `TablaProgreso` como nodo raíz `CanvasLayer` (layer 30). Ahora toma el tamaño completo del viewport (1280×720) y centra perfectamente la tarjeta en `(640, 360)` mediante anclas completas (`PRESET_FULL_RECT`), visible sin importar la posición del marcador.
- **Corrección de tipado en `MarcadorPuntos.gd`**:
  - *Problema*: Error en tiempo de ejecución al asignar un nodo `CanvasLayer` a una variable con anotación estricta `var tabla_progreso: Control`.
  - *Solución*: Se corrigió la anotación a `var tabla_progreso: CanvasLayer = %TablaProgreso`.
- **Comprobación en el motor de Godot**:
  - Ejecución de pruebas y verificación con herramienta de depuración de Godot.
  - Resultado: **0 errores**, todos los scripts validados sin fallos de compilación ni advertencias.

---

## 5. Configuración de Plataformas y Exportación

- **Presets de exportación (`export_presets.cfg`)**:
  - Plataforma Android configurada con paquete `com.losmagicos.app`.
  - Ruta de exportación: `build/android/los-magicos.apk`.
  - Modo inmersivo activado, soporte para pantallas pequeñas, normales, grandes y extragrandes.
- **Resolución base del proyecto**:
  - 1280 × 720 (16:9 widescreen), escalado automático adaptativo para dispositivos táctiles y monitores de sobremesa.

---

## 6. Elementos Pendientes y Decisiones de Producción

1. **Nombre del presentador en Créditos**:
   - En `Final/Creditos.gd` el campo del presentador mantiene el placeholder `[nombre]`, pendiente de confirmación por el equipo.
2. **Tercer animal en la Escena 9**:
   - Decisión pendiente con Casimiro y Esti: incorporar Luciérnagas (comunicación por destellos de luz, gran metáfora visual para la comunidad sorda), Delfines o Perros.
3. **Limpieza de archivos residuales en la raíz**:
   - `escena_1.tscn` (borrador antiguo de la introducción sin navegación).
   - `pack_premio.png` duplicado en la raíz (la versión definitiva está dentro de `premios/`).

---

## 7. Registro de cambios — 28 oct 2026 (sesión de ajustes visuales)

### 7.1 Premio: ilustración propia en cada hoja "GANADO"
- `Premio.tscn` incorpora el nodo `IconoPremio` (hijo de `PremioTextura`) y `Premio.gd` la propiedad exportada `textura_premio: Texture2D`. Si está vacía, la hoja se muestra sin ilustración.
- Área del icono: **150×128 px**, centrada sobre la cinta GANADO (antes 170×145 y, en la primera versión, 200×170).
- Botón del regalo bajado 40 px (`offset_top` −155 → −115; `offset_bottom` −75 → −35).

| Escena | Reto | Imagen de premio |
|---|---|---|
| 4 | Braille | `4/maquina.png` |
| 5 | Gallaudet | `5/gallaudet.png` (extraída con IA de `5.png`) |
| 6 | Manos / sordociegos | `6/hand.png` |
| 7 | Edison | `7/bombilla.png` (fondo eliminado con IA) |
| 8 | Historia LSE | `8/manos_lse.png` (Gemini; recorte manual de una mano) |
| 9 | Abejas | `9/9.png` |
| 10 | Inventores | `10/YYC.png` |
| 11 | Implante | `11/IC.png` |

### 7.2 Eliminación de fondos con IA
- Modelo **U²-Net** (`rembg`, `u2net.onnx`, 176 MB).
- `7/bombilla.png`: aislada la bombilla; el original se conservó en `/tmp/opencode/bombilla_original.png`.
- `5/gallaudet.png`: recorte del graduado con el libro "G" de `5/5.png` + fondo eliminado.
- `6/hand.png`: fondo blanco eliminado; original en `/tmp/opencode/hand_original.png`.
- `8/manos_lse.png`: partiendo de `8/Gemini_Generated_Image_t0bfsdt0bfsdt0bf.jpg`, se elimina el fondo con U²-Net y, mediante segmentación por componentes de piel, se quita la mano derecha (3 dedos + pulgar) y sus trazos huérfanos. Queda **solo la mano izquierda**, completa (5 dedos con uñas). 941×747 con alfa; se dibuja a 170×135.
- Escala del icono por escena: `Premio.gd` expone `escala_premio` (1.0 por defecto). La escena 6 la tiene a **0.85** para que la mano quede algo más pequeña dentro de la hoja.

### 7.3 Preguntas (Cuestion)
- `Cuestion.tscn` adopta el estilo grande que ya usaba `5/CuestionGallaudet.tscn`: tarjeta **1100×620**, pregunta y título a **34 px**, opciones a **32 px** con `escala_opciones = 1.6`, cerrar 48×48, márgenes 48/36.
- Afecta a las escenas 5, 7, 8, 9, 10 y 11 (la 5 mantiene su archivo propio, visualmente idéntico).

### 7.4 Minijuego del implante (Escena 11)
- `MinijuegoIC.tscn` / `.gd`: tarjeta **1100×620**, título 28, pregunta 30, opciones 26 con ajuste de línea y alto 84, diagrama a 20, cerrar 48.
- Verificado: los 3 pasos caben en el ancho (996 px útiles); el paso 3 crece 12 px por una opción a dos líneas.

### 7.5 Imágenes de página
- 11: se mantiene la textura original (sin `AtlasTexture`): la ilustración encaja por altura (424 px de ancho) y queda **debajo del texto**, sin taparlo.
- 10: `AtlasTexture` (región 1495×1031) → ilustración a 715 px (100 % del ancho).
- 6: botones-mano del panel «Abecedario en las manos» de 53×66 a **60×80** (icono 61×76, +34 % de superficie); márgenes del papel 26/56/26/8 y vista previa 280×210.

### 7.6 Fondo del campo
- 10 y 11: `Fondo/TextureRect` con `stretch_mode = 6` (cubrir) → `Campo.png` ocupa el ancho completo (1480×867 en vez de 1312×769).
- Las escenas 5-9 ya usaban `expand_mode = 5`, que cubre el ancho.

### 7.7 Pendientes derivados de esta sesión
- Ninguno: las 8 hojas de premio tienen ya ilustración.

---

## 8. Exportación — 30 oct 2026

### 8.1 Presets (`export_presets.cfg`)
| Preset | Plataforma | Salida | Notas |
|---|---|---|---|
| `Android` | Android | `build/android/los-magicos.apk` | Mantiene `--remote-debug tcp://192.168.1.195:6007` para Remote Deploy desde el editor. |
| `Android Final` | Android | `build/android/los-magicos-30oct.apk` | Sin argumentos de remote-debug; para compartir/instalar. |
| `iOS` | iOS | `build/ios/los-magicos.ipa` | `bundle_identifier = com.losmagicos.app`; pendiente de Team ID y firma. |

### 8.2 APK generado
- Archivo: `build/android/los-magicos-30oct.apk` (**125 MB**), generado el 30/10 a las 00:34.
- Paquete: `com.losmagicos.app` · versión `1.0` (versionCode 2) · minSdk **24** · targetSdk **36**.
- Firmado con la **keystore de depuración** (válido para probar e instalar por ADB; para Google Play hace falta una keystore de release).
- Instalación:
  ```bash
  ADB=/home/Malabo/Android/Sdk/platform-tools/adb
  $ADB install -r build/android/los-magicos-30oct.apk
  $ADB shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER com.losmagicos.app
  ```
- Comando de exportación:
  ```bash
  flatpak run --command=godot org.godotengine.Godot --headless \
    --path "/home/Malabo/Documentos/2025/Godot/los-magicos" \
    --export-debug "Android Final" build/android/los-magicos-30oct.apk
  ```

### 8.3 iOS: qué se puede hacer en Linux y qué no
- **Sí se puede** generar el proyecto Xcode en Linux con el preset `iOS`. Ya está hecho: `build/ios/` (525 MB) contiene
  - `los-magicos.xcodeproj` (proyecto Xcode),
  - `los-magicos.pck` (98 MB, datos del juego),
  - `los-magicos/` (Info.plist, entitlements, imágenes, lanzamiento),
  - los `.xcframework` de Godot para iOS.
- **No se puede** compilar ni firmar el `.ipa` aquí: eso exige **macOS + Xcode** (archivar y firmar). En Linux el export termina en *«Project export completed with warnings»*.
- ⚠️ El proyecto generado lleva un **Team ID de relleno** (`ABCDE12345`) porque Godot no exporta sin uno. Hay que sustituirlo por el Team ID real de la cuenta Apple (en el preset o en Xcode → Signing & Capabilities).
- Pasos en un Mac:
  1. Copiar la carpeta `build/ios/`.
  2. Abrir `los-magicos.xcodeproj`.
  3. Poner el Team real y el provisioning profile (Xcode → Settings → Accounts).
  4. Product → Archive → distribuir a App Store Connect o instalar en el dispositivo.
- Requisitos de cuenta: Apple Developer Program (de pago) para distribuir; para probar en un iPhone propio basta una cuenta gratuita con firma de 7 días.

### 8.4 Codemagic: compilar el `.ipa` en la nube (repo privado)
- Archivo **`codemagic.yaml`** en la raíz del proyecto. Workflow `ios-release` en `mac_mini_m2` (macOS):
  1. Descarga **Godot 4.7.2** y las plantillas de exportación (quedan en caché).
  2. Escribe el **Team ID** real en `export_presets.cfg` (variable `APPLE_TEAM_ID`).
  3. Exporta el proyecto Xcode con `--export-release "iOS"`.
  4. Firma con `xcode-project use-profiles` y genera el `.ipa` con `xcode-project build-ipa`.
- Artefactos: `build/ios/ipa/*.ipa`, `build/ios/*.pck` y los logs de Xcode.
- Requisitos:
  - Repositorio **privado** (GitHub/GitLab/Bitbucket) con el proyecto, **sin** `build/` (ya está en `.gitignore`).
  - En Codemagic: subir **certificado `.p12` + provisioning `.mobileprovision`** (bundle `com.losmagicos.app`) y definir `APPLE_TEAM_ID`.
  - `distribution_type: development` para instalar en un iPhone; `app_store` para App Store/TestFlight.
- Plan gratuito de Codemagic: 500 min/mes. La primera compilación tarda más (descarga ~1,5 GB de plantillas); luego usan la caché.
- Con cuenta Apple **de pago** se puede usar la integración **App Store Connect** (bloque comentado en el YAML) y Codemagic crea los certificados sin Mac.
- Preparar el repo:
  ```bash
  cd "/home/Malabo/Documentos/2025/Godot/los-magicos"
  git init
  git add .
  git commit -m "Los magicos 4.7.2"
  git remote add origin git@github.com:USUARIO/los-magicos.git   # repo privado
  git push -u origin main
  ```
  `.gitignore` excluye `build/`, `.godot/`, `*.apk`, `*.idsig`, `*.ipa` y `addons/godot_mcp/cache/` (el proyecto queda en ~95 MB).

### 8.5 Pendientes de publicación
- Keystore de **release** para Android (Google Play rechaza APK/AAB firmados en debug).
- Team ID, certificado y provisioning de iOS.
- Revisar el `versionCode`/`versionName` antes de cada subida.
