# Lumière — Agent Guide

## What is Lumière?

Lumière is a premium, Netflix-like tvOS app for self-hosted media enthusiasts. It unifies the entire media acquisition and playback pipeline into a single couch experience — from discovering and requesting content, through the full download lifecycle, to watching — without ever switching between services.

**Platform:** tvOS, SwiftUI, Xcode
**Language:** Swift 6
**Minimum deployment:** tvOS 17+

---

## The Problem It Solves

Users running a self-hosted *arr stack today must juggle multiple isolated web UIs:
- Browse and request on Seerr
- Hope Sonarr/Radarr picked up the request (no visibility unless logging into their UI)
- Hope qBittorrent is downloading (no visibility unless logging into its UI)
- Wait an unknown amount of time
- Finally find the content available in Jellyfin's mediocre UI

Lumière makes the entire pipeline visible, beautiful, and controllable from the TV remote.

---

## Target User

A technical self-hosted enthusiast running all of the following on their home server:

| Service | Role |
|---|---|
| Jellyfin | Media server — streaming and library |
| Seerr | Content discovery and request management (fusion of Overseerr + Jellyseerr) |
| Sonarr | TV show acquisition and management |
| Radarr | Movie acquisition and management |
| Prowlarr | Indexer aggregation (used by Sonarr/Radarr) |
| Bazarr | Subtitle search and download |
| qBittorrent | Download client |

All services are self-hosted. The user configures each service's base URL and API key inside Lumière.

---

## Core Concept: The Pipeline State Machine

Every piece of content has a visible lifecycle. This is the heart of the app.

```
DISCOVERED
    ↓
REQUESTED              ← via Seerr API
    ↓
SEARCHING_INDEXERS     ← Sonarr/Radarr grab event
    ↓
PENDING_DOWNLOAD       ← Sonarr/Radarr grabbed, queued in qBittorrent
    ↓
DOWNLOADING            ← qBittorrent: progress %, ETA, speed, seeders, state (queued/stalled/downloading)
    ↓  (parallel)
FETCHING_SUBTITLES     ← Bazarr: searching / found / downloading
    ↓
PROCESSING             ← Sonarr/Radarr import event
    ↓
AVAILABLE              ← Present in Jellyfin library, ready to watch
```

Subtitle pipeline runs in parallel with or after download and has its own sub-states:
```
SUBTITLES_SEARCHING
SUBTITLES_FOUND
SUBTITLES_DOWNLOADING
SUBTITLES_AVAILABLE
SUBTITLES_NOT_FOUND
```

---

## Integrations & APIs

### Jellyfin
- Base URL + API key configured by user
- Used for: library browsing, playback session, user authentication, resume position sync, artwork
- Playback: HLS transcoding first, direct play as enhancement
- Endpoint reference: `{baseURL}/api-docs/swagger`

### Seerr
- Base URL + API key configured by user
- Used for: content search/discovery, submitting requests, request status
- Note: Seerr is the combined Overseerr/Jellyseerr project — use its unified API

### Sonarr
- Base URL + API key configured by user
- Used for: TV show queue status, history events (grabbed, imported), episode availability
- v3 API

### Radarr
- Base URL + API key configured by user
- Used for: movie queue status, history events (grabbed, imported), movie availability
- v3 API

### qBittorrent
- Base URL + credentials configured by user
- Used for: torrent list, per-torrent progress, download speed, ETA, state (queued/stalled/downloading/seeding)
- Web API v2

### Bazarr
- Base URL + API key configured by user
- Used for: subtitle search status per episode/movie, available subtitles

### TMDB
- Used for: supplementary metadata, posters, backdrops, recommendations, trending content
- API key configured by user or bundled

---

## App Structure

### Home Screen Rows
```
🎬  Ready to Watch        — content available in Jellyfin
⏳  Coming Soon           — requested/downloading, with ETA
🔄  Continue Watching     — in-progress from Jellyfin resume data
🔥  Trending              — from TMDB/Seerr, requestable
⭐  Recommended           — based on watch history
```

