# Upstream Baseline Record

This file is the authoritative record of what Overdrive Engine was forked from (§2.4 step 5: "Record the upstream base commit/tag in project documentation"). Update it — never rewrite it — when the baseline is verified or the base changes.

---

## Import record

| Field | Value |
|---|---|
| Upstream repository | `https://github.com/ShadowMario/FNF-PsychEngine` |
| Product at upstream | Friday Night Funkin': Psych Engine |
| Version | **1.0.4** |
| Commit | `5c67ced49e5a98535298a6daa3f8f4ec79ac8399` |
| Tag | `1.0.4` (lightweight — tag object and commit are identical) |
| Release published | 2025-03-24T18:03:54Z |
| Licence | Apache-2.0 (verified from repository metadata and `LICENSE` at the tag) |
| Upstream status | **Archived 2025-03-31** — read-only, no further commits |
| Release artefacts | `PsychEngine-Windows64.zip` 370,294,016 B · `PsychEngine-Windows32.zip` 317,637,885 B · `PsychEngine-Linux.zip` 326,507,034 B · `PsychEngine-MacOS.zip` 389,090,824 B |
| Chart metadata format | `psych_v1` (with `psych_v1_convert` on load of older formats) |
| App version string in `Project.xml` | `0.2.8` — **not** the release version; see note below |

### Note on version identity

`gitVersion.txt` says `1.0.4`; `Project.xml` declares `version="0.2.8"`. These are different numbers for different purposes and both are upstream's own. Do not "fix" `Project.xml`'s version to satisfy a test — record the divergence and use the commit hash as the only trustworthy base identifier.

---

## How the import was performed

- **Method:** server-side fork of `ShadowMario/FNF-PsychEngine` into `DatOneFlareon/Overdrive-Engine`, preserving full upstream history and provenance.
- **Why a fork rather than a re-init:** it transfers the exact pinned tree without a 600 MB round trip through a build sandbox, keeps the upstream history available for `git log`/`git blame`, and makes the provenance of every inherited file explicit. The repository is independent from that point on; upstream cannot push to it.
- **Unmodified baseline:** the fork commit is byte-identical to upstream `5c67ced…`. No Overdrive source change exists yet. Documentation commits that follow do not alter gameplay code.

---

## Verification performed (sandbox, no Windows toolchain)

| Check | Result |
|---|---|
| Tag `1.0.4` resolves to `5c67ced…` | PASS — GitHub ref API |
| Licence is Apache-2.0 | PASS — repository metadata + `LICENSE` at tag |
| `source/states/editors/ChartingState.hx` present | PASS — 167,391 bytes |
| Chart format constant is `psych_v1` | PASS — `source/backend/Song.hx` |
| Build docs read at tag | PASS — `docs/BUILDING.md` (Haxe 4.3.4+, VS 2022, `lime test cpp`) |
| Library pins read at tag | PASS — `Project.xml` |
| Windows compile performed | **NOT PERFORMED** — no MSVC/Windows in this environment |
| Game run, song played, editor opened | **NOT PERFORMED** — same reason |

---

## Milestone 1 exit gates — pending on a Windows machine

Record the outcome of each gate from `docs/BUILDING-OVERDRIVE.md` §6 here.

| Gate | Status | Date | Notes |
|---|---|---|---|
| G1 pin verified locally | pending | — | `git rev-parse HEAD` |
| G2 `lime test cpp` compiles | pending | — | |
| G3 game launches | pending | — | |
| G4 song plays correctly | pending | — | |
| G5 Chart Editor opens | pending | — | |
| G6 Chart Editor edits and saves | pending | — | |
| G7 settings persist | pending | — | |
| G8 offline launch plays main song | pending | — | |
| G9 baseline committed before custom changes | pending | — | |

Milestone 1 is complete only when G1–G9 are all PASS.
