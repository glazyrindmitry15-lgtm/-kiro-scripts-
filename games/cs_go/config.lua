-- config.lua | CS:GO
local K = shared.KIRO
if not K then return end

K.Settings = K.Settings or {}

-- Combat
K.Settings.Combat = K.Settings.Combat or {}
K.Settings.Combat.Aimbot = false
K.Settings.Combat.SilentAim = false
K.Settings.Combat.ShowFOV = true
K.Settings.Combat.FOV = 120
K.Settings.Combat.Smoothness = 5
K.Settings.Combat.WallCheck = true
K.Settings.Combat.TeamCheck = true
K.Settings.Combat.Triggerbot = false
K.Settings.Combat.TriggerDelay = 50
K.Settings.Combat.RCS = false
K.Settings.Combat.RCSStrength = 80
K.Settings.Combat.AutoBuy = false

-- Visuals
K.Settings.Visuals = K.Settings.Visuals or {}
K.Settings.Visuals.Enabled = false
K.Settings.Visuals.BoxESP = false
K.Settings.Visuals.NameESP = false
K.Settings.Visuals.HealthESP = false
K.Settings.Visuals.Tracers = false
K.Settings.Visuals.TracerOrigin = "Screen Bottom"
K.Settings.Visuals.Snaplines = false
K.Settings.Visuals.Chams = false
K.Settings.Visuals.MaxDistance = 1000
K.Settings.Visuals.Radar = false
K.Settings.Visuals.WeaponESP = false
K.Settings.Visuals.DistanceESP = true
K.Settings.Visuals.BombTimer = false
K.Settings.Visuals.AntiFlash = false

-- Utility
K.Settings.Utility = K.Settings.Utility or {}
K.Settings.Utility.AutoBuy = false

-- Misc
K.Settings.Misc = K.Settings.Misc or {}
K.Settings.Misc.BunnyHop = false
K.Settings.Misc.Fullbright = false
K.Settings.Misc.NoFlash = false
K.Settings.Misc.AntiFlash = false
K.Settings.Misc.BombTimer = false
K.Settings.Misc.Hitmarker = false

-- Camera
K.Settings.Camera = K.Settings.Camera or {}
K.Settings.Camera.DefaultFOV = 70
K.Settings.Camera.ZoomFOV = 40
K.Settings.Camera.ZoomKey = Enum.KeyCode.Z
K.Settings.Camera.FOVChanger = 70

-- Keybinds
K.Settings.Keybinds = K.Settings.Keybinds or {}
K.Settings.Keybinds.Menu = Enum.KeyCode.F4
K.Settings.Keybinds.ESP = Enum.KeyCode.F1
K.Settings.Keybinds.Aimbot = Enum.KeyCode.C
K.Settings.Keybinds.Triggerbot = Enum.KeyCode.V
K.Settings.Keybinds.Fly = nil
K.Settings.Keybinds.Speed = nil
K.Settings.Keybinds.Noclip = nil
K.Settings.Keybinds.AutoRepair = nil
K.Settings.Keybinds.Zoom = Enum.KeyCode.Z

-- Language
K.Settings.Language = K.Settings.Language or "RU"

K.Version = "1.2.0"
K.GameId = K.GameId or "cs_go"

print("[KIRO CONFIG] CS:GO config loaded.")
return K