# AGENTS.md — Los mágicos (Godot 4.7)

Notas operativas para agentes. El diseño del juego está en `PROGRESO.md`.

## Entorno
- Godot **Flatpak** `org.godotengine.Godot` **4.7.2.stable**.
- Proyecto: `/home/Malabo/Documentos/2025/Godot/los-magicos` (escena principal `res://Main.tscn`).
- `adb`: `/home/Malabo/Android/Sdk/platform-tools/adb` (NO está en `PATH`).
- PC: **192.168.1.195** (`enp4s0`). Móvil de pruebas: Xiaomi M2101K9G (Android 13), adb por WiFi (mDNS), serial `adb-e714489a-zQyPTv._adb-tls-connect._tcp`, IP 192.168.1.250.
- Package Android: `com.losmagicos.app`; launcher (alias exportado): `com.godot.game.GodotAppLauncher`.

## Deploy Android / remote-debug (lo importante)
- El remote-debug **NO se pasa por intent extra**. Godot lo **embebe en el APK** en `EditorExportPlatformAndroid::get_command_line_flags()` (`command_line/extra_args` + `gen_export_flags`). En el dispositivo aparece como `Project command line parameters: [...]`.
- El permiso `INTERNET` solo se añade si el export se hace con `DEBUG_FLAG_REMOTE_DEBUG` o `DEBUG_FLAG_DUMB_CLIENT` (`export_plugin.cpp`: `p_give_internet`).
  - Exportar por CLI (`--export-debug`) **NO** activa esas flags → APK **sin `INTERNET`** → `socket()` falla al instante (`_inet_open`, `Remote Debugger: Unable to connect`).
  - El botón **Remote Deploy** del editor SÍ las activa (añade `INTERNET` y las flags solo).
- **Remote Deploy = 4.º icono** de la barra de ejecución (monitor + play, `PlayRemote`).
- El editor **NO relee `export_presets.cfg` en caliente** → reiniciar Godot tras editarlo.
- El editor escucha en `192.168.1.195:6007` mientras está en *play*. Puerto `6007/tcp` abierto en la zona `public` del firewall.
- Editor settings útiles: `network/debug/remote_host`, `network/debug/remote_port=6007`, `export/android/use_wifi_for_remote_debug=true`, `export/android/wifi_remote_debug_host=192.168.1.195`.
- `export_presets.cfg` debe conservar `[runnable_presets]` + `Android="Android"` para que el botón liste el preset.

### Comandos
```bash
ADB=/home/Malabo/Android/Sdk/platform-tools/adb

# Export debug por CLI (ojo: aquí NO se añade INTERNET ni --remote-debug)
flatpak run --command=godot org.godotengine.Godot --headless \
  --path "/home/Malabo/Documentos/2025/Godot/los-magicos" \
  --export-debug Android build/android/los-magicos-debug.apk

# Instalar / lanzar / logs
$ADB install -r -t build/android/los-magicos-debug.apk
$ADB shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER com.losmagicos.app
$ADB logcat -d | grep -E "godot|GodotActivity"
```
- El `/tmp` del Flatpak es **privado**: exportar dentro del proyecto o copiar con
  `flatpak run --command=sh org.godotengine.Godot -c 'cp /tmp/x.apk <destino>'`.
- `adb install -r` falla si la firma de depuración cambió → `$ADB uninstall com.losmagicos.app` y reinstalar.

## Permisos
- `permissions/internet=true` está activado en `export_presets.cfg` para que **cualquier** export tenga red (necesario también para el runtime del addon `godot_mcp`).

## Automatización de UI (limitación)
- KDE Plasma **Wayland**: `xdotool` y `ydotool` **no** inyectan clics fiables (movimiento absoluto roto). Automatizar vía `adb`/MCP, no con clics sintéticos.
- Captura de pantalla: `spectacle -b -n -f -o out.png` (`grim`/`import` no sirven). La captura sale a **2×** del espacio lógico.

## Reglas
- No editar `.tscn` como texto salvo corrupción: usar herramientas de escena.
- No commitear sin permiso explícito.
