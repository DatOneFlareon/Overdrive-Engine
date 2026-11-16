# Building Overdrive Engine on Windows

**Status: written from verified upstream facts, not yet executed on a Windows machine.** The steps below are Psych Engine 1.0.4's own documented build process (verified from `docs/BUILDING.md` at tag `1.0.4`) with Overdrive's pin, disk advice and verification gates added. Until Milestone 1's exit gate runs on your PC, treat the build as unproven.

---

## 1. The pin

| | |
|---|---|
| Base | Psych Engine **1.0.4** |
| Commit | `5c67ced49e5a98535298a6daa3f8f4ec79ac8399` |
| Tag object | lightweight tag; tag and commit are the same object |
| Released | 2025-03-24 |
| Upstream | `https://github.com/ShadowMario/FNF-PsychEngine` (archived 2025-03-31, read-only) |
| Licence | Apache-2.0 |
| Chart format | `psych_v1` (auto-converts older formats on load) |

Never build from a branch name. Check the commit before your first build:

```bat
git rev-parse HEAD
```

Must print `5c67ced49e5a98535298a6daa3f8f4ec79ac8399`.

---

## 2. Toolchain

| Component | Requirement | Notes |
|---|---|---|
| Windows | 10 or 11, 64-bit | Windows 10 SDK 19041 is enough |
| Haxe | **4.3.4 or greater** (upstream requirement) | 4.3.5 is a safe choice |
| haxelib | ships with Haxe | run `haxelib setup` once |
| C++ compiler | **Visual Studio Build Tools 2022** with the "Desktop development with C++" workload | See §3 — use Build Tools, not the full IDE, to save disk |
| git | any current version | for `git-scm` and for the `git`-sourced haxelibs |
| lime/openfl | installed by `setup\windows.bat` | do not install by hand; the script pins versions |

Pinned library versions come from `Project.xml` at the tag: flixel 5.6.1, flixel-addons 3.2.2, tjson 1.4.0, hscript-iris 1.1.3, hxvlc 2.0.1, hxdiscord_rpc 1.2.4, plus git-sourced flxanimate, linc_luajit, funkin.vis and grig.audio.

---

## 3. Disk budget (read this first)

The development machine has had under 10 GB free. Do not install the full Visual Studio Community IDE unless you have the room.

| Choice | Approximate footprint |
|---|---|
| Build Tools 2022 + C++ workload only | **2–4 GB** ← recommended |
| Visual Studio Community 2022 + C++ workload | 4–7 GB |
| Haxe + haxelib libraries (incl. four git-sourced ones) | 200–500 MB |
| Source checkout | 150–400 MB |
| `export\windows\cpp` build output | 1–2 GB per clean build |

Rules that keep you under budget:

1. Install Build Tools, not the IDE. The upstream installer script pulls all of Community, including the IDE you don't need.
2. Build only the Windows 64-bit target. Never run the Linux or macOS targets; they add GBs of nothing useful.
3. Delete `export\` before a clean rebuild instead of keeping several build trees:
   ```bat
   rmdir /s /q export
   ```
4. Check free space before you start:
   ```bat
   wmic logicaldisk get size,freespace,caption
   ```

---

## 4. First-time setup

```bat
:: 1. Clone the Overdrive repository (not upstream) and enter it
git clone https://github.com/DatOneFlareon/Overdrive-Engine.git
cd Overdrive-Engine
git rev-parse HEAD

:: 2. Install Haxe 4.3.5, then point haxelib at a local repo folder
haxelib setup
::    when asked for the repository path, type: .haxelib

:: 3. Run the repository's own dependency installer
cd setup
windows.bat
cd ..
```

Wait for the script to print **Finished!**. It installs lime, openfl, flixel and the rest at the versions Psych 1.0.4 expects, from `setup/` in this repository.

If `haxelib` complains it is not configured, re-run `haxelib setup` and accept the default path.

---

## 5. Build and run

```bat
lime test cpp
```

- First compile takes roughly 5–10 minutes (upstream's own estimate). Later builds are much faster.
- `lime test cpp` compiles and launches. For a build without launching, use `lime build cpp`.
- The executable lands in `export\windows\cpp\` (or under `export\release\windows\` for a release build). The exact folder is chosen by `Project.xml`'s `<app file="..."/>` — currently `PsychEngine`, which Milestone 2 renames.

For a distributable build (Milestone 16):

```bat
lime build windows -release
```

---

## 6. Milestone 1 verification gates

Do these in order and record the results in `docs/UPSTREAM-BASELINE.md`. A build that compiles but fails a gameplay gate is not a green baseline.

| Gate | Check | Pass condition |
|---|---|---|
| G1 | `git rev-parse HEAD` | equals `5c67ced…` |
| G2 | `lime test cpp` | completes with no errors |
| G3 | Game launches | main menu appears, no black screen |
| G4 | Play a song | notes, vocals, health, score and misses behave normally |
| G5 | Chart Editor opens | via the existing editor entry point; layout is untouched |
| G6 | Chart Editor works | load a chart, place notes, save, reload |
| G7 | Settings persist | change a setting, restart, setting survives |
| G8 | Offline launch | disable the network, launch, play a main song |
| G9 | Baseline recorded | commit hash + build date + result written into `docs/UPSTREAM-BASELINE.md` |

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `ApplicationMain.exe : fatal error LNK1120: 1 unresolved externals` | stale C++ objects | `lime test cpp -clean`, or delete `export\` and rebuild |
| `haxelib` cannot find a library | `haxelib setup` never ran, or the wrong repo path | re-run `haxelib setup`, then `setup\windows.bat` again |
| `flxanimate`/`linc_luajit` install fails | these are git-sourced, not version-pinned on haxelib | install git, then re-run setup; the script fetches specific refs |
| Compile succeeds, window is blank | graphics driver / OpenGL context | update GPU drivers; integrated graphics is supported, but ancient drivers are not |
| `Error: Could not find haxelib "lime"` | setup script ran in the wrong directory | run it from `setup\`, not from the repository root |
| Build is very slow every time | antivirus scanning `export\` | exclude the repository folder from real-time scanning |

---

## 8. What this document does not claim

- It does not claim a Windows build has been performed for Overdrive. It has not.
- It does not claim the toolchain works on your specific machine. Gates G2–G8 must be run by you.
- It does not cover the Song Portal or the backend; those are separate deploy targets with their own instructions (Milestone 6).

When G1–G9 pass, add the results to `docs/UPSTREAM-BASELINE.md` and Milestone 1 is complete.
