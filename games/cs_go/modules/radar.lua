-- radar.lua | Kiro Scripts — detailed radar (players / cupboards / loot)
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

-- Without the Drawing API every Drawing.new below would throw and the whole
-- module would die silently (that is why the radar appeared to be missing).
if not Drawing then
    warn("[KIRO RADAR] Drawing API unavailable - radar disabled")
    return
end

local RADAR_SIZE = 150
local RADAR_POS = Vector2.new(100, 100)

local C_PLAYER = Color3.fromRGB(255, 70, 70)
local C_TEAM   = Color3.fromRGB(90, 200, 255)
local C_CUP    = Color3.fromRGB(200, 100, 255)
local C_LOOT   = Color3.fromRGB(255, 200, 60)
local C_RING   = Color3.fromRGB(100, 100, 120)

local function mkCircle(radius, thickness, color, filled)
    local d = Drawing.new("Circle")
    d.Radius = radius
    d.Thickness = thickness
    d.Color = color
    d.Filled = filled
    d.Visible = false
    return d
end

local radarCircle = mkCircle(RADAR_SIZE / 2, 2, C_RING, false)
radarCircle.NumSides = 48

local rangeRing = mkCircle(RADAR_SIZE / 4, 1, C_RING, false)
rangeRing.NumSides = 40
rangeRing.Transparency = 0.6

local radarDot = mkCircle(3, 1, Color3.fromRGB(100, 160, 255), true)

-- pools: circles for players/loot, squares for cupboards
local MAX_CIRCLES = 50
local MAX_SQUARES = 24
local circlePool, squarePool = {}, {}

for i = 1, MAX_CIRCLES do
    circlePool[i] = mkCircle(3, 1, C_PLAYER, true)
end
for i = 1, MAX_SQUARES do
    local s = Drawing.new("Square")
    s.Thickness = 1.5
    s.Filled = false
    s.Size = Vector2.new(7, 7)
    s.Visible = false
    squarePool[i] = s
end

-- ============ MODEL CACHE ============
local cachedModels = {}

local CUP_NAMES = { "cupboard", "toolcupboard", "buildingprivilege", "building_privilege", "privilege" }
local LOOT_NAMES = { "crate", "barrel", "loot", "chest", "trash", "supply", "box", "locker" }

local function nameHas(name, list)
    for _, k in ipairs(list) do
        if name:find(k, 1, true) then return true end
    end
    return false
end

local function refreshModels()
    local models = {}
    local seen = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local friendly = plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
                table.insert(models, { model = char, kind = "player", enemy = not friendly })
                seen[char] = true
            end
        end
    end

    -- world scan only on survival games that have cupboards/loot
    if K.GameId == "trident_survival" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            local kind = nil
            if nameHas(name, CUP_NAMES) then
                kind = "cup"
            elseif nameHas(name, LOOT_NAMES) then
                kind = "loot"
            end
            if kind and not seen[obj] then
                seen[obj] = true
                table.insert(models, { model = obj, kind = kind })
            end
        end
    end

    cachedModels = models
end

task.spawn(function()
    while true do
        if G("Visuals.Radar", false) then
            refreshModels()
        end
        task.wait(2)
    end
end)

-- ============ RENDER ============
local function hideAll()
    for i = 1, MAX_CIRCLES do circlePool[i].Visible = false end
    for i = 1, MAX_SQUARES do squarePool[i].Visible = false end
end

local function getPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        local p = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        if p then return p.Position end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if K._dead then
        radarCircle.Visible = false
        radarDot.Visible = false
        rangeRing.Visible = false
        hideAll()
        return
    end

    if not G("Visuals.Radar", false) then
        radarCircle.Visible = false
        radarDot.Visible = false
        rangeRing.Visible = false
        hideAll()
        return
    end

    radarCircle.Visible = true
    radarDot.Visible = true
    rangeRing.Visible = true

    local lpChar = LocalPlayer.Character
    local lpHrp = lpChar and (lpChar:FindFirstChild("HumanoidRootPart") or lpChar:FindFirstChild("Torso"))
    if not lpHrp then
        hideAll()
        return
    end

    local center = RADAR_POS + Vector2.new(RADAR_SIZE / 2, RADAR_SIZE / 2)
    radarDot.Position = center

    local maxDist = tonumber(G("Visuals.MaxDistance", 1000)) or 1000
    local circleIdx, squareIdx = 0, 0
    local scale = RADAR_SIZE / 2 / 100 -- 100 studs = half radar

    for _, entry in ipairs(cachedModels) do
        local obj = entry.model
        local pos = getPos(obj)
        if not pos then continue end

        local diff = pos - lpHrp.Position
        if diff.Magnitude > maxDist then continue end

        local x = diff.X * scale
        local z = diff.Z * scale

        local mag = math.sqrt(x * x + z * z)
        local limit = RADAR_SIZE / 2 - 6
        if mag > limit then
            local ratio = limit / mag
            x = x * ratio
            z = z * ratio
        end

        local sp = center + Vector2.new(x, z)

        if entry.kind == "cup" then
            squareIdx += 1
            local s = squarePool[squareIdx]
            if s then
                s.Position = sp - Vector2.new(3.5, 3.5)
                s.Color = C_CUP
                s.Visible = true
            end
        else
            circleIdx += 1
            local c = circlePool[circleIdx]
            if c then
                c.Position = sp
                c.Color = entry.enemy and C_PLAYER or C_TEAM
                if entry.kind == "loot" then c.Color = C_LOOT end
                c.Visible = true
            end
        end
    end

    for i = circleIdx + 1, MAX_CIRCLES do circlePool[i].Visible = false end
    for i = squareIdx + 1, MAX_SQUARES do squarePool[i].Visible = false end
end)

print("[KIRO RADAR] Loaded. Game: " .. (K.GameId or "unknown"))
return K