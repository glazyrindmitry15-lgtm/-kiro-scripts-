local K = shared.KIRO
if not K then return end

K.OriginalSizes = K.OriginalSizes or {}

K.Theme = {
    BG = Color3.fromRGB(8,8,12), Glass = Color3.fromRGB(18,18,24), GlassLight = Color3.fromRGB(26,26,36),
    Accent = Color3.fromRGB(100,160,240), Accent2 = Color3.fromRGB(160,90,230),
    TextColor = Color3.fromRGB(245,245,250), TextDim = Color3.fromRGB(120,125,140),
    Red = Color3.fromRGB(255,90,110), Green = Color3.fromRGB(80,230,150),
}
K.Fonts = { Main = Enum.Font.GothamMedium, Bold = Enum.Font.GothamBold, Black = Enum.Font.GothamBlack }

K.Settings = {
    Aimbot = { Enabled = true, FOV = 150, Smoothness = 0.3, Part = "Head", VisibleOnly = true, TeamCheck = true, DrawFOV = true },
    Combat = { TriggerBot = false, TriggerDelay = 0.08 },
    ESP = { Enabled = true, Box = true, Name = true, Distance = true, Health = true, MaxDist = 2500, TeamCheck = true, Color = Color3.fromRGB(255,60,60) },
    Security = { AntiAFK = true, NoFlash = true },
    Misc = { Bunnyhop = false, Fullbright = false },
    Keybinds = { Menu = Enum.KeyCode.RightShift }
}

function K.GetSetting(path)
    local t = K.Settings
    for p in string.gmatch(path, "[^%.]+") do if t == nil then return nil end; t = t[p] end
    return t
end

function K.SetSetting(path, v)
    local parts = {}
    for p in string.gmatch(path, "[^%.]+") do table.insert(parts, p) end
    local t = K.Settings
    for i = 1, #parts - 1 do if t[parts[i]] == nil then t[parts[i]] = {} end; t = t[parts[i]] end
    t[parts[#parts]] = v
end

print("[KIRO CS:GO] Настройки загружены.")
