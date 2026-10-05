local Players=game:GetService('Players')
local GuiService=game:GetService('GuiService')
local UIS=game:GetService('UserInputService')
local UI={}
local C={bg=Color3.fromRGB(23,42,59),panel=Color3.fromRGB(31,57,73),yellow=Color3.fromRGB(255,203,70),white=Color3.fromRGB(255,249,229),muted=Color3.fromRGB(179,204,210),green=Color3.fromRGB(99,220,159),red=Color3.fromRGB(255,121,116)}
local function new(class,props,parent) local o=Instance.new(class); for k,v in props do o[k]=v end; o.Parent=parent; return o end
local function corner(o,r) new('UICorner',{CornerRadius=UDim.new(0,r or 14)},o) end
local function panel(parent,name,size,pos,anchor,color,z)
    local p=new('Frame',{Name=name,Size=size,Position=pos,AnchorPoint=anchor or Vector2.zero,BackgroundColor3=color or C.panel,BorderSizePixel=0,ZIndex=z or 2},parent); corner(p); new('UIStroke',{Color=C.muted,Transparency=0.78,Thickness=1},p); return p
end
local function text(parent,name,str,size,pos,fontSize,col,z)
    return new('TextLabel',{Name=name,Text=str,Size=size,Position=pos,BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=fontSize or 18,TextColor3=col or C.white,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,ZIndex=z or parent.ZIndex+1},parent)
end
local function button(parent,name,str,size,pos,callback,col)
    local b=new('TextButton',{Name=name,Text=str,Size=size,Position=pos,BackgroundColor3=col or C.yellow,BorderSizePixel=0,TextColor3=C.bg,Font=Enum.Font.GothamBold,TextSize=19,AutoButtonColor=true,Selectable=true,ZIndex=parent.ZIndex+2},parent); corner(b,11); b.Activated:Connect(callback); return b
