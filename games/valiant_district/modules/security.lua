-- security.lua | anti-detect: block anticheat remotes + block kicks
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")

local BAD_WORDS = {
    anticheat = true, anti_cheat = true, anticheat_ = true,
    detect = true, detection = true, detected = true,
    ban = true, banned = true, kick = true, report = true,
    flag = true, flagged = true, suspicious = true, sus = true,
}

local function isBadName(name)
    local n = tostring(name):lower()
    for word in pairs(BAD_WORDS) do
        if n:find(word, 1, true) then return true end
    end
    return false
end

-- Single __namecall hook: blocks anticheat report remotes and kicks.
pcall(function()
    if hookmetamethod and getnamecallmethod and newcclosure then
        local old
        old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "Kick" then
                local ok, isCaller = pcall(checkcaller)
                if ok and not isCaller then
                    return
                end
            end

            if method == "FireServer" or method == "InvokeServer" then
                local ok, isCaller = pcall(checkcaller)
                if ok and not isCaller and isBadName(self.Name) then
                    return
                end
            end

            return old(self, ...)
        end))
    end
end)

-- Fallback for executors without newcclosure
pcall(function()
    if hookmetamethod and getnamecallmethod and not newcclosure then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" then
                local ok, isCaller = pcall(checkcaller)
                if ok and not isCaller then return end
            end
            if method == "FireServer" or method == "InvokeServer" then
                local ok, isCaller = pcall(checkcaller)
                if ok and not isCaller and isBadName(self.Name) then return end
            end
            return old(self, ...)
        end)
    end
end)

-- Hide the UI from the game's own CoreGui scans where possible
pcall(function()
    if syn and syn.protect_gui then
        local gui = (gethui and gethui()) or game:GetService("CoreGui")
        local kiro = gui:FindFirstChild("KiroUI")
        if kiro then syn.protect_gui(kiro) end
    end
end)

print("[KIRO SECURITY] Anti-detect loaded.")