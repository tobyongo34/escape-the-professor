-- Edit-time MCP recipe. Changes only this game's unmanaged scenery and professor template.
local world=assert(workspace:FindFirstChild('EscapeSchool'),'Open the complete saved game first.')
local assets=assert(game.ServerStorage:FindFirstChild('EscapeAssets'),'Professor assets missing')
local V,F=Vector3.new,CFrame.new
local C={cream=Color3.fromRGB(244,233,211),white=Color3.fromRGB(255,248,229),navy=Color3.fromRGB(31,48,61),teal=Color3.fromRGB(54,126,132),yellow=Color3.fromRGB(247,177,24),wood=Color3.fromRGB(137,89,54),green=Color3.fromRGB(99,148,102)}
local old=world:FindFirstChild('VisualPolish'); if old then old:Destroy() end
local decor=Instance.new('Folder'); decor.Name='VisualPolish'; decor.Parent=world
local function part(parent,name,size,pos,color,material,shape)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=F(pos); p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end; p.Parent=parent; return p
end
local function label(p,message,face,color)
    local gui=Instance.new('SurfaceGui'); gui.Name='Lettering'; gui.Face=face or Enum.NormalId.Front; gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=40; gui.LightInfluence=.2; gui.Parent=p
    local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(.88,.86); t.Position=UDim2.fromScale(.06,.07); t.BackgroundTransparency=1; t.Text=message; t.TextColor3=color or C.white; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Parent=gui; return t
end
local function sign(name,message,size,pos,color,face)
    local p=part(decor,name,size,pos,color or C.navy); label(p,message,face); return p
end
local function rod(parent,name,a,b,r,color)
    local p=part(parent,name,V(r,(b-a).Magnitude,r),(a+b)/2,color)
    p.CFrame=CFrame.lookAt((a+b)/2,b)*CFrame.Angles(math.pi/2,0,0); return p
end
-- Warm floors, quieter color variation, and actual window panes facing the room.
for _,p in world:GetDescendants() do if p:IsA('BasePart') and not p:IsDescendantOf(decor) then
    if p.Name=='CreamWall' or p.Name=='PortalWall' or p.Name=='PortalTop' then p.Color=C.cream end
    if p.Name=='WoodDesktop' or p.Name=='BookshelfBack' or p.Name=='BookshelfSide' or p.Name=='BookshelfShelf' then p.Color=C.wood end
    if p.Name=='CeilingBeam' then p.Color=Color3.fromRGB(206,185,153); p.Material=Enum.Material.Wood end
    if p.Name=='WarmFixture' then p.Color=Color3.fromRGB(255,233,186) end
    if p.Name=='BlueWindow' then p.Position=V(p.Position.X,p.Position.Y,-30.77); p.Color=Color3.fromRGB(161,210,220) end
    if p.Name=='WindowCross' then p.Position=V(p.Position.X,p.Position.Y,-30.35) end
    if p.Name=='Sill' then p.Position=V(p.Position.X,p.Position.Y,-30.2) end
    if p.Name=='Wainscot' then p.Color=Color3.fromRGB(56,113,119) end
    if p.Name=='RoundTree' then p.Color=if p.Position.X%3<1 then Color3.fromRGB(112,156,100) else Color3.fromRGB(83,137,94) end
