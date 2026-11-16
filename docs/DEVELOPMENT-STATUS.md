# Development Status

Last updated: 2026-11-16 (Phase 2 integration). This file is the resume point.
It must stay truthful even when that is unflattering: the specification (Part
A4, Part AC) forbids marking anything as working that has not been run.

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

## 2. Commit ledger

| Commit | Contents |
|---|---|
| `fa759df` | Windows build guide, upstream baseline record |
| `88fbf76` | `OVERDRIVE.md`, Apache-2.0 `NOTICE` |
| `f6a6996` | `ODConfig.hx` — identity, profiles, feature flags, timeouts |
| `9ada447` | `ODRating.hx` — global star model (G1) |
| `de0455b` | `ODTheme.hx` — design tokens |
| `f1c1379` | `ODButton.hx` — five-state button |
| `ad5a102` | `OverdriveMainMenuState.hx` — the menu |
| `ef902f7` | this ledger |
| `da54c7f` | **title screen now opens the Overdrive menu** |
| `379f748` | **`Project.xml` rebranded to Overdrive Engine** |

The engine tree is still upstream `5c67ced…` except for the two files in §3.

---

## 3. Modified inherited files (complete list)

| File | Change | Diff size |
|---|---|---|
| `source/states/TitleState.hx` | transition target `MainMenuState` → `OverdriveMainMenuState` | 3 insertions, 2 deletions |
| `Project.xml` | `<app>` element: title, exe name, package, company, version | 1 insertion, 1 deletion |

Both diffs were verified by fetching the commits back and diffing against their
parents. **`Project.xml` is exactly the intended single line** and parses as
well-formed XML (74 top-level children, `<app>` = Overdrive Engine /
OverdriveEngine / 0.1.0).

`TitleState.hx` is **not** a clean single-line diff: besides the intended change
it introduced two inert lines — a stray `titleJSON.startx;` statement and one
whitespace-only line. Neither alters behaviour, but both are sloppy and must be
removed on the next touch of that file. Everything else in the file is
byte-identical to upstream.

`PSYCH_WATERMARKS` is still defined. Removing it now would leave a blank spot on
the loading screen because no Overdrive logo artwork exists yet.

---

## 4. Implemented, not compiled

| File | Covers | State |
|---|---|---|
| `ODConfig.hx` | C3 configuration, per-profile endpoints, feature flags | Implemented |
| `ODRating.hx` | G1 star bands, G2 validation, demon tiers | Implemented |
| `ODTheme.hx` | D1 palette, spacing, type face | Implemented |
| `ODButton.hx` | D2 normal/hover/pressed/disabled/focus | Implemented |
| `OverdriveMainMenuState.hx` | E1 layout, E2 separation, keyboard + mouse navigation | Implemented |

### Checks actually run

- Every commit fetched back: files exist at the expected paths.
- Delimiter balance in all new `.hx` files (string/comment aware). Crude, not a
  compile, proves nothing about types.
- `Project.xml` parsed with an XML parser; `<app>` attributes read back.
- `TitleState.hx` and `Project.xml` diffed against their parents; the exact
  per-file diff is quoted in §3.
- Engine API usage (`Paths.*`, `ClientPrefs.data.*`, `OptionsState.onPlayState`,
  `MusicBeatState.switchState`, `Achievements.unlock`) confirmed against real
  baseline source.
- **Not run:** compile, launch, any menu interaction, any gameplay. There is no
  Windows, MSVC or Haxe in this environment.

---

## 5. Menu honesty rule

Live tiles: **PLAY** (`FreeplayState`) and **SETTINGS** (`OptionsState`).
All others are created disabled and print their real blocker when focused
(`COMMUNITY — unavailable: Needs the Song Portal`). Spec E4 forbids decorative
placeholders; spec A4 forbids pretending.

Consequence: **E4 remains unsatisfied.** Seven tiles do not open their real
destination. They must be replaced by real screens, never by deleting labels.

---

## 6. Blocked

| Item | Blocked by |
|---|---|
| Any Windows build (B3, AC1, AD) | No Windows/MSVC/Haxe in this environment |
| Song Portal, accounts, cloud saves (L, M, P) | A deployed backend and storage |
| Multiplayer (N), clans (O), friends (Q) | Same, plus realtime service |
| Daily/Weekly rotation (J) | Server-side time authority |
| Original artwork, logo, icons (D1) | Artist output; none exists |
| Upload caps, storage budget (D-B1) | Owner decision; R2 needs a payment card |

---

## 7. Next actions, in order

1. **Build on Windows and run gates G1–G9** (`docs/BUILDING-OVERDRIVE.md` §6),
   now exercising the new path: title screen → Overdrive menu → PLAY → song →
   Chart Editor. Record results in `docs/UPSTREAM-BASELINE.md`.
   This is the top item. Nothing below should be trusted as working before it.
2. Clean the two inert lines in `TitleState.hx`; simplify `ODRating.starGlyphs`.
3. Song selection (F1/F2): PLAY opens the GD-style selector; `FreeplayState`
   becomes SONGS. Do not merge them (E2).
4. Skins (H1/H3): grid, preview, lock state, cosmetic only.
5. Accessibility (Part 17) on top of existing `ClientPrefs`.

Do not start Phase 5 (backend) before steps 1–2 pass on a real machine.

---

## 8. Known blemishes

- `TitleState.hx`: stray `titleJSON.startx;` and one whitespace-only line (§3).
- `ODRating.starGlyphs()`: pointless `StringTools.lpad(..., 0)` call; should be
  `'${n}★'`.
- `OverdriveMainMenuState`: the footer wallet shows em-dashes rather than real
  balances because no account system exists. That is deliberate, not a bug, and
  must change when accounts land.
