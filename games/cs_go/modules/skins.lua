-- skins.lua | Kiro Scripts - Inventory Changer (Weapon Skins)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Settings.Skins = K.Settings.Skins or {}
if K.Settings.Skins.ActiveSkin == nil then K.Settings.Skins.ActiveSkin = "Default" end

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

if not K.Notify then
    function K.Notify(title, text, ntype)
        print(string.format("[KIRO %s] %s: %s", ntype and ntype:upper() or "INFO", title, text))
    end
end

local SKINS = {
    Default = { Color = Color3.fromRGB(180, 180, 180), Material = Enum.Material.Plastic },
    Gold    = { Color = Color3.fromRGB(255, 200, 60),  Material = Enum.Material.Metal },
    Neon    = { Color = Color3.fromRGB(0, 255, 180),   Material = Enum.Material.Neon },
    Red     = { Color = Color3.fromRGB(220, 60, 60),   Material = Enum.Material.SmoothPlastic },
    Dark    = { Color = Color3.fromRGB(30, 30, 40),    Material = Enum.Material.SmoothPlastic },
}

local function applySkin(tool, skinName)
    if not tool or not tool:IsA("Tool") then return end
    local skin = SKINS[skinName] or SKINS.Default
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.Color = skin.Color
                d.Material = skin.Material
            end)
        end
        if d:IsA("MeshPart") then
            pcall(function()
                d.Color = skin.Color
            end)
        end
    end
    pcall(function()
        tool.Name = "Weapon [" .. skinName .. "]"
    end)
end

local function refresh()
    local enabled = K.GetSetting("Skins.Enabled")
    if not enabled then return end
    local skinName = K.GetSetting("Skins.ActiveSkin") or "Default"
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        applySkin(tool, skinName)
    end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then applySkin(equipped, skinName) end
end

-- Watch for new tools in backpack
LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    task.wait(0.1)
    refresh()
end)

-- Watch for equipped tool in character
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    refresh()
    char.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if child:IsA("Tool") then
            refresh()
        end
    end)
end)

-- Periodic refresh
task.spawn(function()
    while task.wait(2) do
        if K.GetSetting("Skins.Enabled") then refresh() end
    end
end)

-- Expose for UI
K.Skins = {
    Apply = refresh,
    List = SKINS,
    GetActive = function() return K.GetSetting("Skins.ActiveSkin") or "Default" end,
    SetActive = function(name) K.SetSetting("Skins.ActiveSkin", name) refresh() end
}

print("[KIRO SKINS] Inventory Changer loaded.")
return K