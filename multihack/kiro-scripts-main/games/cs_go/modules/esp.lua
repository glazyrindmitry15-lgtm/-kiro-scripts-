local K = shared.KIRO
if not K then return end
if not Drawing then warn("[KIRO ESP] Drawing недоступен") return end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

K.ESPObjects = K.ESPObjects or {}

local function newObj(type)
    local o = Drawing.new(type)
    o.Visible = false
    o.Thickness = 1
    o.Transparency = 1
    return o
end

local function isEnemy(plr)
    if not K.GetSetting("ESP.TeamCheck") then return true end
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    if plr.TeamColor and LP.TeamColor then return plr.TeamColor ~= LP.TeamColor end
    return true
end

local function getChar(plr)
    local c = plr.Character
    if not c then return end
    local hrp  = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if hrp and head and hum and hum.Health > 0 then
        return hrp, head, hum
    end
end

local function getData(plr)
    if not K.ESPObjects[plr] then
        K.ESPObjects[plr] = {
            box   = newObj("Square"),
            name  = newObj("Text"),
            dist  = newObj("Text"),
            hpBg  = newObj("Square"),
            hpFg  = newObj("Square"),
        }
        K.ESPObjects[plr].name.Size    = 14
        K.ESPObjects[plr].name.Center  = true
        K.ESPObjects[plr].name.Outline = true
        K.ESPObjects[plr].dist.Size    = 12
        K.ESPObjects[plr].dist.Center  = true
        K.ESPObjects[plr].dist.Outline = true
    end
    return K.ESPObjects[plr]
end

local function hideAll(o)
    for _, v in pairs(o) do v.Visible = false end
end

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ESP.Enabled") then
        for _, o in pairs(K.ESPObjects) do hideAll(o) end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local o = K.ESPObjects[plr]
        if not o then o = getData(plr) end
        if plr == LP or not isEnemy(plr) then
            hideAll(o); continue
        end
        local hrp, head, hum = getChar(plr)
        if not hrp then hideAll(o); continue end

        local headScreen, onHead = Camera:WorldToViewportPoint(head.Position)
        local feetScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 1, 0))
        if not (onHead and feetScreen.Z > 0) then hideAll(o); continue end

        local height = feetScreen.Y - headScreen.Y
        if height < 5 then hideAll(o); continue end
        local width = height / 2
        local x = headScreen.X - width/2
        local y = headScreen.Y

        local dist = 0
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            dist = (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
        end
        if dist > K.GetSetting("ESP.MaxDist") then hideAll(o); continue end

        local col = K.GetSetting("ESP.Color")
        if typeof(col) == "table" then col = Color3.fromRGB(col[1], col[2], col[3]) end

        if K.GetSetting("ESP.Box") then
            o.box.Visible = true
            o.box.Color = col
            o.box.Size = Vector2.new(width, height)
            o.box.Position = Vector2.new(x, y)
        else o.box.Visible = false end

        if K.GetSetting("ESP.Name") then
            o.name.Visible = true
            o.name.Text = plr.Name
            o.name.Color = col
            o.name.Position = Vector2.new(headScreen.X, y - 16)
        else o.name.Visible = false end

        if K.GetSetting("ESP.Distance") then
            o.dist.Visible = true
            o.dist.Text = string.format("%d m", math.floor(dist))
            o.dist.Color = col
            o.dist.Position = Vector2.new(headScreen.X, y + height + 4)
        else o.dist.Visible = false end

        if K.GetSetting("ESP.Health") then
            local frac = hum.Health / hum.MaxHealth
            o.hpBg.Visible = true
            o.hpBg.Color = Color3.fromRGB(30,30,30)
            o.hpBg.Size = Vector2.new(3, height)
            o.hpBg.Position = Vector2.new(x - 6, y)
            o.hpBg.Filled = true
            o.hpFg.Visible = true
            o.hpFg.Color = Color3.fromRGB(60,255,120):Lerp(Color3.fromRGB(255,60,60), 1-frac)
            o.hpFg.Size = Vector2.new(3, height*frac)
            o.hpFg.Position = Vector2.new(x - 6, y + height*(1-frac))
            o.hpFg.Filled = true
        else
            o.hpBg.Visible = false
            o.hpFg.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local o = K.ESPObjects[plr]
    if o then
        for _, v in pairs(o) do v:Remove() end
        K.ESPObjects[plr] = nil
    end
end)

print("[KIRO ESP] Модуль загружен.")
