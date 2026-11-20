-- triggerbot.lua | auto-fire, burst fire, silent aim
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local lastShot = 0
local cachedModels = {}
local lastModelUpdate = 0

local function getModels()
    if tick() - lastModelUpdate < 0.5 then return cachedModels end
    lastModelUpdate = tick()

    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character or workspace:FindFirstChild(plr.Name)
            if char and not seen[char] then
                seen[char] = true
                table.insert(models, { model = char, player = plr })
            end
        end
    end

    if #models == 0 then
        local myChar = LP.Character
        for _, m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= myChar and not seen[m] then
                if m:FindFirstChildOfClass("Humanoid") and (m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")) then
                    seen[m] = true
                    table.insert(models, { model = m, player = nil })
                end
            end
        end
    end

    cachedModels = models
    return models
end

local function getPart(model)
    if model:IsA("BasePart") then return model end
    local head = model:FindFirstChild("Head") or model:FindFirstChild("head")
        or model:FindFirstChild("UpperTorso") or model:FindFirstChild("UpperTorso")
    local body = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    return head or body or model.PrimaryPart
end

local function isAlive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end
    local hp = model:GetAttribute("Health") or model:GetAttribute("HP")
    if type(hp) == "number" then return hp > 0 end
    return true
end

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Blacklist
pcall(function() losParams.IgnoreWater = true end)

local function hasLOS(model, part)
    local char = LP.Character
    if not char then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    losParams.FilterDescendantsInstances = { char, model }
    local origin = cam.CFrame.Position
    return workspace:Raycast(origin, part.Position - origin, losParams) == nil
end

-- ============================================================
-- SHOOTING
-- ============================================================
local function click()
    if not VirtualUser then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

-- Silent aim: point the camera at the target's head for the shot only.
-- The bullet goes to the head; the view snaps back a moment later.
local function shootAt(targetPart)
    local cam = workspace.CurrentCamera
    if cam and targetPart and G("Combat.SilentAim", false) then
        local saved = cam.CFrame
        pcall(function()
            cam.CFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
        end)
        click()
        task.delay(0.04, function()
            pcall(function() cam.CFrame = saved end)
        end)
    else
        click()
    end
end

-- ============================================================
-- TRIGGER LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not G("Combat.Triggerbot", false) then return end

    local baseMs = tonumber(G("Combat.TriggerDelay", 80)) or 80
    local jitter = math.random(0, math.max(1, math.floor(baseMs * 0.35)))
    local delay = (baseMs + jitter) / 1000
    if tick() - lastShot < delay then return end

    local mouse = UIS:GetMouseLocation()

    for _, entry in ipairs(getModels()) do
        local model = entry.model
        if not model or not model.Parent then continue end

        local part = getPart(model)
        if not part then continue end
        if not isAlive(model) then continue end
        if not hasLOS(model, part) then continue end

        local scr, on = Camera:WorldToViewportPoint(part.Position)
        if on and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 15 then
            lastShot = tick()

            if K.KillFeed and K.KillFeed.SetLastDamage then
                K.KillFeed.SetLastDamage(entry.player and entry.player.Name or "Unknown")
            end
            K._lastPlayerDamageTime = tick()

            if G("Combat.Burst", false) then
                -- burst fire: N shots as fast as the delay allows
                local count = tonumber(G("Combat.BurstCount", 10)) or 10
                local gap = (tonumber(G("Combat.BurstDelay", 60)) or 60) / 1000
                for i = 1, count do
                    shootAt(part)
                    if i < count then task.wait(gap) end
                end
            else
                shootAt(part)
            end
            break
        end
    end
end)

print("[KIRO TRIGGER] loaded.")
return K