### Content Card States
A single card represents a movie or episode and visually reflects its pipeline state. Tapping a card in "Coming Soon" shows full pipeline detail (which step it's on, download %, ETA, subtitle status). Tapping a card in "Ready to Watch" goes straight to playback.

### Request Flow
Browse trending/search → Select title → Tap Request → Card appears in Coming Soon row → Pipeline status updates passively → Notification when available → Card moves to Ready to Watch

Voice search via Siri Remote is a first-class input method for finding content.

---

## Priority Download — "Watch Soon"

A key UX feature inspired by PlayStation's "Game Ready" experience.

### User Flow
1. User finds a movie that is currently downloading
2. Taps **"Watch Soon"** on the content card
3. Lumière instructs qBittorrent to set this torrent to the highest priority (move to top of queue, max bandwidth)
4. A full-screen or prominent overlay appears — PlayStation-style — showing:
   - Movie poster + title
   - Animated progress bar
   - **"Ready in ~X minutes"** — calculated from qBittorrent's ETA, updated in real time
   - A subtle ambient background (blurred backdrop from TMDB)
   - Option to cancel / go back to browsing
5. When download hits 100% and Jellyfin confirms the file is available:
   - A satisfying completion animation plays
   - **Auto-play begins immediately** — no tap required
   - Brief "Now Playing" transition into the player

### qBittorrent Priority API
- Set torrent priority: `POST /api/v2/torrents/topPrio` with the torrent hash
- This moves it to the top of the download queue
- Also set download limit to unlimited for this torrent if a global limit is set: `POST /api/v2/torrents/setDownloadLimit`

### ETA Calculation
- Primary source: qBittorrent's `eta` field on the torrent object (in seconds)
- Poll qBittorrent every 10 seconds while "Watch Soon" screen is active
- Display as: "Ready in ~X minutes" — round to nearest minute, never show seconds (reduces anxiety)
- If ETA is unreliable (stalled, no seeders): show "Calculating..." rather than a wrong estimate
- If ETA exceeds 60 minutes: show hours + minutes ("Ready in ~1h 20m")
- When ETA drops below 2 minutes: transition to "Almost ready..." state with heightened animation

### Jellyfin Availability Check
- Poll Jellyfin library every 15 seconds once qBittorrent reports 100%
- Sonarr/Radarr webhook or polling confirms import is complete
- Only trigger auto-play once Jellyfin confirms the item exists and is playable — not just when the download finishes

### UI States
```
QUEUED          — "Watch Soon" tapped, torrent being prioritized
DOWNLOADING     — progress bar + ETA countdown, real-time updates
ALMOST_READY    — ETA < 2min, heightened animation, "Almost ready..."
PROCESSING      — download done, Sonarr/Radarr importing
LAUNCHING       — Jellyfin confirmed available, countdown to auto-play (3s)
PLAYING         — seamless transition into AVPlayerViewController
```

### Edge Cases
- User navigates away from "Watch Soon" screen: continue priority download in background, send push notification when ready
- Download stalls: surface stall state clearly ("Waiting for seeders..."), do not show fake ETA
- User has multiple "Watch Soon" active: queue them, only one can be top priority at a time

---

## Player

### Approach
- Use `AVPlayerViewController` as the base for standard playback UI
- Custom overlay view on top of `AVPlayer` for subtitle rendering
- HLS transcoding via Jellyfin is the primary playback method
- Direct play support is a secondary enhancement — do not block on it

### Subtitle Requirements
- SRT / VTT: parse and render manually via overlay
- ASS / SSA: full renderer required (libass integration or equivalent)
- **Double subtitles:** two simultaneous subtitle tracks rendered at once
  - Track 1: bottom of screen (e.g. English)
  - Track 2: top of screen or above Track 1 (e.g. original language)
  - This is a key differentiating feature — do not cut corners here
- Subtitle track selection exposed in player UI
- Subtitle sync offset control

### Skip Intro / Skip Credits
- Jellyfin exposes intro and credits timestamps via the Chapter Images / Intro Skipper plugin API
- Endpoints: `GET /Episode/{itemId}/IntroTimestamps` (requires Intro Skipper plugin on server)
- When playback position enters an intro segment: show a prominent **"Skip Intro"** button (bottom-right, Netflix-style)
  - Button appears with a smooth slide-in animation after 2 seconds into the intro
  - Tapping it seeks to `intro.end` timestamp
  - Button auto-dismisses if user doesn't interact within the intro window
- Same pattern for credits: **"Skip Credits"** button tied to credits segment timestamps
- Button must be focusable via Siri Remote with a clear focus state — never require precise navigation to find it

### Next Episode & Auto-Play Countdown
- When playback reaches the credits segment (or last ~30 seconds of final episode runtime if no credits data):
  - Slide in a **"Next Episode"** panel (bottom of screen, non-blocking)
  - Shows: next episode thumbnail, title, episode number, season
  - Shows a **circular countdown timer** (default: 15 seconds, user-configurable in Settings)
  - When countdown reaches 0: auto-play next episode seamlessly, no button press required
  - Tapping "Next Episode" skips the countdown and plays immediately
  - Tapping "Cancel" or pressing Back dismisses the panel and lets current content finish
- For the **last episode of a season or series**: no auto-play countdown, show a "Up Next" suggestion card instead (next season, or related content from TMDB)
- For **movies**: no next episode panel. Instead, at end of credits (or when credits segment ends):
  - Show a clean "Up Next" suggestion — similar movie from Jellyfin library or TMDB recommendation
  - Same 15-second countdown and auto-play behavior
  - This means a movie marathon can run completely hands-free

### Countdown Behaviour Details
```
CREDITS_APPROACHING   — pre-fetch next episode metadata 30s before credits
COUNTDOWN_VISIBLE     — panel slides in, timer starts
COUNTDOWN_CANCELLED   — user dismissed, content plays to natural end
AUTO_PLAYING          — countdown hit 0, seamless transition to next item
```

- Pre-fetch next episode from Jellyfin 30 seconds before the countdown appears — no loading delay when auto-play triggers
- If next episode is not yet available (still downloading): replace countdown panel with pipeline status ("Next episode ready in ~X minutes") — same "Watch Soon" UI pattern
- Countdown duration configurable in Settings (5s / 15s / 30s / Off)

### Other Player Features
- Resume playback — sync position to/from Jellyfin on play/pause/exit
- Audio track selection
- Playback speed control

---

## Design Language

**Aesthetic:** Premium, cinematic, lean-back. Netflix-level polish. Dark-first.

**Colors:**
- Background: `#0A0A14`
- Primary accent: `#F5C842` (warm gold)
- Surface: dark navy variants
- Text: white / off-white hierarchy

**Typography:** Clean, modern, TV-appropriate — large enough for 10-foot viewing distance.

**Motion:** Smooth, intentional. Focus transitions, card hover states (parallax on Apple TV remote), loading shimmer.

**Icon:** Geometric neon gold play button (3D wireframe triangle) on dark navy. Layered for tvOS parallax:
- Back layer: dark navy gradient (`#25283F` → `#11111F`)
- Middle layer: ambient glow
- Front layer: neon gold play symbol

---

## Monetization & Licensing

- Core features: free, MIT licensed, open source
- Premium features: proprietary license, source visible but not redistributable
- Pricing: ~$19.99/year or ~$49.99 lifetime (no forced subscription)

### Premium Features (proprietary module)
- Full pipeline visibility (qBittorrent progress, Bazarr subtitle status)
- Double subtitle support
- Push notifications ("X is now available to watch")
- Advanced home screen customization

### Free Features (MIT core)
- Jellyfin library browsing and playback
- Basic *arr status
- Content requesting via Seerr
- Standard single subtitle track

---

## Project Conventions

- **Architecture:** MVVM + clean layering. No API calls or business logic in Views.
- **Concurrency:** Swift Concurrency (`async`/`await`, `Actor`) throughout. No completion handlers.
- **No third-party UI frameworks** — pure SwiftUI only.
- **Networking:** Use `URLSession` with async/await. One dedicated API client per service.
- **Error handling:** All API failures must surface meaningfully to the UI — never silently swallow errors.
- **Configuration:** All service base URLs and API keys stored in Keychain, configurable via Settings screen.
- **Testing:** Unit test all API clients and the pipeline state machine. UI tests for critical flows.

---

## Competitive Context

| App | Player | Requesting | Pipeline visibility |
|---|---|---|---|
| Infuse | ⭐⭐⭐⭐⭐ | ❌ | ❌ |
| Swiftfin | ⭐⭐⭐ | ❌ | ❌ |
| Mediora | ⭐⭐ | ✅ | Partial |
| **Lumière** | **⭐⭐⭐⭐⭐** | **✅** | **✅ Full** |

Lumière's unique position: the only native tvOS app combining a premium playback experience with full *arr pipeline visibility and double subtitle support.
