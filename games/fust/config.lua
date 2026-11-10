-- config.lua | FUST
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
K.Settings.Visuals.ChestESP = false
K.Settings.Visuals.LootESP = false
K.Settings.Visuals.BuildingESP = false
K.Settings.Visuals.SkeletonESP = false
K.Settings.Visuals.NoGrass = false
K.Settings.Visuals.Hitmarker = false
K.Settings.Visuals.MaxDistance = 1000
K.Settings.Visuals.Radar = false
K.Settings.Visuals.WeaponESP = true
K.Settings.Visuals.DistanceESP = true

-- Utility
K.Settings.Utility = K.Settings.Utility or {}
K.Settings.Utility.AutoFarm = false
K.Settings.Utility.ChestESP = false
K.Settings.Utility.AutoSwing = false
K.Settings.Utility.AutoHeal = false

-- Misc
K.Settings.Misc = K.Settings.Misc or {}
K.Settings.Misc.Speed = false
K.Settings.Misc.WalkSpeed = 16
K.Settings.Misc.BunnyHop = false
K.Settings.Misc.Fullbright = false
K.Settings.Misc.Zoom = false

-- Camera
K.Settings.Camera = K.Settings.Camera or {}
K.Settings.Camera.DefaultFOV = 70
K.Settings.Camera.ZoomFOV = 40
K.Settings.Camera.ZoomKey = Enum.KeyCode.Z
K.Settings.Camera.FOVChanger = 70
K.Settings.Camera.CustomFOV = 70
K.Settings.Camera.ViewmodelX = 0
K.Settings.Camera.ViewmodelY = 0
K.Settings.Camera.ViewmodelZ = 0

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
K.Settings.Keybinds.AutoFarm = nil
K.Settings.Keybinds.AutoSwing = nil

-- Language
K.Settings.Language = K.Settings.Language or "RU"

-- Skins
K.Settings.Skins = K.Settings.Skins or {}
K.Settings.Skins.Enabled = false
K.Settings.Skins.ActiveSkin = "Default"

K.Version = "1.2.0"
K.GameId = K.GameId or "fust"

print("[KIRO CONFIG] FUST config loaded.")
return K