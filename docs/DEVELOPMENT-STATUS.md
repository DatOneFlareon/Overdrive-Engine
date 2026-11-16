# Development Status

Last updated: 2026-11-16 (Phase 3, song selection). This file is the resume
point. It must stay truthful even when that is unflattering.

---

## 1. Verification legend

| Term | Meaning |
|---|---|
| **Implemented** | Source exists and was reviewed. |
| **Built** | Compiled to a Windows binary. **Nothing is Built.** |
| **Tested** | Observed running. **Nothing is.** |
| **Blocked** | Needs something outside this environment. |

---

## 2. Commit ledger (Phase 3)

| Commit | Contents |
|---|---|
| `139af9b` | removed my two inert lines from `TitleState.hx` |
| `4fbe4c5` | `ODRating`: `starGlyphs` fix, `bandLabel`, `categoryForDifficulty` |
| `7b6e0c5` | `ODSongLibrary` — local library model |
| `4082188` | `OverdriveSongSelectState` — the PLAY screen |
| `81099db` | `OverdriveSongLibraryState` — the SONGS screen |
| `bab1652` | menu routes PLAY and SONGS, adds the SONGS tile |

---

## 3. Verified deviations from upstream `5c67ced`

`git diff --no-renames --name-status 5c67ced bab1652` → **15 paths: 13 added,
2 modified.**

| Modified | Diff |
|---|---|
| `Project.xml` | 1 line (`<app>` identity) |
| `source/states/TitleState.hx` | **1 line** (`MainMenuState` → `OverdriveMainMenuState`) |

The TitleState diff was re-verified after `139af9b`:

```
@@ -390 +390 @@
-					MusicBeatState.switchState(new MainMenuState());
+					MusicBeatState.switchState(new OverdriveMainMenuState());
```

No other inherited file is touched.

---

## 4. Implemented this phase

| File | Purpose |
|---|---|
| `overdrive/songs/ODSongLibrary.hx` | Week-file loader, lock rule, search, per-week difficulties |
| `states/OverdriveSongSelectState.hx` | PLAY: one song, prev/next, difficulty, band, mode, load |
| `states/OverdriveSongLibraryState.hx` | SONGS: paged list, live search, category filter |
| `states/OverdriveMainMenuState.hx` | PLAY and SONGS routed; SONGS tile added |
| `overdrive/ODRating.hx` | `bandLabel`, `categoryForDifficulty` |

### The playback path actually used

```haxe
WeekData.setDirectoryFromWeek(week);
Difficulty.loadFromWeek(week);
var chart = Highscore.formatSong(folder, diffIndex);
Song.loadFromJson(chart, folder);
PlayState.isStoryMode = false;
PlayState.storyDifficulty = diffIndex;
ClientPrefs.data.gameplaySettings.set('practice', practiceMode);
LoadingState.prepareToSong();
LoadingState.loadAndSwitchState(new PlayState());
```

That is the inherited pipeline, not a copy. `practice` is the exact key
`PlayState` reads (`ClientPrefs.getGameplaySetting('practice')`, PlayState.hx:304)
and the same one `GameplayChangersSubstate` writes.

---

## 5. Not done, and why

| Phase 3 item | State | Reason |
|---|---|---|
| Results screen | **not implemented** | Psych 1.0.4 has no results state. `PlayState.endSong()` calls `switchState(new FreeplayState())` (PlayState.hx:2502). Hooking Overdrive results needs a ~1-line edit in a ~2,600-line file; that file cannot be safely rewritten through the commit API. Needs a local `git push` with credentials, or a human edit. |
| Skins | **not implemented** | Needs the character grid screen; no Overdrive art exists. |
| Accessibility additions | **not implemented** | Foundation only: existing `ClientPrefs` options are untouched and still work. |
| Star ratings per song | **absent by design** | No rating data exists. Screens show the category band (2, 3, 4-5, 6-7, 8-9, 10) and label everything else Unrated. |
| Chart Editor via Community | **not wired here** | Community is Phase 6. The editor is still reachable the inherited way: SONGS → FreeplayState → Chart Editor. |

---

## 6. Checks run / not run

**Run:** file presence at expected paths; delimiter balance in every Overdrive
`.hx`; `git diff` of both modified inherited files; path audit against upstream.

**Not run:** compilation, launch, menu traversal, song load, gameplay, practice
run, results, character selection, Chart Editor. No Windows, MSVC or Haxe here.

No test in Phase 3 section 13 of the prompt can be marked passed. Every one of
them requires a running binary.

---

## 7. Next actions

1. **Windows build + gates G1–G9**, now through: title → menu → PLAY → song →
   Chart Editor. This is still the top item and unblocks every "tested" claim.
2. **Results screen**: add the hook in `PlayState.endSong()` on a machine with
   push credentials, then `OverdriveResultsState` reads `PlayState` stats.
3. **Skins**: character grid from real `characters/` assets, cosmetic only.
4. **Accessibility**: colourblind palettes, reduced shake/effects, UI scale,
   note transparency — each must actually affect rendering or not ship.
5. Then Phase 5 (backend), which is blocked on deployment and D-B1.
