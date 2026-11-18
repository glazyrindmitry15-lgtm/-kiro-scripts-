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
            headDot = newObj("Circle"),
            offscreen = newObj("Circle"),
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
        o.headDot.Radius = 3
        o.headDot.Filled = true
        o.headDot.Thickness = 1
        o.offscreen.Radius = 6
        o.offscreen.Filled = true
        o.offscreen.Thickness = 1
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
    o.headDot.Visible = false
    o.offscreen.Visible = false
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

-- ============ 3D HIGHLIGHT POOL (raid targets) ============
-- Highlight instances glow through walls, which is what makes a cupboard
-- actually findable. A plain 2D box does not tell you where the base is.
local hlFolder = Instance.new("Folder")
hlFolder.Name = "KiroHighlights"
hlFolder.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local MAX_HL = 24
local hlPool = {}

local function getHighlight(idx)
    local h = hlPool[idx]
    if not h then
        h = Instance.new("Highlight")
        h.FillTransparency = 0.92
        h.OutlineTransparency = 0.05
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = nil
        h.Parent = hlFolder
        hlPool[idx] = h
    end
    return h
end

local function clearHighlights(fromIndex)
    for i = fromIndex, #hlPool do
        pcall(function() hlPool[i].Adornee = nil end)
    end
end

-- Player chams: real 3D highlight, visible through walls
local chamsPool = {}

local function getCham(idx)
    local h = chamsPool[idx]
    if not h then
        h = Instance.new("Highlight")
        h.FillTransparency = 0.6
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = nil
        h.Parent = hlFolder
        chamsPool[idx] = h
    end
    return h
end

local function clearChams(fromIndex)
    for i = fromIndex, #chamsPool do
        pcall(function() chamsPool[i].Adornee = nil end)
    end
end

-- ============ ENTITY CACHE ============
local cachedPlayers, cachedLoot, cachedTCs, cachedGrass = {}, {}, {}, {}
local cachedGens, cachedChests = {}, {}

-- ============ ROBUST PLAYER RESOLUTION ============
-- Some games never set plr.Character and store characters in custom folders
-- under GUIDs. This tries every known strategy, then falls back to a deep
-- index of every Model in the DataModel.
local containers = {}
local nameIndex = {}
local lastIndexBuild = 0

local function refreshContainers()
    local list = {}
    for _, n in ipairs({ "Players", "Entities", "Characters", "NPCs", "NPC", "Mobs", "Units", "Actors" }) do
        local c = workspace:FindFirstChild(n)
        if c then list[#list + 1] = c end
    end
    containers = list
end

local function rebuildIndex()
    nameIndex = {}
    for _, m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Model") then
            local n = m.Name:lower()
            if n ~= "" and nameIndex[n] == nil then
                nameIndex[n] = m
            end
        end
    end
    lastIndexBuild = tick()
end

local function ensureIndex()
    if #nameIndex == 0 or (tick() - lastIndexBuild) > 10 then
        pcall(rebuildIndex)
    end
end

refreshContainers()

local charCache = {}

local function isCharLike(v)
    return typeof(v) == "Instance" and v.Parent ~= nil and (v:IsA("Model") or v:IsA("BasePart"))
end

local function findByAttribute(root, uid)
    for _, m in ipairs(root:GetDescendants()) do
        if m:IsA("Model") or m:IsA("BasePart") then
            local attr = m:GetAttribute("UserId")
                or m:GetAttribute("PlayerUserId")
                or m:GetAttribute("userid")
                or m:GetAttribute("UserID")
            if attr == uid then return m end

            local pref = m:GetAttribute("Player") or m:GetAttribute("Owner")
            if typeof(pref) == "Instance" then
                local ok, val = pcall(function() return pref.Value end)
                if ok and val then return m end
            end
        end
    end
    return nil
end

local function resolveCharacter(plr)
    local cached = charCache[plr]
    if cached == false then return nil end
    if isCharLike(cached) then return cached end

    -- 1) standard Roblox character
    local char = plr.Character
    if isCharLike(char) then
        charCache[plr] = char
        return char
    end

    -- 2) by name inside known containers
    for _, c in ipairs(containers) do
        local m = c:FindFirstChild(plr.Name)
        if isCharLike(m) then
            charCache[plr] = m
            return m
        end
    end

    -- 3) model parented straight to workspace under the player's name
    local direct = workspace:FindFirstChild(plr.Name)
    if isCharLike(direct) then
        charCache[plr] = direct
        return direct
    end

    -- 4) by UserId / Player attribute anywhere
    local uid = plr.UserId
    if uid then
        local byAttr = findByAttribute(workspace, uid)
        if byAttr then
            charCache[plr] = byAttr
            return byAttr
        end
    end

    -- 5) deep name index (exact, then substring, then DisplayName)
    ensureIndex()
    local target = (plr.Name or ""):lower()
    local display = (plr.DisplayName or ""):lower()

    if nameIndex[target] and isCharLike(nameIndex[target]) then
        charCache[plr] = nameIndex[target]
        return nameIndex[target]
    end

    for n, m in pairs(nameIndex) do
        if target ~= "" and (n:find(target, 1, true) or target:find(n, 1, true)) then
            if isCharLike(m) then
                charCache[plr] = m
                return m
            end
        elseif display ~= "" and (n:find(display, 1, true) or display:find(n, 1, true)) then
            if isCharLike(m) then
                charCache[plr] = m
                return m
            end
        end
    end

    charCache[plr] = false
    task.delay(8, function() charCache[plr] = nil end)
    return nil
