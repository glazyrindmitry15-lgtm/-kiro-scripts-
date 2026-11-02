local K = shared.KIRO
if not K then return end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

-- Debug: проверяем Drawing
if not Drawing then
    warn("[KIRO ESP] Drawing API недоступен в этом исполнителе!")
    return
end
print("[KIRO ESP] Drawing OK, старт...")

K.ESPObjects = K.ESPObjects or {}

local function getChar(plr)
    -- пробуем стандартный Character
    local c = plr.Character
    if not c then
        -- fallback: ищем в workspace по имени
        c = workspace:FindFirstChild(plr.Name)
    end
    if not c then return nil end
    local head = c:FindFirstChild("Head") or c:FindFirstChild("head") or c:FindFirstChild("UpperTorso")
    local hrp  = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("LowerTorso")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if head and hrp and hum and hum.Health > 0 then
        return c, head, hrp, hum
    end
    return nil
end

local function isEnemy(plr)
    if not K.GetSetting("ESP.TeamCheck") then return true end
    if plr == LP then return false end
    -- team check через Team
    if plr.Team and LP.Team then
        return plr.Team ~= LP.Team
    end
    -- fallback: атрибут Team
    local pTeam = plr:GetAttribute("Team") or plr:GetAttribute("team")
    local lTeam = LP:GetAttribute("Team") or LP:GetAttribute("team")
    if pTeam and lTeam then return pTeam ~= lTeam end
    return true
end

local function newObj(t)
    local o = Drawing.new(t)
    o.Visible = false
    o.Thickness = 1
    o.Transparency = 1
    return o
end

local function getData(plr)
    if not K.ESPObjects[plr] then
        K.ESPObjects[plr] = {
            box  = newObj("Square"),
            name = newObj("Text"),
            dist = newObj("Text"),
        }
        K.ESPObjects[plr].name.Size = 13
        K.ESPObjects[plr].name.Center = true
        K.ESPObjects[plr].name.Outline = true
        K.ESPObjects[plr].dist.Size = 11
        K.ESPObjects[plr].dist.Center = true
        K.ESPObjects[plr].dist.Outline = true
    end
    return K.ESPObjects[plr]
end

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ESP.Enabled") then
        for _, o in pairs(K.ESPObjects) do
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local o = getData(plr)
        if plr == LP or not isEnemy(plr) then
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
            continue
        end
        local res = getChar(plr)
        if not res then
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
            continue
        end
        local char, head, hrp, hum = res

        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen or headPos.Z <= 0 then
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
            continue
        end

        local hrpPos = Camera:WorldToViewportPoint(hrp.Position)
        local height = math.abs(hrpPos.Y - headPos.Y) * 2
        if height < 4 then
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
            continue
        end
        local width = height / 2
        local x = headPos.X - width / 2
        local y = headPos.Y - height * 0.15

        local dist = 0
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            dist = (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
        elseif LP.Character and LP.Character:FindFirstChild("Torso") then
            dist = (LP.Character.Torso.Position - hrp.Position).Magnitude
        end
        if dist > (K.GetSetting("ESP.MaxDist") or 500) and dist > 0 then
            o.box.Visible = false; o.name.Visible = false; o.dist.Visible = false
            continue
        end

        local col = K.GetSetting("ESP.Color")
        if typeof(col) == "table" then col = Color3.fromRGB(col[1], col[2], col[3]) end
        if typeof(col) ~= "Color3" then col = Color3.fromRGB(255, 60, 60) end

        if K.GetSetting("ESP.Box") then
            o.box.Visible = true
            o.box.Color = col
            o.box.Size = Vector2.new(width, height)
            o.box.Position = Vector2.new(x, y)
        else o.box.Visible = false end

        if K.GetSetting("ESP.Name") then
            o.name.Visible = true
            o.name.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "]"
            o.name.Color = col
            o.name.Position = Vector2.new(headPos.X, y - 14)
        else o.name.Visible = false end

        if K.GetSetting("ESP.Distance") then
            o.dist.Visible = true
            o.dist.Text = string.format("%d m", math.floor(dist))
            o.dist.Color = col
            o.dist.Position = Vector2.new(headPos.X, y + height + 2)
        else o.dist.Visible = false end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local o = K.ESPObjects[plr]
    if o then
        for _, v in pairs(o) do pcall(function() v:Remove() end) end
        K.ESPObjects[plr] = nil
    end
end)

print("[KIRO ESP] Модуль загружен.")

task.spawn(function()
    task.wait(4)
    print("[KIRO DEBUG] Players count:", #Players:GetPlayers())
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            print("[KIRO DEBUG] Player:", plr.Name, "Team:", tostring(plr.Team))
            local c = plr.Character or workspace:FindFirstChild(plr.Name)
            if c then
                print("[KIRO DEBUG]   Char:", c:GetFullName(), "parts:", #c:GetChildren())
                for _, d in ipairs(c:GetChildren()) do
                    if d:IsA("BasePart") then print("[KIRO DEBUG]     Part:", d.Name, d.Position) end
                end
            else
                print("[KIRO DEBUG]   No character")
            end
            break
        end
    end
end)
