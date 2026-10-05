local S = game:GetService('ProximityPromptService')
local Config = require(game.ReplicatedStorage.EscapeShared.Config)
local Quiz = require(script.Parent.Quiz)
local I={}
function I.Init(world,P)
    local function near(player,part,dist)
        local root,hum=P.Root(player); local s=P.States[player]
        return s and s.Active and not s.Finished and not s.Busy and root and hum and hum.Health>0 and (root.Position-part.Position).Magnitude<dist
    end
    local function handle(player,part)
        local s=P.States[player]; local t=workspace:GetServerTimeNow()
        if not s or not near(player,part,14) or part:GetAttribute('Stage')~=s.Stage or t-s.LastPrompt<0.25 then return end
        s.LastPrompt=t
        local action=part:GetAttribute('Action')
        if action=='Homework' then
            local id=part:GetAttribute('ItemId'); if s.Sheets[id] then return end
            s.Sheets[id]=true; s.Homework+=1; P.Push(player); P.Send(player,'Pickup',{Name=part.Name,Text='Homework '..s.Homework..'/3',Position=part.Position})
        elseif action=='Key' then
            if s.Key then return end
            s.Key=true; s.Protected=math.max(s.Protected,t+1.5); P.Push(player); P.Send(player,'Pickup',{Name=part.Name,Text='EXIT KEY! Get to the final door.',Position=part.Position})
        elseif action=='Quiz' then
            if s.Quiz>=3 then P.Send(player,'Toast',{Text='Quiz complete! Use the exit.',Tone='good'}); return end
            s.QuizOpenUntil=t+90; P.Send(player,'Quiz',Quiz.View(s))
        elseif action=='Door' then
            if s.Stage==1 then
                if s.Homework<3 then P.Send(player,'Toast',{Text='Find all 3 homework sheets first.',Tone='bad'}); return end
                P.Stage(player,2,'HallStart')
                P.Send(player,'Dialogue',"YOU DIDN'T SHOW YOUR WORK!")
            elseif s.Stage==2 then
                if s.Checkpoint~='HallEnd' then P.Send(player,'Toast',{Text='Reach the green checkpoint at the end of the hallway.',Tone='bad'}); return end
                P.Stage(player,3,'LibraryStart')
            elseif s.Stage==3 then
                if s.Checkpoint~='LibraryEnd' then P.Send(player,'Toast',{Text='Use both library checkpoints first.',Tone='bad'}); return end
                P.Stage(player,4,'Science')
            elseif s.Stage==4 then
                if s.Quiz<3 then P.Send(player,'Toast',{Text='The quiz board unlocks this exit.',Tone='bad'}); return end
                P.Stage(player,5,'Staff'); P.Send(player,'Dialogue','Grab the key. Don’t let the professor catch you!')
            end
        elseif action=='FinalDoor' then
            if not s.Key then P.Send(player,'Toast',{Text='You need the gold exit key!',Tone='bad'}); return end
            P.Send(player,'DoorOpening',{Name=part.Name}); P.Stage(player,6,'Final'); P.Send(player,'Dialogue','FINAL BELL! Weave, jump, and sprint. He is getting faster!')
        end
    end
    S.PromptTriggered:Connect(function(prompt,player)
        local part=prompt.Parent
        if part and part:IsA('BasePart') and part:IsDescendantOf(world) then handle(player,part) end
    end)
    I.Handle=handle
    I.Near=near
    I.Answer=function(player,index)
        local s=P.States[player]; local t=workspace:GetServerTimeNow(); local board=world.Doors.QuizBoard
        if not s or s.Stage~=4 or s.Quiz>=3 or t>s.QuizOpenUntil or t<s.QuizUntil or not near(player,board,19) or type(index)~='number' or index%1~=0 or index<1 or index>3 then return end
        local question=s.QuizDeck[s.Quiz+1]
        if index==question.Correct then
            s.Quiz+=1; s.QuizUntil=t+0.85; P.Push(player)
            P.Send(player,'QuizResult',{Correct=true,Done=s.Quiz>=3,Question=Quiz.View(s),Text=question.Explanation,Answer=index})
        else
            s.QuizUntil=t+Config.QuizCooldown
            P.Send(player,'QuizResult',{Correct=false,Question=Quiz.View(s),Text=question.Hint,Answer=index,Cooldown=Config.QuizCooldown})
        end
    end
end
return I
