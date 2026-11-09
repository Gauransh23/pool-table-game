# 0.3.3 owner-test preview — 2026-11-09

Both requested edits are included in this locally built candidate. Work remained on the original checkout's `main`; no branch or worktree was created for these edits.

- **Proportional guides:** relative immediate post-impact momentum replaces independently capped travel-path lengths. The two projected centerlines share one scale, including obstruction limiting. Menu → Guide length saves a 0.25–3.00x preference. Physics, power mapping, fine aim and practice saves remain unchanged. See [guide implementation/evidence](PROPORTIONAL_GUIDES.md) and its independent review.
- **Recorded contacts:** five ball, five cue, five pocket and one rail take replace the four synthetic tones. Source recordings, licences, edits and reproducible processing are documented in [audio research/evidence](REAL_AUDIO.md). Pitch stays unshifted; gain, bounded variants, voice fades/decisions and mute handling are tested. Menu → Sound credits and the bundled CREDITS.txt expose the attributions. [Independent audio review](real-audio-review.md) found no important blocker and reconstructed all 16 edited samples from verified source bytes.

The final universal arm64/x86_64 app and DMG were rebuilt after both edits. Signature and installer checksum checks passed. The complete CREDITS.txt payload is present in the exported resource pack. The exported app launched without headless mode using `--quit-after 60`, logged Metal Forward+ on Apple M4, and exited 0 without runtime errors. Native CUA automation was unavailable, so this is graphical startup evidence rather than a new native input trial. Source GUI captures and actual Viewport event tests are recorded separately.

Package: `build/Long Rail-0.3.3-mac.dmg`. Exact source, binary, pack, installer and audition hashes: [RELEASE_0_3_3.json](RELEASE_0_3_3.json). The installer is locally ad-hoc signed; notarization is not configured.

Owner audition files are local ignored artifacts under `captures/audio/`: `before-synthetic.wav`, `after-recorded.wav`, `physics-break.wav`, and the full `real-contact-audition.wav`. The before/after pair compares old versus recorded assets under the same new gain/pitch mix; it is not an old-build reproduction. The actual Godot offline mixer deck measured about -1.9566 dBTP, no clipped PCM and later digital silence after mute. This is not speaker/headphone listening or device timing evidence.

Human listening and preference remain unverified. The rail recording is a single phone-quality take, public HQ previews are lossy sources, and frame-scheduled fades do not establish a sample-accurate 10 ms mute guarantee. The complete physical/perceptual quality contract remains open; this candidate is ready for the owner's comparison and feedback.
