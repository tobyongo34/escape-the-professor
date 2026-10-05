-- Convert the course's original layout coordinates into the school's current placement.
-- The classroom floor was authored at (0, 40, 0); its CFrame follows model moves/rotation.
local Course={}
Course.__index=Course
function Course.new(world)
    return setmetatable({Floor=world:WaitForChild('01_Detention'):WaitForChild('TileFloor')},Course)
end
function Course:Frame()
    return self.Floor.CFrame*CFrame.new(0,-40,0)
end
function Course:ToLocal(position)
    return self:Frame():PointToObjectSpace(position)
end
function Course:ToWorld(position)
    return self:Frame():PointToWorldSpace(position)
end
function Course:ToWorldCFrame(cf)
    return self:Frame()*cf
end
return Course
