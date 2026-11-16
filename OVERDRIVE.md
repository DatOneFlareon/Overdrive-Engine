# Overdrive Engine

A standalone, FNF-inspired rhythm-game engine and community platform, forked from official **Psych Engine 1.0.4**, with a Geometry Dash-inspired presentation and original online systems.

> **Status: Milestone 1 — clean baseline fork. No Overdrive source changes, no build, no release yet.**
> This repository currently contains the unmodified upstream engine plus baseline documentation. Nothing has been compiled or deployed.

---

## The pin

| | |
|---|---|
| Base | Psych Engine **1.0.4** |
| Commit | `5c67ced49e5a98535298a6daa3f8f4ec79ac8399` |
| Upstream | [ShadowMario/FNF-PsychEngine](https://github.com/ShadowMario/FNF-PsychEngine) — archived 2025-03-31, read-only |
| Licence | Apache-2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE) |
| Chart format | `psych_v1`, inherited as-is |
| Target | Windows 10/11 64-bit, ZIP distribution, integrated graphics |

Verify the base before building:

```bat
git rev-parse HEAD
:: must print 5c67ced49e5a98535298a6daa3f8f4ec79ac8399
```

---

## Documentation in this repository

| Document | Purpose |
|---|---|
| [docs/BUILDING-OVERDRIVE.md](docs/BUILDING-OVERDRIVE.md) | Windows toolchain, disk budget, build steps, verification gates, troubleshooting |
| [docs/UPSTREAM-BASELINE.md](docs/UPSTREAM-BASELINE.md) | Import record, what was verified, and the pending Milestone 1 exit gates |
| [NOTICE](NOTICE) | Apache-2.0 modification statement and attribution |
| [docs/BUILDING.md](docs/BUILDING.md) | Upstream's own build instructions (retained, unmodified) |

The wider planning set (feasibility report, confirmed-requirement checklist, open-decision register, architecture, milestone plan, risk register, licence register) is prepared and will be committed in the next documentation commit.

---

## Quick start (Windows)

```bat
git clone https://github.com/DatOneFlareon/Overdrive-Engine.git
cd Overdrive-Engine
haxelib setup          :: repository path: .haxelib
cd setup && windows.bat && cd ..
lime test cpp
```

Full requirements, including the **use Visual Studio Build Tools, not the full IDE** disk advice, are in [docs/BUILDING-OVERDRIVE.md](docs/BUILDING-OVERDRIVE.md).

---

## Settled product direction

- Windows-only at launch; ZIP distribution, no installer.
- **No Story Mode.** Songs are played individually.
- **PLAY and SONGS are separate buttons**; PLAY is the main song list, SONGS the full library.
- The **Chart Editor stays exactly as Psych 1.0.4 ships it** — Overdrive adds Song ID loading around it, never a replacement.
- **Skins**, not Garage; characters are cosmetic only.
- Wish Cloud is inside the game, not on the Song Portal.
- Song Portal uploads are audio-only, produce a Song ID immediately, and have **no approval queue**.
- Central accounts, automatic cloud saves, owner-controlled official ratings, one global Demonlist (Extreme Demons only).
- Strict £0 hosting with graceful, honest limits.

---

## Provenance and licensing

Overdrive Engine is a modified fork. Upstream is not affiliated with this product. Psych Engine's Apache-2.0 terms are retained in full; modified files are listed in [NOTICE](NOTICE). Geometry Dash material was used only as a layout reference — no Geometry Dash artwork, icons, audio or other assets are included.

Friday Night Funkin' and related marks belong to their respective owners.
