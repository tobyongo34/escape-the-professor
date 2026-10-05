-- Edit-time recipe. Run through MCP; never installed as a live game script.
-- Owns only EscapeSchool, EscapeAssets, and named Escape lighting effects.
local W, SS, L = workspace, game:GetService('ServerStorage'), game:GetService('Lighting')
assert(not W:FindFirstChild('EscapeSchool'), 'EscapeSchool exists: preserve it; do not rebuild over manual edits.')
local world = Instance.new('Model'); world.Name = 'EscapeSchool'; world.ModelStreamingMode=Enum.ModelStreamingMode.Persistent; world.Parent = W
local assets = Instance.new('Folder'); assets.Name = 'EscapeAssets'; assets.Parent = SS
local C = { cream=Color3.fromRGB(244,230,199), teal=Color3.fromRGB(43,124,137), navy=Color3.fromRGB(25,48,68), yellow=Color3.fromRGB(255,199,58), wood=Color3.fromRGB(161,104,66), green=Color3.fromRGB(80,205,139), red=Color3.fromRGB(213,76,83), white=Color3.fromRGB(255,249,226), blue=Color3.fromRGB(120,188,206), purple=Color3.fromRGB(139,116,185) }
local V, F = Vector3.new, CFrame.new
local function folder(name, parent) local o=Instance.new('Folder'); o.Name=name; o.Parent=parent or world; return o end
local function part(parent,name,size,pos,color,material,collide)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=F(pos+V(0,40,0)); p.Anchored=true; p.Color=color or C.cream
    p.Material=material or Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    p.CanCollide=collide~=false; p.CanTouch=false; p.CastShadow=true; p.Parent=parent; return p
end
local function label(p,text,face,color,size)
    local g=Instance.new('SurfaceGui'); g.Name='Lettering'; g.Face=face or Enum.NormalId.Front; g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; g.PixelsPerStud=35; g.LightInfluence=0.15; g.Parent=p
    local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(0.94,0.88); t.Position=UDim2.fromScale(0.03,0.06); t.BackgroundTransparency=1; t.Text=text; t.TextColor3=color or C.white; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Parent=g; return t
end
local function sign(parent,name,text,pos,size,color,face)
    local p=part(parent,name,size,pos,color or C.navy,nil,false); label(p,text,face); return p
end
local function prompt(p,kind,text,stage,id)
    p:SetAttribute('Action',kind); p:SetAttribute('Stage',stage); if id then p:SetAttribute('ItemId',id) end
    local a=Instance.new('ProximityPrompt'); a.Name='Interact'; a.ActionText=text; a.ObjectText=p.Name; a.HoldDuration=0.15; a.MaxActivationDistance=10; a.RequiresLineOfSight=false; a.KeyboardKeyCode=Enum.KeyCode.E; a.GamepadKeyCode=Enum.KeyCode.ButtonX; a.Parent=p; return a
end
local checks=folder('Checkpoints'); local doors=folder('Doors'); local pickups=folder('Pickups'); local hazards=folder('Hazards'); local platforms=folder('Platforms'); local waypoints=folder('PatrolPoints')
local function checkpoint(name,x,z,stage,y)
    local p=part(checks,name,V(12,0.25,12),V(x,y or 1.2,z),C.teal,Enum.Material.SmoothPlastic,false); p:SetAttribute('Stage',stage)
    label(p,'CHECKPOINT\n'..stage,Enum.NormalId.Top,C.white)
    for _,d in {-1,1} do part(checks,name..'Edge',V(12,0.1,0.22),V(x,(y or 1.2)+0.15,z+d*5.8),C.green,Enum.Material.Neon,false) end
    return p
end
local function door(name,x,stage,kind)
    local p=part(doors,name,V(1,15,12),V(x,8.5,0),C.teal,Enum.Material.Wood)
    prompt(p,kind or 'Door','OPEN DOOR',stage)
    label(p,'EXIT  →\nE / X TO OPEN',Enum.NormalId.Left,C.white)
    part(doors,'Handle',V(0.3,0.5,2),V(x-0.65,7,-3.8),C.yellow,Enum.Material.Metal,false)
    for _,z in {-6.7,6.7} do part(doors,'DoorFrame',V(1.7,17,0.7),V(x,8.5,z),C.navy) end
    part(doors,'Lintel',V(1.7,0.8,14),V(x,17,0),C.navy)
    return p
