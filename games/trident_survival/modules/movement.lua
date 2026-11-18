-- movement.lua | Kiro Scripts (Fixed: LinearVelocity speed + Stepped noclip)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}

if type(K.GetSetting) ~= "function" then
    function K.GetSetting(path)
        if type(path) ~= "string" then return nil end
        if K.Settings[path] ~= nil then return K.Settings[path] end
        local current = K.Settings
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) == "table" and current[part] ~= nil then
                current = current[part]
            else
                return nil
            end
        end
        return current
    end
end

if type(K.SetSetting) ~= "function" then
    function K.SetSetting(path, value)
        if type(path) ~= "string" then return end
        K.Settings[path] = value
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        local current = K.Settings
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(current[key]) ~= "table" then current[key] = {} end
            current = current[key]
        end
        current[parts[#parts]] = value
    end
end

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local gameId = K.GameId or "unknown"

-- Bunnyhop (all games)
local spaceDown = false
local noclipParts = {}
local lastNoclipScan = 0
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end
end)

-- Fly
local flying = false
local flyLV, flyAttachment, flyGyro

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if G("Misc.InfJump", false) then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Speed / Noclip loop on Stepped (better than RenderStepped for physics)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char then return end

    -- JumpPower (previously never applied — slider did nothing)
    if hum then
        local jp = tonumber(G("Misc.JumpPower", 50)) or 50
        if hum.UseJumpPower ~= true then hum.UseJumpPower = true end
        if math.abs(hum.JumpPower - jp) > 0.01 then hum.JumpPower = jp end
    end

    -- Bunnyhop
    if spaceDown and G("Misc.BunnyHop", false) and hum then
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end

    -- Noclip (cached parts — GetDescendants() every physics frame was the cost)
    local noclipOn = G("Misc.Noclip", false)
    if noclipOn and char then
        if tick() - lastNoclipScan > 2 or #noclipParts == 0 then
            lastNoclipScan = tick()
            noclipParts = {}
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    noclipParts[#noclipParts + 1] = { part = p, wasCollidable = p.CanCollide }
                end
            end
        end
        for _, e in ipairs(noclipParts) do
            if e.part.Parent and e.part.CanCollide then
                e.part.CanCollide = false
            end
        end
    elseif not noclipOn and #noclipParts > 0 then
        -- restore exactly what we changed
        for _, e in ipairs(noclipParts) do
            pcall(function()
                if e.part.Parent then e.part.CanCollide = e.wasCollidable end
            end)
        end
        noclipParts = {}
    end

    -- Speed via LinearVelocity (no rubberbanding)
    if G("Misc.Speed", false) and hrp and hum then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local lv = hrp:FindFirstChild("SpeedLV")
            if not lv then
                lv = Instance.new("LinearVelocity")
                lv.Name = "SpeedLV"
                lv.MaxForce = 1e6
                lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector

                local att = hrp:FindFirstChild("RootRigAttachment")
                if not att then
                    att = Instance.new("Attachment")
                    att.Name = "RootRigAttachment"
                    att.Parent = hrp
                end
                lv.Attachment0 = att
                lv.Parent = hrp
            end
            local speed = G("Misc.WalkSpeed", 16) or 16
            lv.VectorVelocity = moveDir * speed
        else
            local lv = hrp:FindFirstChild("SpeedLV")
            if lv then lv:Destroy() end
        end
        -- Keep WalkSpeed at vanilla so server doesn't desync
        if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
    else
        local lv = hrp and hrp:FindFirstChild("SpeedLV")
        if lv then lv:Destroy() end
        local target = G("Misc.WalkSpeed", 16) or 16
        if hum and hum.WalkSpeed ~= target then hum.WalkSpeed = target end
    end
end)

-- Fly loop on RenderStepped
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char then return end

    if G("Misc.Fly", false) and hrp then
        if not flying then
            flying = true
            flyAttachment = hrp:FindFirstChild("RootRigAttachment")
            if not flyAttachment then
                flyAttachment = Instance.new("Attachment")
                flyAttachment.Name = "RootRigAttachment"
                flyAttachment.Parent = hrp
            end
            flyLV = Instance.new("LinearVelocity")
            flyLV.Name = "FlyLV"
            flyLV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyLV.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            flyLV.Attachment0 = flyAttachment
            flyLV.Parent = hrp

            flyGyro = Instance.new("BodyGyro")
            flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyGyro.CFrame = hrp.CFrame
            flyGyro.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        flyLV.VectorVelocity = move * (G("Misc.FlySpeed", 50) or 50)
        flyGyro.CFrame = cam.CFrame
    else
        if flying then
            flying = false
            if flyLV then flyLV:Destroy(); flyLV = nil end
            if flyGyro then flyGyro:Destroy(); flyGyro = nil end
        end
    end
end)

-- Teleport (T key) - only for Valiant
if gameId == "valiant_district" then
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.T and G("Misc.Teleport", false) then
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            local nearest, nearestDist = nil, math.huge
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - myHrp.Position).Magnitude
                        if d < nearestDist then nearestDist = d; nearest = hrp end
                    end
                end
            end
            if nearest then
                myHrp.CFrame = nearest.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
end

-- Anti-AFK (VirtualUser resolved once, guarded)
task.spawn(function()
    local vu = nil
    pcall(function() vu = game:GetService("VirtualUser") end)
    if not vu then return end
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)

print("[KIRO MOVEMENT] Loaded (LinearVelocity speed + Stepped noclip). Game: " .. gameId)
return K