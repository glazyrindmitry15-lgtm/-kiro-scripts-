-- entry.lua | FUST
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

-- 3. UI
load(base.."modules/ui.lua")

-- 4. RPC (Discord Rich Presence)
load(base.."modules/rpc.lua")

-- 5. Other modules
load(base.."modules/visuals.lua")
load(base.."modules/aimbot.lua")
load(base.."modules/movement.lua")
load(base.."modules/misc.lua")
load(base.."modules/radar.lua")
load(base.."modules/utility.lua")
load(base.."modules/debugger.lua")
load(base.."modules/skins.lua")
load(base.."modules/killfeed.lua")

print("[KIRO FUST] All modules loaded.")