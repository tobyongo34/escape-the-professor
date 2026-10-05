local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local CAS=game:GetService('ContextActionService')
local Tween=game:GetService('TweenService')
local GuiService=game:GetService('GuiService')
local UIS=game:GetService('UserInputService')
local player=Players.LocalPlayer
local config=require(RS:WaitForChild('EscapeShared'):WaitForChild('Config'))
local effects=require(script.Parent.Effects)
local ui=require(script.Parent.UI)
local event=RS:WaitForChild('EscapeEvent')
local world=workspace:WaitForChild('EscapeSchool')
local course=require(RS.EscapeShared:WaitForChild('Course')).new(world)
local shuttle=world:WaitForChild('Platforms'):WaitForChild('StationeryShuttle')
world:WaitForChild('Checkpoints'); world:WaitForChild('Pickups'); world:WaitForChild('Doors')
effects.Init(); ui.Init(config,event,effects)
local guidance=require(script.Parent.Guidance).new(world,course,ui,effects)
local state={Active=false,Stage=1,Stamina=1,Started=0,Finished=false}
local priorStart=0; local sprint=false; local hidden={}; local defaultColors={}; local animatedProfessors={}
local headStartUntil=0; local professorState='Idle'
local priorStage=0
for _,p in world.Checkpoints:GetChildren() do if p:IsA('BasePart') then defaultColors[p]=p.Color end end
local function canSprint()
    return state.Active and not state.Finished and not state.Busy and not ui.Quiz.Visible and not ui.Settings.Visible
end
local function stopSprint()
    sprint=false; ui.TouchSprint.Text='RUN'; event:FireServer('Sprint',false)
end
local function sprintAction(_,input)
    if input==Enum.UserInputState.Begin then sprint=canSprint()
    elseif input==Enum.UserInputState.End or input==Enum.UserInputState.Cancel then sprint=false else return Enum.ContextActionResult.Pass end
    event:FireServer('Sprint',sprint); return Enum.ContextActionResult.Sink
end
CAS:BindAction('EscapeSprint',sprintAction,false,Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL3)
ui.OnTouchSprint=function()
    sprint=not sprint and canSprint()
    event:FireServer('Sprint',sprint); ui.TouchSprint.Text=if sprint then 'WALK' else 'RUN'
end
for _,modal in {ui.Quiz,ui.Settings} do
    modal:GetPropertyChangedSignal('Visible'):Connect(function() if modal.Visible then stopSprint() end end)
end
UIS.WindowFocusReleased:Connect(stopSprint)
local function prompts()
    for _,container in {world.Pickups,world.Doors} do for _,p in container:GetChildren() do
        local prompt=p:FindFirstChildWhichIsA('ProximityPrompt'); if prompt then prompt.Enabled=state.Active and not state.Finished and p:GetAttribute('Stage')==state.Stage and not hidden[p.Name] end
    end end
end
local function ownNPC(model)
    local owner=model:GetAttribute('Owner'); if owner and owner~=player.UserId then
        local function hide(d) if d:IsA('BasePart') then d.LocalTransparencyModifier=1 elseif d:IsA('BillboardGui') or d:IsA('SurfaceGui') or d:IsA('Highlight') then d.Enabled=false end end
        for _,d in model:GetDescendants() do hide(d) end; model.DescendantAdded:Connect(hide)
    elseif owner==player.UserId then
        task.spawn(function()
            local torso=model:WaitForChild('Torso',5); local root=model:WaitForChild('HumanoidRootPart',5)
            if not torso or not root then return end
            local joints={}
            for _,name in {'Left Hip','Right Hip','Left Shoulder','Right Shoulder'} do local j=torso:WaitForChild(name,5); if j then joints[name]=j end end
            animatedProfessors[model]={Root=root,Joints=joints,Phase=0,Amount=0}
        end)
    end
