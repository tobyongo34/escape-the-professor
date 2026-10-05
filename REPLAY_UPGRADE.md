# Replay upgrade — September 30, 2026

Saved game: **ESCAPE THE PROFESSOR - Replay Upgrade.rbxl**. The earlier game files are preserved.

## Changes

- Six optional golden hall passes, one per room. Collection is validated on the server by player state, current stage and distance. Passes stay collected after failure, clear on replay, and do not gate progression.
- Session-best completion time, clean-escape and all-pass result recognition, and a clearer completed-run HUD. Times last only until the player leaves the server; no DataStore is used.
- Six-step route display and a world-space marker for the next required pickup, checkpoint or exit. OBJECTIVE HINTS can disable the marker. This replaces the previous inactive Music toggle; no soundtrack is configured.
- A visible three-second final-chase head start, followed by the existing chase warning.
- Framed room entrances, a hall-pass challenge notice, a finish arch and checker stripe, pennants and an escape-club challenge board. Added scenery does not collide or obstruct professor sight tests.
- Preserved the moved school and photo-inspired yellow-hoodie professor. Code was changed locally through Rojo. Map content was edited through MCP outside Rojo ownership.

## Verification

- All ten production Luau sources and the edit-time recipe compile. Local sync marker `escape-professor-polish-2026-09-30` was read back through Studio MCP.
- All eleven ReplayChallenges checks passed: distance, wrong-stage, busy, inactive and duplicate rejection; valid collection; persistence after falling; all six passes; replay reset; slower-time preservation; faster-time replacement.
- Existing door, checkpoint and quiz progression checks passed. Moving and rotating the runtime school preserved safe spawn and shuttle placement.
- An actual client walk collected a hall pass. The shared server part stayed present while that client hid its card and lettering and displayed 1/6.
- Actual Settings button clicks toggled objective hints off; hints also hid while the settings panel was open. The marker selected the closest remaining sheet during ordinary play.
- Final stage displayed its three-second countdown and then changed to the red chase warning. Finished runs showed CAMPUS ESCAPED, a completed route and the session-best result.
- Visually checked the results, classroom card/notice, route HUD and finish arch. Repositioned the classroom notice after finding a window overlap.
- Removed the temporary local test-driver copy and verified its removal in Studio. A fresh normal run showed the menu, accepted Play and collected a pass with health 100 and zero falls.
- No game-script runtime errors were observed. Studio reported the existing avatar mood-animation asset failure (114302219876492) and CoreGui warnings from its automated mouse-input utility.

## Scope of testing

Targeted one-client regression and normal-startup testing, with later stages seeded by a Studio-only fixture. This was not a new full manual playthrough or multiplayer/hardware-device certification. The latest HUD was inspected at desktop viewport sizes; physical touch/controller tests, six-player performance and newcomer timing remain unverified. Earlier checks remain documented in BUILD_STATUS.md and BUG_REVIEW.md.

`studio/ReplayPolish.luau` records the applied unmanaged content. It derives its placement from the classroom floor and replaces only the `ReplayPolish` and `BonusPasses` folders. The older map recipes still assume their original coordinates.