end end
local roomData={{'01_Detention',-36,36,32},{'02_SlipperyHallway',36,204,18},{'04_PopQuizLab',372,444,31},{'05_StaffRoom',444,576,35}}
for i,d in roomData do
    local floor=world[d[1]].TileFloor; floor.Material=Enum.Material.SmoothPlastic
    floor.Color=if i==2 then Color3.fromRGB(184,207,205) elseif i==4 then Color3.fromRGB(200,178,144) else Color3.fromRGB(223,214,193)
    -- Insets are flush and non-colliding; the tested floor and obstacles stay unchanged.
    for x=d[2]+4,d[3]-4,8 do for z=-d[4]+4,d[4]-4,8 do
        if (math.floor((x-d[2])/8)+math.floor((z+d[4])/8))%2==0 then
            part(decor,'InlaidTile',V(7.85,.016,7.85),V(x,41.012,z),if i==2 then Color3.fromRGB(197,216,211) else Color3.fromRGB(232,224,205))
        end
    end end
    for _,z in {-d[4]+1.4,d[4]-1.4} do
        part(decor,'FloorBorder',V(d[3]-d[2]-2,.024,.45),V((d[2]+d[3])/2,41.024,z),C.navy)
        part(decor,'ChairRail',V(d[3]-d[2]-.5,.18,.3),V((d[2]+d[3])/2,46.2,z+math.sign(z)*.64),Color3.fromRGB(206,164,94),Enum.Material.Wood)
    end
end
-- Repeating hallway stripes guide players and break up long, empty walls.
for x=46,193,8 do part(decor,'HallGuidanceDash',V(3,.022,.24),V(x,41.04,-10),C.yellow) end
for _,x in {49,99,149,195} do
    sign('RoomNumber','ROOM '..(100+math.floor(x/10)),V(5.4,1.8,.16),V(x,54,16.25),C.navy)
end
-- Framed noticeboards with layered, pinned notices.
local function noticeboard(x,z,title)
    part(decor,'NoticeFrame',V(15,8,.35),V(x,52,z),C.wood,Enum.Material.Wood)
    part(decor,'CorkBoard',V(14.3,7.3,.15),V(x,52,z-.24),Color3.fromRGB(176,138,91),Enum.Material.Fabric)
    for i=-1,1 do
        local p=part(decor,'PinnedNotice',V(3.8,4.7,.08),V(x+i*4.25,51.6,z-.35),if i==0 then C.yellow else C.white)
        p.CFrame*=CFrame.Angles(0,0,i*.04); label(p,({'LOST:\nMY WEEKEND','CLUB FAIR\n3:01 PM','NO MORE\nEXTRA CREDIT'})[i+2],Enum.NormalId.Front,C.navy)
        part(decor,'NoticePin',V(.24,.24,.16),V(x+i*4.25,53.6,z-.46),C.teal,nil,Enum.PartType.Ball)
    end
    sign('NoticeHeading',title,V(14,1.6,.1),V(x,57.1,z-.25),C.navy)
end
noticeboard(-9,30.9,'CAMPUS NEWS'); noticeboard(122,16.2,'TOTALLY NORMAL SCHOOL')
-- Classroom drawing details and pendant fixture mounts.
for _,p in world['01_Detention']:GetChildren() do
    if p:IsA('BasePart') and p.Name=='WoodDesktop' then
        part(decor,'DeskApron',V(p.Size.X-.3,.3,.16),p.Position+V(0,-.45,-p.Size.Z/2+.12),Color3.fromRGB(183,135,88),Enum.Material.Wood)
    end
