-- security.lua | anti-detect: block anticheat remotes + block kicks
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")

local BAD_WORDS = {
    -- anticheat / detection
    anticheat = true, anti_cheat = true, ["anti-cheat"] = true,
    antihack = true, anti_hack = true, antiexploit = true,
    detect = true, detection = true, detected = true, detector = true,
    -- moderation
    ban = true, banned = true, banplayer = true,
    kick = true, kickplayer = true,
    report = true, reported = true, reportplayer = true,
    flag = true, flagged = true, suspicious = true, sus = true,
    cheater = true, hacker = true,
    -- server-side validation
    validate = true, validation = true, verify = true, verification = true,
    sanity = true, integrity = true,
}

local function isBadName(name)
    local n = tostring(name):lower()
    for word in pairs(BAD_WORDS) do
        if n:find(word, 1, true) then return true end
    end
    return false
end

-- ============================================================
-- __namecall hook: anticheat remotes + kicks
-- ============================================================
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

-- ============================================================
-- Hide the UI from CoreGui scans where the executor supports it
-- ============================================================
pcall(function()
    if syn and syn.protect_gui then
        local gui = (gethui and gethui()) or game:GetService("CoreGui")
        for _, name in ipairs({ "KiroUI", "KiroHitmarker" }) do
            local inst = gui:FindFirstChild(name)
            if inst then syn.protect_gui(inst) end
        end
    end
end)

-- ============================================================
-- VALUE SPOOFING
-- The game's own scripts and the anticheat must read vanilla values while
-- our features are active. Only intercepts two properties, and only while a
-- feature that actually changes them is enabled (no cost / no behaviour
-- change when everything is off).
-- ============================================================
local spoofTargets = nil

local function spoofActive()
    if spoofTargets == nil then
        local function g(p)
            local ok, v = pcall(function() return K.GetSetting(p) end)
            if ok then return v end
            return nil
        end
        local speedOn = (g("Misc.Speed") == true)
        local jp = tonumber(g("Misc.JumpPower")) or 50
        local flyOn = (g("Misc.Fly") == true)
        spoofTargets = (speedOn or jp ~= 50 or flyOn) and true or false
    end
    return spoofTargets
end

task.spawn(function()
    while true do
        task.wait(0.75)
        spoofTargets = nil
    end
end)

pcall(function()
    if hookmetamethod and newcclosure then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if key == "WalkSpeed" or key == "JumpPower" then
                local ok, humanoid = pcall(function()
                    return typeof(self) == "Instance" and self:IsA("Humanoid")
                end)
                if ok and humanoid and spoofActive() then
                    local ok2, isCaller = pcall(checkcaller)
                    if ok2 and not isCaller then
                        if key == "WalkSpeed" then return 16 end
                        return 50
                    end
                end
            end
            return oldIndex(self, key)
        end))
    end
end)

-- ============================================================
-- Client-side rate guard: never let one frame do absurd work.
-- Cheats that spike the frame time are trivially detectable.
-- ============================================================
local frameCount, frameTime, windowStart = 0, 0, os.clock()

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function(dt)
    frameCount += 1
    frameTime += dt
    local now = os.clock()
    if now - windowStart >= 1 then
        K.FPS = math.floor(frameCount / math.max(frameTime, 0.001) + 0.5)
        frameCount, frameTime, windowStart = 0, 0, now
    end
end)

print("[KIRO SECURITY] Anti-detect loaded.")