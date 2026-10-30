# Guía Técnica y Pedagógica: Minijuegos e Interactivos (Escenas 4 a 11)
## Proyecto: *El secreto de los mágicos*

Documento técnico y de diseño interactivo para el videojuego educativo sobre lengua de signos, braille y accesibilidad en **Godot 4.7**.

---

## 1. Arquitectura del Sistema de Retos

El sistema interactivo funciona mediante una arquitectura desacoplada y orientada a eventos:

```
┌────────────────────────────────────────────────────────┐
│               EstadoJuego.gd (Autoload)                │
│  - Control de los 8 retos (0 a 7)                      │
│  - Puntuación: 5 pts por acierto | 0 pts por fallo     │
│  - Persistencia: user://progreso_magicos.json          │
│  - Señales: puntos_actualizados, reto_actualizado      │
└──────────────────────────┬─────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌──────────────────┐ ┌───────────────┐ ┌──────────────────┐
│ MarcadorPuntos   │ │ TablaProgreso │ │ Premio.tscn      │
│  - Widget ⭐ pts │ │  - Modal 2x4  │ │  - Regalo pulso  │
│  - Botón "Retos" │ │  - Capa 30    │ │  - Postal GANADO │
│  - Escenas 4-15  │ │  - V y X      │ │  - Efectos luz   │
└──────────────────┘ └───────────────┘ └────────┬─────────┘
                                                │
                 ┌──────────────────────────────┼──────────────────────────────┐
                 ▼                              ▼                              ▼
      ┌─────────────────────┐        ┌─────────────────────┐        ┌─────────────────────┐
      │ JuegoArrastrarLetras│        │ Cuestion.tscn       │        │ MinijuegoIC.tscn    │
      │  - Escena 4: Braille│        │  - Preguntas test   │        │  - Escena 11: IC    │
      │    ("CASIMIRO")     │        │  - Escenas 5, 7, 8, │        │  - 3 etapas sonido  │
      │  - Escena 6: Helen  │        │    9, 10            │        │  - Viaje al cerebro │
      │    ("ESTIBALIZ")    │        │  - Fallo.tscn hook  │        │  - ¡BOOM! biónico   │
      └──────────┬──────────┘        └──────────┬──────────┘        └──────────┬──────────┘
                 │                              │                              │
                 └──────────────────────────────┴──────────────────────────────┘
                                                │ (en caso de error)
                                                ▼
                                     ┌─────────────────────┐
                                     │ Fallo.tscn          │
                                     │  - Modal no punitivo│
                                     │  - Pista didáctica  │
                                     │  - "Probar otra vez"│
                                     └─────────────────────┘
```

---

## 2. Especificación de la Tabla de Progreso (2×4) y Puntuación

### Reglas de Puntuación
* **+5 puntos** por cada reto completado con éxito en su primer acierto.
* **0 puntos** por intento fallido (no hay deducción de puntos).
* Puntuación total máxima del juego: **40 puntos** (8 retos $\times$ 5 puntos).

### Tabla de Progreso 2×4 (`TablaProgreso.tscn`)
* **Jerarquía**: `CanvasLayer` (capa 30) para renderizado absoluto en pantalla (1280×720 px), garantizando que no se corte en ningún lateral ni dependa de transformaciones del nodo padre.
* **Diseño visual**: Cuadrícula de 2 filas y 4 columnas:
  * **Fila 1 (Casillas 1 a 4)**:
    1. *Braille* (Escena 4)
    2. *Gallaudet* (Escena 5)
    3. *Sordociegos* (Escena 6)
    4. *Edison* (Escena 7)
  * **Fila 2 (Casillas 5 a 8)**:
    5. *Historia LSE* (Escena 8)
    6. *Animales* (Escena 9)
    7. *Inventores* (Escena 10)
    8. *Implante (IC)* (Escena 11)
* **Símbolos de estado**:
  * **`V`**: Reto completado con éxito (+5 pts). Fondo verde suave con borde esmeralda.
  * **`X`**: Reto intentado pero no superado aún (0 pts). Fondo rojizo suave.
  * **`—`**: Reto aún no iniciado. Fondo gris traslúcido.
* **Contador**: Muestra en la parte inferior: `Puntos de premios: [X] / 40 ⭐`.

---

## 3. Especificación Detallada de Cada Reto

---

