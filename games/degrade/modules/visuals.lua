-- visuals.lua | Kiro Scripts — ESP (Drawing based)
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

if not Drawing then
    warn("[KIRO VISUALS] Drawing API not available!")
    return
end

local ENEMY_COLOR = Color3.fromRGB(255, 60, 60)
local FRIEND_COLOR = Color3.fromRGB(90, 200, 255)
local LOOT_COLOR = Color3.fromRGB(255, 200, 60)
local TC_COLOR = Color3.fromRGB(200, 100, 255)

local Pool = {}
local function newObj(t)
    local o = Drawing.new(t)
    o.Visible = false
    o.Thickness = 2
    o.Transparency = 1
    return o
end

local MAX_SKEL = 10

local function getObj(key)
    if not Pool[key] then
        Pool[key] = {
            box = newObj("Square"),
            chams = newObj("Square"),
            name = newObj("Text"),
            dist = newObj("Text"),
            hpText = newObj("Text"),
            hpBg = newObj("Square"),
            hpFg = newObj("Square"),
            tracer = newObj("Line"),
            snapline1 = newObj("Line"),
            snapline2 = newObj("Line"),
            skel = {},
        }
        local o = Pool[key]
        o.name.Size = 13
        o.name.Center = true
        o.name.Outline = true
        o.name.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.dist.Size = 12
        o.dist.Center = true
        o.dist.Outline = true
        o.dist.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.hpText.Size = 12
        o.hpText.Center = true
        o.hpText.Outline = true
        o.hpText.OutlineColor = Color3.fromRGB(0, 0, 0)
        o.tracer.Thickness = 2
        o.snapline1.Thickness = 1.5
        o.snapline2.Thickness = 1.5
        o.hpBg.Filled = true
        o.hpFg.Filled = true
        o.chams.Filled = true
        for i = 1, MAX_SKEL do
            local sk = newObj("Line")
            sk.Thickness = 1
            sk.Transparency = 0.85
            o.skel[i] = sk
        end
    end
    return Pool[key]
end

local function hideObj(o)
    if not o then return end
    o.box.Visible = false
    o.chams.Visible = false
    o.name.Visible = false
    o.dist.Visible = false
    o.hpText.Visible = false
    o.hpBg.Visible = false
    o.hpFg.Visible = false
    o.tracer.Visible = false
    o.snapline1.Visible = false
    o.snapline2.Visible = false
    for i = 1, MAX_SKEL do
        local sk = o.skel[i]
        if sk then sk.Visible = false end
    end
end

local function hideKey(key)
    local o = Pool[key]
    if o then hideObj(o) end
end

-- ============ ENTITY CACHE ============
local cachedPlayers, cachedLoot, cachedTCs, cachedGrass = {}, {}, {}, {}

-- DEGRADE (Rust clone) entity keywords
local KW_CUPBOARD = { "cupboard", "toolcupboard", "buildingprivilege", "building_privilege", "privilege" }
local KW_LOOT     = { "crate", "barrel", "loot", "chest", "trash", "supply", "box", "locker" }
local KW_FOLIAGE  = { "grass", "weed", "bush", "fern", "plant", "foliage", "shrub", "ivy" }

local function nameHas(name, list)
    for _, k in ipairs(list) do
        if name:find(k, 1, true) then return true end
    end
    return false
end

local function refreshPlayers()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if not char then
                char = workspace:FindFirstChild(plr.Name)
            end
            if char and (char:IsA("Model") or char:IsA("BasePart")) then
                table.insert(players, { model = char, player = plr })
            end
        end
    end
    cachedPlayers = players
end

