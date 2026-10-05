# ESCAPE THE PROFESSOR!

## Team and timing

Main presentation: 14 slides, approximately 9 minutes 25 seconds including a 30-second demo. Appendix slides 15–17 are for questions.

- Peace Funso-Ore: game design, slides 1–4, about 2 minutes 25 seconds.
- James Hunter: programming, slides 5–7, about 2 minutes 10 seconds.
- Emaury Onyeneho: visuals and interface, slides 8–10, about 1 minute 55 seconds.
- Tobenna Uyanwune: testing, improvements, and demo, slides 11–14, about 2 minutes 55 seconds including the demo.

These are assigned project and presentation responsibilities. Adjust any claims about past contributions to match what each person actually did. The project used AI assistance for code and debugging. Everyone should understand the section they present.

## Rehearsal script

### Slide 1: ESCAPE THE PROFESSOR!

**Peace Funso-Ore — 35 seconds**

Hi, we are Peace, James, Emaury, and Tobenna. Our project is ESCAPE THE PROFESSOR, a Roblox school escape game. The joke is that school has ended, but the professor has assigned one thousand questions. The player has to escape through six rooms and reach the school bus. We will explain the game design, show how some of the real code works, and discuss the bugs and improvements.

### Slide 2: Our assigned project roles

**Peace Funso-Ore — 35 seconds**

For this presentation, each person has a project responsibility. I am the game design lead, so I will explain the rules and the order of the rooms. James is the programming lead and will explain how the server runs the game. Emaury is the visual and interface lead, explaining the school, character, and screen layout. Tobenna is the testing and improvement lead, covering bugs, difficulty, and our demonstration. These are our assigned responsibilities for understanding and presenting the project.

### Slide 3: Six rooms to reach the bus

**Peace Funso-Ore — 35 seconds**

The rooms change the type of challenge as the player moves forward. First, find three homework sheets. Next, dodge the pencils in the hallway. The library turns books into a jumping course. The science room adds a three-question quiz. Then the player sneaks past the professor to collect an exit key. The final room combines weaving, jumping, and sprinting. The giant books and school jokes make ordinary school objects part of the obstacle course.

### Slide 4: Progress, retry, and replay

**Peace Funso-Ore — 40 seconds**

The player always has a current objective. Completing it opens the next part of the school. Checkpoints help a mistake feel recoverable, because the player returns to a saved point. Six optional hall passes encourage exploration, but the player does not need them to escape. Sprinting uses stamina, so holding the run button forever will not work. At the end, players receive a grade based on time and catches and can replay to improve their session best. James will explain how the code controls these rules.

### Slide 5: How the project fits together

**James Hunter — 40 seconds**

Roblox Studio holds the school and runs the game. Luau is the programming language. Rojo syncs our local code files into the correct Studio folders. The server controls progress, catches, and correct answers. The client handles input, the interface, and effects. Shared files hold settings used by both. We edit the source files on the computer so Rojo keeps them in sync. The project used AI assistance for development and debugging. Understanding and checking the code is part of our responsibility.

### Slide 6: Code: the classroom exit

**James Hunter — 45 seconds**

This is real code from the interaction script, with extra spacing to make it readable. The variable s stores the player state. The if statement checks whether Homework is below three. If it is, the server sends a message and return stops this action. Once the player has three sheets, the program reaches P.Stage. That function advances the player to stage two and uses the HallStart checkpoint. The check runs on the server, so the interface alone cannot decide that the player has completed a room.

### Slide 7: Code: a different quiz each run

**James Hunter — 45 seconds**

The quiz contains nine possible questions. Each run selects one math question, one science question, and one school-survival question. This loop shuffles the answer positions. The list starts with one, two, and three. The loop chooses a random position and swaps two entries. This means the correct answer does not always appear on the same button. Correct answers remain on the server, and a cooldown discourages clicking every answer instantly. Emaury will now explain how the game communicates these challenges visually.

### Slide 8: Professor Popquiz

**Emaury Onyeneho — 40 seconds**

Our professor is a stylized Roblox character with a bright yellow hoodie, dark trousers, and a recognizable face. The design follows the appearance reference chosen for the project. The yellow color makes him easy to spot inside the school. His exaggerated school dialogue keeps the tone funny. The model in this image is the actual professor asset, staged in the classroom for a clear view. His movement and catching behavior come from a separate AI script.

### Slide 9: A school that explains the game

**Emaury Onyeneho — 35 seconds**