end
local function room(name,a,b,half,color,openStart,openEnd)
    local f=folder(name)
    part(f,'TileFloor',V(b-a,2,half*2),V((a+b)/2,0,0),color or C.cream,Enum.Material.Concrete)
    for _,z in {-half,half} do
        part(f,'CreamWall',V(b-a,24,1.2),V((a+b)/2,12,z),C.cream)
        part(f,'Wainscot',V(b-a,5,1.35),V((a+b)/2,3.5,z),C.teal)
        part(f,'Baseboard',V(b-a,0.45,1.5),V((a+b)/2,1.25,z),C.navy)
        part(f,'Crown',V(b-a,0.6,1.6),V((a+b)/2,23,z),C.white)
    end
    for i,x in {a,b} do
        local opened=if i==1 then openStart else openEnd
        if opened then
            for _,side in {-1,1} do part(f,'PortalWall',V(1.2,24,half-6),V(x,12,side*(half+6)/2),C.cream) end
            part(f,'PortalTop',V(1.2,7,12),V(x,20.5,0),C.cream)
        else part(f,'EndWall',V(1.2,24,half*2),V(x,12,0),C.cream) end
    end
    -- Narrow ceiling rafters keep third-person cameras clear while suggesting a roof.
    for x=a+12,b-8,24 do
        part(f,'CeilingBeam',V(1.1,1,half*2),V(x,23,0),C.white)
        local fixture=part(f,'WarmFixture',V(7,0.35,2),V(x,22.3,0),C.white,Enum.Material.Neon,false)
        if math.floor(x/24)%3==0 then local light=Instance.new('PointLight'); light.Color=C.white; light.Brightness=0.55; light.Range=27; light.Shadows=false; light.Parent=fixture end
    end
    for x=a+6,b-2,12 do part(f,'TileSeam',V(0.035,0.015,half*2-1),V(x,1.01,0),Color3.fromRGB(201,202,186),nil,false) end
    return f
end
local function desk(f,x,z,scale)
    scale=scale or 1
    part(f,'WoodDesktop',V(6,0.6,4)*scale,V(x,4*scale,z),C.wood,Enum.Material.Wood)
    for _,dx in {-2.5,2.5} do for _,dz in {-1.5,1.5} do part(f,'DeskLeg',V(0.35,3,0.35)*scale,V(x+dx*scale,2.25*scale,z+dz*scale),C.navy,Enum.Material.Metal) end end
    part(f,'ChairSeat',V(3,0.4,3)*scale,V(x-4.6*scale,2.5*scale,z),C.teal)
    part(f,'ChairBack',V(0.4,3.5,3)*scale,V(x-5.8*scale,4.3*scale,z),C.teal)
    part(f,'ChairBase',V(0.5,1.5,0.5)*scale,V(x-4.6*scale,1.6*scale,z),C.navy)
end
local function books(f,x,y,z,count)
    for i=1,count do local co=({C.teal,C.red,C.yellow,C.purple,C.blue})[i%5+1]; local b=part(f,'Book',V(0.65,2.8+i%2*0.4,2),V(x+i*0.85,y,z),co,nil,false); part(f,'SpineStripe',V(0.67,0.16,0.05),V(b.Position.X, y+0.8, z-1.03),C.white,nil,false) end
end
local function shelf(f,x,z)
    part(f,'BookshelfBack',V(12,13,1),V(x,7.5,z),C.wood,Enum.Material.Wood)
    for _,dx in {-6,6} do part(f,'BookshelfSide',V(0.5,13,3.5),V(x+dx,7.5,z-1.3),C.wood,Enum.Material.Wood) end
    for y=2,12,4 do part(f,'BookshelfShelf',V(12,0.4,3.5),V(x,y,z-1.3),C.wood,Enum.Material.Wood); books(f,x-5.5,y+1.7,z-1.4,11) end
