local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local lastShot = 0

local cachedModels = {}
local lastModelUpdate = 0

local function getModels()
    if tick() - lastModelUpdate < 0.5 then return cachedModels end
    lastModelUpdate = tick()
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
    cachedModels = models
    return models
end

local function hasLOS(model, part)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LP.Character, model }
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local hit = workspace:Raycast(origin, dir, params)
    return hit == nil
end

RunService.Heartbeat:Connect(function()
    if not K.GetSetting("Combat.TriggerBot") then return end
    if tick() - lastShot < (K.GetSetting("Combat.TriggerDelay") or 0.08) then return end

    local mouse = UIS:GetMouseLocation()
    for _, entry in ipairs(getModels()) do
        local model = entry.model
        local head = model:FindFirstChild("Head") or model:FindFirstChild("head") or model:FindFirstChild("UpperTorso")
        if not head then continue end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if not hasLOS(model, head) then continue end
        local scr, on = Camera:WorldToViewportPoint(head.Position)
        if on and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 15 then
            lastShot = tick()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton1(Vector2.new())
            end)
            break
        end
    end
end)

print("[KIRO TRIGGER] Модуль загружен.")
