local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local SKINS = {
    Default = { Color = Color3.fromRGB(180,180,180), Material = Enum.Material.Plastic },
    Gold    = { Color = Color3.fromRGB(255,200,60),  Material = Enum.Material.Metal   },
    Neon    = { Color = Color3.fromRGB(0,255,180),   Material = Enum.Material.Neon    },
    Dark    = { Color = Color3.fromRGB(30,30,40),    Material = Enum.Material.SmoothPlastic },
    Red     = { Color = Color3.fromRGB(220,60,60),   Material = Enum.Material.SmoothPlastic },
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
            pcall(function() d.Color = skin.Color end)
        end
    end
    pcall(function() tool.Name = "Weapon ["..skinName.."]" end)
end

local function refresh()
    if not K.GetSetting("Skins.Enabled") then return end
    local skinName = K.GetSetting("Skins.Skin") or "Default"
    local char = LP.Character
    if not char then return end
    for _, tool in ipairs(LP.Backpack:GetChildren()) do
        applySkin(tool, skinName)
    end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then applySkin(equipped, skinName) end
end

-- watch for new tools
LP.Backpack.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if K.GetSetting("Skins.Enabled") then
        refresh()
    end
end)

-- periodic refresh
task.spawn(function()
    while task.wait(2) do
        if K.GetSetting("Skins.Enabled") then refresh() end
    end
end)

-- expose for ui
K.Skins = { Apply = refresh, List = SKINS }

print("[KIRO SKINS] Модуль загружен.")
