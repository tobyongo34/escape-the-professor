# Studio regression checks

StudioRegression.server.luau is a temporary, Studio-only test driver, outside the Rojo mapping. It seeds player progress to exercise the production modules; it is not a full player-controlled playthrough.

1. Stop Play mode. Copy the driver to src/server/StudioRegression.server.luau and let Rojo sync it.
2. Start a one-player Studio test. From the Server data model, invoke game.ServerStorage.EscapeRegression with these commands:

```luau
local test=game.ServerStorage:WaitForChild('EscapeRegression')
test:Invoke('FinalBoundary')
test:Invoke('LateCollisionPart')
test:Invoke('CoursePlacement')
test:Invoke('TranslatedObstacles')
test:Invoke('ProgressionRules')
test:Invoke('QuizVariety')
test:Invoke('FinishReplay')
test:Invoke('ReplayChallenges')
test:Invoke('PatrolCircuit', 2)
test:Invoke('PatrolCircuit', 5)
test:Invoke('StandCatch', 5)
test:Invoke('RunFinal', 'walk')
test:Invoke('RunFinal', 'sprint')
```

Each result contains descriptive booleans that must be true. FinalBoundary must report Chase, Idle, Chase. CoursePlacement temporarily moves/rotates the runtime school and restores it. The driver gives the server ownership of the test character to avoid stale client poses replacing rapid fixture teleports.

ReplayChallenges checks hall-pass distance, stage, busy/inactive and duplicate rejection, collection of all six, retention after falling, replay reset, and session-best replacement only by a faster finish. It seeds three finish times and ends on the results screen. Test results are temporary and vanish when the play test stops.

PatrolCircuit samples 24 seconds of protected patrol: require completedCircuit and sameActor, Success path status, at least four new waypoint visits, and zero recoveries. StandCatch should report caught=true. RunFinal seeds the final stage and key, then physically moves/jumps along the course without teleporting between obstacles. Walking should be caught; sprinting after X=642 should finish with zero falls/catches/recoveries. Its 2.5-stud arrival tolerance accounts for Humanoid MoveTo completion distance. These commands change runtime player progress only and are not a full manual playthrough or a substitute for newcomer difficulty feedback.

Additional client checks:

- Prepare stage 1, send Sprint true and false back-to-back through EscapeEvent, then verify Snapshot reports sprinting=false and speed=16.
- Invoke Quiz, then `test:Invoke('QuizAnswer', 'wrong')` to submit a deliberately wrong answer regardless of the shuffled choices. Hide the actual Quiz panel as its Close handler does. After 1.8 seconds it must remain hidden.
- Open Settings during sprint and verify the server stops sprinting.
- For shuttle carry, prepare stage 3, restore player network ownership, and place the character above StationeryShuttle. Compare client root position in the shuttle's CFrame over 1.5 seconds while grounded.

3. Stop the test, delete only the temporary src/server/StudioRegression.server.luau copy, and verify its removal through Rojo. Keep this tests/ copy.
4. Run a normal startup check, then save the place with no test driver installed.