end
local function window(f,x,z)
    part(f,'WindowFrame',V(12,10,0.45),V(x,14,z),C.white)
    part(f,'BlueWindow',V(10.8,8.8,0.5),V(x,14,z-0.25),C.blue,Enum.Material.SmoothPlastic,false)
    part(f,'WindowCross',V(0.35,9,0.65),V(x,14,z-0.45),C.white,nil,false)
    part(f,'WindowCross',V(11,0.35,0.65),V(x,14,z-0.45),C.white,nil,false)
    part(f,'Sill',V(13,0.4,1.6),V(x,9,z-0.55),C.white)
end
local function arrow(f,x,z)
    local p=part(f,'GuidanceArrow',V(6,0.02,5),V(x,1.03,z),C.yellow,nil,false); p.Transparency=1; label(p,'➜',Enum.NormalId.Top,C.yellow)
end
local classroom=room('01_Detention',-36,36,32,C.cream,false,true)
sign(classroom,'Chalkboard','SURPRISE EXAM:\n1,000 QUESTIONS.\n\nNo calculators. No escape.',V(13,13,31.2),V(26,10,0.5),C.navy)
sign(classroom,'FindHomework','01 / DETENTION\nFIND 3 HOMEWORK SHEETS',V(-10,17,-31.2),V(28,5,0.5),C.teal,Enum.NormalId.Back)
desk(classroom,17,23,1.25)
for _,x in {-16,-2,12} do for _,z in {-16,0,15} do desk(classroom,x,z); part(classroom,'Paper',V(2,0.035,2.7),V(x,4.34,z),C.white,nil,false); local pencil=part(classroom,'Pencil',V(2.3,0.13,0.13),V(x+1,4.42,z-0.7),C.yellow,nil,false); pencil.CFrame*=CFrame.Angles(0,0.4,0) end end
shelf(classroom,-24,30); window(classroom,16,-31.1); window(classroom,-17,-31.1)
local clockFace=part(classroom,'Clock',V(0.25,4,4),V(35.1,18,20),C.white,nil,false); clockFace.Shape=Enum.PartType.Cylinder; label(clockFace,'3:01\nGO HOME!',Enum.NormalId.Left,C.navy)
sign(classroom,'Poster','A+ FOR\nEFFORT\nB- FOR HIDING',V(-35.1,12,-10),V(0.35,8,10),C.yellow,Enum.NormalId.Right)
checkpoint('Classroom',-25,0,1)
for i,p in {V(-27,5,25),V(16,5,-17),V(22,1.6,16)} do
    local sheet=part(pickups,'Homework'..i,V(3.2,0.18,4),p,C.white,nil,false); prompt(sheet,'Homework','TAKE HOMEWORK',1,i); label(sheet,'HOMEWORK\n#'..i..'\nA+',Enum.NormalId.Top,C.teal)
    local h=Instance.new('Highlight'); h.FillColor=C.yellow; h.FillTransparency=0.65; h.OutlineColor=C.yellow; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Parent=sheet
end
door('ClassroomExit',36,1)
local hall=room('02_SlipperyHallway',36,204,18,Color3.fromRGB(211,223,221),true,true)
sign(hall,'HallSign','02 / SLIPPERY HALLWAY\nPENCILS HAVE RIGHT OF WAY',V(49,15,17.1),V(23,6,0.45),C.navy)
for x=48,195,10 do for _,z in {-17.1,17.1} do
    local locker=part(hall,'Locker',V(4,10,2),V(x,6,z-math.sign(z)),if x%20==8 then C.blue else C.teal,Enum.Material.Metal)
    for y=8,10,1 do part(hall,'LockerVent',V(2.5,0.12,0.08),V(x,y,z-math.sign(z)*2.06),C.navy,nil,false) end
    part(hall,'LockerHandle',V(0.2,1,0.15),V(x+1.2,6,z-math.sign(z)*2.1),C.yellow,nil,false)
