local K = shared.KIRO
if not K then return end

-- спуфинг WalkSpeed / JumpPower (с защитой от краша)
pcall(function()
    if hookmetamethod then
        local oldIndex = hookmetamethod(game, "__index", function(self, key)
            local isCaller = false
            pcall(function() isCaller = checkcaller() end)
            if (not isCaller) and typeof(self) == "Instance" then
                if self:IsA("Humanoid") then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

-- блокировка ремоутов античита
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