### Reto 1: Escena 4 — Braille (Palabra "CASIMIRO")
* **Componente**: `JuegoArrastrarLetras.tscn` (`modo = "braille"`).
* **Objetivo pedagógico**: Reconocer los caracteres Braille y asociarlos a su letra correspondiente.
* **Palabra objetivo**: **CASIMIRO** (8 letras: C - A - S - I - M - I - R - O).
* **Interacción**:
  * Superior: 8 casillas rectangulares vacías con guión bajo.
  * Inferior: Abecedario completo de la A a la Z. Cada botón muestra la letra en tinta y su glifo Braille Unicode correspondiente (`A: ⠁`, `B: ⠃`, `C: ⠉`, `D: ⠙`, `E: ⠑`, `F: ⠋`, `G: ⠛`, `H: ⠓`, `I: ⠊`, `J: ⠚`, `K: ⠅`, `L: ⠇`, `M: ⠍`, `N: ⠝`, `O: ⠕`, `P: ⠏`, `Q: ⠟`, `R: ⠗`, `S: ⠎`, `T: ⠞`, `U: ⠥`, `V: ⠧`, `W: ⠺`, `X: ⠭`, `Y: ⠽`, `Z: ⠵`).
  * El jugador puede **arrastrar** la ficha hacia la casilla o **tocar la letra y luego la casilla**.
* **Resultado**:
  * Al completar correctamente las 8 letras: confeti de estrellas, animación de satisfacción, `EstadoJuego.registrar_acierto(0)` (+5 puntos, casilla `V`) y apertura del popup `Premio.tscn`.

---

### Reto 2: Escena 5 — Universidad de Gallaudet
* **Componente**: `Cuestion.tscn` (`indice_reto = 1`).
* **Pregunta**: *¿Dónde está la Universidad de Gallaudet?*
* **Opciones**:
  * A) España 🇪🇸
  * B) Polo Norte ❄️
  * **C) Estados Unidos (EEUU) 🇺🇸** *(Respuesta Correcta)*
* **Pista en caso de fallo (`Fallo.tscn`)**:
  > *"¡Casi! No está en el frío Polo Norte ni en España... ¡está en Washington D.C., en EEUU, la única universidad del mundo pensada para personas sordas!"*
* **Puntos**: +5 pts al acertar (casilla `V`).

---

### Reto 3: Escena 6 — Helen Keller / Dactilológico en Palma ("ESTIBALIZ")
* **Componente**: `JuegoArrastrarLetras.tscn` (`modo = "sordociegos"`).
* **Objetivo pedagógico**: Conocer el sistema de comunicación dactilológico en palma para personas sordociegas.
* **Palabra objetivo**: **ESTIBALIZ** (9 letras: E - S - T - I - B - A - L - I - Z).
* **Interacción**:
  * Superior: 9 casillas vacías para la palabra ESTIBALIZ.
  * Inferior: Botonera con las 30 letras recortadas en alta definición (`res://6/sordociegos/<letra>.png`), mostrando la mano táctil en posición sobre la palma.
  * Doble método de control: arrastre o toque directo.
* **Resultado**:
  * Al completar las 9 posiciones: `EstadoJuego.registrar_acierto(2)` (+5 puntos, casilla `V`) y apertura del popup `Premio.tscn`.

---

### Reto 4: Escena 7 — Thomas Edison
* **Componente**: `Cuestion.tscn` (`indice_reto = 3`).
* **Pregunta**: *La persona que inventó la bombilla... ¿era oyente o sorda?*
* **Opciones**:
  * A) Era oyente 👂
  * **B) Era sorda (o con dificultad auditiva) 🦻** *(Respuesta Correcta)*
* **Pista en caso de fallo (`Fallo.tscn`)**:
  > *"¡Casi! Thomas Edison tenía sordera desde joven, y decía que no oír ruidos molestos le ayudaba a concentrarse mejor para inventar."*
* **Puntos**: +5 pts al acertar (casilla `V`).

---

### Reto 5: Escena 8 — Historia de la Lengua de Signos
* **Componente**: `Cuestion.tscn` (`indice_reto = 4`).
* **Pregunta**: *¿Hace cuánto tiempo existía ya la Lengua de Signos?*
* **Opciones**:
  * A) Hace 100 años
  * **B) Hace más de 2.000 años** *(Respuesta Correcta)*
  * C) Hace 2 años
* **Pista en caso de fallo (`Fallo.tscn`)**:
  > *"¡No pasa nada! Recuerda que en la antigua Grecia y Roma, hace miles de años, ¡las personas ya se comunicaban con signos!"*
* **Puntos**: +5 pts al acertar (casilla `V`).

---

