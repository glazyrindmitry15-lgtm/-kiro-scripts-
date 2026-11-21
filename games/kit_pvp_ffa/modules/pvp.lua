-- pvp.lua | Minecraft-style PvP helpers for DEGRADE-like Roblox PvP games
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local LP         = Players.LocalPlayer

local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local function getChar()
    return LP.Character
end

local function getRoot()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local function getTool()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Tool")
end

-- ============================================================
-- TARGET UNDER THE CROSSHAIR
-- ============================================================
local TARGET_PARTS = { "Head", "head", "UpperTorso", "Torso", "HumanoidRootPart" }

local function getTargetPart(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    for _, n in ipairs(TARGET_PARTS) do
        local p = model:FindFirstChild(n)
        if p then return p end
    end
    return model.PrimaryPart
end

local function getEnemies()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(list, plr.Character)
            end
        end
    end

    -- fallback: any Model with a Humanoid (bots / custom characters)
    if #list == 0 then
        local myChar = LP.Character
        for _, m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= myChar then
                local hum = m:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and (m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")) then
                    table.insert(list, m)
                end
            end
        end
    end
    return list
end

local function targetUnderCrosshair(maxDist)
    local cam = workspace.CurrentCamera
    local root = getRoot()
    if not cam or not root then return nil, nil end

    local mouse = UIS:GetMouseLocation()
    local best, bestDist = nil, maxDist or 6

    for _, model in ipairs(getEnemies()) do
        local part = getTargetPart(model)
        if part then
            local dist = (part.Position - root.Position).Magnitude
            if dist <= (maxDist or 6) then
                local scr, on = cam:WorldToViewportPoint(part.Position)
                if on and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 60 then
                    if dist < bestDist then
                        bestDist = dist
                        best = model
                    end
                end
            end
        end
    end
    return best, bestDist
end

-- ============================================================
-- AUTO TRIGGER + CRITICALS
-- ============================================================
local lastSwing = 0

RunService.Heartbeat:Connect(function()
    if K._dead then return end
    if not G("PvP.AutoTrigger", false) then return end

    local tool = getTool()
    local root = getRoot()
    if not tool or not root then return end

    local reach = tonumber(G("PvP.Reach", 6)) or 6
    local target, dist = targetUnderCrosshair(reach)
    if not target then return end

    -- rate limit
    local cps = tonumber(G("PvP.CPS", 8)) or 8
    local delay = 1 / math.max(cps, 1)
    if tick() - lastSwing < delay then return end
    lastSwing = tick()

    -- Criticals: jump first so the hit lands as a critical
    local hum = getChar() and getChar():FindFirstChildOfClass("Humanoid")
    if G("PvP.Criticals", false) and hum then
        pcall(function() hum.Jump = true end)
    end

    pcall(function() tool:Activate() end)
end)

-- ============================================================
-- AUTO CLICKER (hold left mouse)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if K._dead then return end
    if not G("PvP.AutoClicker", false) then return end
    if not VirtualUser then return end

    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end

    local cps = tonumber(G("PvP.AutoClickerCPS", 12)) or 12
    local now = tick()
    if now - (K._lastAutoClick or 0) < 1 / math.max(cps, 1) then return end
    K._lastAutoClick = now

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end)

-- ============================================================
-- VELOCITY (anti-knockback)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if K._dead then return end
    if not G("PvP.Velocity", false) then return end

    local root = getRoot()
    if not root then return end

    local v = root.AssemblyLinearVelocity
    local damp = tonumber(G("PvP.VelocityPercent", 80)) or 80
    local keep = 1 - (damp / 100)

    -- only damp horizontal knockback, never vertical (falling)
    local newV = Vector3.new(v.X * keep, v.Y, v.Z * keep)
    if (v - newV).Magnitude > 0.05 then
        pcall(function() root.AssemblyLinearVelocity = newV end)
    end
end)

-- ============================================================
-- AUTO ARMOR (equip armour from the backpack)
-- ============================================================
local ARMOR_WORDS = { "helmet", "chestplate", "leggings", "boots", "armor", "armour", "plate" }

local function isArmor(name)
    local n = name:lower()
    for _, w in ipairs(ARMOR_WORDS) do
        if n:find(w, 1, true) then return true end
    end
    return false
end

local lastArmor = 0

task.spawn(function()
    while true do
        task.wait(1)
        if K._dead or not G("PvP.AutoArmor", false) then continue end
        if tick() - lastArmor < 2 then continue end
        lastArmor = tick()

        local char = getChar()
        local bp = LP:FindFirstChildOfClass("Backpack")
        if not char or not bp then continue end

        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and isArmor(item.Name) then
                local already = char:FindFirstChild(item.Name)
                if not already then
                    pcall(function()
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(item) end
                    end)
                    task.wait(0.15)
                end
            end
        end
    end
end)

print("[KIRO PVP] Loaded.")
return K