-- aimbot.lua | Kiro Scripts
-- Camera is written in BindToRenderStep AFTER the game camera (Camera+1),
-- because writing CFrame in Heartbeat happens after rendering and has no effect.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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

-- FOV circle
local fovCircle = nil
pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.NumSides = 64
        fovCircle.Filled = false
        fovCircle.Color = Color3.fromRGB(138, 100, 255)
        fovCircle.Visible = false
    end
end)

-- cached players
-- ============ ROBUST PLAYER RESOLUTION (same as visuals) ============
local containers = {}
local function refreshContainers()
    local list = {}
    for _, n in ipairs({ "Players", "Entities", "Characters", "NPCs", "NPC", "Mobs" }) do
        local c = workspace:FindFirstChild(n)
        if c then list[#list + 1] = c end
    end
    containers = list
end
refreshContainers()

local charCache = {}

local function isCharLike(v)
    return typeof(v) == "Instance" and v.Parent ~= nil and (v:IsA("Model") or v:IsA("BasePart"))
end

local function resolveCharacter(plr)
    local cached = charCache[plr]
    if cached == false then return nil end
    if isCharLike(cached) then return cached end

    local char = plr.Character
    if isCharLike(char) then
        charCache[plr] = char
        return char
    end

    for _, c in ipairs(containers) do
        local m = c:FindFirstChild(plr.Name)
        if isCharLike(m) then
            charCache[plr] = m
            return m
        end
    end

    local direct = workspace:FindFirstChild(plr.Name)
    if isCharLike(direct) then
        charCache[plr] = direct
        return direct
    end

    local uid = plr.UserId
    if uid then
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character then
                local attr = m:GetAttribute("UserId")
                    or m:GetAttribute("PlayerUserId")
                    or m:GetAttribute("userid")
                if attr == uid then
                    charCache[plr] = m
                    return m
                end
            end
        end
    end

    charCache[plr] = false
    task.delay(5, function() charCache[plr] = nil end)
    return nil
end

local cachedPlayers = {}
task.spawn(function()
    while true do
        refreshContainers()

        local players = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = resolveCharacter(plr)
                if char then
                    table.insert(players, { model = char, player = plr })
                end
            end
        end
        cachedPlayers = players
        task.wait(0.5)
    end
end)

local function isEnemy(plr)
    if not G("Combat.TeamCheck", true) then return true end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

local HEAD_NAMES = { "Head", "head", "HeadMesh", "UpperTorso", "uppertorso" }

local function getPart(model)
    if model:IsA("BasePart") then return model end
    for _, n in ipairs(HEAD_NAMES) do
        local p = model:FindFirstChild(n)
        if p then return p end
    end
    local fallback = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    return fallback
end

local function isAlive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end
    local attrHp = model:GetAttribute("Health") or model:GetAttribute("HP") or model:GetAttribute("Hp")
    if type(attrHp) == "number" then return attrHp > 0 end
    return true
end

-- one RaycastParams reused for every line-of-sight test
local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Blacklist

local function hasLOS(model, part)
    if not G("Combat.WallCheck", true) then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local camera = workspace.CurrentCamera
    if not camera then return false end
    losParams.FilterDescendantsInstances = { char, model }
    local origin = camera.CFrame.Position
    local hit = workspace:Raycast(origin, part.Position - origin, losParams)
    return hit == nil
end

local cachedTarget = nil
local lastTargetUpdate = 0

local function findTarget()
    local now = tick()
    -- reuse cache while it is fresh AND the target is still valid
    if cachedTarget and cachedTarget.Parent and (now - lastTargetUpdate) < 0.1 then
        if isAlive(cachedTarget.Parent) then return cachedTarget end
    end
    lastTargetUpdate = now

    local camera = workspace.CurrentCamera
    if not camera then cachedTarget = nil return nil end

    local bestPart, bestScore = nil, math.huge
    local fov = tonumber(G("Combat.FOV", 120)) or 120
    local mouse = UserInputService:GetMouseLocation()

    for _, entry in ipairs(cachedPlayers) do
        if not isEnemy(entry.player) then continue end
        local model = entry.model
        if not model or not model.Parent then continue end
        local part = getPart(model)
        if not part then continue end
        if not isAlive(model) then continue end
        if not hasLOS(model, part) then continue end

        local scr, on = camera:WorldToViewportPoint(part.Position)
        if not on or scr.Z <= 0 then continue end

        local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
        if d > fov then continue end
        if d < bestScore then
            bestScore = d
            bestPart = part
        end
    end

    cachedTarget = bestPart
    return bestPart
end

-- Recoil control: bounded so it can never fling the camera
local rcsOffset = Vector2.new(0, 0)

local function updateRCS(dt)
    if not G("Combat.RCS", false) then
        rcsOffset = rcsOffset * math.exp(-10 * dt)
        if rcsOffset.Magnitude < 0.01 then rcsOffset = Vector2.new(0, 0) end
        return
    end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local strength = (tonumber(G("Combat.RCSStrength", 80)) or 80) / 100
        rcsOffset = rcsOffset + Vector2.new(0, strength * 18 * dt)
        if rcsOffset.Y > 5 then rcsOffset = Vector2.new(rcsOffset.X, 5) end
    else
        rcsOffset = rcsOffset * math.exp(-12 * dt)
        if rcsOffset.Magnitude < 0.01 then rcsOffset = Vector2.new(0, 0) end
    end
end

-- Notify killfeed/hitmarker when the player fires on a target
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local target = findTarget()
    if not target then return end

    local victimName = "Unknown"
    for _, entry in ipairs(cachedPlayers) do
        local model = entry.model
        if model == target.Parent or model == target:FindFirstAncestorOfClass("Model") then
            victimName = entry.player and entry.player.Name or "Unknown"
            break
        end
    end
    if K.KillFeed and K.KillFeed.SetLastDamage then
        K.KillFeed.SetLastDamage(victimName)
    end
    K._lastPlayerDamageTime = tick()
end)