### Reto 6: Escena 9 — Comunicación Animal (Las Abejas)
* **Componente**: `Cuestion.tscn` (`indice_reto = 5`).
* **Pregunta**: *¿Cómo se comunican las abejas para avisar a sus compañeras de dónde están las flores?*
* **Opciones**:
  * **A) Con un baile o danza especial 🐝💃** *(Respuesta Correcta)*
  * B) Hablando por teléfono móvil 📱
  * C) Enviando cartas por correo ✉️
* **Pista en caso de fallo (`Fallo.tscn`)**:
  > *"¡Casi! Las abejas no usan tecnología ni papel... ¡hacen una divertida danza en forma de ocho con su cuerpo para indicar dirección y distancia!"*
* **Puntos**: +5 pts al acertar (casilla `V`).

---

### Reto 7: Escena 10 — Inventores Modernos (Robert Weitbrecht)
* **Componente**: `Cuestion.tscn` (`indice_reto = 6`).
* **Pregunta**: *¿Qué inventó Robert Weitbrecht para que las personas sordas pudieran comunicarse a distancia por teléfono?*
* **Opciones**:
  * **A) El TTY (teléfono para escribir mensajes de texto) 📠** *(Respuesta Correcta)*
  * B) Una nave espacial 🚀
  * C) Una televisión parlante 📺
* **Pista en caso de fallo (`Fallo.tscn`)**:
  > *"¡Casi! Weitbrecht inventó el TTY (teletipoacoplador), el primer teléfono para enviar mensajes de texto escritos a través de la línea telefónica."*
* **Puntos**: +5 pts al acertar (casilla `V`).

---

### Reto 8: Escena 11 — Implante Coclear (El Viaje del Sonido al Cerebro)
* **Componente**: `MinijuegoIC.tscn` / `MinijuegoIC.gd` (`indice_reto = 7`).
* **Objetivo pedagógico**: Comprender las 3 partes fundamentales del Implante Coclear y la ruta que sigue el sonido transformado en impulsos eléctricos hasta el cerebro.
* **Mecánica secuencial en 3 pasos**:
  1. **Fase 1: La Parte Exterior**
     - Pregunta: *¿Qué parte va por fuera recogiendo los sonidos del aire?*
     - Opciones:
       - **El procesador con micrófono detrás de la oreja 🦻** *(Correcta)*
       - Un sombrero mágico con plumas 🎩
       - Un altavoz gigante 📢
  2. **Fase 2: La Transmisión sin Cables**
     - Pregunta: *¿Cómo pasa la información a través de la piel sin ningún cable?*
     - Opciones:
       - **Un imán y una antena que envían ondas invisibles 🧲⚡** *(Correcta)*
       - Con una cuerda elástica invisible 🪢
       - Tirando avioncitos de papel ✈️
  3. **Fase 3: La Parte Interior (El Caracol)**
     - Pregunta: *¿A dónde llega dentro del oído para mandar los impulsos eléctricos al cerebro?*
     - Opciones:
       - **Al caracol (cóclea) con electrodos que conectan con el nervio auditivo y el cerebro 🐚🧠** *(Correcta)*
       - A la punta de la lengua 👅
       - A las uñas de los dedos 💅
* **Esquema de progreso visual**:
  - Encabezado con 4 nodos que se iluminan progresivamente:  
    `🦻 Micrófono ──▶ 🧲 Imán ──▶ 🐚 Caracol ──▶ 🧠 Cerebro`
* **Final**:
  - Al completar los 3 pasos: explosión visual de energía biónica, texto *"¡SUPERPODER AUDITIVO ACTIVADO!"*, `EstadoJuego.registrar_acierto(7)` (+5 puntos, casilla `V`) y apertura del popup `Premio.tscn`.

---

## 4. Filosofía de Retroalimentación y Accesibilidad

1. **Diseño No Punitivo**:
   - Errar una respuesta nunca resta puntos ni bloquea la navegación.
   - El popup `Fallo.tscn` refuerza el aprendizaje explicando el concepto correcto de manera cariñosa.
2. **Hitboxes Grandes y Toque Adaptativo**:
   - Todos los botones tienen un tamaño mínimo de 50×50 px y tipografía clara para facilitar la interacción en tabletas, pantallas táctiles y dispositivos móviles.
3. **Persistencia Transparente**:
   - El progreso se guarda en `user://progreso_magicos.json` inmediatamente tras cada acierto o fallo, permitiendo retomar la partida sin perder los puntos conseguidos.
4. **Visibilidad Continua**:
   - El marcador de puntos acompaña al jugador no solo durante los retos (4 a 11), sino también en el desenlace (Escena 12, Dactológico 14 y Final 15), premiando el recorrido completo.
