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

-- ============ PLAYER RESOLUTION ============
-- Reuses the resolver built by visuals.lua (identical logic, no duplicate code).
local resolveCharacter = K.ResolveCharacter

local function safeResolve(plr)
    if resolveCharacter then
        local ok, res = pcall(resolveCharacter, plr)
        if ok and res then return res end
    end
    local c = plr.Character
    if typeof(c) == "Instance" and c.Parent then return c end
    return nil
end


local cachedPlayers = {}
task.spawn(function()
    while true do
        refreshContainers()

        local players = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = safeResolve(plr)
                if char then
                    table.insert(players, { model = char, player = plr })
                end
            end
        end
        -- Fallback: some games never set plr.Character at all. If nothing
        -- resolved, treat every Model that has a Humanoid as a target.
        if #players == 0 then
            local myChar = LocalPlayer.Character
            for _, m in ipairs(workspace:GetDescendants()) do
                if m:IsA("Model") and m ~= myChar then
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    local part = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                    if hum and part then
                        table.insert(players, { model = m, player = nil })
                    end
                end
            end
        end

        cachedPlayers = players
        task.wait(0.5)
    end
end)

local function isEnemy(plr)
    if not plr then return true end
    if not G("Combat.TeamCheck", true) then return true end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

local HEAD_NAMES = { "Head", "head", "HeadMesh", "UpperTorso", "uppertorso" }
local BODY_NAMES = {
    "UpperTorso", "uppertorso", "Torso", "torso",
    "HumanoidRootPart", "humanoidrootpart", "RootPart", "rootpart",
    "LowerTorso", "lowertorso", "Pelvis", "pelvis",
}
local LEGS_NAMES = {
    "LeftUpperLeg", "leftupperleg", "LeftLowerLeg", "LeftLeg", "LeftUpLeg", "LeftFoot",
    "RightUpperLeg", "rightupperleg", "RightLowerLeg", "RightLeg", "RightUpLeg", "RightFoot",
    "Left Leg", "Right Leg",
}

local function getPart(model)
    if model:IsA("BasePart") then return model end

    local mode = G("Combat.Hitbox", "Head")
    local names = HEAD_NAMES
    if mode == "Body" then
        names = BODY_NAMES
    elseif mode == "Legs" then
        names = LEGS_NAMES
    end

    for _, n in ipairs(names) do
        local p = model:FindFirstChild(n)
        if p then return p end
    end

    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
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
pcall(function() losParams.IgnoreWater = true end)

-- Coordinate spaces differ:
--   GetMouseLocation()  -> screen space (includes the 36px topbar inset)
--   WorldToViewportPoint -> viewport space (starts BELOW the inset)
-- Comparing them directly offsets the aim by the inset and the FOV check drifts.
local GuiService = game:GetService("GuiService")

local function mouseViewport()
    local ok, m = pcall(function() return UserInputService:GetMouseLocation() end)
    if not ok or not m then return Vector2.new(0, 0) end
    local inset = Vector2.new(0, 0)
    pcall(function()
        local i = GuiService:GetGuiInset()
        inset = Vector2.new(i.X, i.Y)
    end)
    return Vector2.new(m.X - inset.X, m.Y - inset.Y)
end

local function mouseScreen()
    local ok, m = pcall(function() return UserInputService:GetMouseLocation() end)
    if ok and m then return m end
    return Vector2.new(0, 0)
end

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
    local camera = workspace.CurrentCamera
    if not camera then cachedTarget = nil return nil end

    -- reuse cache while fresh and still valid
    if (now - lastTargetUpdate) < 0.1 and cachedTarget and cachedTarget.Parent then
        if isAlive(cachedTarget.Parent) then return cachedTarget end
    end
    lastTargetUpdate = now

    local bestPart, bestScore = nil, math.huge
    local fov = tonumber(G("Combat.FOV", 300)) or 300
    if fov < 40 then fov = 40 end   -- never let the FOV become uselessly tiny
    local mouse = mouseViewport()

    local function scan(checkLOS)
        for _, entry in ipairs(cachedPlayers) do
            if not isEnemy(entry.player) then continue end
            local model = entry.model
            if not model or not model.Parent then continue end
            local part = getPart(model)
            if not part then continue end
            if not isAlive(model) then continue end
            if checkLOS and not hasLOS(model, part) then continue end

            local scr, on = camera:WorldToViewportPoint(part.Position)
            if not on or scr.Z <= 0 then continue end

            local d = (Vector2.new(scr.X, scr.Y) - mouse).Magnitude
            if d > fov then continue end

            -- hysteresis: the current target wins ties, so the view stops
            -- snapping between two enemies at similar screen distance
            local score = d
            if part == cachedTarget then score = d * 0.55 end
            if score < bestScore then
                bestScore = score
                bestPart = part
            end
        end
        return bestPart
    end

    -- pass 1: respect walls
    scan(true)
    -- pass 2: if foliage/cover hid everyone, ignore LOS rather than not aiming
    if not bestPart then
        scan(false)
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

