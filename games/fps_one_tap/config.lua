-- config.lua | FPS One tap
local K = shared.KIRO
if not K then return end

K.Settings = K.Settings or {}

-- Combat
K.Settings.Combat = K.Settings.Combat or {}
K.Settings.Combat.Aimbot = false
K.Settings.Combat.SilentAim = false
K.Settings.Combat.ShowFOV = true
K.Settings.Combat.FOV = 150
K.Settings.Combat.Smoothness = 1
K.Settings.Combat.WallCheck = true
K.Settings.Combat.TeamCheck = true
K.Settings.Combat.Hitbox = "Head"
K.Settings.Combat.Snap = false
K.Settings.Combat.Triggerbot = false
K.Settings.Combat.TriggerDelay = 40
K.Settings.Combat.RCS = false
K.Settings.Combat.RCSStrength = 80
K.Settings.Combat.AutoBuy = false
K.Settings.Combat.Burst = false
K.Settings.Combat.BurstCount = 10
K.Settings.Combat.BurstDelay = 60

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
K.Settings.Visuals.SkeletonESP = false
K.Settings.Visuals.HeadDot = true
K.Settings.Visuals.Offscreen = true
K.Settings.Visuals.Hitmarker = false
K.Settings.Visuals.MaxDistance = 1000
K.Settings.Visuals.Radar = false
K.Settings.Visuals.WeaponESP = false
K.Settings.Visuals.DistanceESP = true
K.Settings.Visuals.BombTimer = false
K.Settings.Visuals.AntiFlash = false

-- Utility
K.Settings.Utility = K.Settings.Utility or {}

-- Misc
K.Settings.Misc = K.Settings.Misc or {}
K.Settings.Misc.Speed = false
K.Settings.Misc.WalkSpeed = 16
K.Settings.Misc.Fly = false
K.Settings.Misc.FlySpeed = 50
K.Settings.Misc.Noclip = false
K.Settings.Misc.InfJump = false
K.Settings.Misc.JumpPower = 50
K.Settings.Misc.BunnyHop = false
K.Settings.Misc.Spinbot = false
K.Settings.Misc.SpinSpeed = 90
K.Settings.Misc.Fullbright = false
K.Settings.Misc.Zoom = false
K.Settings.Misc.RPC = true

-- Camera
K.Settings.Camera = K.Settings.Camera or {}
K.Settings.Camera.DefaultFOV = 80
K.Settings.Camera.ZoomFOV = 45
K.Settings.Camera.ZoomKey = Enum.KeyCode.Z
K.Settings.Camera.FOVChanger = 80
K.Settings.Camera.ViewmodelX = 0
K.Settings.Camera.ViewmodelY = 0
K.Settings.Camera.ViewmodelZ = 0

-- ThirdPerson
K.Settings.ThirdPerson = K.Settings.ThirdPerson or {}
K.Settings.ThirdPerson.Enabled = false
K.Settings.ThirdPerson.Distance = 8

-- Keybinds
K.Settings.Keybinds = K.Settings.Keybinds or {}
K.Settings.Keybinds.Menu = Enum.KeyCode.F4
K.Settings.Keybinds.ESP = Enum.KeyCode.F1
K.Settings.Keybinds.Aimbot = Enum.KeyCode.C
K.Settings.Keybinds.Triggerbot = Enum.KeyCode.V
K.Settings.Keybinds.Zoom = Enum.KeyCode.Z
K.Settings.Keybinds.Fly = nil
K.Settings.Keybinds.Speed = nil
K.Settings.Keybinds.Noclip = nil
K.Settings.Keybinds.AutoRepair = nil

-- Language
K.Settings.Language = K.Settings.Language or "RU"

K.Version = "1.2.0"
K.GameId = K.GameId or "fps_one_tap"

print("[KIRO CONFIG] FPS One tap config loaded.")
return K