The environment gives players clues without needing a long tutorial. Numbered doors show the room order, while posters connect the school theme to the next challenge. Glowing homework and a golden key attract attention to important items. Room colors help players recognize where they are. We also separate decoration from obstacles. New decorative pieces do not collide with players, so a poster or small visual detail should not unexpectedly block a route.

### Slide 10: The interface helps players decide

**Emaury Onyeneho — 40 seconds**

The HUD is the information displayed while playing. It shows the room objective, collected items, time, and stamina. The interface also includes hints, sound effects, and reduced-motion settings. This small code example sets the width of the stamina bar. A value of one means full width, and zero means empty. math.clamp keeps the value inside that range. The bar displays the server state, while the server decides the actual sprint speed. Tobenna will explain what testing revealed.

### Slide 11: Testing checked rules and movement

**Tobenna Uyanwune — 35 seconds**

Testing needs to check more than whether the game opens. The project ran one hundred seeded quiz tests to check question variety, answer positions, and the information sent to the client. Progression checks tested room requirements, and replay checks tested collectibles and session records. Patrol checks watched the professor complete routes without getting stuck. The interface also received desktop and phone simulator checks. These results are useful evidence, but they do not replace watching new players or testing on physical phones.

### Slide 12: Bug fix: the professor faced a wall

**Tobenna Uyanwune — 40 seconds**

One reported bug was that the professor stared at a wall instead of moving. A cause was the path calculation using a point near the body instead of the floor. That could produce a route onto cabinet tops. The fix puts the path endpoints at foot level. This function converts a position into course coordinates, sets its height to the floor, then converts it back to the world. The AI also keeps useful routes between updates and can recover if movement stalls. Later patrol tests completed without needing recovery.

### Slide 13: The final chase now rewards timing

**Tobenna Uyanwune — 35 seconds**

Another piece of feedback was that the ending felt too easy. The updated course uses alternating exam carts, three hurdles, and a professor who accelerates. The player gets a short head start and has to manage sprint stamina. In a controlled test, a timed sprint route escaped in 8.1 seconds, while a walking attempt got caught after 7.3 seconds. These are two different attempts, not average player scores. Newcomer playtests would help us judge whether the difficulty feels fair.

### Slide 14: Demo and what we learned

**Tobenna Uyanwune — 35 seconds**

For our short demo, we will start the game, point out the objective and stamina bar, and collect one homework sheet. The full game takes longer than this presentation, so the screenshots show the later rooms. Our main lesson is that rules, visuals, and testing all affect how a game feels. A pathfinding bug can stop a chase even when the character looks finished. Next, we would test with more new players and on real phones and controllers. Thank you. We are ready for questions.

## Demo preparation

1. Open the PowerPoint and test Slide Show on the classroom computer. Speaker notes appear in Presenter View.
2. Open Roblox Studio before presenting. Use File > Open from File and select the complete Campus Upgrade .rbxl from the companion ZIP. If the home screen hangs, Ctrl+O may still open the file.
3. Start a playtest, then return to the menu before the presentation. Keep the game ready in the background.
4. Tobenna: switch to Studio, start the run, show the objective and stamina bar, then collect one sheet using E near glowing homework. Keep the demo to about 30 seconds.
5. If Studio or the network fails, stay on the screenshots and explain the same steps. Do not spend class time troubleshooting.
6. The published experience was Public with an Ages 16+ and trusted-friends audience setting when checked. Use the local Studio demo if a classmate's account cannot join.

## Likely questions

**What language does Roblox use?** Luau. This project uses scripts and modules for separate systems.

**What is a server?** The authoritative game process. It decides progress, correct answers, stamina, and catches. A client is the player's device and handles input and display.

**What is Rojo?** A tool that synchronizes local source files with Studio objects according to default.project.json. It does not contain this project's entire school map.

**Why did the professor get stuck?** Navigation endpoints at body height could select cabinet tops. Foot-level endpoints and route retention improved movement.

**Why use random quiz answers?** Shuffling prevents the correct answer from always using the same button. The server still checks the chosen answer.

**How do checkpoints help?** A failed attempt returns the player to a saved part of the route instead of restarting the whole course.

**Are the test times average player scores?** No. They are controlled traversals. New players may take much longer.

**Did AI help?** Yes. AI assisted with implementation and debugging. We explain the design, inspect the code, and discuss the tests and limitations.

**What would you improve next?** More newcomer playtests, real phone and controller testing, and difficulty adjustments based on those results.

## Source-code companion

The ZIP contains all 11 production Luau files, the Rojo configuration, map recipes, regression tests, project notes, and the complete local game. Code excerpts in the PowerPoint preserve the source behavior but expand spacing for readability. No excerpt alone is a complete standalone script.
