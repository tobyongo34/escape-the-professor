local Pathfinding = game:GetService('PathfindingService')
local Physics = game:GetService('PhysicsService')
local Config = require(game.ReplicatedStorage.EscapeShared.Config)
local AI = {Encounters={}}
local world, P, npcs, template, patrol, course
local function clock() return workspace:GetServerTimeNow() end
local function flatDistance(a,b) return Vector3.new(a.X-b.X,0,a.Z-b.Z).Magnitude end
local hallRoute = {Vector3.new(182,41.1,10),Vector3.new(142,41.1,10),Vector3.new(142,41.1,-10),Vector3.new(182,41.1,-10)}
-- The finale has an authored race line. It avoids path replans switching sides of carts
-- as the runner weaves, while normal navigation still handles a player doubling back.
local finalRoute={{618,10},{632,10},{643,0},{655,0,true},{659,-10},{677,-10},{682,0},{694,0,true},{716,0},{733,0,true}}

function AI.Init(w,progress)
    world=w; P=progress; template=game.ServerStorage:WaitForChild('EscapeAssets'):WaitForChild('Professor')
    course=require(game.ReplicatedStorage.EscapeShared.Course).new(world)
    npcs=Instance.new('Folder'); npcs.Name='EscapeEncounters'; npcs.Parent=workspace
    patrol=world.PatrolPoints:GetChildren(); table.sort(patrol,function(a,b) return a.Name<b.Name end)
    pcall(function() Physics:RegisterCollisionGroup('EscapeProfessor') end)
    pcall(function() Physics:RegisterCollisionGroup('EscapePlayers') end)
    Physics:CollisionGroupSetCollidable('EscapeProfessor','EscapeProfessor',false)
    Physics:CollisionGroupSetCollidable('EscapeProfessor','EscapePlayers',false)
    Physics:CollisionGroupSetCollidable('EscapePlayers','EscapePlayers',false)
end

local function clearPath(e)
    e.PathVersion+=1; e.Waypoints=nil; e.NextPath=0; e.Goal=nil
end

function AI.Reset(player)
    local e=AI.Encounters[player]
    if e then e.Dead=true; e.PathVersion+=1; e.Model:Destroy(); AI.Encounters[player]=nil end
    if P then P.Send(player,'Alert',{State='Idle'}) end
end

local function state(e,value)
    if e.State==value then return end
    e.State=value; e.Since=clock(); e.StuckSince=e.Since; e.LastPosition=e.Root.Position
    e.Model:SetAttribute('State',value); clearPath(e)
    e.Model.Head.StateBubble.Caption.Text=if value=='Chase' then 'EXTRA HOMEWORK!!!' elseif value=='Alert' then '... IS THAT A STUDENT?' elseif value=='Investigate' then 'WHERE DID YOU GO?' else 'PROFESSOR POPQUIZ'
    P.Send(e.Player,'Alert',{State=value})
end

local function visible(e,target)
    local origin=e.Root.Position+Vector3.new(0,1.2,0)
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={npcs,e.Player.Character,world.Checkpoints,world.PatrolPoints}; params.RespectCanCollide=true
    return workspace:Raycast(origin,target+Vector3.new(0,1,0)-origin,params)==nil
end

local function floorPoint(position)
    -- Navmesh endpoints belong at foot level. Root-height endpoints can snap onto cabinet tops.
    local p=course:ToLocal(position)
    return course:ToWorld(Vector3.new(p.X,41.15,p.Z))
end

local function patrolGoal(e)
    return if e.Stage==2 then course:ToWorld(hallRoute[e.Point]) else floorPoint(patrol[e.Point].Position)
end

local function spawn(player,s)
    local model=template:Clone(); model.Name='Professor_'..player.UserId; model:SetAttribute('Owner',player.UserId); model.Parent=npcs
    for _,d in model:GetDescendants() do if d:IsA('BasePart') then d.CollisionGroup='EscapeProfessor'; d.Anchored=false end end
    local localSpawn=if s.Stage==2 then Vector3.new(182,45,10) elseif s.Stage==5 then Vector3.new(542,45,17) else Vector3.new(579,45,0)
    local pos=course:ToWorld(localSpawn); model:PivotTo(CFrame.lookAt(pos,pos+course:Frame().RightVector))
    local root=model.HumanoidRootPart; root:SetNetworkOwner(nil)
    local e={Model=model,Root=root,Hum=model.Humanoid,Player=player,Stage=s.Stage,State='',Since=clock(),
        NextPath=0,Point=if s.Stage==5 then 3 else 1,Waypoints=nil,Index=1,LastSeen=0,LastTalk=0,
        LastPosition=pos,StuckSince=clock(),Ready=clock()+(if s.Stage==6 then Config.FinalHeadStart else 1),
        BusyPath=false,Dead=false,PathVersion=0,Goal=nil,Recoveries=0,PatrolVisits=0,FinalPoint=1,FinalJumped=0}
    AI.Encounters[player]=e; state(e,if s.Stage==6 then 'Idle' else 'Patrol')
    if s.Stage==6 then P.Send(player,'HeadStart',{Until=e.Ready}) end
    return e