end
local function plant(x,z,height)
    local pot=part(decor,'TerracottaPot',V(2.8,2.7,2.8),V(x,42.35,z),Color3.fromRGB(174,112,77),Enum.Material.CeramicTiles,Enum.PartType.Cylinder)
    pot.CFrame*=CFrame.Angles(0,0,math.pi/2)
    part(decor,'PotSoil',V(.2,2.3,2.3),V(x,43.72,z),Color3.fromRGB(72,54,40),nil,Enum.PartType.Cylinder).CFrame=F(x,43.72,z)*CFrame.Angles(0,0,math.pi/2)
    for i=1,5 do
        local angle=i*math.pi*2/5; local leaf=part(decor,'PlantLeaf',V(1.7,height,1.1),V(x+math.cos(angle)*.8,43.8+height*.36,z+math.sin(angle)*.8),if i%2==0 then C.green else Color3.fromRGB(66,125,94),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        leaf.CFrame*=CFrame.Angles(math.sin(angle)*.3,angle,math.cos(angle)*.25)
    end
end
plant(29,27,4); plant(-29,-26,4); plant(384,25,4); plant(436,-25,4); plant(450,29,5); plant(568,30,5)
-- The library gains patterned homework, book spines, and wall-mounted reading lamps.
for x=226,354,16 do for _,z in {-19,20} do
    local page=part(decor,'DangerHomeworkPage',V(5,.03,7),V(x,41.285,z),Color3.fromRGB(238,160,143))
    page.CFrame*=CFrame.Angles(0,(x%3-1)*.15,0)
    label(page,'DUE\nYESTERDAY',Enum.NormalId.Top,Color3.fromRGB(128,54,54))
end end
for _,x in {232,280,328} do for _,z in {-30.7,30.7} do
    part(decor,'LibraryLampBack',V(2.2,3,.3),V(x,55,z),C.wood,Enum.Material.Wood)
    part(decor,'ReadingLamp',V(3.1,.7,1.4),V(x,55.4,z-math.sign(z)*.7),C.yellow)
end end
-- A real orbit diagram makes the floating atom read as an intentional science display.
local atomCenter=V(403,52,0)
for plane=1,2 do for i=0,23 do
    local a=i*math.pi/12; local b=(i+1)*math.pi/12
    local function point(t) return atomCenter+V(math.cos(t)*5,math.sin(t)*3,math.sin(t)*(if plane==1 then 4 else -4)) end
    rod(decor,'AtomOrbit',point(a),point(b),.09,Color3.fromRGB(172,178,169))
end end
sign('AtomPlinth','THE HOMEWORK ATOM\n100% UNSTABLE',V(8,2.2,.2),V(403,44.5,-5.2),C.navy,Enum.NormalId.Front)
-- Staff room visual clues and cabinet details, without changing line-of-sight collision.
for _,p in world['05_StaffRoom']:GetChildren() do if p:IsA('BasePart') and p.Name=='CoverCabinet' then
    for _,side in {-1,1} do for _,dz in {-7,7} do
        part(decor,'CabinetHandle',V(.2,1.1,.2),p.Position+V(side*3.12,0,dz),C.yellow,Enum.Material.Metal)
    end end
end end
sign('KeyDeskPlaque','EXIT KEY\nDEFINITELY NOT FOR STUDENTS',V(6,2,.15),V(553,48.5,-29),C.navy,Enum.NormalId.Back)
-- Courtyard: layered planting, benches, paving edges, and a welcoming finish area.
for _,z in {-14.7,14.7} do part(decor,'BusLaneCurb',V(204,.38,1.2),V(682.5,41.23,z),Color3.fromRGB(227,217,193),Enum.Material.Concrete) end
for x=594,730,8 do for _,z in {-17,17} do part(decor,'CourtyardPaver',V(7.3,.04,3.3),V(x,41.04,z),Color3.fromRGB(212,203,181),Enum.Material.Concrete) end end
for _,x in {620,662,706} do for _,z in {-37,37} do
    part(decor,'FlowerBed',V(12,.5,5),V(x,41.25,z),Color3.fromRGB(102,79,55),Enum.Material.Ground)
    for i=-2,2 do
        local stem=V(x+i*2,42.2,z+(i%2)*1.2)
        part(decor,'FlowerStem',V(.13,1.7,.13),stem,C.green)
        part(decor,'Flower',V(.95,.55,.95),stem+V(0,.9,0),if i%2==0 then C.yellow else Color3.fromRGB(171,145,193),nil,Enum.PartType.Ball)
    end
end end
for _,x in {613,692} do for _,z in {-24,24} do
    for i=0,3 do part(decor,'BenchSlat',V(8,.25,.55),V(x,43.2,z+i*.7),C.wood,Enum.Material.Wood) end
    for _,dx in {-3,3} do part(decor,'BenchLeg',V(.45,2.2,2.8),V(x+dx,42.1,z+1),C.navy,Enum.Material.Metal) end
end end
local bus=world['06_FinalBell'].FreedomExpress
for _,z in {-4.2,4.2} do part(decor,'BusHeadlight',V(.28,1.5,1.5),V(743.7,46,z),C.white,Enum.Material.Neon,Enum.PartType.Ball) end
part(decor,'BusBumper',V(.45,1.2,12),V(743.5,43.5,0),Color3.fromRGB(78,88,92),Enum.Material.Metal)
sign('RoutePlate','01 / FREEDOM',V(.22,1.9,8),V(743.3,54.3,0),C.yellow,Enum.NormalId.Left)
-- Replace the original costume with a stylized likeness of the supplied reference.
local npc=assets.Professor
local keep={HumanoidRootPart=true,Torso=true,Head=true,['Left Arm']=true,['Right Arm']=true,['Left Leg']=true,['Right Leg']=true,Humanoid=true}
for _,child in npc:GetChildren() do if not keep[child.Name] then child:Destroy() end end
local root,torso,head=npc.HumanoidRootPart,npc.Torso,npc.Head
local skin=Color3.fromRGB(139,91,59); local hair=Color3.fromRGB(37,29,23); local dark=Color3.fromRGB(26,29,33)
torso.Size=V(2.5,3,1.5); torso.Color=C.yellow; torso.Material=Enum.Material.Fabric
head.Size=V(2.25,2.7,2.08); head.Shape=Enum.PartType.Ball; head.Color=skin; head.CFrame=F(0,6.92,0)
torso.Neck.C0=torso.CFrame:ToObjectSpace(head.CFrame)
local function attach(name,size,pos,color,to,shape,material)
    local p=part(npc,name,size,pos,color,material,shape); p.Anchored=false; p.Massless=true; p.CanQuery=false
    local w=Instance.new('WeldConstraint'); w.Part0=to or head; w.Part1=p; w.Parent=p; return p
end
-- Close-cropped hair, slim cheeks, eyebrows, warm brown eyes, and a small smile.
attach('CloseCroppedHair',V(2.15,2.65,2),V(0,7.04,.15),hair,head,Enum.PartType.Ball)
for _,s in {-1,1} do
    attach('Ear',V(.38,.72,.45),V(s*1.13,6.91,.02),skin,head,Enum.PartType.Ball)
    attach('EyeWhite',V(.49,.27,.15),V(s*.49,7.08,-.935),Color3.fromRGB(244,235,219),head,Enum.PartType.Ball)
    attach('Iris',V(.20,.23,.09),V(s*.47,7.075,-1.019),Color3.fromRGB(66,45,30),head,Enum.PartType.Ball)
    attach('Pupil',V(.10,.17,.055),V(s*.47,7.075,-1.067),Color3.fromRGB(15,18,21),head,Enum.PartType.Ball)
    attach('EyeCatchlight',V(.054,.056,.035),V(s*.47-.035,7.12,-1.099),C.white,head,Enum.PartType.Ball)
    attach('Eyebrow',V(.61,.13,.13),V(s*.49,7.34,-.91),hair)
    attach('Cheek',V(.62,.62,.37),V(s*.53,6.59,-.69),skin,head,Enum.PartType.Ball)
end
attach('NoseBridge',V(.27,.47,.28),V(0,6.96,-.99),skin,head,Enum.PartType.Ball)
attach('Nose',V(.4,.25,.31),V(0,6.72,-1.09),skin,head,Enum.PartType.Ball)
attach('Smile',V(.59,.11,.12),V(0,6.34,-.9),Color3.fromRGB(83,47,35),head,Enum.PartType.Ball)
attach('LowerLip',V(.43,.10,.13),V(0,6.26,-.85),Color3.fromRGB(157,102,79),head,Enum.PartType.Ball)
attach('NeckSkin',V(.83,.68,.8),V(0,5.7,0),skin,torso,Enum.PartType.Ball)
-- Hood, neckline, kangaroo pocket, ribbing, drawstrings and small chest crest.
attach('Hood',V(2.3,1.3,1.18),V(0,5.14,.67),Color3.fromRGB(228,149,16),torso,Enum.PartType.Ball,Enum.Material.Fabric)
attach('Collar',V(1.1,.45,.5),V(0,5.34,-.54),Color3.fromRGB(217,138,13),torso,Enum.PartType.Ball,Enum.Material.Fabric)
attach('HoodiePocket',V(1.68,.8,.15),V(0,3.35,-.81),Color3.fromRGB(236,160,18),torso,nil,Enum.Material.Fabric)
attach('PocketTopSeam',V(1.52,.04,.03),V(0,3.72,-.90),Color3.fromRGB(255,194,44),torso)
attach('WaistRibbing',V(2.52,.32,1.52),V(0,2.65,0),Color3.fromRGB(227,147,14),torso,nil,Enum.Material.Fabric)
for _,s in {-1,1} do
    attach('Drawstring',V(.052,.95,.06),V(s*.3,4.87,-.81),Color3.fromRGB(255,210,78),torso)
    attach('DrawstringTip',V(.08,.18,.09),V(s*.3,4.37,-.82),C.white,torso)
end
local crest=attach('ChestCrest',V(.55,.58,.055),V(.72,4.6,-.793),C.yellow,torso); label(crest,'P',Enum.NormalId.Front,C.white)
for _,s in {-1,1} do
    local arm=npc[if s==-1 then 'Left Arm' else 'Right Arm']; arm.Size=V(1,3.1,1.2); arm.Color=C.yellow; arm.Material=Enum.Material.Fabric
    local leg=npc[if s==-1 then 'Left Leg' else 'Right Leg']; leg.Color=dark; leg.Material=Enum.Material.Fabric
    attach('SleeveCuff',V(1.04,.35,1.22),V(s*1.9,2.7,0),Color3.fromRGB(226,147,13),arm,nil,Enum.Material.Fabric)
    attach('Hand',V(.87,.63,.96),V(s*1.9,2.24,-.02),skin,arm,Enum.PartType.Ball)
    attach('Sneaker',V(1.2,.5,1.8),V(s*.65,.63,-.18),Color3.fromRGB(39,41,43),leg)
    attach('ShoeSole',V(1.23,.14,1.85),V(s*.65,.39,-.18),Color3.fromRGB(214,208,189),leg)
    local shoulder=torso[if s==-1 then 'Left Shoulder' else 'Right Shoulder']; shoulder.C0=F(s*1.9,1.15,0); shoulder.C1=F(0,1.15,0)
    local hip=torso[if s==-1 then 'Left Hip' else 'Right Hip']; hip.C0=F(s*.65,-1.5,0); hip.C1=F(0,1.05,0)
end
for _,p in npc:GetChildren() do if p:IsA('BasePart') and p~=root then p.CanCollide=false; p.CanTouch=false; p.Massless=true end end
npc:SetAttribute('Costume','ReferenceYellowHoodie'); npc:SetAttribute('VisualVersion',2)
npc.Humanoid.HipHeight=.6 -- Keep the custom sneakers above the floor on the taller R6 rig.
head.StateBubble.StudsOffset=V(0,2.25,0)
local L=game.Lighting; L.ClockTime=14.6; L.Brightness=1.8; L.Ambient=Color3.fromRGB(139,151,162); L.OutdoorAmbient=Color3.fromRGB(164,174,183)
L.EscapeColor.Saturation=.035; L.EscapeColor.Contrast=.05; L.EscapeColor.TintColor=Color3.fromRGB(255,249,238)
L.EscapeBloom.Intensity=.06
world:SetAttribute('VisualVersion',2)
return {scenery=#decor:GetDescendants(),professor=#npc:GetDescendants(),version=2}
