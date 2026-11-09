# Recorded pool-contact checkpoint — 2026-11-09

Candidate improvement; **not full AUD acceptance**. The previous four sine/noise effects have been replaced by edited real pool recordings in every contact class. No competitor assets or physics coefficients were used. Main checkout only; ownership is audio assets, TableAudio, audio tests/tools and this report. Other working changes belong to the parent.

## Contract and bounded scope

Read QUALITY_TARGETS, controls/presentation AUD branch, F-AUDIO/F-PERCEPTION, TASK and NEXT_CHECKPOINT before editing. Selected AUD-001–008, with objective asset/event/mix checks separated from listening, device timing and panel acceptance. Expected counterexamples: resonant synthetic beep substituted for impact, one waveform pitch-shifted for all classes, same-frame true contacts deleted, an active pocket tail continuing after mute, clean isolated files clipping when overlapped. Active engine/event API remains PhysicsStepper → `play_contact(kind,speed)`.

## Research and asset decision

[KVV Audio's cue recording](https://freesound.org/people/KVV_Audio/sounds/851086/), [single-ball impacts](https://freesound.org/people/KVV_Audio/sounds/851087/) and [empty-pocket drops](https://freesound.org/people/KVV_Audio/sounds/851090/) explicitly identify their classes and a Zoom H5/XYH-5 recorder. Each contains five separated onsets; the edited game set has **5 ball, 5 cue, 5 pocket** onsets. These are separate portions of actual creator-labelled recordings, not pitch copies. The published original specification is 96kHz/24-bit stereo; originals require login. We used the exact public **HQ MP3 preview** URLs supplied in original HTML, so source fidelity is lossy and is not represented as original-WAV quality. Each original page states CC BY 4.0. Creator also requests credit and no raw-stock redistribution; only edited game contacts are distributed, with full attribution/modification notices in [CREDITS](../../../assets/audio/CREDITS.md).

The [rail recording by mccarthy@bedmas.com](https://freesound.org/people/mccarthy%40bedmas.com/sounds/42364/) explicitly identifies a pool ball hitting a rail and is CC0. Its Nokia 6125i phone capture is a material quality limitation. It supplies **one real rail take**, not the required three. Repeated copies with altered pitch would conceal this missing evidence, so they were not fabricated. Upgrade acquisition remains open.

Other researched recordings: [juskiddink's dry mid-air ball impact](https://freesound.org/people/juskiddink/sounds/108615/) (CC BY4.0, NT4/BMA2/R09HR, 84ms); [bsumusictech's pool-ball recording](https://freesound.org/people/bsumusictech/sounds/62331/) (CC0); [Za-Games' billiard clack](https://freesound.org/people/Za-Games/sounds/539854/) (CC0); [csaszi's pool shots](https://freesound.org/people/csaszi/sounds/350918/) (CC0); [jtroan's corner-pocket recording](https://freesound.org/people/jtroan/sounds/241373/) (CC BY3.0); [Caitlin_100's potting recording](https://freesound.org/people/Caitlin_100/sounds/365525/) (CC0). They were not arbitrarily relabelled by spectral appearance. Rejected the explicitly noncommercial [150112 cue sample](https://freesound.org/people/150112/sounds/324737/). No purchases, accounts, proprietary game extraction or guessed CDN addresses.

[Riner and Petculescu, JASA 2010](https://pubmed.ncbi.nlm.nih.gov/20649208/), DOI10.1121/1.3438477, relates plastic-sphere acoustic emission to transient acceleration/contact force. Its polypropylene experiment is a conceptual basis for preserving a short impact rather than inventing a sustained note; its material/numerical results are **not phenolic-pool calibration**. [Kim's cue-stroke paper](https://doi.org/10.3938/NPSM.72.208) discusses a brief tip contact and cue-end vibration: that supports retaining a different recorded cue-body transient rather than making cue and ball identical. Material class still requires listening. The selected recordings preserve cue body/room decay, brief ball transients, a separate rail body, and pocket-drop structure without added tonal oscillators or reverb.

[Godot's audio-bus documentation](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) identifies digital clipping and keeping the final bus below 0dB. Practical mix decisions: bounded variants, unshifted pitch, gain as the strength control, peak headroom, separate event integrity from acoustic congestion, and measured output after the actual Contacts limiter. These are authored mix choices, not a claim to have measured Miniclip's mix.

## Reproduction and provenance

`assets/audio/sources/*.json`: exact page/preview/licence URLs, retrieval date, creator, raw MP3 SHA256, HTML SHA256 and archive paths. Raw previews and HTML are archived at `/Users/gt/.codex/audio-source-archive/pool-2026-11-09/` outside the distributable repository. Original synthetic WAVs and generator are preserved in `assets/audio/baseline/`.

`python3 tools/generate_audio.py --source-dir /Users/gt/.codex/audio-source-archive/pool-2026-11-09` decodes verified preview bytes using FFmpeg, downmixes/resamples to mono44.1kHz PCM, trims each identified onset, removes DC, applies a 0.2ms attack ramp and 25ms final fade, matches early-body RMS subject to a -4dBFS stored-peak ceiling, writes16-bit PCM. Exact offsets, gains and output SHA256 are in `recorded_contacts.json`. No added oscillator, pitch shift, reverb or compression. Original four filenames remain compatible aliases for first variants.

TableAudio uses its own RNG and avoids immediate repeats. Speed is the unchanged input proxy for impulse/energy within each class; `-18 + 12 log10(speed)` dB is monotonic over the nine tested legal speeds, bounded -46..-7dB; fixed small class offsets balance cue/rail/pocket. Pitch stays1.0. No physics RNG consumption or parameter changes. 32 fixed voices replace12; saturated replacement requests a6ms tail fade and reserves that voice during the fade. Starts, steals and drops are counted. Mute invalidates queued starts and fades/stops current voices. Tween fades are **render-frame scheduled**, so a requested6ms is not a sample-accurate6ms ramp or evidence for the10ms mute bound. Audible clicking on these transitions remains unverified.

## Actual checks and limitations

- `bash tools/godot.sh --headless --path . --script tests/audio_contacts.gd`: **0 failures**. Four classes/declared variants load, no immediate repeats, nine gains increase, cosmetic selection preserves global RNG;100 simultaneous real-stream submissions keep32 fixed voices and record32 initial starts/32 steal decisions/36 drops. Mute releases reservations/stops tails; unmute resurrects none. Historical actual two-independent-physics-impact fixture and100 event-only delivery test remain intact. Event-only portion deliberately uses null streams; it is not a mix/listening test.
- `bash tools/godot.sh --headless --path . --script tests/practice_flow.gd`: **42 checks,0 failures**. It prints an existing shutdown warning (3 ObjectDB instances/1 resource); no listening/physical-fidelity inference follows from these checks.
- `python3 tools/check_audio.py`:16 edited-onset hashes/endpoints/peak bounds, five distinct file hashes per ball/cue/pocket, nine strength gains. Ball maxima arrive0.88–0.98ms after trimmed start;90% integrated energy arrives1.56–4.63ms. Cue maxima2.02–5.46ms; rail5.80ms; pocket strongest drop59–76ms after initial recorded activity. These are objective envelopes, not perception or propagation measurements.
- Actual rendered Godot MovieMaker mix: `bash tools/godot.sh --path . --rendering-method gl_compatibility --resolution 64x64 --fixed-fps 120 --write-movie captures/audio/real-contact-audition.avi --script tests/capture_audio_audition.gd`.120FPS fixed clock,27s,48000Hz16-bit stereo; actual engine Contacts limiter in path. This is offline digital output, not CoreAudio/speaker capture or native pacing evidence. Includes actual PhysicsStepper rack-break event sequence,100 distinct contacts/100ms, and active pocket mute. Output measurements and hashes are in `assets/audio/qa-evidence.json`; capture commands and results below. No normalization is applied to these measurements.

Initial headless MovieMaker attempt failed with `texture_2d_get: Parameter t is null` then signal11 under Dummy rendering. Preserved `/tmp/pool-audio-capture.txt`; switching to a real OpenGL renderer addressed that specific prerequisite. The first mute check ran before tween processing in the same frame; after an explicit process-frame barrier it passes. This fixture establishes eventual lifecycle completion, not an elapsed10ms promise. Neither failure was converted into a relaxed contract threshold.

## Acceptance map

| ID | Evidence/status |
|---|---|
| AUD-001 | **NOT_RUN** listening. No model/tool capability actually heard speaker/headphone audio; owner audition artifacts are available. No audible competitor-reference acquisition or parity claim. |
| AUD-002 | **INCONCLUSIVE**: creator-labelled real classes;5/5/1/5 onsets. Missing two natural rail takes, error/miscue vocabulary and blinded material/naturalness panel. |
| AUD-003 | **Partial** objective monotonic nine-level gain; **NOT_RUN** human ordering, calibrated soft-contact90% detection/silence false-positive gate. Speed proxy is uncalibrated acoustic strength. |
| AUD-004 | **Partial** preserved simultaneous contacts and explicit bounded voice decisions; runtime100/100ms mix plus actual-break sequence. No per-contact IDs available to TableAudio; no numerical duplicate coalescing or blinded break recognition acceptance. |
| AUD-005 | **Partial** measured post-limiter8x oversampled true-peak estimate below-1dBTP/no clipped PCM. Actual listening/de-click safety remains **NOT_RUN**; requested6ms tween is frame-quantized. |
| AUD-006 | **BLOCKED** calibrated display/acoustic timing instrument absent; movie clocks cannot establish hardware latency/drift. |
| AUD-007 | **Partial** private cosmetic RNG verified. Mono camera-neutral mix has no misleading pan, but spatial localization/camera/replay panel acceptance remains open. |
| AUD-008 | **Partial** bounded voices, queued-start cancellation, eventual engine tail stop and recorded later digital silence. <=10ms artifact-free mute/device-change stress remains unverified. |

Next discriminating action: listen to the three WAV auditions on built-in speakers and wired headphones, explicitly judging ball dry click, cue woody body, phone-rail quality, pocket timing/body, repetitions, full break and mute/steal transitions; then replace the provisional one-take phone rail with at least three verified cleaner recordings. Preserve the target and current raw evidence until those tests resolve it.

## Digital mix result and owner audition

Final capture:168 accepted submissions,42 physical-break contacts,163 actual voice starts,68 steal decisions,0 dropped submissions during the100ms-spaced stress. Counters distinguish actual starts from replacement decisions; some pending replacements are cancelled when mute occurs. Same-instant100-event unit stress deliberately exceeds the available reserved slots and documents36 drops rather than silently cutting active fades.

Raw27-second PCM SHA256 `634e7b1736f835c9b5081129c5e47439a57a67bce3a7f0de5369ade25eeb9ac6`; stored peak **-2.00018dBFS**, FFmpeg swresample8x/384kHz peak estimate **-1.95660dBTP**, **0 clipped PCM samples**; final mute region from26.25s is digitally zero. Integrated RMS-40.52837dBFS includes the quiet gaps and is not a loudness calibration. This passes the digital peak bound for this specified deck only. It does not prove every possible mix or a formal infinite-band reconstruction bound.

Extraction: `ffmpeg -i captures/audio/real-contact-audition.avi -vn -c:a pcm_s16le captures/audio/real-contact-audition.wav`; `tools/check_audio.py` preserves raw measurements and exact SHA. No gain normalization/limiting is applied after engine capture. The AV file is generated with offline fixed-frame rendering, so its47–49s capture wall time is not game performance evidence.

Owner playback files (ignored QA artifacts):

- `captures/audio/before-synthetic.wav`:0–9s, cue/ball/rail/pocket, three repetitions each. This uses **the old assets under the new fixed-pitch/current-gain mix**, so it is a matched-level timbre comparison, not an old-build reproduction.
- `captures/audio/after-recorded.wav`:10–19s, same contact classes/speeds with the new real recordings.
- `captures/audio/physics-break.wav`:19–23s, actual42-contact active-PhysicsStepper break sequence.
- `captures/audio/real-contact-audition.wav`:full deck, with100/100ms stress at24s and pocket tail/mute at26s.

The lifecycle self-review caught a possible stale mute tween stopping a freshly reused naturally finished voice. `_start_voice` now kills/removes any old fade before playback; a focused stop/reuse/wait test passes. The capture deck does not unmute/reuse that slot, so this fix does not change its samples.

Distribution integration authorized by the parent: `assets/audio/CREDITS.txt` contains creator/source/licence URLs and modification notice; a **Sound credits** home-menu card exposes readable attributions/links and Back under existing modal focus. The parent owns export inclusion. The smoke test verifies the distributable text and visible card payload, source links, Back focus and return to home. This is attribution UX, not a new gameplay flow. No unrelated HUD sections were changed.
