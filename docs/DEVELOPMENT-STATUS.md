# Development Status

Last updated: 2026-11-16. This file is the resume point. It must stay truthful
even when that is unflattering: the specification (Part A4, Part AC) forbids
marking anything as working that has not been run.

---

## 1. Verification legend

| Term | Meaning here |
|---|---|
| **Implemented** | Source exists in the repository and was reviewed. |
| **Built** | Compiled to a Windows binary. **Nothing is Built yet.** |
| **Auto-tested** | Exercised by an automated test. None exist yet. |
| **Manual-tested** | Run by a human and observed. **Nothing is.** |
| **Deployed** | Live on a public host. **Nothing is.** |
| **Blocked** | Cannot proceed without something outside this environment. |

---

## 2. What exists now

| Commit | Contents |
|---|---|
| `fa759df` | Windows build guide, upstream baseline record |
| `88fbf76` | `OVERDRIVE.md`, Apache-2.0 `NOTICE` |
| `f6a6996` | `source/overdrive/ODConfig.hx` — identity, profiles, feature flags, timeouts |
| `9ada447` | `source/overdrive/ODRating.hx` — global star model (spec G1) |
| `de0455b` | `source/overdrive/ui/ODTheme.hx` — design tokens |
| `f1c1379` | `source/overdrive/ui/ODButton.hx` — five-state button |
| `ad5a102` | `source/states/OverdriveMainMenuState.hx` — the menu |

The engine tree below those directories is still byte-identical to upstream
`5c67ced…`. The only new behaviour is unused until the title screen is routed,
which is the first item in section 6.

### Implemented, not compiled

| File | Covers | State |
|---|---|---|
| `ODConfig.hx` | C3 configuration, per-profile endpoints, feature flags | Implemented |
| `ODRating.hx` | G1 star bands, G2 validation, demon tiers | Implemented |
| `ODTheme.hx` | D1 palette, spacing, type face | Implemented |
| `ODButton.hx` | D2 normal/hover/pressed/disabled/focus | Implemented |
| `OverdriveMainMenuState.hx` | E1 layout, E2 separation, keyboard + mouse navigation | Implemented |

### What was actually checked

- All five files exist at the expected paths on `main` (confirmed by fetching
  the commits back into a local clone).
- Delimiters balance in every file (string- and comment-aware scan). This is a
  crude check. **It is not a compile and proves nothing about types.**
- `Paths.font`, `Paths.sound`, `Paths.image`, `ClientPrefs.data.*`,
  `Achievements.unlock`, `OptionsState.onPlayState` and `MusicBeatState.switchState`
  were confirmed against the real baseline source before being used.
- Nothing has been compiled, launched, or seen on screen.

---

## 3. Menu honesty rule

Two tiles are live: **PLAY** (`FreeplayState`) and **SETTINGS** (`OptionsState`).
Everything else is created disabled and prints the real reason when focused
(`COMMUNITY — unavailable: Needs the Song Portal`). This is deliberate: spec E4
forbids decorative placeholders, and spec A4 forbids pretending.

Consequence: **E4 is not yet satisfied**, because seven tiles do not open their
real destination. They must be replaced by real screens, not by removing the
labels.

---

## 4. Blocked items

| Item | Blocked by | Consequence |
|---|---|---|
| Any Windows build (spec B3, AC1, AD) | No Windows/MSVC/Haxe in the build environment | No binary, no screenshot, no gameplay gate |
| Song Portal, accounts, cloud saves (L, M, P) | A deployed backend + storage | Feature flags stay `false` |
| Multiplayer (N), clans (O), friends (Q) | Same, plus a realtime service | Menu tiles stay disabled |
| Daily / Weekly rotation (J) | Server-side datetime authority | Tiles stay disabled |
| Original artwork and icons (D1, AF) | Artist output; none exists | UI is drawn procedurally, no assets |
| Audio upload caps and storage budget (D-B1) | Owner decision, possible card requirement | Upload path unbuildable |

---

## 5. Phase progress (spec AF)

| Phase | State |
|---|---|
| 1 Baseline | Partially done: pin verified, source inspected, build documented. **Build not attempted.** |
| 2 Core engine | Started: config, rating model, design tokens, button, menu. Not routed, not branded, not compiled. |
| 3–8 | Not started. |

---

## 6. Next actions, in order

1. **Route the title screen.** In `source/states/TitleState.hx`, inside the
   `FlxTimer` callback, change `new MainMenuState()` to
   `new OverdriveMainMenuState()`. One identifier; same package, so no import.
   Then rebuild and confirm the menu appears and every key works.
2. **Rebrand `Project.xml`**: `title`, `file` (`OverdriveEngine`), `packageName`.
   Keep `main="Main"`. This changes the executable name, so update the build
   guide's path note at the same time.
3. **Build on Windows** and record gates G1–G9 from
   `docs/BUILDING-OVERDRIVE.md` §6 into `docs/UPSTREAM-BASELINE.md`.
4. **Song selection (F1/F2)**: replace PLAY's target with the GD-style selector
   and keep `FreeplayState` as the SONGS library. Do not merge them (E2).
5. **Skins (H1/H3)**: grid + preview + unlock state, cosmetic only.

Do not start Phase 4 (backend) before steps 1–3 pass on a real Windows machine.
A menu that has never been compiled is not a foundation.

---

## 7. Housekeeping

- `ODRating.starGlyphs()` contains a pointless `StringTools.lpad(..., 0)` call
  left from authoring. Harmless, but it should be simplified to `'${n}★'` the
  next time that file is touched.