end

local function refreshPlayers()
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
end

-- shared with aimbot.lua so both use identical resolution
K.ResolveCharacter = resolveCharacter

local function refreshWorld()
    -- no full DataModel sweep unless a world ESP feature is actually on
    local needLoot = G("Visuals.LootESP", false)
    local needTC = G("Visuals.BuildingESP", false)
    local needGrass = G("Visuals.NoGrass", false)
    local needGen = G("Visuals.GeneratorESP", false)
    local needChest = G("Visuals.ChestESP", false)

    if not needLoot and not needTC and not needGrass and not needGen and not needChest then
        cachedLoot, cachedTCs, cachedGrass, cachedGens, cachedChests = {}, {}, {}, {}, {}
        return
    end

    local loot, tcs, grass, gens, chests = {}, {}, {}, {}, {}
    local survival = (K.GameId == "fust" or K.GameId == "trident_survival")
    local valiant = (K.GameId == "valiant_district")

    if survival or valiant then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()

            if needTC and (name:find("tc") or name:find("toolcupboard") or name:find("cupboard")) then
                if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(tcs, obj) end
            elseif needChest and (name:find("chest") or name:find("crate")) then
                if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(chests, obj) end
            elseif needGen and (name:find("generator") or name:find("gen")) then
                if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(gens, obj) end
            elseif needLoot and (name:find("weapon") or name:find("ore") or name:find("wood")
                or name:find("chest") or name:find("loot")) then
                if obj:IsA("Model") or obj:IsA("BasePart") then table.insert(loot, obj) end
            elseif needGrass and (name:find("grass") or name:find("weed") or name:find("bush")) then
                if obj:IsA("BasePart") then table.insert(grass, obj) end
            end
        end
    end

    cachedLoot, cachedTCs, cachedGrass = loot, tcs, grass
    cachedGens, cachedChests = gens, chests
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
        task.wait(4)
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

-- cache head/hrp/humanoid per character: this ran 3 FindFirstChild per player
-- per frame, which is thousands of calls per second with a full server
local partsCache = {}

local function getPlayerParts(char)
    -- if char is a BasePart (rare but possible), use it directly
    if char:IsA("BasePart") then
        return char, char, nil
    end

    local cached = partsCache[char]
    if cached and cached.head.Parent and cached.hrp.Parent then
        local hum = cached.hum
        local alive = true
        if hum and hum.Parent then
            alive = hum.Health > 0
        else
            local attrHp = char:GetAttribute("Health") or char:GetAttribute("HP") or char:GetAttribute("Hp")
            if type(attrHp) == "number" then alive = attrHp > 0 end
        end
        if alive then return cached.head, cached.hrp, hum end
        return nil
    end

    local head = char:FindFirstChild("Head") or char:FindFirstChild("head")
        or char:FindFirstChild("UpperTorso") or char:FindFirstChild("uppertorso")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("humanoidrootpart")
        or char:FindFirstChild("Torso") or char:FindFirstChild("torso")
        or char:FindFirstChild("RootPart") or head
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- CS:GO and other games often replace the Humanoid with a custom health
    -- system. Do not require a Humanoid to draw ESP: fall back to attributes.
    local alive = true
    if hum then
        alive = hum.Health > 0
    else
        local attrHp = char:GetAttribute("Health") or char:GetAttribute("HP") or char:GetAttribute("Hp")
        if type(attrHp) == "number" then
            alive = attrHp > 0
        end
    end

    if head and hrp and alive then
        partsCache[char] = { head = head, hrp = hrp, hum = hum }
        return head, hrp, hum
    end
    return nil
