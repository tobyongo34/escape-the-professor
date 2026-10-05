# AI tools and responsibilities

This project used **OpenAI Codex / ChatGPT** as a development assistant. AI assistance contributed to Luau implementation, game systems, debugging, scene-building recipes, interface improvements, test execution, documentation, and the class presentation.

The team supplied the game requirements, appearance reference, gameplay feedback, and classroom requirements. Feedback included a professor who did not move correctly and a final chase that was too easy. Development changes addressed those reports, and the repository records the associated checks.

The **Roblox Studio MCP tools** provided a connection between the assistant and Roblox Studio for inspecting the game, creating or changing content outside the Rojo-managed script areas, and running Studio playtests. **Rojo** synchronized edits from local source files into the mapped Studio script folders. MCP and Rojo are development tools, not hosted dependencies needed by players.

The professor's runtime behavior uses scripted states, Roblox pathfinding, line-of-sight checks, and movement recovery. It does not use an LLM. The quiz is a predefined server-side question bank with randomized selection and answer ordering. No AI model is called during gameplay, and no AI API key is required to run the game.

## Assigned team responsibilities

| Member | Responsibility |
| --- | --- |
| Peace Funso-Ore | Game design and progression explanation. |
| James Hunter | Programming and quiz logic explanation. |
| Emaury Onyeneho | Visual design and interface explanation. |
| Tobenna Uyanwune | Testing, improvements, and demonstration. |

These assignments support presenting and maintaining the project. They are not a claim that each student personally authored a specific set of code. Each presenter should understand the source examples they discuss and describe their actual contribution accurately.

## Validation and limits

The repository includes the complete production Luau source, edit-time scene recipes, and a Studio regression driver. Recorded checks and their limits appear in [Campus Upgrade](../CAMPUS_UPGRADE.md) and the [regression guide](../tests/README.md). The game still benefits from newcomer playtests and physical phone/controller checks.
