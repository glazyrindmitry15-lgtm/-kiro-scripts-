-- config.lua | Valiant District
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
K.Settings.Visuals.KillerESP = false
K.Settings.Visuals.GeneratorESP = false
K.Settings.Visuals.MaxDistance = 1000
K.Settings.Visuals.Radar = false
K.Settings.Visuals.WeaponESP = false
K.Settings.Visuals.DistanceESP = true

-- Utility
K.Settings.Utility = K.Settings.Utility or {}
K.Settings.Utility.AutoRepair = false
K.Settings.Utility.AutoSkillCheck = false

-- Misc
K.Settings.Misc = K.Settings.Misc or {}
K.Settings.Misc.Fly = false
K.Settings.Misc.FlySpeed = 50
K.Settings.Misc.Noclip = false
K.Settings.Misc.InfJump = false
K.Settings.Misc.Speed = false
K.Settings.Misc.WalkSpeed = 16
K.Settings.Misc.JumpPower = 50
K.Settings.Misc.BunnyHop = false
K.Settings.Misc.Fullbright = false

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
K.Settings.Keybinds.Fly = nil
K.Settings.Keybinds.Speed = nil
K.Settings.Keybinds.Noclip = nil
K.Settings.Keybinds.AutoRepair = nil
K.Settings.Keybinds.Zoom = Enum.KeyCode.Z

-- Language
K.Settings.Language = K.Settings.Language or "RU"

K.Version = "1.2.0"
K.GameId = K.GameId or "valiant_district"

print("[KIRO CONFIG] Valiant District config loaded.")
return K