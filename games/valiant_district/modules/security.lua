local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players = game:GetService("Players")

pcall(function()
    if hookmetamethod then
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local isCaller = false
            pcall(function() isCaller = checkcaller() end)
            if (not isCaller) and method == "FireServer" then
                local name = tostring(self.Name):lower()
                if name:find("anticheat") or name:find("detect") or name:find("ban") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

print("[KIRO SECURITY] Anti-detect loaded.")
