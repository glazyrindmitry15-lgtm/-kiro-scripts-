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

-- cached once, not per shot
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local lastShot = 0

local cachedModels = {}
local lastModelUpdate = 0

local function getModels()
    if tick() - lastModelUpdate < 0.5 then return cachedModels end
    lastModelUpdate = tick()
    local models = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(models, {model = plr.Character, player = plr})
            seen[plr.Character] = true
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
    if not K.GetSetting("Combat.Triggerbot") then return end

    -- TriggerDelay is stored in MILLISECONDS; tick() delta is SECONDS.
    local baseMs = tonumber(K.GetSetting("Combat.TriggerDelay")) or 80
    -- small random jitter so the click cadence is not robotic
    local jitter = math.random(0, math.max(1, math.floor(baseMs * 0.4)))
    local delay = (baseMs + jitter) / 1000
    if tick() - lastShot < delay then return end

    local mouse = UIS:GetMouseLocation()
    for _, entry in ipairs(getModels()) do
        local model = entry.model
        local head = model:FindFirstChild("Head")
            or model:FindFirstChild("head")
            or model:FindFirstChild("UpperTorso")
        if not head then continue end

        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if not hasLOS(model, head) then continue end

        local scr, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen and (Vector2.new(scr.X, scr.Y) - mouse).Magnitude < 15 then
            lastShot = tick()

            if K.KillFeed and K.KillFeed.SetLastDamage then
                K.KillFeed.SetLastDamage(entry.player and entry.player.Name or "Unknown")
            end
            K._lastPlayerDamageTime = tick()

            if VirtualUser then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new())
                end)
            end
            break
        end
    end
end)

print("[KIRO TRIGGER] loaded.")