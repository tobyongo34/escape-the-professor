# ESCAPE THE PROFESSOR! — verification notes

Latest pass (October 4): complete Campus Upgrade saved as `ESCAPE THE PROFESSOR - Campus Upgrade.rbxl`, 145,058 bytes, with eleven production scripts and no test driver. See CAMPUS_UPGRADE.md for quiz variety, room visuals, phone layout fixes and current validation. Older entries below are historical.

Publication follow-up (October 4): uploaded Campus Upgrade as version 4. Creator Dashboard confirms Public access with audience reach Ages 16+ and trusted friends. See PUBLISH_STATUS.md. Historical notes below describe earlier passes.

Updated October 2, 2026. The current game is saved locally as ESCAPE THE PROFESSOR - Chase Upgrade.rbxl (141,753 bytes). Replay Upgrade was also saved with these changes and matches the Chase Upgrade copy. Prior Bug Checked, Visual Upgrade and original copies remain. The current version contains ten production scripts and no test driver. See CHASE_UPGRADE.md for the current changes and validation.

## Chase upgrade and startup recovery

- Bypassed the stuck Studio start screen with File > Open from File. The October 2 log reports a deserialization failure in the built-in StartPage_24439.rbxm. The editor and game load normally when opened directly; the underlying plugin failure remains unresolved.
- Restarted Rojo on localhost:34872, confirmed the connected plugin, and verified the local removal of the temporary test driver synced into Edit mode.
- Corrected NPC path endpoints to foot level and kept useful routes between waypoints. Prior 24-second patrol tests covered 225 studs/eight waypoint visits in the hallway and 228 studs/five visits in the staff room, with successful paths, no recoveries, and the same actor throughout.
- Added a final race route around alternating carts, widened hurdles, lane hedges and signs. The professor accelerates from 23.5 to 26 studs/second. The initial head start is 1.8 seconds; normal respawn protection remains 2.5 seconds.
- October 2 seeded physical traversal: timed sprint escaped in 8.1 seconds with zero catches/falls/recoveries; walking was caught in 7.8 seconds. This verifies a viable route and sprint pressure, not newcomer difficulty or a complete human playthrough.
- Staff catch succeeded. Final safe-boundary transitions, six progression/quiz/key checks and eleven collectible/replay checks passed.
- All ten production sources and the map recipe passed syntax compilation. Removed the temporary driver locally and verified it was absent in Edit and in a fresh playtest.
- A normal menu click started stage one. Actual W input moved the character six studs with health 100 and no falls. Automated mouse input produced Studio CoreGui utility warnings; no game-script error was returned.
- Saved locally, then copied the saved place to Chase Upgrade and verified matching SHA256 DDA7D8CBB55D684C58EE2595C3AAC8F2C295B505A0F6A58498DC788A2C54C0D2. No cloud publishing was performed in this pass.

## Replay upgrade verification

- Added six optional hall passes, session-best time, clean-escape/collector result recognition, objective hints and a six-room route display. The final chase now shows its three-second head start.
- Applied framed room entrances, a challenge notice and a decorated finish arch. Kept the current map position and yellow-hoodie professor.
- All eleven new collectible/replay checks passed. Existing progression and moved/rotated-map checks also passed. Actual client movement collected a pass; actual button clicks disabled objective hints.
- All ten sources compiled and synced. Removed the temporary test helper, then verified a normal menu/start/collection run with full health and no falls.
- Visually inspected desktop HUD/results and scenery. This pass did not repeat physical-device or multiplayer testing. Session-best times do not persist after leaving the server.
- Saved using Studio Save to File As from a local place (PlaceId 0); no cloud publication was performed.

## Visual upgrade verification

