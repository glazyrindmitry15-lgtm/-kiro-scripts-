-- =====================================================================
-- VISUALS | Advanced ESP (Optimized: Cache + Pooling + Distance + Throttle)
-- =====================================================================
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local gameId = K.GameId or "unknown"\nif not gameId or gameId == "" then gameId = "unknown" end

K.Highlights = K.Highlights or {}
K.ESPObjects = K.ESPObjects or {}

-- ============ MODEL CACHE (updated via task.spawn, not RenderStepped) ============
local cachedModels = {}
local lastModelUpdate = 0
local MODEL_UPDATE_INTERVAL = 0.5

local function refreshModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
        end
    end
    -- Only scan workspace once per 0.5s, not every frame
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Humanoid") then
            local m = d.Parent
            if m and m:IsA("Model") and m ~= LP.Character and not seen[m] then
                if LP.Character and m:IsDescendantOf(LP.Character) then continue end
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
        task.wait(MODEL_UPDATE_INTERVAL)
    end
end)

local function getModels()
    return cachedModels
end

-- ============ HELPERS ============
local function isEnemy(entry)
    if not K.GetSetting("ESP.TeamCheck") then return true end
    local plr = entry.player
    if plr then
        if plr.Team and LP.Team then return plr.Team ~= LP.Team end
        local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
        local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
        if pTeam and lTeam then return pTeam ~= lTeam end
    end
    local mTeam = entry.model:GetAttribute("Team") or entry.model:GetAttribute("team")
    local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
    if mTeam and lTeam then return mTeam ~= lTeam end
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

-- Object pooling: create Drawing objects once
local function newObj(t)
    local o = Drawing.new(t)
    o.Visible = false
    o.Thickness = 1
    o.Transparency = 1
    return o
end

local function getData(key)
    if not K.ESPObjects[key] then
        local o = {
            lines = {},
            name = newObj("Text"),
            dist = newObj("Text"),
            hpBg = newObj("Square"),
            hpFg = newObj("Square"),
            skeleton = {},
        }
        o.name.Size = 13
        o.name.Center = true
        o.name.Outline = true
        o.dist.Size = 11
        o.dist.Center = true
        o.dist.Outline = true
        for i = 1, 12 do
            local l = newObj("Line")
            l.Thickness = 1
            o.lines[i] = l
        end
        for i = 1, 8 do
            local l = newObj("Line")
            l.Thickness = 1
            o.skeleton[i] = l
        end
        K.ESPObjects[key] = o
    end
    return K.ESPObjects[key]
end

local function hideAll(o)
    for _, l in ipairs(o.lines) do l.Visible = false end
    for _, l in ipairs(o.skeleton) do l.Visible = false end
    o.name.Visible = false
    o.dist.Visible = false
    o.hpBg.Visible = false
    o.hpFg.Visible = false
end

local boxEdges = {
    {1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8}
}

local function getBoxCorners(hrp, head)
    local cf = hrp.CFrame
    local height = (head.Position - hrp.Position).Magnitude * 2
    local width = hrp.Size.X
    local depth = hrp.Size.Z
    local corners = {}
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = cf * CFrame.new(x * width/2, y * height/2, z * depth/2)
                table.insert(corners, corner.Position)
            end
        end
    end
    return corners
end

local function updateChams(model, enabled)
    if not K.GetSetting("ESP.Highlight") then
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
        hl.FillTransparency = K.GetSetting("ESP.ChamsTransparency") or 0.7
        hl.OutlineTransparency = 0.3
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = model
        K.Highlights[model] = hl
    end
end

-- ============ THROTTLED VISUAL UPDATE ============
local lastVisualUpdate = 0
local VISUAL_UPDATE_INTERVAL = 0.05

