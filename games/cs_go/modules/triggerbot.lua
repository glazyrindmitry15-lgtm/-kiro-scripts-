local K = shared.KIRO
if not K then return end
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local lastShot = 0

local function getModels()
    local models = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
        end
    end
    for _, folderName in ipairs({"Players", "Characters", "Ragdolls", "Humans", "Agents"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then
            for _, m in ipairs(f:GetChildren()) do
                if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m ~= LP.Character then
                    table.insert(models, {model = m, player = nil})
                end
            end
        end
    end
    for _, m in ipairs(workspace:GetChildren()) do
        if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") and m ~= LP.Character then
            local dup = false
            for _, e in ipairs(models) do if e.model == m then dup = true break end end
            if not dup then table.insert(models, {model = m, player = nil}) end
        end
    end
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
