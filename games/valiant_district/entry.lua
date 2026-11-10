local K = shared.KIRO
if not K then return end

-- Принудительно делаем K глобальным для всех модулей
getgenv().K = K
_G.K = K
shared.K = K

local base = K.GAME_BASE
local load = K.SecureLoad

-- 1. АНТИ-ДЕТЕКТ ДОЛЖЕН БЫТЬ ПЕРВЫМ!
load(base.."modules/security.lua")

-- 2. Затем локализация и конфиги
load(base.."modules/locales.lua")
load(base.."config.lua")
load(base.."modules/config_system.lua")

-- 3. Затем UI и остальные модули
load(base.."modules/ui.lua")
load(base.."modules/visuals.lua")
load(base.."modules/aimbot.lua")
load(base.."modules/movement.lua")
load(base.."modules/misc.lua")
load(base.."modules/radar.lua")
load(base.."modules/teleport.lua")
load(base.."modules/utility.lua")
load(base.."modules/debugger.lua")
load(base.."modules/skins.lua")
load(base.."modules/killfeed.lua")

print("[KIRO VALIANT] All modules loaded.")