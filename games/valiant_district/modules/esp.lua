local K = shared.KIRO
if not K then return end
if not Drawing then warn("[KIRO ESP] Drawing недоступен"); return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

K.ESPObjects = K.ESPObjects or {}

local function getModels()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
        end
    end
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
    return models
end

local function getParts(model)
    local head = model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or head
    local hum = model:FindFirstChildOfClass("Humanoid")
    if head and hrp and hum and hum.Health > 0 then return head, hrp, hum end
    return nil
end

local function newObj(t)
    local o = Drawing.new(t); o.Visible = false; o.Thickness = 1; o.Transparency = 1; return o
end

local function getData(key)
    if not K.ESPObjects[key] then
        K.ESPObjects[key] = { box = newObj("Square"), name = newObj("Text"), dist = newObj("Text") }
        K.ESPObjects[key].name.Size = 13; K.ESPObjects[key].name.Center = true; K.ESPObjects[key].name.Outline = true
        K.ESPObjects[key].dist.Size = 11; K.ESPObjects[key].dist.Center = true; K.ESPObjects[key].dist.Outline = true
    end
    return K.ESPObjects[key]
end

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ESP.Enabled") then
        for _, o in pairs(K.ESPObjects) do o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false end
        return
    end
    local models = getModels()
    local seen = {}
    for _, entry in ipairs(models) do
        local model = entry.model
        seen[model] = true
        local o = getData(model)
        local head, hrp, hum = getParts(model)
        if not head then
            o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false; continue
        end
        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false; continue
        end
        local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
        local height = math.abs(hrpPos.Y - headPos.Y) * 2
        if height < 4 then
            o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false; continue
        end
        local width = height / 2
        local x = headPos.X - width / 2
        local y = headPos.Y - height * 0.15

        local dist = 0
        local lpChar = LP.Character
        local lpHrp = lpChar and (lpChar:FindFirstChild("HumanoidRootPart") or lpChar:FindFirstChild("Torso"))
        if lpHrp then dist = (lpHrp.Position - hrp.Position).Magnitude end
        if dist > (K.GetSetting("ESP.MaxDist") or 3000) and dist > 0 then
            o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false; continue
        end

        local col = K.GetSetting("ESP.Color")
        if typeof(col) == "table" then col = Color3.fromRGB(col[1], col[2], col[3]) end
        if typeof(col) ~= "Color3" then col = Color3.fromRGB(100, 160, 240) end

        local label = (entry.player and entry.player.Name) or model.Name

        if K.GetSetting("ESP.Box") then
            o.box.Visible = true; o.box.Color = col; o.box.Size = Vector2.new(width, height); o.box.Position = Vector2.new(x, y)
        else o.box.Visible = false end

        if K.GetSetting("ESP.Name") then
            o.name.Visible = true; o.name.Text = label .. " [" .. math.floor(hum.Health) .. "]"; o.name.Color = col; o.name.Position = Vector2.new(headPos.X, y - 14)
        else o.name.Visible = false end

        if K.GetSetting("ESP.Distance") then
            o.dist.Visible = true; o.dist.Text = string.format("%d m", math.floor(dist)); o.dist.Color = col; o.dist.Position = Vector2.new(headPos.X, y + height + 2)
        else o.dist.Visible = false end
    end
    for key, o in pairs(K.ESPObjects) do
        if not seen[key] then o.box.Visible=false; o.name.Visible=false; o.dist.Visible=false end
    end
end)

print("[KIRO ESP] Модуль загружен.")
