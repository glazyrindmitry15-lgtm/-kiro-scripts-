-- KIRO HACK | CONFIG MODULE - VALIANT DISTRICT
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local K = shared.KIRO
if not K then return end

K.LP = LP
K.Camera = workspace.CurrentCamera
K.MenuOpen = false
K.Loading = true
K.ESPObjects = {}
K.OriginalSizes = K.OriginalSizes or {}
K.UIControls = {}

K.Theme = {
    BG=Color3.fromRGB(8,8,12), Glass=Color3.fromRGB(18,18,24), GlassLight=Color3.fromRGB(26,26,36),
    Accent=Color3.fromRGB(100,160,240), Accent2=Color3.fromRGB(160,90,230),
    Text=Color3.fromRGB(245,245,250), TextDim=Color3.fromRGB(120,125,140),
    Red=Color3.fromRGB(255,90,110), Green=Color3.fromRGB(80,230,150),
}
K.Fonts = { Main = Enum.Font.GothamMedium, Bold = Enum.Font.GothamBold, Black = Enum.Font.GothamBlack }

K.Settings = {
    ESP = { Enabled=true, Box=true, Name=true, Distance=true, Health=true, MaxDist=3000, TeamCheck=false, Color={100,160,240} },
    Aimbot = { Enabled=false, FOV=200, Smoothness=0.4, Part="Head", VisibleOnly=true, TeamCheck=false, DrawFOV=true, AimMode="Hold", SmoothCurve="SmoothStep", Key=Enum.KeyCode.C, Jitter=0.4, MaxDistance=600 },
    Misc = { Bunnyhop=false, Speed=false, SpeedValue=32, Fly=false, FlySpeed=50, Noclip=false, InfiniteJump=false, Fullbright=false, NoFlash=true, AntiAFK=true },
    Teleport = { Enabled=false },
    Utils = { AutoEquip=false, AutoCollect=false, HeadExpander=false, HeadSize=2.5, TorsoExpander=false, TorsoSize=2.5 },
    Keybinds = { Menu=Enum.KeyCode.F4, Panic=Enum.KeyCode.Delete },
    UI = { FOVCircle=true },
    VisualExtras = { Trajectory=false, ImpactMarker=false, CustomCrosshair=false, ViewmodelChams=false, ProjectileSpeed=175, GravityMultiplier=1.0, DebugDot=false },
    MapHack = { Enabled=false, MaxDist=500 },
    Fun = { Hitmarker=true, KillMessages=true },
    World = { Fullbright=false, NoFog=false, RemoveGrass=false, PerformanceMode=false },
    Camera = { DefaultFOV=70, ZoomFOV=70, ZoomKey=Enum.KeyCode.Z },
    Combat = { TriggerBot=false, TriggerDelay=0.05, NoRecoil=false, NoSpread=false, ProjMagnet=false, MagnetRadius=15 },
    Security = { StaffDetect=true, ObserverAlert=true, ObserveTime=2.0, MinFacing=0.88, LOSRequired=true, AlertCooldown=10, AntiAFK=true },
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

K.Notify = K.Notify or function(title, text, isErr) end

print("[KIRO VALIANT] Настройки загружены.")
