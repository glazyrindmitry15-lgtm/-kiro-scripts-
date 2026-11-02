local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and typeof(self) == "Instance" then
        if self:IsA("Humanoid") then
            if key == "WalkSpeed" then return 16 end
            if key == "JumpPower" then return 50 end
        end
    end
    return oldIndex(self, key)
end)

local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" then
        local name = tostring(self.Name):lower()
        if name:find("anticheat") or name:find("detect") then return end
    end
    return oldNamecall(self, ...)
end)

print("[KIRO SECURITY] Анти-детект загружен.")
