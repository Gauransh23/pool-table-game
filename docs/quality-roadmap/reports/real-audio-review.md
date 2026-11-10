# Independent recorded-audio review — 2026-11-09

Reviewed original main checkout `/Users/gt/Documents/My Public repos/Pool table game`, HEAD `78ca44464b0a4a31d8aaa4c446e203699b21dba7`, bounded diff `ca1d7d1..78ca444`. Read AGENTS.md, QUALITY_TARGETS, AUD target branch, F-AUDIO/F-PERCEPTION, TASK/NEXT_CHECKPOINT, source/tests, REAL_AUDIO, credits, manifests and raw archived source evidence. Parent-owned README/export-preset modifications were left untouched. Only this report was written; no product edits, branches, worktrees or subagents.

## Verdicts

**Specification/evidence: acceptable as a bounded recorded-contact candidate, not full AUD acceptance.** Creator-labelled recorded contacts replace the four synthetic effects. The report distinguishes objective sample/mix facts from unavailable listening, device timing and panel evidence. It explicitly retains the one-take rail shortfall and all relevant acceptance limits. No Miniclip audio is adopted and no heard parity or native listening result is claimed.

**Code: no important correctness finding in the reviewed change.** Existing `play_contact(kind,speed)` and compatibility aliases remain. Fixed pitch and monotonically increasing nine-level gain are consistent with authored intensity rather than false source calibration. Source-class variety comes from separate recording segments, not pitch copies. Voice count stays 32; all occupied/reserved slots produce an explicit bounded drop rather than cutting a pending fade. Mute invalidates pending starts, kills/replaces old fades and clears reservations. Starting a newly reused voice kills its stale fade. Cosmetic random choice uses a private RNG. Existing two-independent-contact physics fixture and event-only API tests remain intact.

## Independent verification

A read-only Python/FFmpeg inspection independently verified the four used source MP3 and archived HTML SHA256 values, published preview URLs and licence URLs against `sources/{851086,851087,851090,42364}.json`. Creator descriptions identify cue hit, ball impact and empty-pocket drop (KVV Audio, Zoom H5/XYH-5) and rail bounce (mccarthy@bedmas.com, Nokia 6125i). Archived pages publish CC BY 4.0 and CC0 respectively. These facts establish documented provenance, not independent acoustic recognition or recording-session authentication.

Decoded the four verified MP3 previews in memory and independently reconstructed all declared trim offsets, DC removal, nine-sample onset ramp, 25 ms end fade, stored gains and 16-bit WAV output. **16/16 complete WAV byte sequences matched their committed assets and manifest hashes.** The 5 ball / 5 cue / 1 rail / 5 pocket onsets occupy distinct source segments. No synthesis or pitch-copy operation occurs in this recipe. Archived KVV pages request creator/use credit and prohibit raw-stock redistribution; gameplay distributes edited contacts with creator/source/licence/modification notices, rather than raw downloaded MP3s.

The captured 27-second PCM hash independently matches committed `qa-evidence.json`: `634e7b1736f835c9b5081129c5e47439a57a67bce3a7f0de5369ade25eeb9ac6`. Reviewed measurement procedure reports -1.95660 dBTP from FFmpeg 8x resampling, zero clipped PCM samples and zero output from 26.25 seconds onward. These remain measurements of the specified offline deck; no listening, hardware latency or universal peak guarantee follows. The supplied passing audio/input/practice/guide results were reviewed as prior evidence and unchanged suites were not rerun.

`CREDITS.txt` and the narrow home-menu Sound credits card retain creators, source links, licence links and modification notices. Parent-owned current `export_presets.cfg:10` includes `assets/audio/CREDITS.txt`; final packaged inclusion still belongs to the parent's export verification.

## Requirement map and remaining limits

| IDs | Review disposition |
|---|---|
| AUD-001 | NOT_RUN listening/reference comparison. Waveforms and captions cannot close it. |
| AUD-002 | Partial recorded vocabulary is verified. `table_audio.gd:6` truthfully declares one rail take; three are required. Error/miscue vocabulary and material/naturalness panel remain open. |
| AUD-003 | Objective nine-level gain increases and pitch stays 1.0; perceived intensity, calibrated soft-contact detection and false positives remain NOT_RUN. |
| AUD-004 | API/event delivery and bounded policy are auditable at `table_audio.gd:89-121`. No contact-ID duplicate coalescing or human dense-break recognition is claimed. Drops under same-instant overload are disclosed. |
| AUD-005 | Specified offline-deck peak evidence is valid within its stated method. `table_audio.gd:66-75` uses render-frame tweens: requested 6 ms is not sample-accurate ramp evidence or heard click safety. |
| AUD-006 | BLOCKED calibrated display/acoustic timing and ten-minute drift evidence. |
| AUD-007 | Private RNG and camera-neutral mono are source-supported; full camera/replay/localization acceptance remains open. |
| AUD-008 | Eventual mute, pending-start invalidation and stale-fade cancellation are covered. <=10 ms artifact-free silence and long device/lifecycle stress remain unverified. |

No issue above is concealed as a passed target, and no concrete new runtime defect was found that blocks this bounded improvement. Next useful acceptance work is owner listening on built-in speakers and wired headphones, followed by cleaner rail acquisition with at least three real takes. Final export/startup validation must use the rebuilt artifact; this source review does not certify it.