end

local function isEnemy(plr)
    if not G("Combat.TeamCheck", true) then return true end
    -- standard Roblox Team
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    -- CS:GO and other games often use attributes instead of Team objects
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
        clearChams(1)
        return
    end

    local lpHrp = LocalPlayer.Character
        and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    if not lpHrp then
        for _, o in pairs(Pool) do hideObj(o) end
        clearChams(1)
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
    local chamIdx = 0

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

        -- off-screen indicator: point toward enemies outside the view
        if not onScreen or headPos.Z <= 0 then
            if G("Visuals.Offscreen", true) then
                local o = getObj(model)
                usedKeys[model] = true
                hideObj(o)

                local dir = Vector2.new(headPos.X - vp.X / 2, headPos.Y - vp.Y / 2)
                if headPos.Z < 0 then dir = -dir end
                if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end
                dir = dir.Unit

                local edge = math.min(vp.X, vp.Y) / 2 - 14
                o.offscreen.Visible = true
                o.offscreen.Position = Vector2.new(vp.X / 2, vp.Y / 2) + dir * edge
                o.offscreen.Color = ENEMY_COLOR
            else
                hideKey(model)
            end
            continue
        end

        local o = getObj(model)
        usedKeys[model] = true
        local col = ENEMY_COLOR

        -- head dot: much easier to track a target than a box corner
        if G("Visuals.HeadDot", true) then
            o.headDot.Visible = true
            o.headDot.Position = Vector2.new(headPos.X, headPos.Y)
            o.headDot.Color = col
        else
            o.headDot.Visible = false
        end
        o.offscreen.Visible = false

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
            chamIdx += 1
            local h = getCham(chamIdx)
            if h then
                h.Adornee = model
                h.FillColor = col
                h.OutlineColor = col
            end
            o.chams.Visible = false
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

    -- ---------- FUST ENTITIES ----------
    if K.GameId == "fust" or K.GameId == "trident_survival" or K.GameId == "valiant_district" then
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
            local tcColor = Color3.fromRGB(200, 100, 255)
            local hlIdx = 0
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

                            -- 3D highlight through walls
                            hlIdx += 1
                            if hlIdx <= MAX_HL then
                                local h = getHighlight(hlIdx)
                                if h then
                                    h.Adornee = tc
                                    h.FillColor = tcColor
                                    h.OutlineColor = tcColor
                                end
                            end

                            local size = Vector2.new(40, 60)
                            o.box.Visible = true
                            o.box.Color = tcColor
                            o.box.Size = size
                            o.box.Position = Vector2.new(sp.X - size.X / 2, sp.Y - size.Y / 2)
                            local label = "CUPBOARD"
                            local owner = tc:GetAttribute("Owner")
                            if owner then label = label .. " [" .. tostring(owner) .. "]" end
                            label = label .. " [" .. math.floor(dist) .. "m]"
                            o.name.Visible = true
                            o.name.Text = label
                            o.name.Color = tcColor
                            o.name.Position = Vector2.new(sp.X, sp.Y - size.Y / 2 - 16)
                            o.dist.Visible = false
                            o.tracer.Visible = false
                            o.snapline1.Visible = false
                            o.snapline2.Visible = false
                            o.chams.Visible = false
                            o.headDot.Visible = false
                            o.offscreen.Visible = false
                            o.hpBg.Visible = false
                            o.hpFg.Visible = false
                            o.hpText.Visible = false
                        end
                    end
                end
            end
            clearHighlights(hlIdx + 1)
        else
            clearHighlights(1)
        end

        if G("Visuals.NoGrass", false) then
            for _, obj in ipairs(cachedGrass) do
                pcall(function()
                    obj.Transparency = 1
                    obj.CanCollide = false
                end)
            end
        end

        -- Generators (Valiant): 3D highlight + box so you know what to repair
        if G("Visuals.GeneratorESP", false) then
            local genColor = Color3.fromRGB(80, 220, 200)
            local hlIdx = 0
            for _, gen in ipairs(cachedGens) do
                local gp = getPos(gen)
                if gp then
                    local dist = (lpHrp.Position - gp).Magnitude
                    if dist <= maxDist then
                        local sp, on = Camera:WorldToViewportPoint(gp)
                        if on and sp.Z > 0 then
                            hlIdx += 1
                            if hlIdx <= MAX_HL then
                                local h = getHighlight(hlIdx)
                                if h then
                                    h.Adornee = gen
                                    h.FillColor = genColor
                                    h.OutlineColor = genColor
                                end
                            end

                            local key = "GEN_" .. tostring(gen)
                            local o = getObj(key)
                            usedKeys[key] = true
                            o.box.Visible = true
                            o.box.Color = genColor
                            o.box.Size = Vector2.new(30, 30)
                            o.box.Position = Vector2.new(sp.X - 15, sp.Y - 15)
                            o.name.Visible = true
                            o.name.Text = "GENERATOR [" .. math.floor(dist) .. "m]"
                            o.name.Color = genColor
                            o.name.Position = Vector2.new(sp.X, sp.Y - 30)
                            o.dist.Visible = false
                            o.tracer.Visible = false
                            o.snapline1.Visible = false
                            o.snapline2.Visible = false
                            o.chams.Visible = false
                            o.headDot.Visible = false
                            o.offscreen.Visible = false
                            o.hpBg.Visible = false
                            o.hpFg.Visible = false
                            o.hpText.Visible = false
                        end
                    end
                end
            end
            clearHighlights(hlIdx + 1)
        end

        -- Chests (Trident): raid targets drawn separately from generic loot
        if G("Visuals.ChestESP", false) then
            local chestColor = Color3.fromRGB(255, 160, 60)
            for _, ch in ipairs(cachedChests) do
                local cp = getPos(ch)
                if cp then
                    local dist = (lpHrp.Position - cp).Magnitude
                    if dist <= maxDist then
                        local sp, on = Camera:WorldToViewportPoint(cp)
                        if on and sp.Z > 0 then
                            local key = "CHEST_" .. tostring(ch)
                            local o = getObj(key)
                            usedKeys[key] = true
                            o.box.Visible = true
                            o.box.Color = chestColor
                            o.box.Size = Vector2.new(26, 26)
                            o.box.Position = Vector2.new(sp.X - 13, sp.Y - 13)
                            o.name.Visible = true
                            o.name.Text = "CHEST [" .. math.floor(dist) .. "m]"
                            o.name.Color = chestColor
                            o.name.Position = Vector2.new(sp.X, sp.Y - 28)
                            o.dist.Visible = false
                            o.tracer.Visible = false
                            o.snapline1.Visible = false
                            o.snapline2.Visible = false
                            o.chams.Visible = false
                            o.headDot.Visible = false
                            o.offscreen.Visible = false
                            o.hpBg.Visible = false
                            o.hpFg.Visible = false
                            o.hpText.Visible = false
                        end
                    end
                end
            end
        end
    end

    -- ---------- cleanup ----------
    for key, o in pairs(Pool) do
        if not usedKeys[key] then hideObj(o) end
    end

    -- release chams that are no longer used (and when ESP is off)
    if not G("Visuals.Enabled", false) or not showChams then
        clearChams(1)
    else
        clearChams(chamIdx + 1)
    end
