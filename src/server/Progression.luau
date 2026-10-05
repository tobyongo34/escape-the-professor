local Players = game:GetService('Players')
local Config = require(game.ReplicatedStorage.EscapeShared.Config)
local Quiz = require(script.Parent.Quiz)
local P = { States = {}, Records = {}, OnReset = nil }
local world, event
local function now() return workspace:GetServerTimeNow() end
function P.Init(w,e) world=w; event=e end
function P.Root(player) local c=player.Character; return c and c:FindFirstChild('HumanoidRootPart'), c and c:FindFirstChildOfClass('Humanoid') end
function P.Send(player,kind,data) if player.Parent then event:FireClient(player,kind,data) end end
function P.Push(player)
    local s=P.States[player]; if not s then return end
    -- Read-only gameplay diagnostics; all decisions still use server state, never these attributes.
    for _,key in {'Active','Finished','Stage','Homework','Quiz','Key','Checkpoint','Catches','Falls','Started','Stamina','Protected','PassCount'} do player:SetAttribute('Escape'..key,s[key]) end
    P.Send(player,'State',{ Active=s.Active,Finished=s.Finished,Stage=s.Stage,Homework=s.Homework,Quiz=s.Quiz,Key=s.Key,Checkpoint=s.Checkpoint,Catches=s.Catches,Falls=s.Falls,Started=s.Started,Elapsed=s.Elapsed,Stamina=s.Stamina,Sprinting=s.Sprinting,Busy=s.Busy,Protected=s.Protected,Grade=s.Grade,Passes=s.Passes,PassCount=s.PassCount,SessionBest=P.Records[player] })
end
function P.Teleport(player,padName)
    local root,hum=P.Root(player); local pad=world.Checkpoints:FindFirstChild(padName)
    if root and pad and hum then
        root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero
        local pos=pad.Position+Vector3.new(0,4.5,0)
        player.Character:PivotTo(CFrame.lookAt(pos,pos+pad.CFrame.RightVector))
        hum:MoveTo(pos)
    end
end
function P.New(player)
    P.States[player]={Active=false,Finished=false,Stage=1,Sheets={},Homework=0,Quiz=0,Key=false,Checkpoint='Classroom',Catches=0,Falls=0,Started=0,Elapsed=0,Stamina=1,Sprinting=false,LastSprint=0,Protected=now()+Config.ProtectionSeconds,Busy=false,QuizUntil=0,LastRemote=0,LastPrompt=0,QuizOpenUntil=0,Token=0,Passes={},PassCount=0}
    P.States[player].QuizDeck=Quiz.NewDeck()
    return P.States[player]
end
function P.Start(player)
    local old=P.States[player]; if old and old.Active and not old.Finished then return end
    local token=(old and old.Token or 0)+1
    if P.OnReset then P.OnReset(player) end
    local s=P.New(player); s.Token=token; s.Active=true; s.Started=now(); s.Protected=now()+3
    P.Teleport(player,'Classroom'); P.Push(player); P.Send(player,'Toast',{Text='School is over. Your escape starts now!',Tone='good'})
end
function P.Checkpoint(player,name)
    local s=P.States[player]; local pad=world.Checkpoints:FindFirstChild(name)
    if not s or not pad or s.Busy or not s.Active or s.Finished or s.Stage~=pad:GetAttribute('Stage') or s.Checkpoint==name then return false end
    if name=='Hangout' then return false end
    if s.Stage==2 and ((name=='HallStart' and s.Checkpoint~='HallStart') or (name=='HallMid' and s.Checkpoint=='HallEnd')) then return false end
    if name=='LibraryEnd' and s.Checkpoint~='LibraryMid' then return false end
    if name=='LibraryStart' and (s.Checkpoint=='LibraryMid' or s.Checkpoint=='LibraryEnd') then return false end
    if name=='LibraryMid' and s.Checkpoint=='LibraryEnd' then return false end
    s.Checkpoint=name; P.Push(player); P.Send(player,'Checkpoint',{Name=name,Position=pad.Position}); return true
end
function P.Stage(player,stage,checkpoint)
    local s=P.States[player]; if not s then return end
    if P.OnReset then P.OnReset(player) end
    s.Stage=stage; s.Checkpoint=checkpoint; s.Protected=now()+Config.ProtectionSeconds; s.QuizOpenUntil=0; s.Stamina=1; s.Sprinting=false
    if stage==6 then s.Protected=now()+Config.FinalHeadStart end
    P.Teleport(player,checkpoint); P.Push(player); P.Send(player,'Checkpoint',{Name=checkpoint,Position=world.Checkpoints[checkpoint].Position})