end
local function selectButton(b) if UIS.GamepadEnabled then GuiService.SelectedObject=b end end
function UI.Init(config,event,effects)
    local gui=new('ScreenGui',{Name='EscapeInterface',ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=25,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},Players.LocalPlayer:WaitForChild('PlayerGui')); UI.Gui=gui
    local root=new('Frame',{Name='Canvas',Size=UDim2.fromScale(1,1),BackgroundTransparency=1},gui); UI.Root=root
    local scale=new('UIScale',{Scale=1},root)
    local function resize()
        local v=workspace.CurrentCamera.ViewportSize; local s=math.clamp(math.min(v.X/1024,v.Y/680),0.68,1.12)
        scale.Scale=s; root.Size=UDim2.fromScale(1/s,1/s)
        if UI.ApplyResponsive then UI.ApplyResponsive(v,s) end
    end
    resize(); workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)
    local hud=panel(root,'ObjectiveCard',UDim2.fromOffset(420,164),UDim2.fromOffset(20,18))
    UI.RoomAccent=new('Frame',{Name='RoomAccent',Size=UDim2.new(1,-24,0,3),Position=UDim2.fromOffset(12,0),BackgroundColor3=C.yellow,BorderSizePixel=0,ZIndex=3},hud)
    text(hud,'School','POPQUIZ ACADEMY  /  AFTER HOURS',UDim2.new(1,-32,0,20),UDim2.fromOffset(16,10),12,C.yellow)
    UI.Stage=text(hud,'Stage','01  SURPRISE EXAM',UDim2.new(1,-32,0,29),UDim2.fromOffset(16,32),22)
    UI.Stage.Font=Enum.Font.GothamBold
    UI.Objective=text(hud,'Objective','Find 3 glowing homework sheets.',UDim2.new(1,-32,0,44),UDim2.fromOffset(16,64),15,C.muted)
    UI.Counter=text(hud,'Counter','HOMEWORK  0 / 3',UDim2.new(1,-32,0,20),UDim2.fromOffset(16,106),13,C.yellow)
    local route=new('Frame',{Name='Route',Size=UDim2.new(1,-32,0,20),Position=UDim2.fromOffset(16,135),BackgroundTransparency=1},hud)
    UI.Route={}
    for i=1,6 do
        local segment=text(route,'Room'..i,string.format('%02d',i),UDim2.new(1/6,-5,1,0),UDim2.fromScale((i-1)/6,0),11,C.muted,4)
        segment.BackgroundTransparency=0; segment.BackgroundColor3=C.bg; segment.TextXAlignment=Enum.TextXAlignment.Center; corner(segment,5); UI.Route[i]=segment
    end
    local timer=panel(root,'TimerCard',UDim2.fromOffset(147,108),UDim2.new(1,-20,0,18),Vector2.new(1,0))
    text(timer,'Title','ESCAPE TIME',UDim2.new(1,-24,0,21),UDim2.fromOffset(12,8),12,C.muted)
    UI.Timer=text(timer,'Timer','0:00',UDim2.new(1,-24,0,38),UDim2.fromOffset(12,31),28,C.white); UI.Timer.Font=Enum.Font.GothamBold
    UI.Best=text(timer,'Best','SESSION BEST  —',UDim2.new(1,-24,0,25),UDim2.fromOffset(12,75),11,C.yellow)
    UI.SettingsButton=button(root,'SettingsButton','⚙ SETTINGS',UDim2.fromOffset(147,34),UDim2.new(1,-167,0,138),function() UI.Settings.Visible=not UI.Settings.Visible; if UI.Settings.Visible then selectButton(UI.Guidance) end end,C.muted)
    local stamina=panel(root,'StaminaCard',UDim2.fromOffset(254,54),UDim2.new(0.5,0,1,-22),Vector2.new(0.5,1)); UI.StaminaCard=stamina
    text(stamina,'Title','SPRINT  ·  SHIFT / L3',UDim2.fromOffset(226,20),UDim2.fromOffset(14,5),11,C.muted)
    local track=panel(stamina,'Track',UDim2.fromOffset(226,10),UDim2.fromOffset(14,31),nil,C.bg)
    UI.Stamina=new('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=C.yellow,BorderSizePixel=0,ZIndex=5},track); corner(UI.Stamina,5)
    UI.Alert=panel(root,'ProfessorAlert',UDim2.fromOffset(490,44),UDim2.new(0.5,0,0,166),Vector2.new(0.5,0),C.red,8); UI.Alert.Visible=false
    UI.AlertText=text(UI.Alert,'Message','RUN! THE PROFESSOR SAW YOU!',UDim2.new(1,-24,1,0),UDim2.fromOffset(12,0),17,C.bg)
    UI.DangerBar=new('Frame',{Name='DistanceBar',Size=UDim2.new(.5,-8,0,4),Position=UDim2.new(0,4,1,-5),BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=10,Visible=false},UI.Alert); corner(UI.DangerBar,2)
    UI.Dialogue=panel(root,'ProfessorSubtitle',UDim2.fromOffset(550,54),UDim2.new(0.5,0,1,-100),Vector2.new(0.5,1),C.bg,8); UI.Dialogue.Visible=false
    UI.DialogueText=text(UI.Dialogue,'Line','',UDim2.new(1,-30,1,0),UDim2.fromOffset(15,0),19,C.yellow); UI.DialogueText.TextXAlignment=Enum.TextXAlignment.Center
    UI.Toast=panel(root,'Toast',UDim2.fromOffset(430,45),UDim2.new(0.5,0,0,224),Vector2.new(0.5,0),C.panel,10); UI.Toast.Visible=false
    UI.ToastText=text(UI.Toast,'Message','',UDim2.new(1,-24,1,0),UDim2.fromOffset(12,0),17,C.green); UI.ToastText.TextXAlignment=Enum.TextXAlignment.Center
    local scrim=new('Frame',{Name='Menu',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=0.18,BorderSizePixel=0,ZIndex=30},root); UI.Menu=scrim
    local card=panel(scrim,'MenuCard',UDim2.fromOffset(590,480),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),C.bg,31)
    text(card,'Eyebrow','A POPQUIZ ACADEMY ESCAPE',UDim2.fromOffset(516,24),UDim2.fromOffset(37,28),14,C.yellow)
    local title=text(card,'Title','ESCAPE THE\nPROFESSOR!',UDim2.fromOffset(516,124),UDim2.fromOffset(37,68),48,C.white); title.Font=Enum.Font.GothamBlack
    text(card,'Pitch','School ended. He assigned 1,000 questions.\nYour only correct answer is the school bus.',UDim2.fromOffset(516,60),UDim2.fromOffset(37,206),20,C.muted)
    text(card,'Route','6 ROOMS  •  6 BONUS HALL PASSES  •  BEAT YOUR TIME',UDim2.fromOffset(516,38),UDim2.fromOffset(37,283),13,C.yellow)
    UI.Play=button(card,'Play','LET’S GET OUT OF HERE  →',UDim2.fromOffset(516,58),UDim2.fromOffset(37,340),function() event:FireServer('Play') end)
    text(card,'Controls','Move: WASD / stick  ·  Jump: Space / A\nInteract: E / X / tap  ·  Sprint: Shift / L3 / RUN',UDim2.fromOffset(516,47),UDim2.fromOffset(37,414),14,C.muted); selectButton(UI.Play)
    UI.Quiz=panel(root,'Quiz',UDim2.fromOffset(500,466),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),C.bg,45); UI.Quiz.Visible=false
    UI.QuizRevision=0
    UI.Quiz:GetPropertyChangedSignal('Visible'):Connect(function()
        if not UI.Quiz.Visible then UI.QuizRevision+=1 end
    end)
    UI.QuizCount=text(UI.Quiz,'Count','POP QUIZ  1 / 3',UDim2.fromOffset(390,25),UDim2.fromOffset(28,22),14,C.yellow)
    button(UI.Quiz,'Close','×',UDim2.fromOffset(36,34),UDim2.fromOffset(436,18),function() UI.Quiz.Visible=false; GuiService.SelectedObject=nil end,C.muted)
    UI.Question=text(UI.Quiz,'Question','',UDim2.fromOffset(444,77),UDim2.fromOffset(28,64),25); UI.Question.Font=Enum.Font.GothamBold
    UI.Answers={}
    for i=1,3 do UI.Answers[i]=button(UI.Quiz,'Answer'..i,'',UDim2.fromOffset(444,53),UDim2.fromOffset(28,143+(i-1)*64),function() if not UI.QuizLocked then event:FireServer('Answer',i) end end,if i==1 then C.yellow else C.muted) end
    UI.QuizFeedback=text(UI.Quiz,'Feedback','Three questions. You’ve got this.',UDim2.fromOffset(444,40),UDim2.fromOffset(28,352),16,C.green)
    UI.Results=panel(root,'Results',UDim2.fromOffset(570,510),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),C.bg,60); UI.Results.Visible=false
    text(UI.Results,'Escaped','YOU ESCAPED\nTHE PROFESSOR!',UDim2.fromOffset(506,98),UDim2.fromOffset(32,27),35,C.yellow).Font=Enum.Font.GothamBlack
    UI.ResultGrade=text(UI.Results,'Grade','A · ESCAPE SCHOLAR',UDim2.fromOffset(506,40),UDim2.fromOffset(32,141),23,C.green)
    UI.Stats=text(UI.Results,'Stats','',UDim2.fromOffset(506,76),UDim2.fromOffset(32,184),20,C.white)
    text(UI.Results,'Formula','A: ≤8 min, ≤2 catches  ·  B: ≤12 min, ≤5 catches\nC: Every other escape. Falls are tracked separately.',UDim2.fromOffset(506,52),UDim2.fromOffset(32,267),13,C.muted)
    UI.Medals=text(UI.Results,'Medals','',UDim2.fromOffset(506,40),UDim2.fromOffset(32,327),17,C.yellow)
    UI.Replay=button(UI.Results,'PlayAgain','PLAY AGAIN',UDim2.fromOffset(244,55),UDim2.fromOffset(32,381),function() event:FireServer('Play') end)
    button(UI.Results,'HangOut','HANG OUT',UDim2.fromOffset(244,55),UDim2.fromOffset(294,381),function() UI.Results.Visible=false; GuiService.SelectedObject=nil; event:FireServer('Hangout') end,C.muted)
    text(UI.Results,'Footer','The bell dismissed you. Eventually.',UDim2.fromOffset(506,30),UDim2.fromOffset(32,455),16,C.muted)
    UI.Settings=panel(root,'Settings',UDim2.fromOffset(380,318),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),C.bg,70); UI.Settings.Visible=false
    text(UI.Settings,'Title','YOUR SETTINGS',UDim2.fromOffset(310,38),UDim2.fromOffset(26,17),22)
    local names={{'Guidance','OBJECTIVE HINTS'},{'Sfx','SOUND EFFECTS'},{'ReducedMotion','REDUCED MOTION'}}
    for i,def in names do local b; b=button(UI.Settings,def[1],def[2]..': '..(effects.Settings[def[1]] and 'ON' or 'OFF'),UDim2.fromOffset(328,43),UDim2.fromOffset(26,68+(i-1)*55),function() effects.Settings[def[1]]=not effects.Settings[def[1]]; b.Text=def[2]..': '..(effects.Settings[def[1]] and 'ON' or 'OFF') end,C.muted); if i==1 then UI.Guidance=b end end
    button(UI.Settings,'Done','DONE',UDim2.fromOffset(328,43),UDim2.fromOffset(26,246),function() UI.Settings.Visible=false; GuiService.SelectedObject=nil end)
    UI.Fail=panel(root,'Failure',UDim2.fromOffset(510,154),UDim2.fromScale(0.5,0.5),Vector2.new(0.5,0.5),C.red,80); UI.Fail.Visible=false
    UI.FailText=text(UI.Fail,'Text','DETENTION!',UDim2.new(1,-32,0,60),UDim2.fromOffset(16,14),31,C.bg); UI.FailText.TextXAlignment=Enum.TextXAlignment.Center; UI.FailText.Font=Enum.Font.GothamBlack
    UI.FailTip=text(UI.Fail,'Retry','Back to your checkpoint. You’ve got this.',UDim2.new(1,-40,0,64),UDim2.fromOffset(20,76),18,C.bg); UI.FailTip.TextXAlignment=Enum.TextXAlignment.Center
    UI.Config=config; UI.Hud=hud; UI.TimerCard=timer
    UI.TouchSprint=button(root,'TouchSprint','RUN',UDim2.fromOffset(84,84),UDim2.new(1,-240,1,-220),function() if UI.OnTouchSprint then UI.OnTouchSprint() end end,C.yellow)
    UI.TouchSprint.AnchorPoint=Vector2.new(0,0); UI.TouchSprint.Visible=false
    UI.ResultsButton=button(root,'ResultsButton','RESULTS / REPLAY',UDim2.fromOffset(254,54),UDim2.new(0.5,-127,1,-76),function() UI.Results.Visible=true; selectButton(UI.Replay) end,C.yellow)
    UI.ResultsButton.Visible=false
    local fitPanels={card,UI.Quiz,UI.Results,UI.Settings,UI.Fail}
    for _,p in fitPanels do new('UIScale',{Name='FitScale',Scale=1},p) end
    UI.ApplyResponsive=function(v,s)
        local small=v.X<960 or v.Y<540
        local virtualWidth=v.X/s
        hud.Size=UDim2.fromOffset(math.min(420,virtualWidth-200),if small then 206 else 164)
        hud.School.TextSize=if small then 17 else 12
        UI.Objective.TextSize=if small then 18 else 15; UI.Objective.Size=UDim2.new(1,-32,0,if small then 82 else 44)
        UI.Counter.TextSize=if small then 17 else 13; UI.Counter.Position=UDim2.fromOffset(16,if small then 150 else 106)
        route.Position=UDim2.fromOffset(16,if small then 180 else 135)
        for _,segment in UI.Route do segment.TextSize=if small then 16 else 11 end
        timer.Title.TextSize=if small then 17 else 12
        UI.SettingsButton.Size=UDim2.fromOffset(147,if small then 66 else 34)
        stamina.Title.TextSize=if small then 17 else 11
        UI.Alert.Position=UDim2.new(0.5,0,0,if small then 236 else 201)
        UI.Toast.Position=UDim2.new(0.5,0,0,if small then 290 else 255)
        UI.Alert.Size=UDim2.fromOffset(math.min(490,virtualWidth-30),44)
        UI.Dialogue.Size=UDim2.fromOffset(math.min(550,virtualWidth-30),54)
        UI.Toast.Size=UDim2.fromOffset(math.min(430,virtualWidth-30),45)
        card.Pitch.TextSize=if small then 24 else 20; card.Controls.TextSize=if small then 21 else 14; card.Route.TextSize=if small then 19 else 13
        UI.Play.Size=UDim2.fromOffset(516,if small then 76 else 58); UI.Play.Position=UDim2.fromOffset(37,if small then 325 else 340)
        UI.Quiz.Size=UDim2.fromOffset(500,if small then 490 else 466)
        for i,b in UI.Answers do b.Size=UDim2.fromOffset(444,if small then 70 else 53); b.Position=UDim2.fromOffset(28,if small then 156+(i-1)*78 else 171+(i-1)*64); b.TextSize=if small then 22 else 19; b.TextWrapped=true end
        UI.Question.Position=UDim2.fromOffset(28,60); UI.Question.Size=UDim2.fromOffset(444,96)
        UI.Quiz.Close.Size=UDim2.fromOffset(if small then 64 else 36,if small then 54 else 34); UI.Quiz.Close.Position=UDim2.fromOffset(if small then 408 else 436,15)
        UI.QuizFeedback.Position=UDim2.fromOffset(28,if small then 401 else 370); UI.QuizFeedback.Size=UDim2.fromOffset(444,72); UI.QuizFeedback.TextSize=if small then 19 else 17
        UI.Results.Size=UDim2.fromOffset(570,if small then 528 else 510); UI.Results.Formula.TextSize=if small then 19 else 13
        UI.Results.Footer.Position=UDim2.fromOffset(32,if small then 485 else 455)
        for _,name in {'PlayAgain','HangOut'} do UI.Results[name].Size=UDim2.fromOffset(244,if small then 76 else 55) end
        UI.Settings.Size=UDim2.fromOffset(380,if small then 378 else 318)
        for i,name in {'Guidance','Sfx','ReducedMotion'} do UI.Settings[name].Size=UDim2.fromOffset(328,if small then 61 else 43); UI.Settings[name].Position=UDim2.fromOffset(26,68+(i-1)*(if small then 72 else 55)) end
        UI.Settings.Done.Size=UDim2.fromOffset(328,if small then 61 else 43); UI.Settings.Done.Position=UDim2.fromOffset(26,if small then 294 else 246)
        -- AbsoluteSize can still reflect the previous orientation during this callback.
        local topInset,bottomInset=GuiService:GetGuiInset()
        local usableHeight=math.max(120,v.Y-topInset.Y-bottomInset.Y)
        for _,p in fitPanels do p.FitScale.Scale=math.min(1,(v.X-24)/(p.Size.X.Offset*s),(usableHeight-18)/(p.Size.Y.Offset*s)) end
        UI.TouchSprint.Size=UDim2.fromOffset(64/s,64/s); UI.TouchSprint.Position=UDim2.new(1,-235/s,1,-156/s)
        -- Keep the course visible on landscape phones; use full-width objectives in portrait.
        local portrait=v.X<v.Y
        if portrait then
            hud.Size=UDim2.fromOffset(virtualWidth-40,164)
            timer.Position=UDim2.new(1,-20,0,192)
            UI.SettingsButton.Position=UDim2.fromOffset(20,192)
            UI.Alert.Position=UDim2.new(.5,0,0,316); UI.Toast.Position=UDim2.new(.5,0,0,370)
        else
            timer.Position=UDim2.new(1,-20,0,18); UI.SettingsButton.Position=UDim2.new(1,-167,0,138)
        end
        if small then
            hud.Size=UDim2.fromOffset(hud.Size.X.Offset,if portrait then 164 else 142)
            hud.School.TextSize=12
            UI.Stage.TextSize=if portrait then 21 else 20
            UI.Objective.TextSize=16; UI.Objective.Position=UDim2.fromOffset(16,62); UI.Objective.Size=UDim2.new(1,-32,0,if portrait then 44 else 34)
            UI.Counter.TextSize=13; UI.Counter.Position=UDim2.fromOffset(16,if portrait then 106 else 96)
            route.Position=UDim2.fromOffset(16,if portrait then 135 else 118)
            for _,segment in UI.Route do segment.TextSize=12 end
            UI.SettingsButton.Size=UDim2.fromOffset(147,48)
            if not portrait then UI.Alert.Position=UDim2.new(.5,0,0,170); UI.Toast.Position=UDim2.new(.5,0,0,222) end
        else UI.Objective.Position=UDim2.fromOffset(16,64); UI.Stage.TextSize=22 end
    end
    task.defer(resize)
    return UI