local function refreshWorld()
    local loot, tcs, grass = {}, {}, {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if nameHas(name, KW_CUPBOARD) then
            if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(tcs, obj) end
        elseif nameHas(name, KW_LOOT) then
            if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(loot, obj) end
        elseif nameHas(name, KW_FOLIAGE) then
            if obj:IsA("BasePart") then table.insert(grass, obj) end
        end
    end
    cachedLoot, cachedTCs, cachedGrass = loot, tcs, grass
end

-- players: fast tick (respawns must appear quickly)
task.spawn(function()
    while true do
        refreshPlayers()
        task.wait(0.5)
    end
end)

-- world geometry: slow tick, GetDescendants() is the expensive part
task.spawn(function()
    while true do
        refreshWorld()
        task.wait(3)
    end
end)

local function getPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if p then return p.Position end
    end
    return nil
end

local function getPlayerParts(char)
    -- if char is a BasePart (rare but possible), use it directly
    if char:IsA("BasePart") then
        return char, char, nil
    end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("head")
        or char:FindFirstChild("UpperTorso") or char:FindFirstChild("uppertorso")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("humanoidrootpart")
        or char:FindFirstChild("Torso") or char:FindFirstChild("torso")
        or char:FindFirstChild("RootPart") or head
    local hum = char:FindFirstChildOfClass("Humanoid")

    local alive = true
    if hum then
        alive = hum.Health > 0
    else
        local attrHp = char:GetAttribute("Health") or char:GetAttribute("HP") or char:GetAttribute("Hp")
        if type(attrHp) == "number" then
            alive = attrHp > 0
        end
    end

    if head and hrp and alive then return head, hrp, hum end
    return nil
end

local function isEnemy(plr)
    if not G("Combat.TeamCheck", true) then return true end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

-- bone pairs, resolved per rig
local R15_BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
}
local R6_BONES = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

local boneCache = {}
local function getBones(char)
    local cached = boneCache[char]
    if cached then return cached end

    local bones = {}
    local def = (char:FindFirstChild("UpperTorso") and R15_BONES) or R6_BONES
    for _, pair in ipairs(def) do
        local a = char:FindFirstChild(pair[1])
        local b = char:FindFirstChild(pair[2])
        if a and b then table.insert(bones, { a, b }) end
    end
    if #bones == 0 then bones = nil end
    boneCache[char] = bones
    return bones
end

