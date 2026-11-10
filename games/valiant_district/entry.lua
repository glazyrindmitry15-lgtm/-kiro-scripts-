local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local base = K.GAME_BASE
local load = K.SecureLoad

load(base.."modules/locales.lua")
load(base.."config.lua")
load(base.."modules/security.lua")
load(base.."modules/config_system.lua")
load(base.."modules/ui.lua")
load(base.."modules/visuals.lua")
load(base.."modules/aimbot.lua")
load(base.."modules/movement.lua")
load(base.."modules/misc.lua")
load(base.."modules/radar.lua")
load(base.."modules/teleport.lua")
load(base.."modules/utility.lua")
load(base.."modules/debugger.lua")

print("[KIRO VALIANT] All modules loaded.")