local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local RS=game:GetService('ReplicatedStorage')
local Config=require(RS:WaitForChild('EscapeShared'):WaitForChild('Config'))
local P=require(script.Parent.Progression)
local AI=require(script.Parent.ProfessorAI)
local Interactions=require(script.Parent.Interactions)
local world=workspace:WaitForChild('EscapeSchool')
local course=require(RS.EscapeShared.Course).new(world)
local event=Instance.new('RemoteEvent'); event.Name='EscapeEvent'; event.Parent=RS
P.Init(world,event); AI.Init(world,P); Interactions.Init(world,P); P.OnReset=AI.Reset
Players.RespawnTime=1.4
local function character(player,c)
    local function collision(d) if d:IsA('BasePart') then d.CollisionGroup='EscapePlayers' end end
    c.DescendantAdded:Connect(collision)
    for _,d in c:GetDescendants() do collision(d) end
    P.Character(player,c)
end
local function added(player)
    P.New(player); player.CharacterAdded:Connect(function(c) character(player,c) end)
    if player.Character then task.spawn(character,player,player.Character) end
end
Players.PlayerAdded:Connect(added); for _,p in Players:GetPlayers() do added(p) end
Players.PlayerRemoving:Connect(function(p) AI.Reset(p); P.States[p]=nil; P.Records[p]=nil end)
event.OnServerEvent:Connect(function(player,action,arg)
    local s=P.States[player]; if not s or type(action)~='string' then return end
    local t=workspace:GetServerTimeNow()
    if action=='Sprint' then
        -- A release must never be dropped by the press-rate limiter.
        if arg~=true then s.Sprinting=false; return end
        if t-(s.LastSprintRemote or 0)<0.06 then return end
        s.LastSprintRemote=t; s.Sprinting=arg==true and s.Active and not s.Finished and not s.Busy; return
    end
    if t-s.LastRemote<0.16 then return end; s.LastRemote=t
    if action=='Ready' then P.Push(player)
    elseif action=='Play' then P.Start(player)
    elseif action=='Answer' then Interactions.Answer(player,arg)
    elseif action=='Hangout' and s.Finished then P.Teleport(player,'Hangout') end
end)
local checks=world.Checkpoints:GetChildren(); local hazards=world.Hazards:GetChildren(); local pickups=world.Pickups:GetChildren()
local shuttle=world.Platforms.StationeryShuttle
local shuttleStart=shuttle:GetAttribute('StartPosition')
local tickAccum=0; local pushAccum=0
RunService.Heartbeat:Connect(function(dt)
    tickAccum+=dt; if tickAccum<0.1 then return end
    local step=math.min(tickAccum,0.3); tickAccum=0; pushAccum+=step
    local t=workspace:GetServerTimeNow()
    shuttle.CFrame=course:ToWorldCFrame(CFrame.new(shuttleStart+Vector3.new(0,0,math.sin(t*0.7)*1.6)))
    for _,d in shuttle:GetChildren() do if d:IsA('BasePart') and d:GetAttribute('ShuttleOffset') then d.CFrame=shuttle.CFrame*d:GetAttribute('ShuttleOffset') end end
    for _,part in hazards do if part:GetAttribute('Hazard')=='Pencil' then
        local z=math.sin(t*0.85+part:GetAttribute('Phase'))*part:GetAttribute('Travel')
        part.CFrame=course:ToWorldCFrame(CFrame.new(part:GetAttribute('BaseX'),42.7,z)*CFrame.Angles(0,math.pi/2,0)*CFrame.Angles(t*1.6,0,0))
        for _,d in part:GetChildren() do if d:IsA('BasePart') and d:GetAttribute('PencilOffset') then d.CFrame=part.CFrame*d:GetAttribute('PencilOffset') end end
    end end
    for player,s in P.States do
        local root,hum=P.Root(player); if not root or not hum or hum.Health<=0 then continue end
        local worldPos=root.Position; local pos=course:ToLocal(worldPos); local slow=false
        if s.Active and not s.Finished and not s.Busy then
            for _,pad in checks do
                local relative=pad.CFrame:PointToObjectSpace(worldPos)
                if pad:GetAttribute('Stage')==s.Stage and math.abs(relative.X)<pad.Size.X/2+1 and math.abs(relative.Z)<pad.Size.Z/2+1 and math.abs(relative.Y)<7 then P.Checkpoint(player,pad.Name) end
            end
            if pos.Y<37 then P.Fail(player,false) end
            if s.Stage==3 and pos.X>220 and pos.X<358 and pos.Y<44.55 then P.Fail(player,false) end
            if s.Stage==2 then
                for _,part in hazards do
                    local kind=part:GetAttribute('Hazard')
                    local hazardPos=course:ToLocal(part.Position)
                    if kind=='Puddle' and math.abs(pos.X-hazardPos.X)<6 and math.abs(pos.Z-hazardPos.Z)<5.5 and pos.Y<46 then slow=true
                    elseif kind=='Pencil' and math.abs(pos.X-hazardPos.X)<1.65 and math.abs(pos.Z-hazardPos.Z)<7.8 and pos.Y<45.5 then P.Fail(player,false) end
                end
            end
            if s.Stage==1 or s.Stage==5 then
                for _,part in pickups do if part:GetAttribute('Stage')==s.Stage and (worldPos-part.Position).Magnitude<4.5 then Interactions.Handle(player,part) end end
            end
            local passes=world:FindFirstChild('BonusPasses')
            if passes then for _,part in passes:GetChildren() do
                if part:IsA('BasePart') and part:GetAttribute('Stage')==s.Stage and (worldPos-part.Position).Magnitude<=4.5 then P.CollectPass(player,part) end
            end end
            if s.Stage==6 and pos.X>728 and pos.X<745 and math.abs(pos.Z)<14 then P.Finish(player) end
            local maxX=({38,206,374,446,578,788})[s.Stage]
            if pos.X>maxX or math.abs(pos.Z)>49 or pos.X< -36 then P.Teleport(player,s.Checkpoint) end
        end
        local moving=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude>1
        if s.Sprinting and moving and s.Stamina>0 and not s.Busy then s.Stamina=math.max(0,s.Stamina-step/Config.SprintSeconds); s.LastSprint=t; if s.Stamina==0 then s.Sprinting=false end
        elseif t-s.LastSprint>Config.RecoveryDelay then s.Stamina=math.min(1,s.Stamina+step/Config.RecoverySeconds) end
        hum.WalkSpeed=if s.Busy then 0 elseif slow then 10 elseif s.Sprinting and s.Stamina>0 then Config.SprintSpeed else Config.WalkSpeed
        if pushAccum>=0.3 then P.Push(player) end
    end
    AI.Step(step)
    if pushAccum>=0.3 then pushAccum=0 end
end)
print('[Escape] Six-stage game ready. Server-authoritative progress; individual professor encounters.')
