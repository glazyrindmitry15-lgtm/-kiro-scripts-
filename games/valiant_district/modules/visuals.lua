-- visuals.lua | Kiro Scripts (Optimized: Object Pooling + Throttling + Player Filtering + Loot/TC ESP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

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

-- Drawing check
if not Drawing then
    warn("[KIRO VISUALS] Drawing API not available!")
    return
end

-- ============================================================
-- OBJECT POOL (no Drawing.new() every frame)
-- ============================================================
local Pool = {}
local PoolSize = 60

local function newObj(t)
    local o = Drawing.new(t)
    o.Visible = false
    o.Thickness = 2
    o.Transparency = 1
    return o
end

local function getObj(key)
    if not Pool[key] then
        Pool[key] = {
            box = newObj("Square"),
            name = newObj("Text"),
            dist = newObj("Text"),
            hpText = newObj("Text"),
            hpBg = newObj("Square"),
            hpFg = newObj("Square"),
            tracer = newObj("Line"),
            snapline1 = newObj("Line"),
            snapline2 = newObj("Line"),
        }
        local o = Pool[key]
        o.name.Size = 14
        o.name.Center = true
        o.name.Outline = true
        o.name.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.dist.Size = 14
        o.dist.Center = true
        o.dist.Outline = true
        o.dist.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.hpText.Size = 14
        o.hpText.Center = true
        o.hpText.Outline = true
        o.hpText.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.tracer.Thickness = 2
        o.snapline1.Thickness = 1.5
        o.snapline2.Thickness = 1.5
        -- Skeleton lines
        for i = 1, 10 do
            local sk = newObj("Line")
            sk.Thickness = 1
            sk.Transparency = 0.8
            table.insert(o, sk)
        end
    end
    return Pool[key]
end

local function hideObj(o)
    o.box.Visible = false
    o.name.Visible = false
    o.dist.Visible = false
    o.hpText.Visible = false
    o.hpBg.Visible = false
    o.hpFg.Visible = false
    o.tracer.Visible = false
    o.snapline1.Visible = false
    o.snapline2.Visible = false
    for i = 10, 19 do
        local sk = o[i]
        if sk then sk.Visible = false end
    end
end

-- ============================================================
-- CACHED ENTITY LISTS (updated 0.5s, not every frame)
-- ============================================================
local cachedPlayers = {}
local cachedLoot = {}
local cachedTCs = {}
local cachedGrass = {}
local lastEntityUpdate = 0

local function refreshEntities()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(players, { model = plr.Character, player = plr })
        end
    end

    local loot = {}
    local tcs = {}
    local grass = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("tc") or name:find("toolcupboard") or name:find("cupboard") or name:find("шкаф") or name:find("tool cupboard") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(tcs, obj)
            end
        elseif name:find("weapon") or name:find("tool") or name:find("ore") or name:find("wood") or name:find("stone") or name:find("rock") or name:find("chest") or name:find("loot") or name:find("barrel") or name:find("crate") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(loot, obj)
            end
        elseif name:find("grass") or name:find("weed") or name:find("bush") then
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                table.insert(grass, obj)
            end
        end
    end
    cachedPlayers = players
    cachedLoot = loot
    cachedTCs = tcs
    cachedGrass = grass

task.spawn(function()
    while true do
        refreshEntities()
        task.wait(0.5)
    end
end)

-- ============================================================
-- FULLBRIGHT (Lighting, not per-frame ESP)
-- ============================================================
task.spawn(function()
    while true do
        if G("Misc.Fullbright", false) then
            Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
        end
        task.wait(0.5)
    end
end)

-- ============================================================
-- MAIN RENDER LOOP (Heartbeat, throttled to 0.05s)
-- ============================================================
local lastVisualUpdate = 0
local VISUAL_INTERVAL = 0.05

local function getPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if p then return p.Position end
    end
    return nil
end

local function getPlayerParts(char)
    local head = char:FindFirstChild("Head") or char:FindFirstChild("head") or char:FindFirstChild("UpperTorso")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or head
    local hum = char:FindFirstChildOfClass("Humanoid")
    if head and hrp and hum and hum.Health > 0 then return head, hrp, hum end
    return nil
end

local function isEnemy(plr)
    if not G("Visuals.TeamCheck", true) then return true end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    return true
end

RunService.Heartbeat:Connect(function()
    if not G("Visuals.Enabled", false) then
        for _, pool in pairs(Pool) do hideObj(pool) end
        return
    end

    -- Throttle visual updates
    if tick() - lastVisualUpdate < VISUAL_INTERVAL then return end
    lastVisualUpdate = tick()

    local lpHrp = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    local maxDist = G("Visuals.MaxDistance", 1000)
    local tracerOrigin = G("Visuals.TracerOrigin", "Screen Bottom")
    local showSnaplines = G("Visuals.Snaplines", false)

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local crosshair = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

    local seen = {}
    local usedKeys = {}

    -- ===== PLAYER ESP =====
    for _, entry in ipairs(cachedPlayers) do
        local model = entry.model
        local plr = entry.player
        seen[model] = true

        if not isEnemy(plr) then
            local o = getObj(model)
            hideObj(o)
            continue
        end

        local parts = getPlayerParts(model)
        if not parts then
            local o = getObj(model)
            hideObj(o)
            continue
        end
        local head, hrp, hum = parts[1], parts[2], parts[3]

        local dist = lpHrp and (lpHrp.Position - hrp.Position).Magnitude or 0
        if dist > maxDist and dist > 0 then
            local o = getObj(model)
            hideObj(o)
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            local o = getObj(model)
            hideObj(o)
            continue
        end

        local o = getObj(model)
        usedKeys[model] = true

        local col = Color3.fromRGB(255, 60, 60)
        local label = plr.Name
        local weapon = model:FindFirstChildOfClass("Tool")
        local weaponName = weapon and weapon.Name:gsub("^%[", ""):gsub("%]$", "") or ""
        local hpText = hum and math.floor(hum.Health) .. " HP" or ""

        -- Box ESP (larger with padding)
        if G("Visuals.BoxESP", false) then
            local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
            local height = math.abs(hrpPos.Y - headPos.Y) * 2.2
            local width = height / 2.2
            local pad = 4
            o.box.Visible = true
            o.box.Color = col
            o.box.Size = Vector2.new(width, height)
            o.box.Position = Vector2.new(headPos.X - width / 2 - pad, headPos.Y - height * 0.1 - pad)
        else
            o.box.Visible = false
        end

        -- Name ESP
        if G("Visuals.NameESP", false) then
            local dn = label
            if weaponName ~= "" then dn = dn .. " [" .. weaponName .. "]" end
            if hpText ~= "" then dn = dn .. " [" .. hpText .. "]" end
            o.name.Visible = true
            o.name.Text = dn
            o.name.Color = col
            o.name.Position = Vector2.new(headPos.X, headPos.Y - 24)
        else
            o.name.Visible = false
        end

        -- Health bar + HP text
        if G("Visuals.HealthESP", false) and hum then
            local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
            local height = math.abs(hrpPos.Y - headPos.Y) * 2.2
            local frac = hum.Health / hum.MaxHealth
            o.hpBg.Visible = true
            o.hpBg.Color = Color3.fromRGB(30, 30, 30)
            o.hpBg.Size = Vector2.new(4, height)
            o.hpBg.Position = Vector2.new(headPos.X - (width or height / 2) - 10, headPos.Y)
            o.hpBg.Filled = true
            o.hpFg.Visible = true
            o.hpFg.Color = Color3.fromRGB(60, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), 1 - frac)
            o.hpFg.Size = Vector2.new(4, height * frac)
            o.hpFg.Position = Vector2.new(headPos.X - (width or height / 2) - 10, headPos.Y + height * (1 - frac))
            o.hpFg.Filled = true

            -- HP text below box
            o.hpText.Visible = true
            o.hpText.Text = hpText
            o.hpText.Color = col
            o.hpText.Position = Vector2.new(headPos.X, headPos.Y + height / 2 + 2)
        else
            o.hpBg.Visible = false
            o.hpFg.Visible = false
            o.hpText.Visible = false
        end

        -- Tracers
        if G("Visuals.Tracers", false) then
            local fromPos = screenBottom
            if tracerOrigin == "Crosshair" then fromPos = crosshair
            elseif tracerOrigin == "Screen Center" then fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) end
            o.tracer.Visible = true
            o.tracer.From = fromPos
            o.tracer.To = Vector2.new(headPos.X, headPos.Y)
            local ratio = math.clamp(dist / maxDist, 0, 1)
            o.tracer.Color = Color3.fromRGB(60, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), ratio)
        else
            o.tracer.Visible = false
        end

        -- Snaplines
        if showSnaplines then
            o.snapline1.Visible = true
            o.snapline1.From = Vector2.new(screenCenter.X, 0)
            o.snapline1.To = Vector2.new(headPos.X, headPos.Y)
            o.snapline1.Color = col
            o.snapline2.Visible = true
            o.snapline2.From = Vector2.new(screenCenter.X, Camera.ViewportSize.Y)
            o.snapline2.To = Vector2.new(headPos.X, headPos.Y)
            o.snapline2.Color = col
        else
            o.snapline1.Visible = false
            o.snapline2.Visible = false
        end

        -- Distance
        if G("Visuals.DistanceESP", true) then
            o.dist.Visible = true
            o.dist.Text = math.floor(dist) .. "m"
            o.dist.Color = col
            o.dist.Position = Vector2.new(headPos.X, headPos.Y - 40)
        else
            o.dist.Visible = false
        end
    end

    -- ===== LOOT ESP =====
    if G("Visuals.LootESP", false) then
        for _, obj in ipairs(cachedLoot) do
            local objPos = getPos(obj)
            if objPos then
                local dist = lpHrp and (lpHrp.Position - objPos).Magnitude or 0
                if dist <= maxDist then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(objPos)
                    if onScreen and screenPos.Z > 0 then
                        local key = "Loot_" .. tostring(obj)
                        seen[obj] = true
                        local o = getObj(key)
                        usedKeys[key] = true

                        local col = Color3.fromRGB(255, 200, 60)
                        local size = Vector2.new(24, 24)
                        o.box.Visible = true
                        o.box.Color = col
                        o.box.Size = size
                        o.box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)

                        o.name.Visible = true
                        o.name.Text = obj.Name
                        o.name.Color = col
                        o.name.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
                        o.dist.Visible = false
                        o.tracer.Visible = false
                        o.hpBg.Visible = false
                        o.hpFg.Visible = false
                        o.hpText.Visible = false
                        o.snapline1.Visible = false
                        o.snapline2.Visible = false
                    end
                end
            end
        end
    end

    -- ===== TC / BUILDING ESP =====
    if G("Visuals.BuildingESP", false) then
        local tcColor = Color3.fromRGB(200, 100, 255)
        for _, tc in ipairs(cachedTCs) do
            local tcPos = getPos(tc)
            if tcPos then
                local dist = lpHrp and (lpHrp.Position - tcPos).Magnitude or 0
                if dist <= maxDist then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(tcPos)
                    if onScreen and screenPos.Z > 0 then
                        local key = "TC_" .. tostring(tc)
                        seen[tc] = true
                        local o = getObj(key)
                        usedKeys[key] = true

                        -- Try to get owner name
                        local ownerName = ""
                        local ownerAttr = tc:GetAttribute("Owner")
                        if ownerAttr then ownerName = tostring(ownerAttr)
                        else
                            local sv = tc:FindFirstChildOfClass("StringValue")
                            if sv and sv.Name:lower():find("owner") then ownerName = sv.Value end
                        end

                        local size = Vector2.new(40, 60)
                        o.box.Visible = true
                        o.box.Color = tcColor
                        o.box.Size = size
                        o.box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)

                        local label = "TC"
                        if ownerName ~= "" then label = label .. " [" .. ownerName .. "]" end
                        label = label .. " [" .. math.floor(dist) .. "m]"
                        o.name.Visible = true
                        o.name.Text = label
                        o.name.Color = tcColor
                        o.name.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 16)

                        o.dist.Visible = false
                        o.tracer.Visible = false
                        o.hpBg.Visible = false
                        o.hpFg.Visible = false
                        o.hpText.Visible = false
                        o.snapline1.Visible = false
                        o.snapline2.Visible = false
                    end
                end
            end
        end
    end

    -- ===== NO GRASS =====
    if G("Visuals.NoGrass", false) then
        for _, obj in ipairs(cachedGrass) do
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.Transparency = 1
                    obj.CanCollide = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end)
        end
    end

    -- ===== SKELETON ESP =====
    if G("Visuals.SkeletonESP", false) then
        local skelColor = Color3.fromRGB(0, 255, 255)
        for _, entry in ipairs(cachedPlayers) do
            local model = entry.model
            local plr = entry.player
            if not isEnemy(plr) then
                local o = getObj(model)
                for i = 10, 19 do o[i].Visible = false end
                continue
            end
            local head = model:FindFirstChild("Head") or model:FindFirstChild("head")
            local upperTorso = model:FindFirstChild("UpperTorso")
            local lowerTorso = model:FindFirstChild("LowerTorso") or model:FindFirstChild("Torso")
            local leftArm = model:FindFirstChild("Left Arm") or model:FindFirstChild("LeftUpperArm")
            local rightArm = model:FindFirstChild("Right Arm") or model:FindFirstChild("RightUpperArm")
            local leftLeg = model:FindFirstChild("Left Leg") or model:FindFirstChild("LeftUpperLeg")
            local rightLeg = model:FindFirstChild("Right Leg") or model:FindFirstChild("RightUpperLeg")
            if not head or not upperTorso then
                local o = getObj(model)
                for i = 10, 19 do o[i].Visible = false end
                continue
            end

            local o = getObj(model)
            usedKeys[model] = true

            local function w2p(part)
                if not part then return nil end
                local sp, on = Camera:WorldToViewportPoint(part.Position)
                return on and sp.Z > 0 and sp or nil
            end

            local h, ut, lt, la, ra, ll, rl = w2p(head), w2p(upperTorso), w2p(lowerTorso), w2p(leftArm), w2p(rightArm), w2p(leftLeg), w2p(rightLeg)
            if not h or not ut then
                for i = 10, 19 do o[i].Visible = false end
                continue
            end

            local sk = {
                {h, ut},          -- Head -> UpperTorso
                {ut, lt},         -- UpperTorso -> LowerTorso
                {ut, la},         -- UpperTorso -> LeftArm
                {ut, ra},         -- UpperTorso -> RightArm
                {lt, ll},         -- LowerTorso -> LeftLeg
                {lt, rl},         -- LowerTorso -> RightLeg
                {la, la},         -- placeholder
                {ra, ra},         -- placeholder
                {ll, ll},         -- placeholder
                {rl, rl},         -- placeholder
            }
            for i = 1, 6 do
                local line = o[i + 9] -- indices 10-19
                local a, b = sk[i][1], sk[i][2]
                if a and b then
                    line.Visible = true
                    line.Color = skelColor
                    line.From = a
                    line.To = b
                else
                    line.Visible = false
                end
            end
        end
    end

    -- Cleanup unused pool entries
    for key, o in pairs(Pool) do
        if not usedKeys[key] then
            hideObj(o)
        end
    end
end)

-- Cleanup on player leave
Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        local o = Pool[plr.Character]
        if o then hideObj(o) end
    end
end)

print("[KIRO VISUALS] Loaded (Object Pool + Throttled + Player Filter + Loot/TC/Skeleton ESP + NoGrass + Hitmarker). Game: " .. (K.GameId or "unknown"))
return K