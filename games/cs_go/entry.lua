-- entry.lua | CS:GO
local K = shared.KIRO
if not K then return end

-- Global K passing
getgenv().K = K
_G.K = K
shared.K = K

local base = K.GAME_BASE
local load = K.SecureLoad

-- 1. Anti-cheat FIRST
load(base.."modules/security.lua")

-- 2. Localization and configs
load(base.."modules/locales.lua")
load(base.."config.lua")
load(base.."modules/config_system.lua")

-- 3. Skins FIRST: the UI needs K.Skins.List() to build the dropdown
load(base.."modules/skins.lua")

-- 4. UI
load(base.."modules/ui.lua")

-- 5. RPC (Discord Rich Presence)
load(base.."modules/rpc.lua")

-- 6. Other modules
load(base.."modules/visuals.lua")
load(base.."modules/aimbot.lua")
load(base.."modules/triggerbot.lua")
load(base.."modules/movement.lua")
load(base.."modules/misc.lua")
load(base.."modules/radar.lua")
load(base.."modules/utility.lua")
load(base.."modules/thirdperson.lua")
load(base.."modules/debugger.lua")
load(base.."modules/killfeed.lua")

print("[KIRO CS:GO] All modules loaded.")