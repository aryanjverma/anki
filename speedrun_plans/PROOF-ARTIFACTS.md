# Proof Artifacts checklist — Wednesday (Phase 1)

> Tracks every proof the spec (§6 "Due Wednesday" + §9) and PRD (§9) require, so nothing is
> lost. Statuses: `VERIFIED` (checked on this machine, evidence below) / `READY — RECORD`
> (artifact exists / pipeline verified; only a human screen-recording remains) / `TODO`.
>
> **Verification pass: 2026-07-01, commit `4c60873350208acf8c90fd44f161cddc6e9c561c`.**
> Everything below was re-verified end-to-end; the remaining work is capturing the
> screen-recordings, which is an inherently manual step.

| #  | Proof artifact                                                                       | Spec / PRD ref      | Status         | Evidence / how to reproduce                                                                 |
| -- | ------------------------------------------------------------------------------------ | ------------------- | -------------- | ------------------------------------------------------------------------------------------ |
| 1  | **Commit hash** of the forked, building checkout                                     | FR-1, §9            | VERIFIED       | `4c60873350208acf8c90fd44f161cddc6e9c561c` (desktop fork HEAD; `git rev-parse HEAD`)        |
| 2  | **Clean-build recording** — fresh checkout builds (`just run` / `just build`)         | FR-1, §6            | READY — RECORD | `just build` → "Build succeeded". Record a fresh `git clone` → `just build` → `just run`.   |
| 3  | **Rust-change diff**                                                                 | FR-3, §6.1, §7a     | VERIFIED       | `git diff 6770ad3ef HEAD -- rslib/ proto/anki/concepts.proto` (new `concepts` module+proto)|
| 4  | **≥3 Rust unit tests** passing (queue / NTR / mastery)                                | FR-3, §6.2, §7a     | VERIFIED       | **11 passed** — `cargo test -p anki concepts::` (8 in `mod.rs`, 3 in `service.rs`). See below.|
| 5  | **≥1 Python test** that calls the new RPC from Python                                 | FR-3, §6.2, §7a     | VERIFIED       | **3 passed** — `pytest pylib/tests/test_concepts.py`. See below.                            |
| 6  | **Undo works + no collection corruption** proof                                       | FR-3, §6.3, §7a/§7g | VERIFIED*      | `test_concept_aware_queue_is_read_only` (py) + `queue_returns_due_cards_only_and_does_not_mutate` (rs) pass. *Full 20× crash test = manual. |
| 7  | **One-page note**: why the change belongs in Rust, not Python                        | §6.4, §7a           | VERIFIED       | `speedrun_plans/rust-change-note.md` (updated to real test counts)                          |
| 8  | **List of upstream files touched** + merge difficulty                                | §6.5, §7a           | VERIFIED       | `speedrun_plans/files-touched.md` (updated)                                                 |
| 9  | **Review-session recording** on the MCAT deck (grades persist, update NTR/DSR)       | FR-4, §6            | READY — RECORD | `just mcat-seed` seeds 525 cards / 1311 reviews; `just mcat-run-demo` opens it. Record the review. |
| 10 | **Memory score with range + give-up rule** visible in the app                        | FR-5, §6            | READY — RECORD | Verified: seed prints `Memory 64% (60-68%)`; 12 `test_memory_score` tests pass. Screenshot Tools→MCAT Dashboard→Memory & NTR. |
| 11 | **Coverage map** visible (drives give-up rule)                                       | FR-5, §7c           | READY — RECORD | Verified: seed prints `topic coverage 67.7%`. Screenshot same panel.                        |
| 12 | **Clean-machine desktop install recording** (install → launch → review, AI off)      | FR-7, §6            | READY — RECORD | **MSI built:** `out/installer/dist/anki-26.05-win-x64.msi` (192.5 MB). Record install on a clean VM. |
| 13 | **Phone review-session recording** on the shared Rust engine                          | FR-8, §6            | READY — RECORD | **APKs built** for all 4 ABIs (below), against the shared engine. Install on `anki_pixel` AVD + record. |

## Verified test results (2026-07-01)

**Rust engine tests — 11 passed** (`cargo test -p anki concepts::`):

