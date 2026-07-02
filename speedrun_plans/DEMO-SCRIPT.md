# Wednesday demo — running order (3–5 min)

> Exam: **MCAT** (472–528; four sections 118–132). Phase 1 = core works on both screens, **no AI**.
> Commit: `4c60873350208acf8c90fd44f161cddc6e9c561c`. Everything shown is deterministic.

Lead with the two things that carry the most grade weight and the two hard caps: the **real Rust
engine change** (20%, avoids the 50% cap) and the **phone sharing that engine** (avoids the 70% cap).

## Setup before recording

```powershell
just mcat-seed          # seeds 525 cards / 21 concepts / 1311 reviews into a throwaway profile
just mcat-run-demo      # opens Anki against that demo profile
# emulator (separate): emulator -avd anki_pixel
```



## Running order

**0:00 — Framing (20s).** "One exam: MCAT. Three scores we never blend — Memory, Performance, Readiness. Honesty rule: no number without its evidence and a give-up rule. No AI today — everything is deterministic."

**0:20 — The Rust engine change (60s). [20% of grade]**

- Show `rslib/src/concepts/mod.rs` + `proto/anki/concepts.proto`: a new `ConceptsService` with
`ConceptAwareQueue` + `ConceptMastery` RPCs; per-concept **NTR = topic_weight × weakness**.
- Run `cargo test -p anki concepts::` → **11 passing**; `pytest pylib/tests/test_concepts.py` → **3 passing**.
- Say why Rust: perf on 50k cards, ships to phone for free, type-safe proto, undo/integrity next
to FSRS. Point at `test_concept_aware_queue_is_read_only` → **undo-safe, read-only**.

**1:20 — Review loop on the MCAT deck (40s). [FR-4]**

- In the running app, study the deck; grade a few cards; the next card appears immediately.
- Note grades persist and feed NTR/DSR.

**2:00 — The three scores, honestly (70s). [20% of grade]**

- Tools → MCAT Dashboard → Memory & NTR. Show, as **three separate** numbers with ranges:
  - **Readiness**: Projected MCAT **501 (likely 488–514)**, confidence medium — plus the
  disclaimer that it's an unvalidated heuristic (`472 + 56 × p`) and the single best next topic.
  - **Memory**: **64% (60–68%)**, "how sure" medium.
  - **Coverage**: **67.7%** of the exam outline.
- Show the **give-up rule**: below the threshold the app abstains and names the failing condition.
- Show the **NTR bar chart**: e.g. concept `1D` has 47% card recall but 90% question accuracy →
its NTR drops. Say explicitly: **question performance feeds NTR only, never Memory** (honesty guard).

**3:10 — Phone on the same engine (60s). [avoids 70% cap]**

- Emulator: install `AnkiDroid-play-x86_64-debug.apk` (built today against the shared backend).
- Explain `local_backend=true` + the backend submodule at `31432d131` carries `rslib/src/concepts`,
so the Rust change runs unchanged on the phone.
- Load the MCAT deck; run a short review session on the phone.
- (Wednesday needs the phone reviewing the same deck; two-way sync is Friday.)

**4:10 — Proof + close (30s).**

- Show `out/installer/dist/anki-26.05-win-x64.msi` (clean-machine installer).
- "44 automated tests green; engine change is additive and undo-safe; phone runs the same engine.
Readiness is deliberately labeled unvalidated — per the spec, an honest 'we can't back this yet'
beats a fabricated number." Point to `speedrun_plans/PROOF-ARTIFACTS.md`.



## Anticipated questions (be ready)

- **"Isn't Readiness made up?"** No — it's a documented deterministic map with a range, a coverage
gate, and a plain disclaimer that it isn't validated against practice tests yet. That's the §9
"grade the bridge, not a fake number" stance.
- **"How is this a real engine change?"** New Rust module + new protobuf service, 11 Rust tests,
called from Python; not a Python-side reskin.
- **"Does the phone really share the engine?"** The APK bundles `librsdroid.so` built from the
same `rslib` (submodule with `concepts/`); no scheduler was reimplemented in Kotlin.
- **"What's out of scope today?"** AI, two-way sync, validated Performance/Readiness models,
lessons/onboarding/reimagined dashboard — all Friday/Sunday per the spec.