end end
for _,x in {63,107,154} do local p=part(hazards,'Puddle',V(12,0.08,11),V(x,1.06,if x==107 then -5 else 5),C.blue,Enum.Material.Glass,false); p.Transparency=0.22; p:SetAttribute('Hazard','Puddle'); sign(hall,'WetFloor','WET\nFLOOR',V(x-5,3,-11),V(0.4,4,3),C.yellow,Enum.NormalId.Left) end
for i,x in {84,136,180} do
    local p=part(hazards,'RollingPencil'..i,V(17,2.8,2.8),V(x,2.7,0),C.yellow,Enum.Material.Wood,false); p.Shape=Enum.PartType.Cylinder; p.CFrame*=CFrame.Angles(0,math.pi/2,0)
    p:SetAttribute('Hazard','Pencil'); p:SetAttribute('BaseX',x); p:SetAttribute('Phase',i*1.8); p:SetAttribute('Travel',11)
    label(p,'NO RUNNING*\n*unless chased',Enum.NormalId.Front,C.navy)
    for _,dx in {-3,3} do part(hall,'PencilCrossing',V(0.35,0.03,30),V(x+dx,1.03,0),C.yellow,nil,false) end
end
part(hall,'FallenLockerJump',V(4,2.7,33),V(114,2.35,0),C.teal,Enum.Material.Metal)
sign(hall,'JumpSign','JUMP ↑\nSPACE / A',V(107,9,17.1),V(12,5,0.4),C.yellow)
for _,x in {52,97,150,194} do arrow(hall,x,0) end
for _,x in {72,161} do
    part(hall,'TrophyPlinth',V(5,3,3),V(x,2.5,-13.5),C.wood,Enum.Material.Wood)
    local cup=part(hall,'Trophy',V(2,2.5,2),V(x,5.3,-13.5),C.yellow,Enum.Material.Metal,false); cup.Shape=Enum.PartType.Ball
    sign(hall,'TrophyTitle','MOST\nHOMEWORK',V(x,7.5,-16),V(7,3,0.3),C.navy,Enum.NormalId.Back)
end
checkpoint('HallStart',44,0,2); checkpoint('HallEnd',197,0,2); door('LibraryEntrance',204,2)
local library=room('03_HomeworkLibrary',204,372,32,Color3.fromRGB(219,194,168),true,true)
for x=216,360,24 do shelf(library,x,30); shelf(library,x,-26) end
sign(library,'LibraryPoster','READING IS FUN.\nFALLING IS EXTRA CREDIT.',V(272,17,31),V(36,5,0.5),C.navy)
local lava=part(hazards,'HomeworkFloor',V(148,0.16,63),V(288,1.18,0),C.red,nil,false); lava:SetAttribute('Hazard','Homework')
label(lava,'HOMEWORK  HOMEWORK  HOMEWORK\nEXTRA CREDIT ZONE',Enum.NormalId.Top,C.white)
part(platforms,'LibraryStart',V(16,2,24),V(212,1,0),C.wood,Enum.Material.Wood)
checkpoint('LibraryStart',211,0,3,2.16)
local platformData={ {229,-4,3},{243,3,4},{257,10,4},{271,3,3},{285,-4,3},{299,-10,4},{313,-3,5},{327,4,4},{341,10,3},{355,3,2} }
for i,v in platformData do
    local co=({C.teal,C.yellow,C.purple,C.blue})[i%4+1]
    local p=part(platforms,if i==8 then 'StationeryShuttle' else 'GiantBook'..i,V(10,1.5,12),V(v[1],v[3],v[2]),co)
    part(platforms,'BookPages',V(10.05,0.7,10.7),V(v[1],v[3],v[2]),C.white,nil,false)
    label(p,({'ALGEBRA','NOPE','LATE WORK','POETRY'})[i%4+1],Enum.NormalId.Top,C.navy)
    if i==5 then checkpoint('LibraryMid',285,-4,3,3.9) end
    if i==8 then p:SetAttribute('MovingPlatform',true); p:SetAttribute('StartPosition',p.Position) end