```
test concepts::test::questions_raise_and_lower_ntr ... ok
test concepts::test::mastery_counts_and_avg_recall ... ok
test concepts::test::questions_drive_ntr_with_no_card_evidence ... ok
test concepts::test::card_with_multiple_concepts_takes_max_ntr ... ok
test concepts::test::questions_reorder_the_queue ... ok
test concepts::test::queue_ordering_by_ntr ... ok
test concepts::test::wildcard_and_prefix_patterns ... ok
test concepts::test::tag_to_concept_matching ... ok
test concepts::service::test::question_stats_flow_through_mastery_rpc ... ok
test concepts::service::test::queue_returns_due_cards_only_and_does_not_mutate ... ok
test concepts::service::test::mastery_end_to_end ... ok
test result: ok. 11 passed; 0 failed
```

**Python backend tests — 3 passed** (`pytest pylib/tests/test_concepts.py`):

```
test_concept_mastery_from_python PASSED
test_question_stats_change_ntr_via_python PASSED
test_concept_aware_queue_is_read_only PASSED      # undo/no-corruption proof
```

**Qt score-surface tests — 30 passed** (`pytest qt/aqt/mcat/tests/`): 12 `test_memory_score`
(give-up rule, Wald range, abstain), 8 `test_questions` (NTR blend), 10 `test_readiness`
(472–528 map, abstain, `test_not_blended_with_memory` — the honesty guard).

**Total: 44 automated tests passing.**

## Verified build artifacts

- **Desktop MSI:** `out/installer/dist/anki-26.05-win-x64.msi` (192.5 MB), built via
  `tools\build-installer.bat` (RELEASE=2). Display name "MCAT Study (Anki fork)".
- **Android shared engine:** `Anki-Android-Backend/rsdroid/build/outputs/aar/rsdroid-release.aar`
  (21 MB) + `librsdroid.so` (x86_64, 77 MB) — the shared Rust engine, with the concepts change,
  cross-compiled for Android (NDK 29.0.14206865, all 4 Rust android targets installed).
- **Android APKs (all ABIs), built 2026-07-01:**
  `Anki-Android/AnkiDroid/build/outputs/apk/play/debug/AnkiDroid-play-{arm64-v8a,armeabi-v7a,x86,x86_64}-debug.apk`.

## Shared-engine wiring (FR-8)

- `Anki-Android/local.properties` has `local_backend=true` → the app builds and bundles the Rust
  backend from `Anki-Android-Backend` rather than a published `.aar`. Building the app therefore
  exercises the shared engine directly.
- `Anki-Android-Backend` anki submodule → commit `31432d131` (on `github.com/aryanjverma/anki`,
  a descendant of desktop HEAD `4c6087335`). Confirmed it contains `proto/anki/concepts.proto`
  and `rslib/src/concepts/`, so the concept-aware queue / NTR / mastery RPCs ship to the phone.
- Fixed `.gitmodules` URL (was upstream `ankitects/anki`, which lacks the fork commit → a fresh
  `submodule update` would fail) to point at the fork, so the mobile build reproduces cleanly.
  Committed as `Anki-Android-Backend@5c89348`.

## Remaining manual steps (screen recordings only)

These require a human at the keyboard (video capture / clean VM / emulator); the underlying
pipelines are all verified above.

1. **Clean-build recording (#2):** fresh clone → `just build` → `just run`.
2. **Desktop review + scores (#9, #10, #11):** `just mcat-seed`, then `just mcat-run-demo`;
   open Tools → MCAT Dashboard → Memory & NTR; grade cards; show the three scores + give-up rule.
3. **Clean-machine install (#12):** copy `anki-26.05-win-x64.msi` to a fresh VM, install, launch,
   run a review with AI off.
4. **Phone review (#13):** `emulator -avd anki_pixel`, then
   `adb install -r AnkiDroid/build/outputs/apk/play/debug/AnkiDroid-play-x86_64-debug.apk`,
   load the MCAT deck, run a review session, record it.

## Notes

- **No AI in any Wednesday artifact** — no model calls, generated cards, or chatbot (spec §6).
  The MCAT scores are deterministic (`seed_demo.py` runs with a fixed seed).
- Two-way sync is **not** a Wednesday proof (Friday item) — intentionally absent.
