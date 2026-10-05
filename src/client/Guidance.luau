local Guidance = {}
Guidance.__index = Guidance

function Guidance.new(world, course, ui, effects)
    local marker = Instance.new('BillboardGui')
    marker.Name = 'NextObjective'
    marker.Size = UDim2.fromOffset(190, 54)
    marker.StudsOffsetWorldSpace = Vector3.new(0, 5.5, 0)
    marker.AlwaysOnTop = true
    marker.MaxDistance = 160
    marker.Enabled = false
    marker.Parent = ui.Gui
    local label = Instance.new('TextLabel')
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(23, 42, 59)
    label.BackgroundTransparency = .12
    label.TextColor3 = Color3.fromRGB(255, 224, 122)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.Parent = marker
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    return setmetatable({World=world, Course=course, UI=ui, Effects=effects, Marker=marker, Label=label, Accum=0}, Guidance)
end

function Guidance:Target(state, hidden, position)
    local world = self.World
    if state.Stage == 1 then
        if state.Homework >= 3 then return world.Doors.ClassroomExit, 'CLASSROOM EXIT' end
        local nearest, distance
        for _, part in world.Pickups:GetChildren() do
            if part:IsA('BasePart') and part:GetAttribute('Action') == 'Homework' and not hidden[part.Name] then
                local d = (position-part.Position).Magnitude
                if not distance or d < distance then nearest, distance = part, d end
            end
        end
        return nearest, 'HOMEWORK SHEET'
    elseif state.Stage == 2 then
        if state.Checkpoint == 'HallEnd' then return world.Doors.LibraryEntrance, 'LIBRARY EXIT' end
        return world.Checkpoints[if state.Checkpoint == 'HallMid' then 'HallEnd' else 'HallMid'], 'NEXT CHECKPOINT'
    elseif state.Stage == 3 then
        if state.Checkpoint == 'LibraryEnd' then return world.Doors.ScienceEntrance, 'SCIENCE EXIT' end
        return world.Checkpoints[if state.Checkpoint == 'LibraryMid' then 'LibraryEnd' else 'LibraryMid'], 'JUMP VIA THE BOOKS'
    elseif state.Stage == 4 then
        return if state.Quiz >= 3 then world.Doors.StaffEntrance else world.Doors.QuizBoard, if state.Quiz >= 3 then 'STAFF ROOM EXIT' else 'POP QUIZ BOARD'
    elseif state.Stage == 5 then
        return if state.Key then world.Doors.FinalExit else world.Pickups.ExitKey, if state.Key then 'UNLOCK THE FINAL DOOR' else 'EXIT KEY'
    end
    return world['06_FinalBell'].FinishZone, 'GET TO THE BUS!'
end

function Guidance:Update(dt, state, hidden, root)
    self.Accum += dt
    if self.Accum < .08 then return end
    self.Accum = 0
    local ui, effects = self.UI, self.Effects
    local active = state.Active and not state.Finished and not state.Busy
    local passes = self.World:FindFirstChild('BonusPasses')
    if passes then
        local t = workspace:GetServerTimeNow()
        for _, part in passes:GetChildren() do
            if not part:IsA('BasePart') then continue end
            local collected = state.Passes and state.Passes[part:GetAttribute('PassId')]
            local show = active and part:GetAttribute('Stage') == state.Stage and not collected
            part.LocalTransparencyModifier = if show then 0 else 1
            for _, detail in part:GetChildren() do
                if detail:IsA('SurfaceGui') or detail:IsA('BillboardGui') or detail:IsA('Highlight') then detail.Enabled = show end
            end
            local pos = part:GetAttribute('CoursePosition')
            if pos then
                local phase = t*1.8 + part:GetAttribute('Stage')
                local bob = if effects.Settings.ReducedMotion then 0 else math.sin(phase)*.22
                local yaw = if effects.Settings.ReducedMotion then 0 else math.sin(phase*.5)*.2
                part.CFrame = self.Course:ToWorldCFrame(CFrame.new(pos+Vector3.new(0,bob,0))*CFrame.Angles(0,math.pi/2+yaw,0))
            end
        end
    end
    self.Marker.Enabled = false
    if not active or not root or not effects.Settings.Guidance or ui.Quiz.Visible or ui.Settings.Visible then return end
    local target, caption = self:Target(state, hidden, root.Position)
    if target then
        local distance = math.floor((root.Position-target.Position).Magnitude)
        self.Marker.Adornee = target
        self.Label.Text = caption .. '\n↓  ' .. distance .. ' STUDS'
        self.Marker.Enabled = true
    end
end

return Guidance