end
function P.Fail(player,caught)
    local s=P.States[player]; if not s or not s.Active or s.Finished or s.Busy then return end
    if caught and now()<s.Protected then return end
    s.Busy=true; s.Sprinting=false; s.Token+=1; local token=s.Token
    if caught then s.Catches+=1 else s.Falls+=1 end
    if s.Stage==5 then s.Key=false; s.Checkpoint='Staff' end
    if P.OnReset then P.OnReset(player) end
    P.Send(player,'Fail',{Text=if caught then 'DETENTION!' else 'TRY THAT AGAIN!',Caught=caught,Tip=Config.RetryTips[s.Stage]})
    local root,hum=P.Root(player); if hum then hum.WalkSpeed=0 end
    task.delay(1.25,function()
        if P.States[player]~=s or s.Token~=token or not player.Parent then return end
        local r,h=P.Root(player)
        if not h or h.Health<=0 then player:LoadCharacterAsync(); return end
        P.Teleport(player,s.Checkpoint); s.Busy=false; s.Stamina=1; s.Protected=now()+Config.ProtectionSeconds; P.Push(player)
    end)
    P.Push(player)
end
function P.CollectPass(player,part)
    local s=P.States[player]; local folder=world:FindFirstChild('BonusPasses')
    if not s or not folder or not part or part.Parent~=folder or not part:IsA('BasePart') then return false end
    local id=part:GetAttribute('PassId')
    if type(id)~='string' or not s.Active or s.Finished or s.Busy or s.Stage~=part:GetAttribute('Stage') or s.Passes[id] then return false end
    local r,h=P.Root(player)
    if not r or not h or h.Health<=0 or (r.Position-part.Position).Magnitude>4.5 then return false end
    -- Only the collecting player's record changes; the shared collectible stays in the map.
    s.Passes[id]=true; s.PassCount+=1
    P.Push(player); P.Send(player,'Pass',{Position=part.Position,Count=s.PassCount})
    return true
end
function P.Finish(player)
    local s=P.States[player]; if not s or not s.Active or s.Finished or s.Busy or s.Stage~=6 or not s.Key then return end
    local r,h=P.Root(player); if not r or not h or h.Health<=0 then return end
    local zone=world['06_FinalBell'].FinishZone
    if (r.Position-zone.Position).Magnitude>20 then return end
    s.Finished=true; s.Sprinting=false; s.Elapsed=now()-s.Started; s.Protected=math.huge
    s.Grade=if s.Elapsed<=Config.GradeASeconds and s.Catches<=Config.GradeACatches then 'A · ESCAPE SCHOLAR' elseif s.Elapsed<=Config.GradeBSeconds and s.Catches<=Config.GradeBCatches then 'B · FREEDOM EXPERT' else 'C · DETENTION SURVIVOR'
    local previous=P.Records[player]
    local record=not previous or s.Elapsed<previous
    if record then P.Records[player]=s.Elapsed end
    if P.OnReset then P.OnReset(player) end
    P.Push(player); P.Send(player,'Victory',{Elapsed=s.Elapsed,Catches=s.Catches,Falls=s.Falls,Grade=s.Grade,PassCount=s.PassCount,SessionBest=P.Records[player],NewRecord=record}); P.Teleport(player,'Hangout')
end
function P.Character(player,character)
    local hum=character:WaitForChild('Humanoid'); local root=character:WaitForChild('HumanoidRootPart')
    hum.UseJumpPower=true; hum.JumpPower=Config.JumpPower; hum.WalkSpeed=Config.WalkSpeed
    local s=P.States[player]; if not s then return end
    if P.OnReset then P.OnReset(player) end
    s.Busy=false; s.Sprinting=false; s.Stamina=1; s.Protected=now()+Config.ProtectionSeconds
    task.defer(function() if character.Parent then P.Teleport(player,if s.Finished then 'Hangout' else s.Checkpoint); P.Push(player) end end)
    hum.Died:Connect(function()
        local current=P.States[player]
        if not current or not current.Active or current.Finished then return end
        if not current.Busy then current.Falls+=1 end
        current.Busy=true; current.Sprinting=false
        if current.Stage==5 then current.Key=false end
        if P.OnReset then P.OnReset(player) end
        P.Push(player)
    end)
end
return P
