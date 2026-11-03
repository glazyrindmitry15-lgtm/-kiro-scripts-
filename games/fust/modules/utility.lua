-- utility.lua | Kiro Scripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}

if type(K.GetSetting) ~= "function" then
    function K.GetSetting(path)
        if type(path) ~= "string" then return nil end
        if K.Settings[path] ~= nil then return K.Settings[path] end
        local current = K.Settings
        for part in string.gmatch(path, "[^%.]+") do
            if type(current) == "table" and current[part] ~= nil then
                current = current[part]
            else
                return nil
            end
        end
        return current
    end
end

if type(K.SetSetting) ~= "function" then
    function K.SetSetting(path, value)
        if type(path) ~= "string" then return end
        K.Settings[path] = value
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        local current = K.Settings
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(current[key]) ~= "table" then current[key] = {} end
            current = current[key]
        end
        current[parts[#parts]] = value
    end
end

local function G(path, default)
    local v = K.GetSetting(path)
    if v == nil then return default end
    return v
end

local gameId = K.GameId or "unknown"

-- CS:GO: Auto-Buy
if gameId == "cs_go" then
    local lastBuy = 0
    RunService.Heartbeat:Connect(function()
        if not G("Utility.AutoBuy", false) then return end
        if tick() - lastBuy < 5 then return end
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local buyRemote = nil
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("buy") or name:find("purchase") or name:find("shop") then
                    buyRemote = obj
                    break
                end
            end
        end

        if buyRemote then
            pcall(function() buyRemote:FireServer("Armor", "Full") end)
            pcall(function() buyRemote:FireServer("Kevlar") end)
            pcall(function() buyRemote:FireServer("AK47") end)
            pcall(function() buyRemote:FireServer("M4A1") end)
            pcall(function() buyRemote:FireServer("Glock") end)
            lastBuy = tick()
        end
    end)
end

-- Valiant District: Auto-Repair Generators
if gameId == "valiant_district" then
    local cachedGens = {}
    local lastGenUpdate = 0

    local function findGenerators()
        if tick() - lastGenUpdate < 3 then return cachedGens end
        lastGenUpdate = tick()
        local gens = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("generator") or name:find("gen") or name:find("repair") then
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    table.insert(gens, obj)
                end
            end
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent then
                    local pname = parent.Name:lower()
                    if pname:find("gen") or pname:find("repair") then
                        table.insert(gens, parent)
                    end
                end
            end
        end
        cachedGens = gens
        return gens
    end

    local lastSkillCheck = 0

    RunService.Heartbeat:Connect(function()
        if not G("Utility.AutoRepair", false) and not G("Utility.AutoSkillCheck", false) then return end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Auto-Repair
        if G("Utility.AutoRepair", false) then
            local gens = findGenerators()
            for _, gen in ipairs(gens) do
                local genPos = nil
                if gen:IsA("BasePart") then genPos = gen.Position
                elseif gen:IsA("Model") then
                    local primary = gen.PrimaryPart or gen:FindFirstChildOfClass("BasePart")
                    if primary then genPos = primary.Position end
                end
                if genPos then
                    local dist = (genPos - hrp.Position).Magnitude
                    if dist < 15 then
                        for _, desc in ipairs(gen:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                pcall(function() desc:InputHoldBegin() end)
                                task.delay(0.1, function()
                                    pcall(function() desc:InputHoldEnd() end)
                                end)
                            end
                        end
                    elseif dist < 100 then
                        local dir = (genPos - hrp.Position).Unit
                        hrp.CFrame = hrp.CFrame + dir * 2
                    end
                end
            end
        end

        -- Auto-Skill Check (throttled)
        if G("Utility.AutoSkillCheck", false) then
            if tick() - lastSkillCheck > 0.5 then
                lastSkillCheck = tick()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetDescendants()) do
                        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                            local name = gui.Name:lower()
                            if name:find("skill") or name:find("check") or name:find("qte") then
                                for _, child in ipairs(gui:GetDescendants()) do
                                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                                        pcall(function()
                                            local vu = game:GetService("VirtualUser")
                                            vu:CaptureController()
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- FUST: Auto-Farm (handled in movement.lua, but add ChestESP here)
if gameId == "fust" then
    task.spawn(function()
        while task.wait(1) do
            if not G("Utility.ChestESP", false) then continue end
            -- scan for chests
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("chest") or obj.Name:lower():find("loot") or obj.Name:lower():find("barrel") then
                    -- could draw ESP here
                end
            end
        end
    end)
end

print("[KIRO UTILITY] Loaded. Game: " .. gameId)
return K