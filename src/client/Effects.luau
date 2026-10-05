local TweenService=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local E={ Settings={Guidance=true,Sfx=true,ReducedMotion=false}, Sounds={} }
-- Bundled Studio sound paths are verified by ContentProvider at runtime; failures remain silent.
local ids={Pickup='rbxasset://sounds/volume_slider.ogg',Checkpoint='rbxasset://sounds/volume_slider.ogg',Correct='rbxasset://sounds/volume_slider.ogg',Wrong='rbxasset://sounds/volume_slider.ogg',Bell='rbxasset://sounds/volume_slider.ogg',Catch='rbxasset://sounds/volume_slider.ogg',Victory='rbxasset://sounds/volume_slider.ogg'}
function E.Init()
    for name,id in ids do
        local s=Instance.new('Sound'); s.Name='Escape_'..name; s.SoundId=id; s.Volume=0.22; s.Parent=game:GetService('SoundService'); E.Sounds[name]=s
        task.spawn(function() pcall(function() game:GetService('ContentProvider'):PreloadAsync({s}) end) end)
    end
end
function E.Sound(name)
    local s=E.Sounds[name]; if E.Settings.Sfx and s and s.IsLoaded then s:Stop(); s.PlaybackSpeed=if name=='Wrong' or name=='Catch' then 0.8 elseif name=='Victory' then 1.3 else 1; s:Play() end
end
function E.Burst(position,color)
    if E.Settings.ReducedMotion then return end
    local anchor=Instance.new('Part'); anchor.Name='EscapeLocalEffect'; anchor.Size=Vector3.one; anchor.Anchored=true; anchor.CanCollide=false; anchor.CanQuery=false; anchor.CanTouch=false; anchor.Transparency=1; anchor.Position=position; anchor.Parent=workspace
    local particles=Instance.new('ParticleEmitter'); particles.Texture='rbxasset://textures/particles/sparkles_main.dds'; particles.Color=ColorSequence.new(color); particles.LightEmission=0.25; particles.Rate=0; particles.Lifetime=NumberRange.new(0.4,0.8); particles.Speed=NumberRange.new(4,9); particles.SpreadAngle=Vector2.new(120,120); particles.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,0)}); particles.Parent=anchor; particles:Emit(14); Debris:AddItem(anchor,1.2)
end
function E.Pickup(part)
    if not part then return end
    part.LocalTransparencyModifier=1
    for _,d in part:GetDescendants() do if d:IsA('SurfaceGui') or d:IsA('BillboardGui') then d.Enabled=false elseif d:IsA('Highlight') then d.Enabled=false elseif d:IsA('ProximityPrompt') then d.Enabled=false end end
end
function E.RestorePickups(world)
    for _,p in world.Pickups:GetChildren() do if p:IsA('BasePart') then p.LocalTransparencyModifier=0; for _,d in p:GetDescendants() do if d:IsA('SurfaceGui') or d:IsA('Highlight') then d.Enabled=true end end end end
end
function E.Confetti(parent)
    if E.Settings.ReducedMotion then return end
    for i=1,44 do
        local f=Instance.new('Frame'); f.Size=UDim2.fromOffset(7,12); f.Position=UDim2.fromScale(math.random(),-0.1); f.BackgroundColor3=({Color3.fromRGB(255,199,58),Color3.fromRGB(80,205,139),Color3.fromRGB(120,188,206)})[i%3+1]; f.BorderSizePixel=0; f.Rotation=math.random(180); f.ZIndex=110; f.Parent=parent
        TweenService:Create(f,TweenInfo.new(2+math.random(),Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromScale(math.random(),1.15),Rotation=math.random(-360,360)}):Play(); Debris:AddItem(f,3.5)
    end
end
return E
