-- KIRO HACK | CONFIG MODULE (FULL) - FUST
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local K = shared.KIRO
if not K then return end

K.LP = LP
K.Camera = workspace.CurrentCamera
K.MenuOpen = false
K.Loading = true
K.Aiming = false
K.Zooming = false
K.FPS = 0
K.CachedTargets = {}
K.ESPObjects = {}
K.Highlights = {}
K.WeaponHighlights = {}
K.OriginalSizes = K.OriginalSizes or {}
K.CurrentAimTarget = nil
K.CurrentAimCFrame = nil
K.CurrentSilentTarget = nil
K.UIControls = {}

K.Theme = {
    BG=Color3.fromRGB(8,8,12), Glass=Color3.fromRGB(18,18,24), GlassLight=Color3.fromRGB(26,26,36),
    Accent=Color3.fromRGB(100,160,240), Accent2=Color3.fromRGB(160,90,230),
    Text=Color3.fromRGB(245,245,250), TextDim=Color3.fromRGB(120,125,140),
    Red=Color3.fromRGB(255,90,110), Green=Color3.fromRGB(80,230,150),
}
K.Fonts = { Main = Enum.Font.GothamMedium, Bold = Enum.Font.GothamBold, Black = Enum.Font.GothamBlack }

K.Settings = {
    Aimbot = { Enabled=true, SilentAim=false, SilentWallCheck=true, FOV=300, Smoothness=0.5, SnapAim=false,
               Humanize=true, Jitter=0.4, SmoothCurve="SmoothStep", AimMode="Hold", Key=Enum.KeyCode.C,
               Prediction=0, DropComp=1.0, AimAtBody=false, WallCheck=false, MultiPointVis=false,
               OnlyArmed=false, IgnoreFriends=false, MaxDistance=600 },
    Combat = { TriggerBot=false, TriggerDelay=0.05, NoRecoil=false, NoSpread=false, ProjMagnet=false, MagnetRadius=15 },
    ESP = { Enabled=true, Box=true, Name=true, Distance=true, Weapon=true, Tracer=false, Health=true, HealthNum=true,
            Highlight=true, Skeleton=false, ShowNPCs=false, MaxDist=500, ChamsTransparency=0.7, Color={120,180,255} },
    VisualExtras = { Trajectory=false, ImpactMarker=false, CustomCrosshair=false, ViewmodelChams=false,
                     ProjectileSpeed=175, GravityMultiplier=1.0, DebugDot=false },
    MapHack = { Enabled=false, MaxDist=500 },
    Security = { StaffDetect=true, ObserverAlert=true, ObserveTime=2.0, MinFacing=0.88, LOSRequired=true,
                 AlertCooldown=10, AntiAFK=true },
    Camera = { DefaultFOV=70, ZoomFOV=70, ZoomKey=Enum.KeyCode.Z },
    Utils = { AutoEquip=false, AutoCollect=false, HeadExpander=false, HeadSize=2.5, TorsoExpander=false, TorsoSize=2.5 },
    World = { Fullbright=false, NoFog=false, RemoveGrass=false, PerformanceMode=false },
    Fun = { Hitmarker=true, KillMessages=true },
    Keybinds = { ESP=Enum.KeyCode.F1, Panic=Enum.KeyCode.Delete },
    UI = { FOVCircle=true, MenuBlur=false },
    Misc = { Bunnyhop=false, Speed=false, SpeedValue=32, Fly=false, FlySpeed=50, Noclip=false, InfiniteJump=false, Fullbright=false, NoFlash=true },
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

function K.MatchesKeybind(input, kb)
    if not kb or typeof(kb) ~= "EnumItem" then return false end
    local ok, et = pcall(function() return kb.EnumType end)
    if not ok then return false end
    if et == Enum.KeyCode then return input.KeyCode == kb end
    if et == Enum.UserInputType then return input.UserInputType == kb end
    return false
end

K.Notify = K.Notify or function(title, text, isErr) end

print("[KIRO FUST] Настройки загружены.")