-- ============ HITS TO KILL ============
local WEAPON_DAMAGE = {
    ak = 36, ak47 = 36, ["ak-47"] = 36,
    m4 = 33, m4a1 = 33, m4a4 = 33,
    awp = 115, scout = 75, ssg = 75,
    deagle = 53, usp = 34, p2000 = 35, glock = 28, p250 = 38,
    ["five-seven"] = 32, tec9 = 30, cz = 30,
    mp9 = 26, mp7 = 28, ump = 25, p90 = 23, mac10 = 29, bizon = 27,
    aug = 32, sg = 45, famas = 30, galil = 30, scar = 38, g36 = 32,
    fal = 45, m249 = 32, negev = 30, tavor = 32,
    nova = 26, xm1014 = 20, sawed = 32, mag7 = 30,
    knife = 40, bayonet = 55, karambit = 55,
}

local HITBOX_MULT = { Head = 4.0, Body = 1.0, Legs = 0.75 }

local function getWeaponDamage()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return 25 end

    local attr = tool:GetAttribute("Damage") or tool:GetAttribute("damage")
    if type(attr) == "number" and attr > 0 then return attr end

    local n = tool.Name:lower()
    for key, dmg in pairs(WEAPON_DAMAGE) do
        if n:find(key, 1, true) then return dmg end
    end
    return 25
end

local function getTargetHealth(model)
    if not model then return 100 end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then return hum.Health end

    local hp = model:GetAttribute("Health") or model:GetAttribute("HP")
    if type(hp) == "number" then return hp end
    return 100
end

local hitsLabel = nil
pcall(function()
    if Drawing then
        hitsLabel = Drawing.new("Text")
        hitsLabel.Size = 13
        hitsLabel.Center = true
        hitsLabel.Outline = true
        hitsLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
        hitsLabel.Visible = false
    end
end)

local function hitsToKill(model)
    local hp = getTargetHealth(model)
    local mode = G("Combat.Hitbox", "Head")
    local mult = HITBOX_MULT[mode] or 1.0
    local dmg = getWeaponDamage() * mult
    if dmg <= 0 then dmg = 1 end
    return math.max(1, math.ceil(hp / dmg))
end

-- ============ AIM LOOP ============
-- Main loop: runs right after the game camera so our CFrame is the one rendered
local lastFrameClock = os.clock()

RunService:BindToRenderStep("KiroAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if K._dead then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    -- frame-rate independent delta
    local nowClock = os.clock()
    local dt = nowClock - lastFrameClock
    lastFrameClock = nowClock
    if dt <= 0 or dt > 0.1 then dt = 1 / 60 end

    local aimbotOn = G("Combat.Aimbot", false)
    local showFov = G("Combat.ShowFOV", true)

    if not aimbotOn then
        K.AimTarget = nil
        if hitsLabel then hitsLabel.Visible = false end
        return
    end

    local target = findTarget()
    K.AimTarget = target

    -- FOV circle turns red while a target is locked
    if fovCircle then
        if showFov then
            fovCircle.Position = mouseScreen()
            fovCircle.Radius = tonumber(G("Combat.FOV", 120)) or 120
            fovCircle.Color = target and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(138, 100, 255)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    updateRCS(dt)

    if not target or not target.Parent then
        if hitsLabel then hitsLabel.Visible = false end
        return
    end

    -- hits-to-kill readout
    if hitsLabel then
        local ok, n = pcall(hitsToKill, target.Parent)
        if ok and n then
            local scr = Camera:WorldToViewportPoint(target.Position)
            if scr.Z > 0 then
                hitsLabel.Text = string.format("%d HIT%s", n, n > 1 and "S" or "")
                hitsLabel.Position = Vector2.new(scr.X, scr.Y - 26)
                hitsLabel.Visible = true
            else
                hitsLabel.Visible = false
            end
        else
            hitsLabel.Visible = false
        end
    end

    local goal = CFrame.new(camera.CFrame.Position, target.Position)

    if rcsOffset.Magnitude > 0.05 then
        goal = goal * CFrame.Angles(math.rad(rcsOffset.Y), math.rad(rcsOffset.X), 0)
    end

    -- Smoothness semantics were inverted: Smoothness = 1 produced the SLOWEST
    -- aim (alpha 0.01) and 30 the fastest. Now 1 = instant, 30 = very smooth.
    local smooth = tonumber(G("Combat.Smoothness", 5)) or 5
    local alpha = math.clamp(1 - (smooth - 1) / 29, 0.02, 1)

    if G("Combat.Snap", false) or alpha >= 0.98 then
        -- instant: no interpolation at all (alpha 1 would make log(0) = -inf)
        camera.CFrame = goal
    else
        local rate = -60 * math.log(1 - alpha)
        -- tiny variation so the motion has no constant signature
        rate = rate * (0.96 + math.random() * 0.08)
        local t = 1 - math.exp(-rate * dt)
        -- fast aim, but never a single-frame teleport
        if t > 0.6 then t = 0.6 end
        camera.CFrame = camera.CFrame:Lerp(goal, t)
    end
end)

print("[KIRO AIMBOT] Loaded. Game: " .. (K.GameId or "unknown"))
return K