local world=workspace.EscapeSchool
if world:GetAttribute('Refined') then return 'Refinement already applied' end
local lib=world['03_HomeworkLibrary']
local shelfNames={BookshelfBack=true,BookshelfSide=true,BookshelfShelf=true,Book=true,SpineStripe=true}
for _,p in lib:GetChildren() do
    if p:IsA('BasePart') and shelfNames[p.Name] and p.Position.Z< -24 then
        local center=216+math.floor((p.Position.X-216+12)/24)*24
        local origin=CFrame.new(center,40,-26)
        p.CFrame=origin*CFrame.Angles(0,math.pi,0)*origin:ToObjectSpace(p.CFrame)
    end
end
local platforms=world.Platforms
local shuttle=platforms.StationeryShuttle
shuttle.Size=Vector3.new(12,1.5,14); shuttle.Color=Color3.fromRGB(139,116,185)
shuttle.Lettering.TextLabel.Text='ERASER\nEXPRESS'
for _,p in platforms:GetChildren() do if p.Name=='BookPages' and math.abs(p.Position.X-327)<0.5 then p.Parent=shuttle; p.Size=Vector3.new(12.05,0.7,12.7); p:SetAttribute('ShuttleOffset',shuttle.CFrame:ToObjectSpace(p.CFrame)) end end
for _,index in {3,7} do
    local top=platforms['GiantBook'..index]; top.Color=Color3.fromRGB(161,104,66); top.Material=Enum.Material.Wood
    top.Lettering.TextLabel.Text=if index==3 then 'QUIET PLEASE' else 'NO HOMEWORK HERE'
    for _,dx in {-4,4} do for _,dz in {-5,5} do
        local p=Instance.new('Part'); p.Name='DeskPlatformLeg'; p.Size=Vector3.new(0.5,top.Position.Y-41,0.5); p.Position=Vector3.new(top.Position.X+dx,41+p.Size.Y/2,top.Position.Z+dz); p.Anchored=true; p.Color=Color3.fromRGB(25,48,68); p.Material=Enum.Material.Metal; p.Parent=platforms
    end end
end
for _,p in world.Hazards:GetChildren() do if p:GetAttribute('Hazard')=='Pencil' then
    local eraser=Instance.new('Part'); eraser.Name='Eraser'; eraser.Shape=Enum.PartType.Cylinder; eraser.Size=Vector3.new(2,2.9,2.9); eraser.Color=Color3.fromRGB(230,131,140); eraser.CFrame=p.CFrame*CFrame.new(-8,0,0); eraser.Anchored=true; eraser.CanCollide=false; eraser.CanQuery=false; eraser.CanTouch=false; eraser:SetAttribute('PencilOffset',CFrame.new(-8,0,0)); eraser.Parent=p
    local tip=Instance.new('Part'); tip.Name='PencilTip'; tip.Shape=Enum.PartType.Ball; tip.Size=Vector3.new(2.2,1.5,1.5); tip.Color=Color3.fromRGB(47,58,68); tip.CFrame=p.CFrame*CFrame.new(8.1,0,0); tip.Anchored=true; tip.CanCollide=false; tip.CanQuery=false; tip.CanTouch=false; tip:SetAttribute('PencilOffset',CFrame.new(8.1,0,0)); tip.Parent=p
end end
-- A second hallway checkpoint makes failures short and avoids replaying earlier jumps.
local original=world.Checkpoints.HallStart
local mid=original:Clone(); mid.Name='HallMid'; mid.Position=Vector3.new(124,41.2,0); mid.Parent=world.Checkpoints
local light=game.Lighting
light.Brightness=1.8
world:SetAttribute('Refined',true)
return 'Shelves face inward; desk platforms, moving eraser, pencil details and hallway midpoint added.'
