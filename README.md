# GDriveStation Alpha (iOS)

Reproductor musical personal inspirado en Tidal para iOS. Almacena y reproduce música desde Google Drive usando un backend en Cloudflare Workers.

## Requisitos

- Xcode 26.2+
- iOS 18.0+
- Un backend desplegado (Cloudflare Worker)

## Configuración

### Backend URL

La única variable que debes cambiar antes de compilar está en `Info.plist`:

```
GDriveStation/Info.plist
```

Busca la key `BackendURL` y reemplaza el valor:

```xml
<key>BackendURL</key>
<string>https://TU-SERVIDOR.workers.dev</string>
```

Esta URL se usa automáticamente en `APIService` para todas las llamadas a la API (tracks, playlists, cover art, streaming).

### Qué valores configurables existen

| Valor | Dónde | Descripción |
|-------|-------|-------------|
| `BackendURL` | `Info.plist` | URL del worker que sirve la música. Reemplazar con tu propio deploy |

No hay API keys, tokens ni secrets en el código. El backend expone endpoints públicos sin autenticación.

## Endpoints esperados del backend

El cliente espera los siguientes endpoints:

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/track` | GET | Todas las tracks |
| `/api/track/:id` | GET | Una track específica |
| `/api/stream/:trackId` | GET | Streaming de audio (soporta Range) |
| `/api/cover/:trackId` | GET | Portada del álbum |
| `/api/playlist` | GET | IDs de playlists |
| `/api/playlist/:id` | GET | Playlist con sus tracks |

## Build sin certificado (GitHub Actions)

El workflow `.github/workflows/build.yml` genera un IPA unsigned automáticamente:

1. Haz push a `main` o ejecuta el workflow manualmente
2. Ve a **Actions** → **Build unsigned iOS IPA** → **Run workflow**
3. Descarga el artifact `GDriveStation-unsigned-ipa` (7 días de retención)
4. Instala el `.ipa` con ESign o similar

No se necesitan secrets en GitHub. El build usa `CODE_SIGNING_ALLOWED=NO`.

## Estructura del proyecto

```
GDriveStation/
├── App.swift                    # Entry point, configuración de escenas
├── ContentView.swift            # Navegación raíz (Library / Playlist)
├── Models/
│   └── Track.swift              # Modelos Track, Playlist, Color hex
├── Services/
│   ├── APIService.swift         # Comunicación con el backend
│   └── PlayerService.swift      # Reproducción de audio (AVPlayer)
├── ViewModels/
│   └── PlayerViewModel.swift    # Estado de la UI y lógica de negocio
├── Views/
│   ├── LibraryView.swift        # Lista de tracks con pull-to-refresh
│   ├── PlayerView.swift         # Player completo (Tidal-style)
│   ├── PlaylistView.swift       # Vista de playlist individual
│   └── Components/
│       ├── MiniPlayer.swift     # Barra inferior con track actual
│       ├── PlayerOverlay.swift  # Overlay drag-to-dismiss
│       └── TrackRow.swift       # Fila individual de track
├── Utilities/
│   └── ColorExtractor.swift     # Extracción de color dominante (CIFilter)
└── Info.plist                   # Configuración (BackendURL va aquí)
```

## Stack

- Swift 6 + SwiftUI
- `@Observable` (no UIKit bindings)
- AVPlayer para audio
- CIFilter para extracción de color de portadas
- Async/await para networking

## Licencia

MIT
