# Focused Miniclip reference review — 2026-10-31

Four separate focused observation assignments: user interaction, precision controls, visuals/sound, physics. Reports below preserve each specialist's focus; there is no combined numerical quality score.

## Coverage and access

Actual first-party animated gameplay was inspected from four official spin demonstrations, together with the official table UI image. The animations show a Portuguese practice/Quick Fire-style HUD; exact game build and capture platform are not established. Native Brave reached the official live-game splash/login/guest screen but did not enter a match. Browser automation host access failed; one later native attempt was blocked by the Mac lock screen. Public YouTube attempts did not yield an inspected audible gameplay segment. GIFs contain no audio.

Consequently this is a formative, partial reference observation. It does not establish current ranked-client parity, native input latency, friction/force coefficients, calibrated rebound/pocket boundaries or sound quality. Animation offsets identify frames, not an unedited gameplay clock. See [access journal](reports/reference-access.md).

## Specialist reports

- [User controls and interaction flow](reports/competitor-user-controls.md)
- [Precision controls](reports/competitor-precision-controls.md)
- [Visuals and sound](reports/competitor-visual-audio.md)
- [Physics](reports/competitor-physics.md)

## Design decisions worth testing next

| Difference | Evidence and interpretation | Concrete next test |
|---|---|---|
| Pull-back/release delivery versus separate power slider and Take Shot | Miniclip's official controls instructions describe web release-to-shoot; the GIFs show an integrated cue and vertical power rail but omit the actual pointer release. This is a documented gesture difference, not a measured responsiveness advantage. | Prototype pull/release alongside the current interaction; compare short-shot placement error, accidental commits, cancellation and acquisition time with identical physics. |
| Large spin selection overlay versus persistent small pad | The animations visibly enlarge the cue ball and red contact marker, then return to the table. Our pad preserves table visibility and now offers fine drag/reset. A larger target may improve selection but introduces occlusion/mode switching. | Compare center/eight-direction selection error, reset discoverability and retained aim at multiple DPI/window sizes. No claim that marker pixels equal the same normalized tip offset. |
| Table-adjacent feedback and compact HUD | Reference frames show the cue, guides, pocket indicators, timer and score in one overhead view; our layout devotes a large side panel to stroke controls/instructions. | Measure table visibility, glance distance and ball identification while aiming and adjusting controls. Keep owner preference separate from task performance. |
| Visible outcome demonstrations versus physical parameter inference | Official animations show spin selection followed by changed trajectories/layouts and break dispersion. Edited timing, cue stats and unknown power prevent coefficient matching. | Build a versioned practice-shot dataset with cue identity/stats, initial placement, power/tip selection and an unedited frame clock before fitting or comparing physics. |
| Material boundaries and guide endpoint | The visual observer identifies a light cushion edge, dark wells, an outlined fine guide and hollow endpoint; our openings are angular and preview endpoint is a filled ghost sphere. Shape and visual-weight choices affect readability independently of physics accuracy. | Run identification tasks with dark/striped balls and tight clusters under the guide; compare material/edge separation and actual-ball-versus-preview recognition before changing the palette or geometry. |
| Pot continuity | The backspin demonstration shows a potted ball moving down a return track alongside score/recent-ball updates. Our practice view exposes a count and status. | Prototype a restrained last-potted identity/progress sequence; verify one update per physical capture and clear transition back to ready. A return track is one option, not a mandatory copied layout. |
| Sound remains an evidence gap | No audible source was successfully reviewed. Our source audit already identifies synthetic samples and coarse voice suppression. | Obtain an audible, identified gameplay recording; compare soft/hard contacts, rails, pocket drops and dense breaks on headphones and speakers, including overlap and timing. |

The existing excellence gates remain in force. These observations add design alternatives and testable questions; they do not authorize silently changing physical coefficients to resemble an edited clip.

## Publication

The owner explicitly requested committing and pushing the current implementation and this research. Remote gameplay media remain temporary analysis inputs outside the repository. Only authored reports, source, original generated assets and test evidence are included in the Git changes.
