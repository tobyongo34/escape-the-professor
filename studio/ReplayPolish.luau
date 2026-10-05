-- Run once through Edit MCP. Only this recipe's unmanaged scenery is replaced.
-- Everything is authored relative to the moved/rotated classroom floor.
local world=assert(workspace:FindFirstChild('EscapeSchool'))
local frame=world['01_Detention'].TileFloor.CFrame*CFrame.new(0,-40,0)
local V=Vector3.new
local C={navy=Color3.fromRGB(23,42,59),gold=Color3.fromRGB(255,203,70),cream=Color3.fromRGB(255,249,229),teal=Color3.fromRGB(57,143,148),green=Color3.fromRGB(99,220,159)}
for _,name in {'ReplayPolish','BonusPasses'} do local old=world:FindFirstChild(name); if old then old:Destroy() end end
local decor=Instance.new('Folder'); decor.Name='ReplayPolish'; decor.Parent=world
local passes=Instance.new('Folder'); passes.Name='BonusPasses'; passes.Parent=world
local function part(parent,name,size,pos,color,material)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=frame*CFrame.new(pos)
    p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
    return p
end
local function label(p,caption,face,color)
    local g=Instance.new('SurfaceGui'); g.Name='Lettering'; g.Face=face; g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; g.PixelsPerStud=48; g.LightInfluence=.1; g.Parent=p
    local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(.92,.88); t.Position=UDim2.fromScale(.04,.06); t.BackgroundTransparency=1
    t.Text=caption; t.TextColor3=color or C.cream; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Parent=g
    return g
end
local definitions={
    {V(-18,44.5,-24),'DETENTION'}, {V(116,44.5,-12),'HALL MONITOR'},
    {V(285,47,-4),'BOOKWORM'}, {V(425,44.5,22),'QUIZ ACE'},
    {V(517,44.5,27),'SNEAKY SCHOLAR'}, {V(673,44.5,8),'LAST BELL'},
}
for i,def in definitions do
    local p=part(passes,'HallPass'..i,V(3.2,4.4,.22),def[1],C.gold)
    p.CFrame*=CFrame.Angles(0,math.pi/2,0)
    p:SetAttribute('Stage',i); p:SetAttribute('PassId',tostring(i)); p:SetAttribute('CoursePosition',def[1])
    for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
        local g=label(p,'HALL PASS\n\n'..string.format('%02d',i)..'\n'..def[2]..'\n\nPOPQUIZ ACADEMY',face,C.navy)
        local line=Instance.new('Frame'); line.Size=UDim2.fromScale(.88,.015); line.Position=UDim2.fromScale(.06,.22); line.BackgroundColor3=C.navy; line.BorderSizePixel=0; line.Parent=g
    end
    local h=Instance.new('Highlight'); h.Name='CollectibleGlow'; h.FillColor=C.gold; h.FillTransparency=.83; h.OutlineColor=C.cream; h.OutlineTransparency=.25; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Parent=p
end

-- Distinct entrances make the six-room route legible at a glance.
local entries={{36,'02  /  SLIPPERY HALLWAY'},{204,'03  /  HOMEWORK LIBRARY'},{372,'04  /  POP QUIZ LAB'},{444,'05  /  STAFF ONLY'},{576,'06  /  FINAL BELL'}}
for i,d in entries do
    local x=d[1]
    for _,z in {-7.1,7.1} do
        part(decor,'DoorFrame',V(.7,15,.65),V(x-.85,48.5,z),C.navy)
        part(decor,'DoorTrim',V(.12,14,.16),V(x-1.25,48.5,z),C.gold,Enum.Material.Neon)
    end
    part(decor,'DoorLintel',V(.7,.65,14.8),V(x-.85,56.2,0),C.navy)
    local p=part(decor,'RouteHeader',V(.2,2.6,19),V(x-.86,59.4,0),if i==4 then C.gold else C.navy)
    label(p,d[2],Enum.NormalId.Left,if i==4 then C.navy else C.cream)
end

-- Optional challenge notice beside the classroom windows.
local board=part(decor,'HallPassNotice',V(13,6,.24),V(0,50,-30.35),C.navy)
label(board,'THE HALL PASS CHALLENGE\n\n6 rooms. 6 golden passes.\nCollect them on your way out!',Enum.NormalId.Back,C.gold)

-- The exit reads as a destination even from the start of the final run.
for _,z in {-15,15} do
    part(decor,'FinishPost',V(1.5,19,1.5),V(736,50.5,z),C.navy)
    part(decor,'FinishPostLight',V(.16,17,.5),V(735.18,50.5,z),C.gold,Enum.Material.Neon)
    part(decor,'FinishFoot',V(3,.5,3),V(736,41.3,z),C.navy)
end
local top=part(decor,'FinishArch',V(1.5,4,33),V(736,61,0),C.navy)
label(top,'F R E E D O M  →',Enum.NormalId.Left,C.gold)
for z=-14,14,2 do for x=730,734,2 do
    part(decor,'FinishChecker',V(1.97,.024,1.97),V(x,41.23,z),if (x/2+z/2)%2==0 then C.cream else C.navy)
end end
for i=0,11 do
    local z=-27+i*4.9
    local p=part(decor,'CelebrationPennant',V(.12,1.6,2.1),V(753,58-math.sin(i/11*math.pi)*2,z),if i%2==0 then C.gold else C.teal)
    label(p,'★',Enum.NormalId.Left,C.cream)
end
local challenge=part(decor,'ChallengeBoard',V(20,9,.4),V(775,57,39.1),C.navy)
label(challenge,'ESCAPE CLUB\n\nCLEAN ESCAPE  •  No catches or falls\nCOLLECTOR  •  All 6 hall passes\nPERSONAL BEST  •  Beat this session’s time',Enum.NormalId.Front,C.cream)

world:SetAttribute('ReplayPolishVersion',1)
return 'Replay scenery ready: 6 optional passes, route entrances, finish arch and escape club board.'
