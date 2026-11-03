-- visuals.lua | Kiro Scripts
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

-- Cached models
local cachedModels = {}
local lastModelUpdate = 0

local function refreshModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
        end
    end
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LocalPlayer.Character and not seen[m] then
                if LocalPlayer.Character and m:IsDescendantOf(LocalPlayer.Character) then continue end
                table.insert(models, {model = m, player = nil})
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

local function getModels()
    return cachedModels
end

local function isEnemy(entry)
    if not G("Visuals.TeamCheck", true) then return true end
    local plr = entry.player
    if plr then
        if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    end
    return true
end

local function getParts(model)
    local head = model:FindFirstChild("Head") or model:FindFirstChild("head") or model:FindFirstChild("UpperTorso")
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("LowerTorso") or head
    local hum = model:FindFirstChildOfClass("Humanoid")
    if head and hrp and hum and hum.Health > 0 then
        return head, hrp, hum
    end
    return nil
end

-- Object pooling
local function newObj(t)
    local o = Drawing.new(t)
    o.Visible = false
    o.Thickness = 1
    o.Transparency = 1
    return o
end

K.ESPObjects = K.ESPObjects or {}

local function getData(key)
    if not K.ESPObjects[key] then
        local o = {
            box = newObj("Square"),
            name = newObj("Text"),
            dist = newObj("Text"),
            hpBg = newObj("Square"),
            hpFg = newObj("Square"),
            tracer = newObj("Line"),
        }
        o.name.Size = 13
        o.name.Center = true
        o.name.Outline = true
        o.dist.Size = 11
        o.dist.Center = true
        o.dist.Outline = true
        o.tracer.Thickness = 1
        K.ESPObjects[key] = o
    end
    return K.ESPObjects[key]
end

local function hideAll(o)
    o.box.Visible = false
    o.name.Visible = false
    o.dist.Visible = false
    o.hpBg.Visible = false
    o.hpFg.Visible = false
    o.tracer.Visible = false
end

-- Chams
K.Highlights = K.Highlights or {}

local function updateChams(model, enabled)
    if not G("Visuals.Chams", false) then
        if K.Highlights[model] then
            pcall(function() K.Highlights[model]:Destroy() end)
            K.Highlights[model] = nil
        end
        return
    end
    if not enabled then
        if K.Highlights[model] then
            pcall(function() K.Highlights[model]:Destroy() end)
            K.Highlights[model] = nil
        end
        return
    end
    if not K.Highlights[model] then
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 60, 60)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.3
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = model
        K.Highlights[model] = hl
    end
end

local lastVisualUpdate = 0
local VISUAL_INTERVAL = 0.05
local lastCleanup = 0

RunService.RenderStepped:Connect(function()
    if not G("Visuals.Enabled", false) then
        for _, o in pairs(K.ESPObjects) do hideAll(o) end
        for model, hl in pairs(K.Highlights) do
            pcall(function() hl.Enabled = false end)
        end
        return
    end

    -- Throttle
    if tick() - lastVisualUpdate < VISUAL_INTERVAL then return end
    lastVisualUpdate = tick()

    local models = getModels()
    local seen = {}
    local lpHrp = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
    local maxDist = G("Visuals.MaxDistance", 1000)

    for _, entry in ipairs(models) do
        local model = entry.model
        seen[model] = true
        local o = getData(model)

        if not isEnemy(entry) then
            hideAll(o)
            updateChams(model, false)
            continue
        end

        local head, hrp, hum = getParts(model)
        if not head then
            hideAll(o)
            updateChams(model, false)
            continue
        end

        -- Distance check FIRST
        local dist = 0
        if lpHrp then
            dist = (lpHrp.Position - hrp.Position).Magnitude
        end
        if dist > maxDist and dist > 0 then
            hideAll(o)
            updateChams(model, false)
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            hideAll(o)
            continue
        end

        updateChams(model, true)

        local col = Color3.fromRGB(255, 60, 60)
        local label = (entry.player and entry.player.Name) or model.Name

        -- Box ESP
        if G("Visuals.BoxESP", false) then
            local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
            local height = math.abs(hrpPos.Y - headPos.Y) * 2
            local width = height / 2
            o.box.Visible = true
            o.box.Color = col
            o.box.Size = Vector2.new(width, height)
            o.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height*0.1)
        else
            o.box.Visible = false
        end

        -- Name ESP
        if G("Visuals.NameESP", false) then
            o.name.Visible = true
            o.name.Text = label .. " [" .. math.floor(hum.Health) .. "]"
            o.name.Color = col
            o.name.Position = Vector2.new(headPos.X, headPos.Y - 18)
        else
            o.name.Visible = false
        end

        -- Health ESP (bar)
        if G("Visuals.HealthESP", false) then
            local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
            local height = math.abs(hrpPos.Y - headPos.Y) * 2
            local frac = hum.Health / hum.MaxHealth
            o.hpBg.Visible = true
            o.hpBg.Color = Color3.fromRGB(30, 30, 30)
            o.hpBg.Size = Vector2.new(3, height)
            o.hpBg.Position = Vector2.new(headPos.X - (height/4) - 6, headPos.Y)
            o.hpBg.Filled = true
            o.hpFg.Visible = true
            o.hpFg.Color = Color3.fromRGB(60, 255, 120):Lerp(Color3.fromRGB(255, 60, 60), 1 - frac)
            o.hpFg.Size = Vector2.new(3, height * frac)
            o.hpFg.Position = Vector2.new(headPos.X - (height/4) - 6, headPos.Y + height * (1 - frac))
            o.hpFg.Filled = true
        else
            o.hpBg.Visible = false
            o.hpFg.Visible = false
        end

        -- Tracers
        if G("Visuals.Tracers", false) then
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            o.tracer.Visible = true
            o.tracer.From = screenCenter
            o.tracer.To = Vector2.new(headPos.X, headPos.Y)
            o.tracer.Color = col
        else
            o.tracer.Visible = false
        end

        -- Distance
        o.dist.Visible = false -- simplified
    end

    -- Cleanup (throttled)
    if tick() - lastCleanup > 2 then
        lastCleanup = tick()
        for key, o in pairs(K.ESPObjects) do
            if not seen[key] then
                hideAll(o)
                if K.Highlights[key] then
                    pcall(function() K.Highlights[key]:Destroy() end)
                    K.Highlights[key] = nil
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local o = K.ESPObjects[plr]
    if o then
        for _, v in pairs(o) do pcall(function() v:Remove() end) end
        K.ESPObjects[plr] = nil
    end
end)

print("[KIRO VISUALS] Loaded (optimized). Game: " .. (K.GameId or "unknown"))
return K