-- ============ MAIN LOOP ============
RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    if not Camera then return end

    if not G("Visuals.Enabled", false) then
        for _, o in pairs(Pool) do hideObj(o) end
        return
    end

    local lpHrp = LocalPlayer.Character
        and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    if not lpHrp then
        for _, o in pairs(Pool) do hideObj(o) end
        return
    end

    local maxDist = tonumber(G("Visuals.MaxDistance", 1000)) or 1000
    local tracerOrigin = G("Visuals.TracerOrigin", "Screen Bottom")
    local showSnaplines = G("Visuals.Snaplines", false)
    local showBox = G("Visuals.BoxESP", false)
    local showName = G("Visuals.NameESP", false)
    local showHealth = G("Visuals.HealthESP", false)
    local showTracer = G("Visuals.Tracers", false)
    local showDist = G("Visuals.DistanceESP", true)
    local showSkel = G("Visuals.SkeletonESP", false)
    local showChams = G("Visuals.Chams", false)
    local showWeapon = G("Visuals.WeaponESP", false)

    local vp = Camera.ViewportSize
    local mouse = UserInputService:GetMouseLocation()
    local crosshair = Vector2.new(mouse.X, mouse.Y)
    local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)
    local screenBottom = Vector2.new(vp.X / 2, vp.Y)

    local usedKeys = {}

    -- ---------- PLAYERS ----------
    for _, entry in ipairs(cachedPlayers) do
        local model = entry.model
        local plr = entry.player

        local head, hrp, hum = getPlayerParts(model)
        if not head or not hrp or not hum or not isEnemy(plr) then
            hideKey(model)
            continue
        end

        local dist = (lpHrp.Position - hrp.Position).Magnitude
        if dist > maxDist then
            hideKey(model)
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            hideKey(model)
            continue
        end

        local o = getObj(model)
        usedKeys[model] = true
        local col = ENEMY_COLOR

        -- box geometry computed ONCE (health bar and skeleton reuse it)
        local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
        local height = math.max(math.abs(hrpPos.Y - headPos.Y) * 2.1, 8)
        local width = height * 0.45
        local topY = headPos.Y - height * 0.08
        local leftX = headPos.X - width / 2

        if showBox then
            o.box.Visible = true
            o.box.Color = col
            o.box.Size = Vector2.new(width, height)
            o.box.Position = Vector2.new(leftX, topY)
        else
            o.box.Visible = false
        end

        if showChams then
            o.chams.Visible = true
            o.chams.Color = col
            o.chams.Size = Vector2.new(width, height)
            o.chams.Position = Vector2.new(leftX, topY)
            o.chams.Transparency = 0.72
        else
            o.chams.Visible = false
        end

        if showName then
            local label = plr.Name
            if showWeapon then
                local weapon = model:FindFirstChildOfClass("Tool")
                local wName = weapon and weapon.Name:gsub("^%[", ""):gsub("%]$", "") or ""
                if wName ~= "" then label = label .. " [" .. wName .. "]" end
            end
            o.name.Visible = true
            o.name.Text = label
            o.name.Color = col
            o.name.Position = Vector2.new(headPos.X, topY - 14)
        else
            o.name.Visible = false
        end

        if showDist then
            o.dist.Visible = true
            o.dist.Text = math.floor(dist) .. "m"
            o.dist.Color = col
            o.dist.Position = Vector2.new(headPos.X, topY + height + 8)
        else
            o.dist.Visible = false
        end

        if showHealth then
            local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            o.hpBg.Visible = true
            o.hpBg.Color = Color3.fromRGB(25, 25, 25)
            o.hpBg.Size = Vector2.new(4, height)
            o.hpBg.Position = Vector2.new(leftX - 8, topY)
            o.hpFg.Visible = true
            o.hpFg.Color = Color3.fromRGB(60, 255, 120):Lerp(ENEMY_COLOR, 1 - frac)
            o.hpFg.Size = Vector2.new(4, height * frac)
            o.hpFg.Position = Vector2.new(leftX - 8, topY + height * (1 - frac))
            o.hpText.Visible = true
            o.hpText.Text = math.floor(hum.Health) .. " HP"
            o.hpText.Color = col
            o.hpText.Position = Vector2.new(headPos.X, topY + height + 22)
        else
            o.hpBg.Visible = false
            o.hpFg.Visible = false
            o.hpText.Visible = false
        end

        if showTracer then
            local fromPos = screenBottom
            if tracerOrigin == "Crosshair" then
                fromPos = crosshair
            elseif tracerOrigin == "Screen Center" then
                fromPos = screenCenter
            end
            o.tracer.Visible = true
            o.tracer.From = fromPos
            o.tracer.To = Vector2.new(headPos.X, headPos.Y)
            local ratio = math.clamp(dist / math.max(maxDist, 1), 0, 1)
            o.tracer.Color = Color3.fromRGB(60, 255, 120):Lerp(ENEMY_COLOR, ratio)
        else
            o.tracer.Visible = false
        end

        if showSnaplines then
            o.snapline1.Visible = true
            o.snapline1.From = Vector2.new(vp.X / 2, 0)
            o.snapline1.To = Vector2.new(headPos.X, headPos.Y)
            o.snapline1.Color = col
            o.snapline2.Visible = true
            o.snapline2.From = Vector2.new(vp.X / 2, vp.Y)
            o.snapline2.To = Vector2.new(headPos.X, headPos.Y)
            o.snapline2.Color = col
        else
            o.snapline1.Visible = false
            o.snapline2.Visible = false
        end

        if showSkel then
            local bones = getBones(model)
            if bones then
                local n = math.min(#bones, MAX_SKEL)
                for i = 1, n do
                    local pair = bones[i]
                    local a, aOn = Camera:WorldToViewportPoint(pair[1].Position)
                    local b, bOn = Camera:WorldToViewportPoint(pair[2].Position)
                    local line = o.skel[i]
                    if aOn and bOn and a.Z > 0 and b.Z > 0 then
                        line.Visible = true
                        line.From = Vector2.new(a.X, a.Y)
                        line.To = Vector2.new(b.X, b.Y)
                        line.Color = col
                        line.Transparency = 0.85
                    else
                        line.Visible = false
                    end
                end
                for i = n + 1, MAX_SKEL do
                    o.skel[i].Visible = false
                end
            else
                for i = 1, MAX_SKEL do o.skel[i].Visible = false end
            end
        else
            for i = 1, MAX_SKEL do o.skel[i].Visible = false end
        end
    end

    -- ---------- DEGRADE ENTITIES ----------
    if K.GameId == "degrade" then
        if G("Visuals.LootESP", false) then
            for _, obj in ipairs(cachedLoot) do
                local objPos = getPos(obj)
                if objPos then
                    local dist = (lpHrp.Position - objPos).Magnitude
                    if dist <= maxDist then
                        local sp, on = Camera:WorldToViewportPoint(objPos)
                        if on and sp.Z > 0 then
                            local key = "Loot_" .. tostring(obj)
                            local o = getObj(key)
                            usedKeys[key] = true
                            o.box.Visible = true
                            o.box.Color = LOOT_COLOR
                            o.box.Size = Vector2.new(24, 24)
                            o.box.Position = Vector2.new(sp.X - 12, sp.Y - 12)
                            o.name.Visible = true
                            o.name.Text = obj.Name
                            o.name.Color = LOOT_COLOR
                            o.name.Position = Vector2.new(sp.X, sp.Y - 16)
                            o.dist.Visible = false
                            o.tracer.Visible = false
                            o.snapline1.Visible = false
                            o.snapline2.Visible = false
                            o.chams.Visible = false
                            o.hpBg.Visible = false
                            o.hpFg.Visible = false
                            o.hpText.Visible = false
                        end
                    end
                end
            end
        end

        if G("Visuals.BuildingESP", false) then
            for _, tc in ipairs(cachedTCs) do
                local tcPos = getPos(tc)
                if tcPos then
                    local dist = (lpHrp.Position - tcPos).Magnitude
                    if dist <= maxDist then
                        local sp, on = Camera:WorldToViewportPoint(tcPos)
                        if on and sp.Z > 0 then
                            local key = "TC_" .. tostring(tc)
                            local o = getObj(key)
                            usedKeys[key] = true
                            local size = Vector2.new(40, 60)
                            o.box.Visible = true
                            o.box.Color = TC_COLOR
                            o.box.Size = size
                            o.box.Position = Vector2.new(sp.X - size.X / 2, sp.Y - size.Y / 2)
                            local label = "TC"
                            local owner = tc:GetAttribute("Owner")
                            if owner then label = label .. " [" .. tostring(owner) .. "]" end
                            label = label .. " [" .. math.floor(dist) .. "m]"
                            o.name.Visible = true
                            o.name.Text = label
                            o.name.Color = TC_COLOR
                            o.name.Position = Vector2.new(sp.X, sp.Y - size.Y / 2 - 16)
                            o.dist.Visible = false
                            o.tracer.Visible = false
                            o.snapline1.Visible = false
                            o.snapline2.Visible = false
                            o.chams.Visible = false
                            o.hpBg.Visible = false
                            o.hpFg.Visible = false
                            o.hpText.Visible = false
                        end
                    end
                end
            end
        end

        if G("Visuals.NoGrass", false) then
            for _, obj in ipairs(cachedGrass) do
                pcall(function()
                    obj.Transparency = 1
                    obj.CanCollide = false
                end)
            end
        end
    end

    -- ---------- cleanup ----------
    for key, o in pairs(Pool) do
        if not usedKeys[key] then hideObj(o) end
    end
end)

-- clear bone cache when characters are removed
Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then boneCache[plr.Character] = nil end
end)

print("[KIRO VISUALS] Loaded. Game: " .. (K.GameId or "unknown"))
return K