end
part(platforms,'LibraryEnd',V(15,2,25),V(365,1,0),C.wood,Enum.Material.Wood)
checkpoint('LibraryEnd',365,0,3,2.2); door('ScienceEntrance',372,3)
local science=room('04_PopQuizLab',372,444,31,C.cream,true,true)
checkpoint('Science',380,0,4)
sign(science,'ScienceBoard','SCIENCE FACT:\nHOMEWORK = TIME²\n\nPIZZA > EXAMS',V(409,14,30.1),V(29,12,0.6),C.navy)
local quiz=part(doors,'QuizBoard',V(2,10,16),V(427,8,-13),C.navy); prompt(quiz,'Quiz','TAKE POP QUIZ',4); label(quiz,'POP QUIZ\n3 QUESTIONS\nE / X TO BEGIN',Enum.NormalId.Left,C.yellow)
for _,x in {392,411} do for _,z in {-21,20} do
    part(science,'LabCabinet',V(12,5,6),V(x,3.5,z),C.teal,Enum.Material.Metal)
    part(science,'Countertop',V(13,0.5,7),V(x,6.25,z),C.white)
    for i=1,3 do local jar=part(science,'ScienceBottle',V(1.5,2+i%2,1.5),V(x-4+i*2,7.9,z),({C.blue,C.green,C.purple})[i],Enum.Material.Glass,false); jar.Shape=Enum.PartType.Cylinder; jar.CFrame*=CFrame.Angles(0,0,math.pi/2); jar.Transparency=0.12 end
end end
local atom=part(science,'AtomCore',V(3,3,3),V(403,12,0),C.yellow,nil,false); atom.Shape=Enum.PartType.Ball
for i=1,8 do local angle=i*math.pi/4; local electron=part(science,'Electron',V(1.2,1.2,1.2),V(403+math.cos(angle)*5,12+math.sin(angle)*3,math.sin(angle)*4),C.teal,nil,false); electron.Shape=Enum.PartType.Ball end
door('StaffEntrance',444,4)
local staff=room('05_StaffRoom',444,576,35,Color3.fromRGB(225,215,192),true,true)
checkpoint('Staff',452,0,5)
sign(staff,'StealthInstruction',"05 / STAFF ONLY\nGRAB THE KEY. BREAK LINE OF SIGHT.",V(472,17,34),V(30,6,0.5),C.navy)
for i,x in {474,502,530,552} do
    local z=if i%2==1 then -12 else 12
    part(staff,'CoverCabinet',V(6,11,28),V(x,6.5,z),C.wood,Enum.Material.Wood)
    for y=4,10,3 do part(staff,'CabinetStripe',V(6.1,0.2,28.1),V(x,y,z),C.cream,nil,false) end
    sign(staff,'CoverLabel','FACULTY\nSNACKS',V(x-3.1,8,z),V(0.1,4,8),C.teal,Enum.NormalId.Left)
end
desk(staff,553,-24,1.2)
local key=part(pickups,'ExitKey',V(1.5,0.35,4),V(553,5.25,-24),C.yellow,Enum.Material.Neon,false); prompt(key,'Key','STEAL EXIT KEY',5)
local ring=part(pickups,'KeyRing',V(3,0.4,3),V(553,5.25,-26.5),C.yellow,Enum.Material.Metal,false); ring.Shape=Enum.PartType.Cylinder; ring.CFrame*=CFrame.Angles(0,0,math.pi/2)
local h=Instance.new('Highlight'); h.FillColor=C.yellow; h.FillTransparency=0.55; h.OutlineColor=C.yellow; h.Parent=key
for i,p in {V(486,4,15),V(517,4,-18),V(542,4,13),V(562,4,0)} do local a=part(waypoints,'Point'..i,V(1,1,1),p,C.yellow,nil,false); a.Transparency=1 end
sign(staff,'CoffeePoster',"WORLD'S OKAYEST\nPROFESSOR",V(563,16,34),V(17,6,0.4),C.yellow)
door('FinalExit',576,5,'FinalDoor')
local yard=folder('06_FinalBell')
part(yard,'Courtyard',V(211,2,94),V(682.5,0,0),Color3.fromRGB(179,205,157),Enum.Material.Grass)
part(yard,'BusLane',V(205,0.2,26),V(683,1.1,0),Color3.fromRGB(198,193,175),Enum.Material.Concrete)
for _,z in {-46,46} do
    part(yard,'HedgeBoundary',V(211,8,3),V(682.5,5,z),C.teal,Enum.Material.Grass)
    part(yard,'SafetyFence',V(211,20,1),V(682.5,11,z),C.cream,nil,true).Transparency=1
    for x=592,772,20 do part(yard,'FencePost',V(0.7,6,0.7),V(x,4,z),C.white) end
    for y=3,6,3 do part(yard,'FenceRail',V(211,0.35,0.4),V(682.5,y,z),C.white) end
