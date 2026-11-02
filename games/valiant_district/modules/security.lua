local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" then
        local name = tostring(self.Name):lower()
        if name:find("anticheat") or name:find("detect") or name:find("ban") then return end
    end
    return oldNamecall(self, ...)
end)

print("[KIRO SECURITY] Анти-детект загружен.")
