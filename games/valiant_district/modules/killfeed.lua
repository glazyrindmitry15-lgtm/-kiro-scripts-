-- killfeed.lua | Kiro Scripts - Kill Feed UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

-- Kill Feed GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KiroKillFeed"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parentGui

local Container = Instance.new("Frame")
Container.Name = "KillFeedContainer"
Container.Size = UDim2.new(0, 300, 0, 400)
Container.Position = UDim2.new(1, -320, 0, 20)
Container.BackgroundTransparency = 1
Container.ZIndex = 50
Container.Parent = ScreenGui

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ListLayout.Parent = Container

local KillFeed = {}
local maxEntries = 5

local function addKillFeed(killer, victim, isHeadshot)
    if #KillFeed >= maxEntries then
        local oldest = KillFeed[1]
        if oldest then
            pcall(function() oldest.Frame:Destroy() end)
            table.remove(KillFeed, 1)
        end
    end

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    Frame.BackgroundTransparency = 0.15
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 51
    Frame.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(138, 100, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.3
    Stroke.Parent = Frame

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -10, 1, 0)
    Text.Position = UDim2.new(0, 10, 0, 0)
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(245, 245, 255)
    Text.Font = Enum.Font.GothamBold
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.ZIndex = 52
    Text.Parent = Frame

    local killerName = killer or "Unknown"
    local victimName = victim or "Unknown"
    local suffix = isHeadshot and " - Headshot" or ""
    Text.Text = killerName .. " убил " .. victimName .. suffix

    -- Slide in animation
    Frame.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    local entry = { Frame = Frame, Time = tick() }
    table.insert(KillFeed, entry)

    -- Auto-remove after 5 seconds
    task.delay(5, function()
        pcall(function()
            TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            Frame:Destroy()
        end)
        for i, e in ipairs(KillFeed) do
            if e == entry then
                table.remove(KillFeed, i)
                break
            end
        end
    end)
end

-- Track last damage time per victim (simple approach)
local lastDamageVictim = nil
local lastDamageTime = 0

-- Listen to Humanoid.Died for all characters
local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        local victim = char.Name
        local killer = lastDamageVictim
        local isHeadshot = false
        local now = tick()
        if lastDamageVictim and (now - lastDamageTime) < 2 then
            killer = lastDamageVictim
        else
            killer = "Unknown"
        end
        addKillFeed(killer, victim, isHeadshot)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(onCharacterAdded)
    if plr.Character then
        task.spawn(function()
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then onCharacterAdded(plr.Character) end
        end)
    end
end)

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end

-- Expose function to allow external damage tracking
K.KillFeed = {
    Add = addKillFeed,
    SetLastDamage = function(victimName)
        lastDamageVictim = victimName
        lastDamageTime = tick()
    end
}

print("[KIRO KILLFED] Kill Feed module loaded.")
return K