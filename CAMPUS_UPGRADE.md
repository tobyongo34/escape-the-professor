# Campus Upgrade — October 4, 2026

Complete local place: `ESCAPE THE PROFESSOR - Campus Upgrade.rbxl` (145,058 bytes).
SHA256: `F3378B6BD14C1045F758402377336F9AF78264AC899F83E33B2BECC114B82FE1`.

## Changes

- Nine server-owned questions, with one maths, science and school-survival question per run. Answer positions shuffle. Correct progress and the current deck survive failures; replay starts a new deck. Only the visible question and options are sent to the client.
- Wrong answers give useful hints. Correct answers give a short explanation. Answer feedback highlights the selected button; server cooldowns still prevent guessing all options at once.
- Room-specific HUD accents, room-entry headings, a professor distance bar, and practical retry tips. Touch players see TAP RUN on the stamina card.
- A more compact landscape-phone HUD and a full-width portrait objective card. Fixed modal scaling after rotating the phone: the previous viewport's stale height could incorrectly shrink panels.
- Coordinated wall colors, five framed room posters with subtle lights, colored entrance markers, a final-course floor trail and bus sign. Doorway labels now sit in front of the walls. New scenery has collision, touch and raycast queries disabled.
- Kept the existing map transform, yellow-hoodie professor, patrol AI and harder finale. `studio/CampusPolish.luau` is an idempotent Edit-time recipe for unmanaged scenery.

## Verification

- Rojo connected on localhost:34872. Read the new `escape-professor-campus-2026-10-04` marker and new Quiz module back from Edit mode.
- All eleven production sources compiled locally and in Studio. Temporary regression driver removed locally and confirmed absent in the final Edit model and fresh playtest.
- 100 seeded quiz decks: all nine questions appeared, all three answer positions appeared, each deck contained three subjects and unique options. Correct answers/hints stayed out of the initial client payload; modifying its option copy did not mutate the server deck. Deck retention on fall and replacement on replay passed.
- Six progression/quiz/exit checks and eleven pass/replay/session-record checks all passed. Wrong-answer cooldown rejected an immediate correct answer; three valid correct answers unlocked the quiz.
- Staff patrol: 225 studs, five waypoint visits in 24 seconds, zero recoveries. Hall patrol: 225 studs, eight visits, zero recoveries. Both retained the same NPC and successful paths.
- Final course physical traversal: timed sprint escaped in 8.1 seconds with zero catches/falls/recoveries; closest professor distance 21.2 studs. Walking was caught after 7.3 seconds, near authored X=690. These are controlled traversals, not a newcomer difficulty study.
- Desktop quiz clicks progressed real server state. A fresh normal menu click began stage one; keyboard input moved the character with health 100 and no falls.
- Inspected desktop and iPhone 17 Pro simulator layouts in both orientations. Quiz questions, options, hints and HUD labels reported TextFits=true. Portrait modal width corrected from 234 to 340 logical pixels after the rotation fix.
- Simulator input automation showed coordinate mismatch/CoreGui warnings; physical phone touch and controller hardware were not certified. No game-script errors were returned. Multiplayer testing was not repeated in this pass.

## Ownership

Edit scripts in `src` and let Rojo sync them. Workspace scenery is outside the Rojo map. A Rojo build alone does not include the school; open the complete `.rbxl` save. See `PUBLISH_STATUS.md` for the cloud release state.
