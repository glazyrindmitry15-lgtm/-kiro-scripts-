local K = shared.KIRO
if not K then return end
local base = K.GAME_BASE
local load = K.SecureLoad

load(base.."config.lua")
load(base.."modules/security.lua")
load(base.."modules/config_system.lua")
load(base.."modules/ui.lua")
load(base.."modules/visuals.lua")
load(base.."modules/aimbot.lua")
load(base.."modules/movement.lua")
load(base.."modules/misc.lua")
load(base.."modules/skins.lua")
load(base.."modules/thirdperson.lua")
load(base.."modules/triggerbot.lua")
load(base.."modules/utility.lua")

print("[KIRO CS:GO] Модули загружены.")
