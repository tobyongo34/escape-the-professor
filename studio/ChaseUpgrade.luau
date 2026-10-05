-- Edit-time recipe: owned scenery only, plus the three existing final hurdles and last bonus pass.
local world=assert(workspace:FindFirstChild('EscapeSchool'))
local frame=world['01_Detention'].TileFloor.CFrame*CFrame.new(0,-40,0)
local V=Vector3.new
local C={navy=Color3.fromRGB(23,42,59),gold=Color3.fromRGB(255,203,70),cream=Color3.fromRGB(255,249,229),green=Color3.fromRGB(69,115,83),orange=Color3.fromRGB(196,107,58)}
local old=world:FindFirstChild('ChaseUpgrade');if old then old:Destroy()end
local folder=Instance.new('Folder');folder.Name='ChaseUpgrade';folder.Parent=world
local function part(name,size,pos,color,collide,material)
    local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=frame*CFrame.new(pos);p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=folder;return p
end
local function label(p,message,face,col)
    local g=Instance.new('SurfaceGui');g.Name='Lettering';g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=35;g.LightInfluence=.1;g.Parent=p
    local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.9,.88);t.Position=UDim2.fromScale(.05,.06);t.Text=message;t.TextColor3=col or C.cream;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextWrapped=true;t.BackgroundTransparency=1;t.Parent=g
end
-- Visible hedges close the bypass around all of the hurdles and tie into the school exit wall.
for _,z in {-16,16} do
    part('ChaseHedge',V(152,9,2),V(652,45.5,z),C.green,true,Enum.Material.Grass)
    part('HedgeCoping',V(152,.3,2.2),V(652,50.1,z),Color3.fromRGB(100,142,92),false,Enum.Material.Grass)
    for x=580,724,12 do
        part('FencePost',V(.5,9.7,2.3),V(x,45.85,z),C.navy,false,Enum.Material.Metal)
        part('FenceReflector',V(.7,.65,.1),V(x,45,z-math.sign(z)*1.07),C.gold,false)
    end
end
for i,def in {{625,-5.5},{670,5.5}} do
    local x,z=def[1],def[2]
    local body=part('ExamCart'..i,V(4,8.5,19),V(x,45.25,z),C.orange,true,Enum.Material.Wood)
    label(body,'EXAM DELIVERY\nGO AROUND',Enum.NormalId.Left,C.cream)
    part('CartBumper',V(4.4,.7,19.4),V(x,41.65,z),C.navy,false,Enum.Material.Metal)
    for j=1,4 do
        part('ExamStack',V(3.4,.55,3.5),V(x,49.9,z-7+(j-1)*4.5),C.cream,false)
        part('ExamBinder',V(3.6,.12,3.7),V(x,50.22,z-7+(j-1)*4.5),if j%2==0 then C.gold else C.navy,false)
    end
    local stripe=part('CartHazardStripe',V(.09,.6,18),V(x-2.05,42.5,z),C.gold,false)
    label(stripe,'/ / / / / / / / / /',Enum.NormalId.Left,C.navy)
end
for _,p in world['06_FinalBell']:GetChildren()do
    if p:IsA('BasePart') and p.Name=='EasyHurdle' then p.Size=V(p.Size.X,2.3,29.2);p.Color=C.gold end
end
local entry=part('ChaseInstructions',V(.2,5,25),V(595,55,0),C.navy,false)
label(entry,'FINAL BELL\nWEAVE  •  JUMP  •  SPRINT',Enum.NormalId.Left,C.gold)
local hall=part('HallPatrolWarning',V(.2,3,23),V(130,55.5,0),C.navy,false)
label(hall,'HALL MONITOR AHEAD\nKEEP MOVING!',Enum.NormalId.Left,C.gold)
local pass=world.BonusPasses:FindFirstChild('HallPass6')
if pass then local pos=V(705,44.5,9);pass:SetAttribute('CoursePosition',pos);pass.CFrame=frame*CFrame.new(pos)*CFrame.Angles(0,math.pi/2,0)end
world:SetAttribute('ChaseUpgradeVersion',1)
return 'Chase course ready: two alternating exam carts, three full-lane hurdles, visible hedge boundaries, and patrol warning.'
