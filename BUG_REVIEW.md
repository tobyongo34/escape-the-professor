# Code review — September 30, 2026

Current saved game: **ESCAPE THE PROFESSOR - Bug Checked.rbxl** (132,630 bytes).

## Fixed

| Issue | Change | Evidence |
| --- | --- | --- |
| Moving the school broke fall checks, obstacle placement, NPC spawn/bounds and the finish area. The current classroom floor is at (114.925, 1, -4.075), while scripts assumed (0, 40, 0). | Added shared Course coordinate conversion; server and client derive layout coordinates from the classroom floor. Checkpoints use their own CFrames. Preserved the user's current map placement. | Before: stage-one player repeatedly had Busy=true, speed=0 and a root near Y=6. After: health=100, zero falls, speed=16. Additional translation and 90-degree yaw test passed. |
| A sprint release inside the 0.06-second press debounce could be discarded. Sprint presentation could also persist after opening a modal or changing stage. | Releases always clear sprint; modal/focus changes stop it; server state controls the local sprint indicator. | Immediate true/false remote pair leaves sprint=false and speed=16. Opening Settings stops sprint and restores RUN label. |
| Closing the quiz during wrong-answer feedback let its delayed callback reopen it. | Quiz revisions and visibility invalidate old feedback callbacks. | Closed after wrong feedback; still closed after 1.8 seconds. |
| Final chase changed to Return at the safe boundary, then used the staff-room patrol logic when the player came back. | Final encounter waits in Idle while safe and resumes Chase on re-entry. | Before: Chase → Return → Return. After: Chase → Idle → Chase. |
| Character parts added after the initial spawn missed collision-group assignment. | Apply EscapePlayers to existing and newly added descendants. | Late test part was Default before, EscapePlayers after. |
| Another player's professor could retain a floating SurfaceGui chest label. | Hide SurfaceGui and Highlight along with body parts and speech bubbles. | Foreign test model's body and SurfaceGui both hidden. |
| Procedural rig transforms were updated in the render phase. | Update Motor6D.Transform during PreSimulation, following Roblox's animation scheduling guidance. | Client hip transforms changed during the live professor encounter. |

## Validation

- Nine production Luau sources compile successfully. Changes were made in local files and synced via Rojo; marker: escape-professor-bugfix-2026-09-30.
- Moved-map puddle slowdown, pencil failure, homework-floor failure, and checkpoint handling passed.
- The moving shuttle remained at its authored course coordinates after a map translation and yaw rotation. A grounded client retained the same relative position on it over 1.5 seconds.
- Locked classroom exit, skipped-library-checkpoint rejection, checkpoint preservation, invalid/wrong answer rejection and cooldown, all three correct quiz answers, and exit-key requirement passed.
- Final-boundary recovery, staff-room patrol and catch, finish/hangout, and replay reset passed.
- A final run without the regression driver showed the menu, accepted Play, collected all three homework sheets, and kept health=100 with zero falls.
- No game-script runtime errors were observed in the final run. The test avatar's Animate.mood.Animation1 asset (114302219876492) still fails to load. Rojo also logged a client play-test HTTP warning during earlier testing; Edit-mode synchronization and removal of the test driver were verified afterward.
- Temporary regression script and runtime helpers were removed before saving. The reusable driver stays in tests/, outside the Rojo mapping.
- Saved with Studio Save to File As. Prior game files were preserved. SHA-256: 07ABC661107B38CC68998577C9797CEFF1D5AA08DD4957451ED8A4CF6F526E5C.

## Limits

This was a source review and targeted one-client regression pass, not a guarantee of zero bugs. Earlier two-client isolation checks are documented in BUILD_STATUS.md; they were not repeated for this patch. Physical touch/controller testing, a six-player load test, and newcomer completion timing remain outstanding. Music still has no configured track. Course movement supports translation and horizontal rotation, not arbitrary rescaling or tilting against gravity.

Roblox references: [Motor6D.Transform scheduling](https://create.roblox.com/docs/reference/engine/classes/Motor6D/Transform) and [character collision groups](https://create.roblox.com/docs/workspace/collisions).
