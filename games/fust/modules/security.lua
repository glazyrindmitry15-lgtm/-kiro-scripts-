-- KIRO HACK | ADVANCED SECURITY CORE (ANTI-DETECTION)
local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Property Spoofing (с защитой)
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            local isCaller = false
            pcall(function() isCaller = checkcaller() end)
            if (not isCaller) and typeof(self) == "Instance" then
                if self:IsA("Humanoid") and (key == "WalkSpeed" or key == "JumpPower") then
                    return 16
                end
                if self:IsA("BasePart") and key == "Size" and K.OriginalSizes and K.OriginalSizes[self] then
                    return K.OriginalSizes[self]
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

-- Блокировка ремоутов
pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local isCaller = false
            pcall(function() isCaller = checkcaller() end)
            if (not isCaller) and method == "FireServer" then
                local name = tostring(self.Name):lower()
                if name:find("anticheat") or name:find("detect") or name:find("ban") or name:find("log") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end)
end)

print("[KIRO SECURITY] Anti-detect loaded.")
