# Aim retention implementation

## Scope

Implemented the deliberate aim-retention checkpoint in `scripts/app/game_controller.gd`, `scripts/ui/game_hud.gd`, and `README.md`. No power, physics, or visual behavior was changed.

## Behavior

- A left press starts an aim gesture only when it reaches `_unhandled_input` and projects to the table interior outside pocket mouths. The press updates aim immediately.
- While that gesture is active and the left button remains held, pointer motion updates aim only when its projected position is on playable cloth. Ordinary pointer motion does not change aim.
- A left release observed in `_input` ends the gesture regardless of GUI consumption, retaining the last direction. Presses are not handled in `_input`, so GUI controls keep their normal input priority.
- Right-button input does not start a gesture. Cue-ball placement continues to use a left click while placing and does not start aiming.
- Menu opening (including Escape), application/window focus loss, starting a rack, undo, camera switching, and shot commitment cancel the gesture. Fine keyboard aim remains available when not placing, shooting, in a menu, or actively dragging.
- HUD and README instructions now describe click-and-drag aiming and release-to-retain; placement instructions identify a clear cloth location.

## Checks and limits

- Inspected the controller, HUD, table projection API, and `TableSpec` bounds/pocket helpers.
- Confirmed the README/HUD aim prompts no longer describe hover aiming.
- Runtime, input-routing, and engine checks were not run in this checkpoint; the parent is coordinating the dedicated tests and engine execution.
