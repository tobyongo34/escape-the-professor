-- Studio-only regression driver. Temporarily copy into src/server, then remove before saving.
if not game:GetService('RunService'):IsStudio() then return end
local Players=game:GetService('Players')
local P=require(script.Parent.Progression)
local AI=require(script.Parent.ProfessorAI)
local I=require(script.Parent.Interactions)
local Quiz=require(script.Parent.Quiz)
local world=workspace:WaitForChild('EscapeSchool')
local course=require(game.ReplicatedStorage.EscapeShared.Course).new(world)
local function at(x,y,z) return course:ToWorldCFrame(CFrame.new(x,y,z)) end
local bridge=Instance.new('BindableFunction')
bridge.Name='EscapeRegression'
bridge.Parent=game.ServerStorage
local function player()
    local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    while not P.States[p] or not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') do task.wait() end
    local _,h=P.Root(p)
    if h.Health<=0 then p:LoadCharacterAsync(); task.wait(.3) end
    return p
end
local function prepare(n)
    local p=player()
    -- Keep rapid server-side fixture teleports from being replaced by an old client pose.
    local root=P.Root(p);root:SetNetworkOwner(nil)
    AI.Reset(p)
    P.States[p].Active=false
    P.Start(p)
    local cp=({'Classroom','HallStart','LibraryStart','Science','Staff','Final'})[n]
    if n~=1 then P.Stage(p,n,cp) end
    return p,P.States[p]
