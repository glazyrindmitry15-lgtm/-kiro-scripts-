-- movement.lua | Kiro Scripts
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
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end
end)

-- Fly
local flying = false
local flyBV, flyBG

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if G("Misc.InfJump", false) then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char then return end

    -- Bunnyhop
    if spaceDown and G("Misc.BunnyHop", false) and hum then
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end

    -- Fly
    if G("Misc.Fly", false) and hrp then
        if not flying then
            flying = true
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        flyBV.Velocity = move * (G("Misc.FlySpeed", 50) or 50)
        flyBG.CFrame = cam.CFrame
    else
        if flying then
            flying = false
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end

    -- Noclip
    if G("Misc.Noclip", false) and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Speed (BodyVelocity)
    if G("Misc.Speed", false) and hrp and hum then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local bv = hrp:FindFirstChild("SpeedBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "SpeedBV"
                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                bv.Parent = hrp
            end
            bv.Velocity = moveDir * (G("Misc.WalkSpeed", 16) or 16)
        end
        hum.WalkSpeed = 16
    else
        if hrp then
            local bv = hrp:FindFirstChild("SpeedBV")
            if bv then bv:Destroy() end
        end
        if hum then hum.WalkSpeed = G("Misc.WalkSpeed", 16) or 16 end
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

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)

print("[KIRO MOVEMENT] Loaded. Game: " .. gameId)
return K