end

local function move(e,dest,speed)
    e.Hum.WalkSpeed=speed
    local t=clock(); local goal=floorPoint(dest)
    local changed=not e.Goal or flatDistance(e.Goal,goal)>5
    if changed then clearPath(e); e.Goal=goal end
    -- Keep a useful route instead of continually rewinding to its second waypoint.
    local exhausted=not e.Waypoints or not e.Waypoints[e.Index]
    if t>=e.NextPath and not e.BusyPath and (changed or exhausted or e.State=='Chase') then
        e.NextPath=t+Config.RepathSeconds; e.BusyPath=true
        local version=e.PathVersion; local origin=floorPoint(e.Root.Position)
        task.spawn(function()
            local path=Pathfinding:CreatePath({AgentRadius=2,AgentHeight=8,AgentCanJump=e.Stage==6,WaypointSpacing=4})
            local ok=pcall(function() path:ComputeAsync(origin,goal) end)
            if not e.Dead and e.PathVersion==version then
                e.Model:SetAttribute('PathStatus',if ok then path.Status.Name else 'Error')
                if ok and path.Status==Enum.PathStatus.Success then
                    e.Waypoints=path:GetWaypoints(); e.Index=2
                    -- Async computation can finish after we have already passed early points.
                    while e.Waypoints[e.Index] and flatDistance(e.Root.Position,e.Waypoints[e.Index].Position)<2.2 do e.Index+=1 end
                end
            end
            e.BusyPath=false
        end)
    end
    local waypoint=e.Waypoints and e.Waypoints[e.Index]
    while waypoint and flatDistance(e.Root.Position,waypoint.Position)<2.2 and math.abs(e.Root.Position.Y-waypoint.Position.Y)<5 do
        e.Index+=1; waypoint=e.Waypoints[e.Index]
    end
    if waypoint then
        if waypoint.Action==Enum.PathWaypointAction.Jump and e.Hum.FloorMaterial~=Enum.Material.Air then e.Hum.Jump=true end
        e.Hum:MoveTo(waypoint.Position)
    elseif visible(e,dest) then
        e.Hum:MoveTo(dest)
    else
        e.Hum:MoveTo(e.Root.Position)
    end
    if flatDistance(e.Root.Position,e.LastPosition)>.7 then
        e.LastPosition=e.Root.Position; e.StuckSince=t
    elseif t-e.StuckSince>1.8 then
        clearPath(e); e.StuckSince=t; e.Recoveries+=1
        e.Model:SetAttribute('RouteRecoveries',e.Recoveries)
        if e.Stage==6 then e.Hum.Jump=true
        elseif e.State=='Patrol' or e.State=='Return' then e.Point=e.Point%(if e.Stage==2 then #hallRoute else #patrol)+1 end
    end
end

local function finalMove(e,target,speed)
    local localRoot=course:ToLocal(e.Root.Position); local localTarget=course:ToLocal(target)
    if localTarget.X<localRoot.X-4 then move(e,target,speed); return end
    local step=finalRoute[e.FinalPoint]
    local function point(def) return course:ToWorld(Vector3.new(def[1],41.2,def[2])) end
    while step and flatDistance(e.Root.Position,point(step))<2.8 do
        e.FinalPoint+=1; step=finalRoute[e.FinalPoint]
    end
    if not step or (step[1]>localTarget.X and visible(e,target)) then move(e,target,speed); return end
    e.Hum.WalkSpeed=speed
    e.Model:SetAttribute('RacePoint',e.FinalPoint)
    if step[3] and e.FinalJumped~=e.FinalPoint and e.Hum.FloorMaterial~=Enum.Material.Air then
        e.Hum.Jump=true; e.FinalJumped=e.FinalPoint
    end
    e.Hum:MoveTo(point(step))
    if flatDistance(e.Root.Position,e.LastPosition)>.7 then e.LastPosition=e.Root.Position;e.StuckSince=clock()
    elseif clock()-e.StuckSince>1.3 then
        e.FinalJumped=0;e.Hum.Jump=true;e.StuckSince=clock();e.Recoveries+=1
        e.Model:SetAttribute('RouteRecoveries',e.Recoveries)
    end
end

function AI.Step(dt)
    local t=clock()
    for player,s in P.States do
        local r,h=P.Root(player)
        local eligible=s.Active and not s.Finished and not s.Busy and (s.Stage==2 or s.Stage==5 or s.Stage==6) and r and h and h.Health>0
        local e=AI.Encounters[player]
        if not eligible then if e then AI.Reset(player) end; continue end
        if e and e.Stage~=s.Stage then AI.Reset(player); e=nil end
        e=e or spawn(player,s)
        if t<e.Ready then continue end
        local target=r.Position; local localTarget=course:ToLocal(target)
        local safe=t<s.Protected or (s.Stage==2 and localTarget.X<132) or (s.Stage==5 and localTarget.X<462) or (s.Stage==6 and localTarget.X>=728)
        local inZone=if s.Stage==2 then localTarget.X>=132 and localTarget.X<204 elseif s.Stage==5 then localTarget.X>=444 and localTarget.X<=575 else localTarget.X>=577 and localTarget.X<735
        if not inZone or safe then
            if s.Stage==6 then state(e,'Idle'); e.Hum:MoveTo(e.Root.Position); continue end
            if e.State=='Chase' or e.State=='Alert' or e.State=='Investigate' then state(e,'Return') end
        end
        local delta=target-e.Root.Position
        local canSee=not safe and inZone and delta.Magnitude<(if s.Stage==2 then 26 else Config.DetectDistance) and visible(e,target)
        local facing=delta.Magnitude<10 or (delta.Magnitude>.01 and e.Root.CFrame.LookVector:Dot(delta.Unit)>.05)
        if s.Stage==6 and e.State~='Chase' then state(e,'Chase') end
        if s.Stage~=6 then
            if (e.State=='Patrol' or e.State=='Return' or e.State=='Investigate') and canSee and facing then state(e,'Alert'); e.LastSeen=t; e.LastKnown=target end
            if e.State=='Alert' then
                e.Hum:MoveTo(e.Root.Position)
                if canSee then e.LastSeen=t; e.LastKnown=target end
                if t-e.Since>.65 then state(e,'Chase') end
            end
            if e.State=='Chase' then
                if canSee then e.LastSeen=t; e.LastKnown=target end
                if t-e.LastSeen>Config.LoseSightSeconds then state(e,'Investigate') end
            elseif e.State=='Investigate' and t-e.Since>2 then state(e,'Return') end
        end
        if e.State=='Chase' then
            local chaseTarget=if s.Stage==6 or canSee then target else e.LastKnown or target
            local speed=if s.Stage==2 then Config.HallChaseSpeed elseif s.Stage==5 then Config.ChaseSpeed else Config.FinalChaseSpeed+(Config.FinalChaseMaxSpeed-Config.FinalChaseSpeed)*math.clamp((t-e.Ready)/10,0,1)
            if s.Stage==6 then finalMove(e,chaseTarget,speed) else move(e,chaseTarget,speed) end
            if delta.Magnitude<Config.CatchDistance and visible(e,target) then P.Fail(player,true); continue end
            if t-e.LastTalk>11 then e.LastTalk=t; P.Send(player,'Dialogue',Config.Dialogue[math.random(#Config.Dialogue)]) end
        elseif e.State=='Patrol' or e.State=='Return' then
            local goal=patrolGoal(e); move(e,goal,Config.PatrolSpeed)
            if flatDistance(e.Root.Position,goal)<3 then
                e.Point=e.Point%(if e.Stage==2 then #hallRoute else #patrol)+1; e.PatrolVisits+=1
                e.Model:SetAttribute('PatrolVisits',e.PatrolVisits); e.Model:SetAttribute('PatrolPoint',e.Point)
                clearPath(e); if e.State=='Return' then state(e,'Patrol') end
            end
        elseif e.State=='Investigate' then move(e,e.LastKnown or e.Root.Position,Config.PatrolSpeed) end
        local pos=course:ToLocal(e.Root.Position)
        local minX=if s.Stage==2 then 126 elseif s.Stage==5 then 460 else 576
        local maxX=if s.Stage==2 then 204 elseif s.Stage==5 then 575 else 736
        if pos.Y<35 or pos.X<minX or pos.X>maxX then AI.Reset(player) end
    end
end
return AI