-- Main loop: runs right after the game camera so our CFrame is the one rendered
local lastFrameClock = os.clock()

RunService:BindToRenderStep("KiroAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    local camera = workspace.CurrentCamera
    if not camera then return end

    -- frame-rate independent delta
    local nowClock = os.clock()
    local dt = nowClock - lastFrameClock
    lastFrameClock = nowClock
    if dt <= 0 or dt > 0.1 then dt = 1 / 60 end

    local aimbotOn = G("Combat.Aimbot", false)
    local showFov = G("Combat.ShowFOV", true)

    if fovCircle then
        if showFov and aimbotOn then
            fovCircle.Position = UserInputService:GetMouseLocation()
            fovCircle.Radius = tonumber(G("Combat.FOV", 120)) or 120
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    updateRCS(dt)

    if not aimbotOn then return end

    local target = findTarget()
    if not target or not target.Parent then return end

    local goal = CFrame.new(camera.CFrame.Position, target.Position)

    if rcsOffset.Magnitude > 0.05 then
        goal = goal * CFrame.Angles(math.rad(rcsOffset.Y), math.rad(rcsOffset.X), 0)
    end

    -- convert the 0..1 slider into a per-second rate, then integrate over dt
    local alpha = (tonumber(G("Combat.Smoothness", 5)) or 5) / 100
    alpha = math.clamp(alpha, 0.01, 0.95)
    local rate = -60 * math.log(1 - alpha)
    -- vary the rate slightly: a constant smoothing factor is a detectable signature
    rate = rate * (0.9 + math.random() * 0.2)
    local t = 1 - math.exp(-rate * dt)
    camera.CFrame = camera.CFrame:Lerp(goal, t)
end)

print("[KIRO AIMBOT] Loaded. Game: " .. (K.GameId or "unknown"))
return K