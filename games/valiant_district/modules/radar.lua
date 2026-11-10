-- radar.lua | Kiro Scripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
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

if not Drawing then
    warn("[KIRO RADAR] Drawing API not available!")
    return
end

-- Radar config
local RADAR_SIZE = 150
local RADAR_SCALE = 0.1 -- world units to radar pixels
local RADAR_POS = Vector2.new(100, 100) -- top-left corner

-- Create radar elements
local radarCircle = Drawing.new("Circle")
radarCircle.Position = RADAR_POS + Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2)
radarCircle.Radius = RADAR_SIZE/2
radarCircle.Thickness = 2
radarCircle.Color = Color3.fromRGB(100, 100, 120)
radarCircle.Filled = false
radarCircle.Visible = false
radarCircle.NumSides = 32

local radarDot = Drawing.new("Circle")
radarDot.Position = RADAR_POS + Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2)
radarDot.Radius = 3
radarDot.Thickness = 1
radarDot.Color = Color3.fromRGB(100, 160, 255)
radarDot.Filled = true
radarDot.Visible = false

local radarPoints = {}

local function clearPoints()
    for _, p in ipairs(radarPoints) do
        p:Remove()
    end
    radarPoints = {}
end

local function addPoint(pos, color)
    local point = Drawing.new("Circle")
    point.Position = pos
    point.Radius = 3
    point.Thickness = 1
    point.Color = color
    point.Filled = true
    point.Visible = true
    table.insert(radarPoints, point)
    return point
end

-- Cached models
local cachedModels = {}
local lastModelUpdate = 0

local function refreshModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(models, {model = plr.Character, player = plr, isEnemy = true})
            seen[plr.Character] = true
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LocalPlayer.Character and not seen[m] then
                if LocalPlayer.Character and m:IsDescendantOf(LocalPlayer.Character) then continue end
                -- Check if it's a chest/generator
                local name = m.Name:lower()
                local isLoot = name:find("chest") or name:find("loot") or name:find("generator") or name:find("gen")
                table.insert(models, {model = m, player = nil, isEnemy = not isLoot, isLoot = isLoot})
                seen[m] = true
            end
        end
    end
    cachedModels = models
end

task.spawn(function()
    while true do
        refreshModels()
        task.wait(0.5)
    end
end)

-- Main radar loop
RunService.RenderStepped:Connect(function()
    if not K.GetSetting("Visuals.Radar") then
        radarCircle.Visible = false
        radarDot.Visible = false
        clearPoints()
        return
    end

    radarCircle.Visible = true
    radarDot.Visible = true

    local lpChar = LocalPlayer.Character
    local lpHrp = lpChar and (lpChar:FindFirstChild("HumanoidRootPart") or lpChar:FindFirstChild("Torso"))
    if not lpHrp then return end

    local center = RADAR_POS + Vector2.new(RADAR_SIZE/2, RADAR_SIZE/2)
    radarDot.Position = center

    -- Clear old points
    clearPoints()

    for _, entry in ipairs(cachedModels) do
        local model = entry.model
        local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local diff = hrp.Position - lpHrp.Position
        local dist = diff.Magnitude
        if dist > 500 then continue end

        -- Scale to radar
        local scale = RADAR_SIZE / 2 / 100 -- 100 studs = half radar
        local x = diff.X * scale
        local z = diff.Z * scale

        -- Clamp to circle
        local mag = math.sqrt(x*x + z*z)
        if mag > RADAR_SIZE/2 - 5 then
            local ratio = (RADAR_SIZE/2 - 5) / mag
            x = x * ratio
            z = z * ratio
        end

        local pos = center + Vector2.new(x, z)

        local color = Color3.fromRGB(255, 60, 60) -- red for enemies
        if entry.isLoot then
            color = Color3.fromRGB(255, 200, 60) -- yellow for loot
        end

        addPoint(pos, color)
    end
end)

print("[KIRO RADAR] Radar module loaded.")
return K