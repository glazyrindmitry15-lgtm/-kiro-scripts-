-- security.lua | anti-detect: block anticheat remotes + block kicks
local K = shared.KIRO
if not K then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
-- PANIC: wipe traces if the anticheat reacts
-- ============================================================
K._unload = K._unload or {}

function K.OnUnload(fn)
    table.insert(K._unload, fn)
end

function K.Panic(reason)
    if K._panicking then return end
    K._panicking = true

    -- 0) let every module remove its own Drawing / Highlight objects
    for _, fn in ipairs(K._unload) do
        pcall(fn)
    end

    -- 1) restore character state
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local lv = hrp:FindFirstChild("SpeedLV")
                if lv then lv:Destroy() end
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    pcall(function()
                        p.LocalTransparencyModifier = 0
                        p.CanCollide = true
                        p.CastShadow = true
                    end)
                end
            end
        end
    end)

    -- 2) restore world / lighting
    pcall(function() game:GetService("Lighting").GlobalShadows = true end)
    pcall(function() workspace.Terrain.Decoration = true end)

    -- 3) destroy our GUI
    pcall(function()
        local roots = {}
        local hui = (gethui and gethui()) or LocalPlayer:FindFirstChild("PlayerGui")
        if hui then table.insert(roots, hui) end
        local cam = workspace.CurrentCamera
        if cam then table.insert(roots, cam) end
        for _, root in ipairs(roots) do
            for _, name in ipairs({ "KiroUI", "KiroToasts", "KiroHitmarker", "KiroHighlights" }) do
                local inst = root:FindFirstChild(name)
                if inst then inst:Destroy() end
            end
        end
    end)

    -- 4) tell every module to stop touching the game
    K._dead = true
    print("[KIRO] Panic unload:", reason or "detected")
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
                    -- anticheat reporting us: wipe and unload before it lands
                    task.spawn(function() K.Panic("blocked remote " .. tostring(self.Name)) end)
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