end
part(yard,'EndBoundary',V(2,24,94),V(788,12,0),C.teal)
checkpoint('Final',587,0,6)
sign(yard,'FinalSign','FINAL BELL!\nBUS DEPARTS: NOW',V(605,10,17),V(19,7,0.7),C.navy)
for _,x in {616,648,687,722} do
    arrow(yard,x,0)
    if x~=616 then part(yard,'EasyHurdle',V(2,2.3,21),V(x,2.2,0),C.yellow); sign(yard,'JumpMark','JUMP ↑',V(x-1.2,3,0),V(0.15,2,8),C.navy,Enum.NormalId.Left) end
end
for i,x in {602,632,672,714,759} do for _,z in {-32,32} do
    part(yard,'TreeTrunk',V(2,10,2),V(x,6,z),C.wood,Enum.Material.Wood)
    local leaves=part(yard,'RoundTree',V(12,12,12),V(x,14,z),if i%2==0 then C.green else C.teal,Enum.Material.Grass); leaves.Shape=Enum.PartType.Ball
end end
local bus=Instance.new('Model'); bus.Name='FreedomExpress'; bus.Parent=yard
part(bus,'BusBody',V(30,11,13),V(759,8,0),C.yellow,Enum.Material.Metal)
part(bus,'BusRoof',V(30.5,1,13.5),V(759,14,0),C.yellow)
part(bus,'BlackStripe',V(30.2,0.8,13.2),V(759,6,0),C.navy,nil,false)
for x=748,770,5.5 do for _,z in {-6.6,6.6} do part(bus,'BusWindow',V(4.2,4,0.25),V(x,10.5,z),C.navy,nil,false) end end
for _,x in {749,769} do for _,z in {-6.8,6.8} do local wheel=part(bus,'Wheel',V(2,5,5),V(x,3.7,z),C.navy); wheel.Shape=Enum.PartType.Cylinder; wheel.CFrame*=CFrame.Angles(0,math.pi/2,0); local hub=part(bus,'WheelHub',V(2.1,2.7,2.7),V(x,3.7,z),C.white,nil,false); hub.Shape=Enum.PartType.Cylinder; hub.CFrame=wheel.CFrame end end
sign(bus,'BusBanner','FREEDOM EXPRESS',V(759,13,6.85),V(26,1.8,0.2),C.navy,Enum.NormalId.Back)
sign(bus,'BusFront','SCHOOL BUS\nNO HOMEWORK ON BOARD',V(743.7,10,0),V(0.25,7,12),C.navy,Enum.NormalId.Left)
local finish=part(yard,'FinishZone',V(15,10,24),V(736,6,0),C.green,nil,false); finish.Transparency=0.8; finish:SetAttribute('Finish',true)
sign(yard,'FinishSign','GET ON THE BUS!\nYOU MADE IT',V(735,15,0),V(0.3,6,24),C.teal,Enum.NormalId.Left)
checkpoint('Hangout',779,25,6)
part(yard,'HangoutPlatform',V(25,1,24),V(774,1.4,27),C.wood,Enum.Material.Wood)
sign(yard,'HangoutSign','DETENTION SURVIVORS CLUB\nMembership: YOU',V(774,8,39),V(23,6,0.4),C.navy)
-- Original R6-compatible character with Motor6Ds and massless decoration.
local npc=Instance.new('Model'); npc.Name='Professor'; npc.Parent=assets
local function body(name,size,pos,col,shape)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.Position=pos; p.Color=col; p.CanCollide=false; p.CanTouch=false; p.Material=Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=npc; if shape then p.Shape=shape end; return p
end
local root=body('HumanoidRootPart',V(2,2,1),V(0,4,0),C.navy); root.Transparency=1; root.CanCollide=true
local torso=body('Torso',V(2.7,3,1.4),V(0,4,0),C.white)
local head=body('Head',V(3.6,3.1,2.7),V(0,7.05,0),Color3.fromRGB(233,182,135))
local function joint(name,a,b) local m=Instance.new('Motor6D'); m.Name=name; m.Part0=a; m.Part1=b; m.C0=a.CFrame:ToObjectSpace(b.CFrame); m.Parent=a; return m end
joint('RootJoint',root,torso); joint('Neck',torso,head)
for _,s in {-1,1} do local arm=body(if s==-1 then 'Left Arm' else 'Right Arm',V(1,3.1,1.2),V(s*1.9,4,0),C.white); joint(if s==-1 then 'Left Shoulder' else 'Right Shoulder',torso,arm); local leg=body(if s==-1 then 'Left Leg' else 'Right Leg',V(1.15,2.1,1.35),V(s*0.65,1.45,0),C.navy); joint(if s==-1 then 'Left Hip' else 'Right Hip',torso,leg) end
local function deco(name,size,pos,col,shape)
    local p=body(name,size,pos,col,shape); p.Massless=true; local w=Instance.new('WeldConstraint'); w.Part0=head; w.Part1=p; w.Parent=p; return p