- Recovered Studio from its stuck Loading Studio home screen by using File > Open from File on the saved place. Login succeeded in the log; Studio subsequently reported that its built-in StartPage_24439.rbxm plugin failed to load. Opening the local file bypasses that screen; the underlying Start Page failure has not been repaired.
- Reconnected Rojo on localhost:34872 and read the local escape-professor-hoodie-2026-09-30 source marker back through Studio MCP.
- Applied warm tiled floors, wood furniture, noticeboards, plants, science and library details, and courtyard planting/benches. Added decoration is non-colliding and does not participate in line-of-sight queries.
- The professor uses the photo as a stylized reference: close-cropped hair, brown skin, yellow hoodie with drawstrings and pocket, black trousers, and dark sneakers. Inspected in Edit and Play views.
- Verified patrol and catch/Staff checkpoint recovery. The final chase reported Chase at 17 studs/second. Client hip transforms changed during the chase, verifying the local walk animation.
- Adjusted the custom rig's HipHeight to 0.6. A moving runtime clone settled with sole bottoms at Y=41.02 over the floor at Y=41, with full health.
- Removed the temporary Studio-only test driver through local files and verified its removal in Studio. The final place contains eight production scripts, no preview clone, and preserved Baseplate/SpawnLocation. A fresh test starts normally at the stage-one menu.
- All eight production sources and the visual recipe passed Luau syntax compilation. No game-script runtime errors occurred. The test avatar's Animate.mood.Animation1 asset (114302219876492) failed to load; this is an avatar animation warning, separate from the custom professor's procedural animation.
- Saved the upgraded copy with Save to File As from a local place (PlaceId 0). No Roblox upload or public publication was performed for this upgrade.

## Verified baseline

- Studio MCP and Rojo 7.7.0 live synchronization; a local source marker appeared in Studio. Scripts were edited locally, while unmanaged geometry was built through MCP.
- Eight production Luau files passed syntax compilation. The temporary Studio test fixture was removed locally and its removal verified in Studio.
- Menu Play starts the timer. All three homework pickups and individual classroom-door eligibility work.
- Puddle slowdown, moving pencil hazards, locker jump, and checkpoint recovery were tested in play mode.
- All library jumps were traversed using Humanoid movement. Deliberate failure returned to the midpoint. The slow platform carried the player, and jumping off using directional movement worked.
- Wrong quiz answers preserve progress and enforce a cooldown. Three correct answers unlock the next stage.
- Key pickup, locked final-door rejection, professor line of sight, alert, chase, investigation, return, catching, and death/respawn cleanup were exercised.
- A continuous staff-room-to-bus traversal succeeded without catches or falls. Running directly into the patrol can still result in a catch; use cover and sprint after taking the key.
- All three courtyard jumps, head start, finish, results, Hang Out, results reopening, and Play Again passed. Replay cleared that player's progress and encounter.
- A real local server with two clients verified individual collection of the same sheet. Player 1 dying, finishing, and restarting did not change Player 2's progress. Later stages were seeded for this isolation test; it was not two complete simultaneous runs.
- Phone landscape and portrait HUDs and tablet layouts were inspected in device emulation. The custom RUN button was moved clear of the default jump control. ScreenOrientation is Sensor, and the UI uses safe core insets. Studio was reset to the default viewport afterward.
- All seven bundled soft feedback cues loaded. Final baseline startup output had no game-script errors. A multiplayer mouse-injection warning came from Studio's test utility hitting CoreGui, not a game script.
- Original Baseplate and SpawnLocation preserved. The baseline map has 1,970 descendants.

## Specific limitations

- Phone/tablet visual layouts were inspected; actual touch hardware and physical controller navigation have not been verified. Automated mouse injection in touch emulation was inconsistent.
- Two-player state isolation was checked; six-player performance and simultaneous complete runs have not been measured.
- The 5–8 minute newcomer target has not been validated with a fresh human player. Grade thresholds are shown on the results screen: A within 8 minutes and 2 catches; B within 12 minutes and 5 catches; otherwise a positive C. Falls are separate.
- Sound effects use one verified bundled soft sound with different pitches. There is no configured music or chase track and no distinctive recorded school bell.
- No FPS claim is made. Target server capacity is six; configure that in experience settings before a future publication.
- No public publishing action was taken. Studio's Download a Copy also saved the current place changes to Roblox before writing the local copy, as reported by Studio's Output.

## Ownership

The src/shared, src/server, and src/client folders hold the authoritative scripts; see WORKFLOW.md. Workspace.EscapeSchool, ServerStorage.EscapeAssets, and named Escape lighting effects are edited through Studio and preserved in the complete place file. The files in studio/ are edit-time recipes, not game scripts. Do not rebuild over later manual changes.