-- ============ MAIN LOOP ============
local lastCleanup = 0

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ESP.Enabled") then
        for _, o in pairs(K.ESPObjects) do hideAll(o) end
        for model, hl in pairs(K.Highlights) do
            pcall(function() hl.Enabled = false end)
        end
        return
    end

    -- Throttle: only update visuals every 0.05s
    if tick() - lastVisualUpdate < VISUAL_UPDATE_INTERVAL then return end
    lastVisualUpdate = tick()

    local models = getModels()
    local seen = {}
    local lpHrp = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character:FindFirstChild("Torso"))
    local maxDist = K.GetSetting("ESP.MaxDist") or 500

    for _, entry in ipairs(models) do
        local model = entry.model
        seen[model] = true
        local o = getData(model)

        if not isEnemy(entry) then
            hideAll(o)
            updateChams(entry, false)
            continue
        end

        local head, hrp, hum = getParts(model)
        if not head then
            hideAll(o)
            updateChams(entry, false)
            continue
        end

        -- Distance check FIRST (before WorldToViewportPoint)
        local dist = 0
        if lpHrp then
            dist = (lpHrp.Position - hrp.Position).Magnitude
        end
        if dist > maxDist and dist > 0 then
            hideAll(o)
            updateChams(entry, false)
            continue
        end

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            hideAll(o)
            continue
        end

        updateChams(entry, true)

        local col = K.GetSetting("ESP.Color")
        if typeof(col) == "table" then col = Color3.fromRGB(col[1], col[2], col[3]) end
        if typeof(col) ~= "Color3" then col = Color3.fromRGB(255, 60, 60) end

        local label = (entry.player and entry.player.Name) or model.Name

        -- 3D Box
        if K.GetSetting("ESP.Box") then
            local corners = getBoxCorners(hrp, head)
            local screenCorners = {}
            local allOnScreen = true
            for _, c in ipairs(corners) do
                local sp, on = Camera:WorldToViewportPoint(c)
                if not on or sp.Z <= 0 then allOnScreen = false break end
                table.insert(screenCorners, sp)
            end
            if allOnScreen and #screenCorners == 8 then
                for i, edge in ipairs(boxEdges) do
                    local l = o.lines[i]
                    l.Visible = true
                    l.From = Vector2.new(screenCorners[edge[1]].X, screenCorners[edge[1]].Y)
                    l.To = Vector2.new(screenCorners[edge[2]].X, screenCorners[edge[2]].Y)
                    l.Color = col
                end
            else
                for _, l in ipairs(o.lines) do l.Visible = false end
            end
        else
            for _, l in ipairs(o.lines) do l.Visible = false end
        end

        -- Skeleton
        if K.GetSetting("ESP.Skeleton") then
            local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local leftArm = model:FindFirstChild("LeftUpperArm") or model:FindFirstChild("Left Arm")
            local rightArm = model:FindFirstChild("RightUpperArm") or model:FindFirstChild("Right Arm")
            local leftLeg = model:FindFirstChild("LeftUpperLeg") or model:FindFirstChild("Left Leg")
            local rightLeg = model:FindFirstChild("RightUpperLeg") or model:FindFirstChild("Right Leg")

            local idx = 1
            local function drawBone(a, b)
                if not a or not b then return false end
                local sp1, on1 = Camera:WorldToViewportPoint(a.Position)
                local sp2, on2 = Camera:WorldToViewportPoint(b.Position)
                if on1 and on2 and sp1.Z > 0 and sp2.Z > 0 then
                    o.skeleton[idx].Visible = true
                    o.skeleton[idx].From = Vector2.new(sp1.X, sp1.Y)
                    o.skeleton[idx].To = Vector2.new(sp2.X, sp2.Y)
                    o.skeleton[idx].Color = col
                    idx = idx + 1
                    return true
                end
                return false
            end

            if torso then drawBone(head, torso) end
            if torso and leftArm then drawBone(torso, leftArm) end
            if torso and rightArm then drawBone(torso, rightArm) end
            if torso and leftLeg then drawBone(torso, leftLeg) end
            if torso and rightLeg then drawBone(torso, rightLeg) end
            for i = idx, #o.skeleton do o.skeleton[i].Visible = false end
        else
            for _, l in ipairs(o.skeleton) do l.Visible = false end
        end

        -- Name
        if K.GetSetting("ESP.Name") then
            o.name.Visible = true
            o.name.Text = label .. " [" .. math.floor(hum.Health) .. "]"
            o.name.Color = col
            o.name.Position = Vector2.new(headPos.X, headPos.Y - 18)
        else
            o.name.Visible = false
        end

        -- Distance
        if K.GetSetting("ESP.Distance") then
            o.dist.Visible = true
            o.dist.Text = string.format("%d m", math.floor(dist))
            o.dist.Color = col
            o.dist.Position = Vector2.new(headPos.X, headPos.Y + 18)
        else
            o.dist.Visible = false
        end

        -- Health bar
        if K.GetSetting("ESP.Health") then
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
    end

    -- cleanup (throttled, every 2s)
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
        for _, v in pairs(o) do
            if type(v) == "table" then
                for _, l in ipairs(v) do pcall(function() l:Remove() end) end
            else pcall(function() v:Remove() end) end
        end
        K.ESPObjects[plr] = nil
    end
end)

print("[KIRO VISUALS] Advanced ESP loaded (optimized). Game: " .. gameId)
