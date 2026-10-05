return {
    SyncVersion = "escape-professor-campus-2026-10-04",
    Title = "ESCAPE THE PROFESSOR!",
    WalkSpeed = 16, SprintSpeed = 23, SprintSeconds = 5, RecoverySeconds = 7,
    RecoveryDelay = 0.8, JumpPower = 50, ProtectionSeconds = 2.5,
    CatchDistance = 4.2, DetectDistance = 38, LoseSightSeconds = 3.5,
    PatrolSpeed = 10, ChaseSpeed = 17, HallChaseSpeed = 15,
    FinalChaseSpeed = 23.5, FinalChaseMaxSpeed = 26, FinalHeadStart = 1.8,
    RepathSeconds = 0.7, QuizCooldown = 1.6,
    TotalPasses = 6,
    Stages = {
        { Name = "SURPRISE EXAM", Objective = "Find 3 glowing homework sheets. Then use the classroom exit." },
        { Name = "SLIPPERY HALLWAY", Objective = "Dodge the pencils. Past the midpoint, watch for the professor!" },
        { Name = "THE FLOOR IS HOMEWORK", Objective = "Jump across the books. Green pads save your progress." },
        { Name = "POP QUIZ DOOR", Objective = "Use the quiz board. Three correct answers unlock the exit." },
        { Name = "STEAL THE EXIT KEY", Objective = "Grab the gold key. Hide behind shelves when the professor looks your way!" },
        { Name = "FINAL BELL", Objective = "Weave around the carts. Jump the hurdles. Save sprint for the last stretch!" },
    },
    RoomColors = {
        Color3.fromRGB(255,203,70), Color3.fromRGB(97,202,217), Color3.fromRGB(184,151,238),
        Color3.fromRGB(99,220,159), Color3.fromRGB(255,174,109), Color3.fromRGB(255,121,116),
    },
    RetryTips = {
        "Collected sheets stay with you. Follow the homework marker.",
        "Wait for the pencils to swing past. Puddles slow you down.",
        "Aim for the middle of each book. Green pads save progress.",
        "Correct answers stay saved. Read the hint before trying again.",
        "Use the tall shelves to break his line of sight, then grab the key.",
        "Right of the first cart, left of the second. Save sprint for the hurdles!",
    },
    Dialogue = { "THE BELL DOESN'T DISMISS YOU!", "THAT'S NOT IN THE SYLLABUS!", "YOU FORGOT QUESTION 47!", "COME BACK FOR EXTRA CREDIT!" },
    -- All grades are positive. A <= 8 min and <= 2 catches; B <= 12 min and <= 5 catches.
    GradeASeconds = 480, GradeACatches = 2, GradeBSeconds = 720, GradeBCatches = 5,
}