end
function UI.Time(seconds) local s=math.max(0,math.floor(seconds or 0)); return string.format('%d:%02d',math.floor(s/60),s%60) end
function UI.ShowQuiz(q,hint)
    if not q then UI.Quiz.Visible=false; return end
    UI.QuizRevision+=1
    UI.Quiz.Visible=true; UI.QuizLocked=false; UI.QuizCount.Text=q.Subject..'  ·  '..q.Index..' / '..q.Total; UI.Question.Text=q.Text
    for i,b in UI.Answers do b.Text=q.Answers[i]; b.BackgroundColor3=C.muted end
    UI.QuizFeedback.Text=if hint then 'HINT: '..hint else 'Pick one answer. Correct answers stay saved.'; UI.QuizFeedback.TextColor3=C.muted; selectButton(UI.Answers[1])
end
function UI.Introduce(stage)
    local school=UI.Hud.School
    UI.IntroToken=(UI.IntroToken or 0)+1; local token=UI.IntroToken
    school.Text='ENTERING ROOM '..stage..' OF 6'; school.TextColor3=UI.Config.RoomColors[stage]
    task.delay(3,function() if UI.IntroToken==token then school.Text='POPQUIZ ACADEMY  /  AFTER HOURS' end end)
end
function UI.Notify(message,bad)
    UI.ToastToken=(UI.ToastToken or 0)+1; local token=UI.ToastToken; UI.Toast.Visible=true; UI.ToastText.Text=message; UI.ToastText.TextColor3=if bad then C.red else C.green
    task.delay(2.7,function() if UI.ToastToken==token then UI.Toast.Visible=false end end)
end
function UI.Line(message)
    UI.LineToken=(UI.LineToken or 0)+1; local token=UI.LineToken; UI.Dialogue.Visible=true; UI.DialogueText.Text=message
    task.delay(3.4,function() if UI.LineToken==token then UI.Dialogue.Visible=false end end)
end
return UI