end
bridge.OnInvoke=function(action,arg)
    if action=='Prepare' then
        local p,s=prepare(arg or 1)
        return {stage=s.Stage,active=s.Active}
    elseif action=='Snapshot' then
        local p=player();local s=P.States[p];local r,h=P.Root(p);local e=AI.Encounters[p]
        return {stage=s.Stage,sprinting=s.Sprinting,speed=h.WalkSpeed,stamina=s.Stamina,busy=s.Busy,falls=s.Falls,
            health=h.Health,position=tostring(r.Position),catches=s.Catches,key=s.Key,quiz=s.Quiz,
            state=e and e.State or 'none',checkpoint=s.Checkpoint,finished=s.Finished,
            visits=e and e.PatrolVisits,recoveries=e and e.Recoveries,path=e and e.Model:GetAttribute('PathStatus')}
    elseif action=='PatrolCircuit' then
        local p,s=prepare(arg or 5);s.Protected=math.huge;task.wait(1.3)
        local e=assert(AI.Encounters[p]);local visits=e.PatrolVisits;local travelled=0;local previous=e.Root.Position
        for _=1,24 do task.wait(1);local pos=e.Root.Position;travelled+=(pos-previous).Magnitude;previous=pos end
        return {stage=s.Stage,visits=e.PatrolVisits-visits,travelled=math.floor(travelled),recoveries=e.Recoveries,
            completedCircuit=e.PatrolVisits-visits>=4,sameActor=AI.Encounters[p]==e,path=e.Model:GetAttribute('PathStatus')}
    elseif action=='RunFinal' then
        local p,s=prepare(6);s.Key=true;P.Push(p)
        local root,hum=P.Root(p);local started=workspace:GetServerTimeNow();local nearest=math.huge;local lastGap=0;local recoveries=0
        local route={{618,10},{632,10},{641,0},{643,0},{655,0,true},{659,-10},{677,-10},{682,0},{694,0,true},{716,0},{729,0,true},{736,0}}
        local reached=0
        for i,point in route do
            local goal=course:ToWorld(Vector3.new(point[1],44.25,point[2]))
            if point[3] then hum.Jump=true end
            hum:MoveTo(goal)
            while (Vector3.new(root.Position.X,goal.Y,root.Position.Z)-goal).Magnitude>2.5 do
                if s.Catches>0 or s.Finished or workspace:GetServerTimeNow()-started>23 then break end
                -- Conserve stamina through the opening turn, then sprint the second half.
                s.Sprinting=arg=='sprint' and course:ToLocal(root.Position).X>642 and s.Stamina>.02
                local e=AI.Encounters[p]
                if e then
                    lastGap=(e.Root.Position-root.Position).Magnitude;recoveries=e.Recoveries
                    if workspace:GetServerTimeNow()>e.Ready then nearest=math.min(nearest,lastGap) end
                end
                task.wait(.05)
            end
            if s.Catches>0 or s.Finished or workspace:GetServerTimeNow()-started>23 then break end
            reached=i
        end
        s.Sprinting=false
        return {mode=arg,finished=s.Finished,catches=s.Catches,falls=s.Falls,seconds=math.floor((workspace:GetServerTimeNow()-started)*10)/10,
            closestProfessor=math.floor(nearest*10)/10,lastGap=math.floor(lastGap*10)/10,recoveries=recoveries,waypoints=reached,position=tostring(course:ToLocal(root.Position)),stamina=s.Stamina}
    elseif action=='StandCatch' then
        local p,s=prepare(arg or 6);s.Key=s.Stage==6;s.Protected=0
        if s.Stage==5 then p.Character:PivotTo(at(542,44.5,14)) end
        local started=workspace:GetServerTimeNow()
        while s.Catches==0 and workspace:GetServerTimeNow()-started<9 do task.wait(.1) end
        return {caught=s.Catches>0,seconds=workspace:GetServerTimeNow()-started}
    elseif action=='Quiz' then
        local p,s=prepare(4)
        p.Character:PivotTo(at(419,45,-13))
        I.Handle(p,world.Doors.QuizBoard)
        return {stage=s.Stage,open=s.QuizOpenUntil>workspace:GetServerTimeNow()}
    elseif action=='Answer' then
        local p=player();I.Answer(p,arg);return P.States[p].Quiz
    elseif action=='FinalBoundary' then
        local p,s=prepare(6);s.Key=true;s.Protected=0
        p.Character:PivotTo(at(635,45,0))
        AI.Step(.1)
        local e=assert(AI.Encounters[p]);e.Ready=0;e.Root.Anchored=true
        e.Model:PivotTo(at(600,44.7,0))
        AI.Step(.1);local before=e.State
        p.Character:PivotTo(at(730,45,25));AI.Step(.1);local safe=e.State
        p.Character:PivotTo(at(635,45,0));AI.Step(.1);local after=e.State
        prepare(1)
        return {before=before,safe=safe,after=after,resumes=after=='Chase'}
    elseif action=='LateCollisionPart' then
        local p=player();local part=Instance.new('Part');part.Name='RegressionLatePart';part.Size=Vector3.one
        part.CanCollide=false;part.Massless=true;part.Anchored=true;part.CFrame=p.Character.HumanoidRootPart.CFrame
        part.Parent=p.Character;task.wait(.1);local group=part.CollisionGroup;part:Destroy()
        return {group=group,passed=group=='EscapePlayers'}
    elseif action=='ProgressionRules' then
        local p,s=prepare(1)
        p.Character:PivotTo(at(30,45,0));I.Handle(p,world.Doors.ClassroomExit)
        local locked=s.Stage==1
        prepare(3);s=P.States[p]
        P.Checkpoint(p,'LibraryEnd');local skipRejected=s.Checkpoint=='LibraryStart'
        P.Checkpoint(p,'LibraryMid');P.Checkpoint(p,'LibraryEnd');P.Checkpoint(p,'LibraryStart')
        local checkpointPreserved=s.Checkpoint=='LibraryEnd'
        prepare(4);s=P.States[p];p.Character:PivotTo(at(419,45,-13));I.Handle(p,world.Doors.QuizBoard)
        local first=s.QuizDeck[1].Correct
        I.Answer(p,0/0);I.Answer(p,4);I.Answer(p,first%3+1);I.Answer(p,first)
        local wrongCooldown=s.Quiz==0
        task.wait(1.7);I.Answer(p,s.QuizDeck[1].Correct);task.wait(.9);I.Answer(p,s.QuizDeck[2].Correct);task.wait(.9);I.Answer(p,s.QuizDeck[3].Correct)
        local quizDone=s.Quiz==3
        prepare(5);s=P.States[p];p.Character:PivotTo(at(570,45,0));I.Handle(p,world.Doors.FinalExit)
        local keyRequired=s.Stage==5
        prepare(1)
        return {lockedClassroom=locked,skipRejected=skipRejected,checkpointPreserved=checkpointPreserved,wrongCooldown=wrongCooldown,quizDone=quizDone,keyRequired=keyRequired}
    elseif action=='QuizVariety' then
        local seen,positions={},{}
        for seed=1,100 do
            local deck=Quiz.NewDeck(Random.new(seed))
            assert(#deck==3)
            for category,q in deck do
                assert(q.Category==category and #q.Answers==3 and q.Correct>=1 and q.Correct<=3)
                assert(q.Answers[1]~=q.Answers[2] and q.Answers[2]~=q.Answers[3] and q.Answers[1]~=q.Answers[3])
                seen[q.Id]=true; positions[q.Correct]=true
            end
        end
        local count=0;for _ in seen do count+=1 end
        local p,s=prepare(4);local deck=s.QuizDeck
        local view=Quiz.View(s)
        local private=view.Correct==nil and view.Hint==nil and view.Explanation==nil and view.Id==nil
        view.Answers[1]='tampered';local isolated=s.QuizDeck[1].Answers[1]~='tampered'
        P.Fail(p,false);task.wait(1.4)
        local retained=s.QuizDeck==deck
        s.Active=false;P.Start(p)
        return {questionsSeen=count,allAnswerPositions=positions[1] and positions[2] and positions[3],answersPrivate=private,viewIsCopy=isolated,deckRetainedOnFall=retained,newDeckOnReplay=P.States[p].QuizDeck~=deck}
    elseif action=='QuizAnswer' then
        local p=player();local s=P.States[p];local index=s.QuizDeck[s.Quiz+1].Correct
        if arg=='wrong' then index=index%3+1 end
        I.Answer(p,index);return {index=index,progress=s.Quiz}
    elseif action=='CoursePlacement' then
        local original=world:GetPivot()
        world:PivotTo(CFrame.new(40,15,30)*CFrame.Angles(0,math.pi/2,0)*original)
        local p,s=prepare(1);task.wait(1)
        local root=P.Root(p);local localPos=course:ToLocal(root.Position)
        local shuttlePos=course:ToLocal(world.Platforms.StationeryShuttle.Position)
        local result={noFalseFall=s.Falls==0 and not s.Busy,localPosition=tostring(localPos),
            shuttlePlaced=math.abs(shuttlePos.X-327)<.01 and math.abs(shuttlePos.Y-44)<.01 and math.abs(shuttlePos.Z-4)<=1.61}
        world:PivotTo(original);prepare(1)
        return result
    elseif action=='TranslatedObstacles' then
        local p,s=prepare(2)
        p.Character:PivotTo(at(63,45,0));task.wait(.4)
        local _,h=P.Root(p);local puddleSlow=h.WalkSpeed==10
        local pencil
        for _,d in world.Hazards:GetChildren() do if d:GetAttribute('Hazard')=='Pencil' then pencil=d;break end end
        local localPencil=course:ToLocal(pencil.Position)
        p.Character:PivotTo(at(localPencil.X,44.4,localPencil.Z));task.wait(.3)
        local pencilFall=s.Falls==1
        prepare(3);s=P.States[p]
        p.Character:PivotTo(at(239,43.5,18));task.wait(.3)
        local homeworkFall=s.Falls==1
        prepare(1)
        return {puddleSlow=puddleSlow,pencilFall=pencilFall,homeworkFall=homeworkFall}
    elseif action=='FinishReplay' then
        local p,s=prepare(6);s.Key=true;s.Protected=math.huge
        p.Character:PivotTo(at(734,45,0));P.Finish(p)
        local finished=s.Finished and AI.Encounters[p]==nil and (p.Character.HumanoidRootPart.Position-world.Checkpoints.Hangout.Position).Magnitude<8
        P.Start(p);s=P.States[p]
        return {finished=finished,replay=s.Stage==1 and s.Active and not s.Finished and not s.Key and s.Homework==0}
    elseif action=='ReplayChallenges' then
        local p,s=prepare(1)
        local passes=world.BonusPasses
        p.Character:PivotTo(at(20,45,20))
        local distantRejected=not P.CollectPass(p,passes.HallPass1)
        p.Character:PivotTo(passes.HallPass2.CFrame)
        local wrongStageRejected=not P.CollectPass(p,passes.HallPass2)
        p.Character:PivotTo(passes.HallPass1.CFrame)
        s.Busy=true; local busyRejected=not P.CollectPass(p,passes.HallPass1); s.Busy=false
        s.Active=false; local inactiveRejected=not P.CollectPass(p,passes.HallPass1); s.Active=true
        local collected=P.CollectPass(p,passes.HallPass1)
        local duplicateRejected=not P.CollectPass(p,passes.HallPass1) and s.PassCount==1
        P.Fail(p,false);task.wait(1.4)
        local survivesFall=s.PassCount==1 and s.Passes['1']==true
        for stage=2,6 do
            P.Stage(p,stage,({'Classroom','HallStart','LibraryMid','Science','Staff','Final'})[stage])
            s.Protected=math.huge
            local pass=passes['HallPass'..stage]
            p.Character:PivotTo(pass.CFrame);P.CollectPass(p,pass)
        end
        local allSix=s.PassCount==6
        s.Key=true;s.Started=workspace:GetServerTimeNow()-120
        p.Character:PivotTo(at(734,45,0));P.Finish(p)
        local firstBest=P.Records[p]
        P.Start(p);s=P.States[p]
        local replayReset=s.PassCount==0 and next(s.Passes)==nil and P.Records[p]==firstBest
        P.Stage(p,6,'Final');s.Key=true;s.Started=workspace:GetServerTimeNow()-150
        p.Character:PivotTo(at(734,45,0));P.Finish(p)
        local slowPreserved=P.Records[p]==firstBest
        P.Start(p);s=P.States[p];P.Stage(p,6,'Final');s.Key=true;s.Started=workspace:GetServerTimeNow()-90
        p.Character:PivotTo(at(734,45,0));P.Finish(p)
        local fasterUpdated=P.Records[p]<firstBest and math.abs(P.Records[p]-90)<1
        return {distantRejected=distantRejected,wrongStageRejected=wrongStageRejected,busyRejected=busyRejected,
            inactiveRejected=inactiveRejected,collected=collected,duplicateRejected=duplicateRejected,
            survivesFall=survivesFall,allSix=allSix,replayReset=replayReset,slowPreserved=slowPreserved,fasterUpdated=fasterUpdated}
    end
    error('Unknown regression command: '..tostring(action))
end