end
for _,x in {-0.9,0.9} do
    deco('ThickGlasses',V(1.6,1.35,0.25),V(x,7.3,-1.43),C.navy)
    deco('Lens',V(1.22,0.97,0.27),V(x,7.3,-1.58),C.white)
    deco('Pupil',V(0.3,0.52,0.3),V(x+0.14,7.3,-1.75),C.navy)
    deco('BushyEyebrow',V(1.7,0.38,0.5),V(x,8.12,-1.5),C.navy)
end
deco('GlassesBridge',V(0.5,0.2,0.25),V(0,7.45,-1.55),C.navy)
deco('Nose',V(0.7,0.75,0.85),V(0,6.85,-1.63),Color3.fromRGB(226,157,112),Enum.PartType.Ball)
deco('Mustache',V(1.4,0.38,0.3),V(0,6.3,-1.46),C.navy)
for i=1,7 do local p=deco('MessyHair',V(0.85,1.4,1.4),V(-1.8+i*0.45,8.9+(i%2)*0.25,0),C.white); p.CFrame*=CFrame.Angles(0,0,(i-4)*0.22) end
deco('BowTie',V(1.6,0.55,0.3),V(0,5.25,-0.95),C.red)
deco('Clipboard',V(1.6,2.4,0.3),V(-2.2,3.7,-1),C.wood)
local hum=Instance.new('Humanoid'); hum.MaxHealth=100000; hum.Health=100000; hum.WalkSpeed=10; hum.HipHeight=0; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None; hum.Parent=npc
npc.PrimaryPart=root
local bb=Instance.new('BillboardGui'); bb.Name='StateBubble'; bb.Size=UDim2.fromOffset(210,42); bb.StudsOffset=V(0,3,0); bb.MaxDistance=75; bb.Parent=head
local txt=Instance.new('TextLabel'); txt.Name='Caption'; txt.Size=UDim2.fromScale(1,1); txt.BackgroundColor3=C.navy; txt.BackgroundTransparency=0.15; txt.Text='PROFESSOR POPQUIZ'; txt.TextColor3=C.white; txt.Font=Enum.Font.GothamBold; txt.TextSize=14; txt.Parent=bb; Instance.new('UICorner',txt).CornerRadius=UDim.new(0,10)
L.ClockTime=14.2; L.Brightness=2; L.Ambient=Color3.fromRGB(134,147,161); L.OutdoorAmbient=Color3.fromRGB(155,164,178); L.GlobalShadows=true
local cc=Instance.new('ColorCorrectionEffect'); cc.Name='EscapeColor'; cc.Saturation=0.06; cc.Contrast=0.07; cc.TintColor=Color3.fromRGB(255,246,230); cc.Parent=L
local bloom=Instance.new('BloomEffect'); bloom.Name='EscapeBloom'; bloom.Intensity=0.08; bloom.Size=16; bloom.Threshold=1.4; bloom.Parent=L
W.CurrentCamera.CFrame=CFrame.lookAt(V(-28,58,-24),V(8,46,8))
world:SetAttribute('BuildVersion',1)
return 'Built '..#world:GetDescendants()..' school objects. Original baseplate and spawn preserved.'