end
task.spawn(function() local f=workspace:WaitForChild('EscapeEncounters'); for _,m in f:GetChildren() do ownNPC(m) end; f.ChildAdded:Connect(ownNPC) end)
event.OnClientEvent:Connect(function(kind,data)
    if kind=='State' then
        state=data
        if data.Started~=priorStart then
            priorStart=data.Started; hidden={}; effects.RestorePickups(world); ui.Results.Visible=false; ui.Quiz.Visible=false; ui.Alert.Visible=false
            sprint=false; headStartUntil=0; professorState='Idle'; ui.TouchSprint.Text='RUN'; priorStage=0
            for p,c in defaultColors do p.Color=c end
            GuiService.SelectedObject=nil
        end
        ui.Menu.Visible=not data.Active; ui.Hud.Visible=data.Active; ui.TimerCard.Visible=data.Active; ui.StaminaCard.Visible=data.Active and not data.Finished
        ui.TouchSprint.Visible=game:GetService('UserInputService').TouchEnabled and data.Active and not data.Finished
        ui.ResultsButton.Visible=data.Finished
        sprint=data.Sprinting==true
        ui.TouchSprint.Text=if sprint then 'WALK' else 'RUN'
        local stage=config.Stages[data.Stage]; ui.Stage.Text=string.format('%02d  %s',data.Stage,stage.Name); ui.Objective.Text=stage.Objective
        local accent=config.RoomColors[data.Stage]
        ui.RoomAccent.BackgroundColor3=accent; ui.Stage.TextColor3=accent
        if data.Active and not data.Finished and data.Stage~=priorStage then
            priorStage=data.Stage
            ui.Introduce(data.Stage)
        end
        if data.Finished then ui.Stage.Text='CAMPUS ESCAPED!'; ui.Objective.Text='Hang out with friends, collect all six passes on a new run, or beat your time.' end
        local progress=if data.Stage==1 then 'SHEETS '..data.Homework..'/3' elseif data.Stage==4 then 'QUIZ '..data.Quiz..'/3' elseif data.Stage>=5 then (if data.Key then 'KEY ✓' else 'FIND THE KEY') else 'CHECKPOINT SAVED'
        ui.Counter.Text=progress..'  ·  PASSES '..(data.PassCount or 0)..'/'..config.TotalPasses
        if data.Finished then ui.Counter.Text='RUN COMPLETE  ·  PASSES '..(data.PassCount or 0)..'/'..config.TotalPasses end
        ui.Best.Text='SESSION BEST  '..(if data.SessionBest then ui.Time(data.SessionBest) else '—')
        for i,segment in ui.Route do
            local done=data.Finished or i<data.Stage
            segment.BackgroundColor3=if done then Color3.fromRGB(99,220,159) elseif i==data.Stage then accent else Color3.fromRGB(23,42,59)
            segment.TextColor3=if done or i==data.Stage then Color3.fromRGB(23,42,59) else Color3.fromRGB(179,204,210)
            segment.Text=if done then '✓' else string.format('%02d',i)
        end
        if data.Stage==5 and not data.Key then
            local key=world.Pickups:FindFirstChild('ExitKey'); hidden.ExitKey=nil
            if key then key.LocalTransparencyModifier=0; local h=key:FindFirstChildOfClass('Highlight'); if h then h.Enabled=true end end
            local ring=world.Pickups:FindFirstChild('KeyRing'); if ring then ring.LocalTransparencyModifier=0 end
        end
        if data.Stage~=4 then ui.Quiz.Visible=false end
        local pad=world.Checkpoints:FindFirstChild(data.Checkpoint); if pad then pad.Color=Color3.fromRGB(80,205,139) end
        prompts()
    elseif kind=='Toast' then ui.Notify(data.Text,data.Tone=='bad')
    elseif kind=='Dialogue' then ui.Line(data)
    elseif kind=='Pickup' then
        hidden[data.Name]=true; effects.Pickup(world.Pickups:FindFirstChild(data.Name)); if data.Name=='ExitKey' then world.Pickups.KeyRing.LocalTransparencyModifier=1 end; effects.Burst(data.Position,Color3.fromRGB(255,199,58)); effects.Sound('Pickup'); ui.Notify(data.Text)
    elseif kind=='Pass' then
        effects.Sound('Pickup'); effects.Burst(data.Position,Color3.fromRGB(255,203,70))
        ui.Notify(if data.Count==config.TotalPasses then 'ALL 6 HALL PASSES! Collector challenge complete.' else 'BONUS HALL PASS  '..data.Count..' / '..config.TotalPasses)
    elseif kind=='Checkpoint' then effects.Sound('Checkpoint'); effects.Burst(data.Position,Color3.fromRGB(80,205,139)); ui.Notify('Checkpoint reached!')
    elseif kind=='Quiz' then ui.ShowQuiz(data)
    elseif kind=='QuizResult' then
        local revision=ui.QuizRevision
        ui.QuizLocked=true; ui.QuizFeedback.Text=(if data.Correct then '✓ ' else 'HINT: ')..data.Text
        ui.QuizFeedback.TextColor3=if data.Correct then Color3.fromRGB(99,220,159) else Color3.fromRGB(255,121,116)
        if ui.Answers[data.Answer] then ui.Answers[data.Answer].BackgroundColor3=ui.QuizFeedback.TextColor3 end
        effects.Sound(if data.Correct then 'Correct' else 'Wrong')
        task.delay(if data.Correct then 1.35 else data.Cooldown,function()
            if state.Stage~=4 or not ui.Quiz.Visible or ui.QuizRevision~=revision then return end
            if data.Done then ui.Quiz.Visible=false; GuiService.SelectedObject=nil; ui.Notify('3/3 CORRECT. The staff-room exit is unlocked!') else ui.ShowQuiz(data.Question,if not data.Correct then data.Text else nil) end
        end)
    elseif kind=='Alert' then
        professorState=data.State
        local active=data.State=='Alert' or data.State=='Chase'; if active and not ui.Alert.Visible then effects.Sound('Wrong') end
        ui.Alert.BackgroundColor3=Color3.fromRGB(255,121,116)
        ui.Alert.Visible=active; ui.AlertText.Text=if data.State=='Alert' then 'UH OH... THE PROFESSOR IS LOOKING!' else 'RUN! THE PROFESSOR SAW YOU!'
    elseif kind=='HeadStart' then headStartUntil=data.Until
    elseif kind=='Fail' then
        sprint=false; headStartUntil=0; ui.TouchSprint.Text='RUN'; event:FireServer('Sprint',false); ui.Quiz.Visible=false; ui.Fail.Visible=true; ui.FailText.Text=data.Text; ui.FailTip.Text=data.Tip or 'Your checkpoint is saved.'; effects.Sound('Catch')
        task.delay(1.25,function() ui.Fail.Visible=false; if data.Tip then ui.Line('TIP: '..data.Tip) end end)
    elseif kind=='DoorOpening' then
        effects.Sound('Bell'); local door=world.Doors:FindFirstChild(data.Name)
        if door and not effects.Settings.ReducedMotion then local cf=door.CFrame; Tween:Create(door,TweenInfo.new(0.6),{CFrame=cf*CFrame.new(0,16,0)}):Play(); task.delay(2,function() if door.Parent then Tween:Create(door,TweenInfo.new(0.6),{CFrame=cf}):Play() end end) end
    elseif kind=='Victory' then
        headStartUntil=0; ui.Alert.Visible=false; ui.Quiz.Visible=false; ui.Results.Visible=true; ui.ResultGrade.Text=data.Grade
        ui.Stats.Text='TIME  '..ui.Time(data.Elapsed)..'     CATCHES  '..data.Catches..'\nOBSTACLE FALLS  '..data.Falls..'\nHALL PASSES  '..data.PassCount..' / '..config.TotalPasses
        local medals={}
        if data.Catches==0 and data.Falls==0 then table.insert(medals,'CLEAN ESCAPE') end
        if data.PassCount==config.TotalPasses then table.insert(medals,'HALL PASS COLLECTOR') end
        ui.Medals.Text=if #medals>0 then table.concat(medals,'  ·  ') else 'NEXT CHALLENGE: NO CATCHES, NO FALLS!'
        ui.Results.Footer.Text=(if data.NewRecord then 'NEW SESSION BEST  •  ' else 'SESSION BEST  •  ')..ui.Time(data.SessionBest)
        effects.Sound('Victory'); effects.Confetti(ui.Root); if game:GetService('UserInputService').GamepadEnabled then GuiService.SelectedObject=ui.Replay end
    end
end)
player.CharacterAdded:Connect(stopSprint)
local fov=70
local shuttleStart=shuttle:GetAttribute('StartPosition')
local lastShuttleFrame=shuttle.CFrame
RunService.PreSimulation:Connect(function(dt)
    for model,a in animatedProfessors do
        if not model.Parent then animatedProfessors[model]=nil; continue end
        local velocity=a.Root.AssemblyLinearVelocity; local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
        a.Amount+=(math.clamp(speed/12,0,1)-a.Amount)*math.min(1,dt*10); a.Phase+=dt*(5+speed*.32)
        local swing=math.sin(a.Phase)*.5*a.Amount
        for name,j in a.Joints do
            local side=if string.find(name,'Left') then 1 else -1; local arm=string.find(name,'Shoulder')~=nil
            j.Transform=CFrame.Angles(swing*side*(if arm then -1 else 1),0,if arm then side*.06 else 0)
        end
    end
end)
RunService.RenderStepped:Connect(function(dt)
    ui.TouchSprint.Visible=game:GetService('UserInputService').TouchEnabled and state.Active and not state.Finished and not ui.Quiz.Visible and not ui.Settings.Visible
    local nextFrame=course:ToWorldCFrame(CFrame.new(shuttleStart+Vector3.new(0,0,math.sin(workspace:GetServerTimeNow()*0.7)*1.6)))
    local char=player.Character; local root=char and char:FindFirstChild('HumanoidRootPart'); local hum=char and char:FindFirstChildOfClass('Humanoid')
    guidance:Update(dt,state,hidden,root)
    if headStartUntil>0 then
        local remaining=headStartUntil-workspace:GetServerTimeNow()
        if remaining>0 and state.Active and not state.Finished then
            ui.Alert.Visible=true; ui.Alert.BackgroundColor3=Color3.fromRGB(255,203,70)
            ui.AlertText.Text=string.format('GO! %.1fs HEAD START',remaining)
        else
            headStartUntil=0; ui.Alert.Visible=professorState=='Chase' or professorState=='Alert'
            ui.Alert.BackgroundColor3=Color3.fromRGB(255,121,116); ui.AlertText.Text='RUN! THE PROFESSOR SAW YOU!'
        end
    end
    if root and hum and hum.FloorMaterial~=Enum.Material.Air then
        local relative=lastShuttleFrame:PointToObjectSpace(root.Position)
        if math.abs(relative.X)<shuttle.Size.X/2+0.2 and math.abs(relative.Z)<shuttle.Size.Z/2+0.2 and relative.Y>2 and relative.Y<5.3 then root.CFrame+=nextFrame.Position-lastShuttleFrame.Position end
    end
    shuttle.CFrame=nextFrame
    for _,d in shuttle:GetChildren() do if d:IsA('BasePart') and d:GetAttribute('ShuttleOffset') then d.CFrame=shuttle.CFrame*d:GetAttribute('ShuttleOffset') end end
    lastShuttleFrame=nextFrame
    local elapsed=if state.Finished then state.Elapsed else workspace:GetServerTimeNow()-state.Started
    ui.Timer.Text=ui.Time(if state.Active then elapsed else 0)
    ui.Stamina.Size=UDim2.fromScale(math.clamp(state.Stamina or 1,0,1),1)
    ui.Stamina.BackgroundColor3=if state.Stamina<.25 then Color3.fromRGB(255,121,116) else Color3.fromRGB(255,203,70)
    ui.StaminaCard.Title.Text=if state.Stamina<.08 then 'RECOVERING  ·  KEEP MOVING' elseif sprint then 'SPRINTING  ·  STAMINA' elseif UIS.TouchEnabled then 'SPRINT  ·  TAP RUN' else 'SPRINT  ·  SHIFT / L3'
    ui.DangerBar.Visible=professorState=='Chase' and headStartUntil==0
    if root and professorState=='Chase' and headStartUntil==0 and state.Active and not state.Finished then
        local encounters=workspace:FindFirstChild('EscapeEncounters')
        local professor=encounters and encounters:FindFirstChild('Professor_'..player.UserId)
        local npcRoot=professor and professor:FindFirstChild('HumanoidRootPart')
        if npcRoot then
            local distance=math.floor((root.Position-npcRoot.Position).Magnitude)
            ui.DangerBar.Size=UDim2.new(math.clamp(1-distance/55,.04,1),-8,0,4)
            ui.AlertText.Text=if state.Stage==6 then 'PROFESSOR  '..distance..' STUDS AWAY  ·  KEEP RUNNING!' else 'SPOTTED! BREAK HIS LINE OF SIGHT!'
        end
    end
    local target=if sprint and state.Stamina>0 and not effects.Settings.ReducedMotion then 76 else 70
    fov+=(target-fov)*math.min(1,dt*6); workspace.CurrentCamera.FieldOfView=fov
end)
prompts(); event:FireServer('Ready')
print('[Escape] Interface ready: keyboard, touch, controller. Local effects respect reduced motion.')