end)

-- clear caches when a player leaves
Players.PlayerRemoving:Connect(function(plr)
    charCache[plr] = nil
    if plr.Character then
        boneCache[plr.Character] = nil
        partsCache[plr.Character] = nil
    end
end)

print("[KIRO VISUALS] Loaded. Game: " .. (K.GameId or "unknown"))

-- one-shot diagnostic
task.delay(4, function()
    local total = math.max(#Players:GetPlayers() - 1, 0)
    print(string.format("[KIRO VISUALS] Resolved %d/%d players", #cachedPlayers, total))
    if total > 0 and #cachedPlayers == 0 then
        warn("[KIRO VISUALS] No players resolved - run K.DebugDump() and send the output")
    end
end)

-- structure dump for support: run K.DebugDump() in the console
function K.DebugDump()
    print("========== KIRO DEBUG DUMP ==========")
    print("GameId:", K.GameId)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            print(string.format("PLAYER %q (id=%s) char=%s",
                plr.Name, tostring(plr.UserId), tostring(plr.Character)))
        end
    end
    print("-- workspace children:")
    for _, c in ipairs(workspace:GetChildren()) do
        print("   ", c.ClassName, c.Name)
    end
    print("-- models with Humanoid (first 15):")
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then
            local attrs = {}
            for k, v in pairs(d:GetAttributes()) do
                table.insert(attrs, k .. "=" .. tostring(v))
            end
            print(string.format("    %s  parent=%s  attrs=[%s]",
                d:GetFullName(),
                d.Parent and d.Parent.Name or "?",
                table.concat(attrs, ", ")))
            n += 1
            if n >= 15 then break end
        end
    end
    print("====================================")
end

return K