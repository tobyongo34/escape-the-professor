-- Unmanaged scenery only. Safe to reapply; preserves course geometry and the professor.
local world=assert(workspace:FindFirstChild('EscapeSchool'))
local frame=world['01_Detention'].TileFloor.CFrame*CFrame.new(0,-40,0)
local V=Vector3.new
local navy=Color3.fromRGB(23,42,59)
local cream=Color3.fromRGB(255,249,229)
local colors={Color3.fromRGB(255,203,70),Color3.fromRGB(97,202,217),Color3.fromRGB(184,151,238),Color3.fromRGB(99,220,159),Color3.fromRGB(255,174,109),Color3.fromRGB(255,121,116)}
local old=world:FindFirstChild('CampusPolish'); if old then old:Destroy() end
local folder=Instance.new('Folder'); folder.Name='CampusPolish'; folder.Parent=world
local function part(name,size,pos,color,material)
    local p=Instance.new('Part'); p.Name=name; p.Size=size; p.CFrame=frame*CFrame.new(pos)
    p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=folder
    return p
end
local function label(p,message,face,color)
    local g=Instance.new('SurfaceGui'); g.Name='Lettering'; g.Face=face; g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    g.PixelsPerStud=40; g.LightInfluence=.1; g.Parent=p
    local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(.9,.86); t.Position=UDim2.fromScale(.05,.07)
    t.BackgroundTransparency=1; t.Text=message; t.TextColor3=color or cream; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Parent=g
end
local rooms={
    {'01_Detention',-36,36,32,'DETENTION','COLLECT 3 SHEETS\nTHEN MAKE YOUR EXIT'},
    {'02_SlipperyHallway',36,204,18,'HALL MONITOR','DODGE THE PENCILS\nWATCH THE PROFESSOR'},
    {'03_HomeworkLibrary',204,372,32,'HOMEWORK LIBRARY','BOOKS ARE SAFE\nTHE FLOOR IS NOT'},
    {'04_PopQuizLab',372,444,31,'SCIENCE CLUB','3 QUESTIONS\nA NEW QUIZ EVERY RUN'},
    {'05_StaffRoom',444,576,35,'STAFF ONLY','HIDE BEHIND SHELVES\nSTEAL THE EXIT KEY'},
    {'06_FinalBell',576,788,46,'LAST BUS','WEAVE  /  JUMP  /  SPRINT\nFREEDOM IS THIS WAY'},
}
for stage,r in rooms do
    local accent=colors[stage]
    local room=world:FindFirstChild(r[1]); assert(room,r[1])
    for _,p in room:GetDescendants() do
        if p:IsA('BasePart') and p.Name=='Wainscot' then p.Color=accent:Lerp(navy,.58) end
    end
    if stage<6 then
        local x=({-27,175,222,385,519})[stage]
        local z=r[4]-1.35
        part('PosterFrame'..stage,V(10,8,.3),V(x,59.3,z),accent)
        local face=part('RoomPoster'..stage,V(9.3,7.3,.1),V(x,59.3,z-.21),navy)
        label(face,string.format('%02d  /  %s\n\n%s\n\nPOPQUIZ ACADEMY',stage,r[5],r[6]),Enum.NormalId.Front,cream)
        local strip=part('RoomSconce'..stage,V(9.4,.16,.5),V(x,63.7,z-.4),accent,Enum.Material.Neon)
        local light=Instance.new('PointLight'); light.Color=accent:Lerp(cream,.7); light.Brightness=.55; light.Range=18; light.Shadows=false; light.Parent=strip
    end
end
-- Pull labels in front of the portal walls so the lettering remains visible.
local exits={36,204,372,444,576}
for _,p in world.ReplayPolish:GetChildren() do
    if p:IsA('BasePart') and p.Name=='RouteHeader' then
        local localPos=frame:PointToObjectSpace(p.Position)
        for i,x in exits do if math.abs(localPos.X-x)<3 then
            p.CFrame=frame*CFrame.new(x-1.8,59.4,0); p.Color=navy
            local g=p:FindFirstChildOfClass('SurfaceGui'); if g then g.TextLabel.TextColor3=colors[i+1] end
        end end
    end
end
-- Matching strips around entry frames tie the world to the HUD's room colors.
for i,x in exits do
    for _,z in {-7.1,7.1} do part('EntryAccent'..i,V(.1,13.8,.23),V(x-1.45,48.5,z),colors[i+1],Enum.Material.Neon) end
    local plaque=part('RoomNumber'..(i+1),V(.2,3,3),V(x-1.7,50,-11),colors[i+1])
    label(plaque,string.format('%02d',i+1),Enum.NormalId.Left,navy)
end
-- A floor trail teaches the opening weave without widening the tested running lane.
for _,d in {{610,9.5},{619,9.5},{637,4},{659,-9.5},{668,-9.5},{702,0},{711,0}} do
    local arrow=part('EscapeTrail',V(3,.025,3),V(d[1],41.23,d[2]),colors[6])
    label(arrow,'→',Enum.NormalId.Top,navy)
end
local busBoard=part('BusDepartureBoard',V(.22,5,20),V(741,58,-25),navy)
label(busBoard,'LAST BUS TO FREEDOM\nDEPARTURE: RIGHT NOW',Enum.NormalId.Left,colors[1])
world:SetAttribute('CampusPolishVersion',1)
return {version=1,decorations=#folder:GetDescendants(),collisionsChanged=false}
