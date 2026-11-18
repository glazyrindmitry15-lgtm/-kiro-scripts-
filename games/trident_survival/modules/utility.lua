-- utility.lua | Kiro Scripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
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

-- cached once, guarded
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

-- ============================================================
-- RЕЖИМ A: ШУТЕР (CS:GO) - Bomb Timer, Anti-Flash, Auto-Buy
-- ============================================================
if gameId == "cs_go" then
    -- Bomb Timer
    if G("Visuals.BombTimer", false) then
        task.spawn(function()
            while task.wait(0.2) do
                if not G("Visuals.BombTimer", false) then continue end
                local bomb = workspace:FindFirstChild("Bomb") or workspace:FindFirstChild("C4")
                if bomb and bomb:IsA("BasePart") then
                    -- Ищем таймер в атрибутах или значениях
                    local timer = bomb:GetAttribute("Timer") or bomb:GetAttribute("TimeLeft")
                    if not timer then
                        for _, v in ipairs(bomb:GetDescendants()) do
                            if v:IsA("NumberValue") or v:IsA("IntValue") then
                                if v.Name:lower():find("time") or v.Name:lower():find("timer") then
                                    timer = v.Value
                                    break
                                end
                            end
                        end
                    end
                    if timer and Drawing then
                        -- Рисуем таймер над бомбой через Drawing API
                        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(bomb.Position)
                        if onScreen and not _G.KiroBombTimer then
                            _G.KiroBombTimer = Drawing.new("Text")
                            _G.KiroBombTimer.Size = 24
                            _G.KiroBombTimer.Center = true
                            _G.KiroBombTimer.Outline = true
                            _G.KiroBombTimer.Color = Color3.fromRGB(255, 200, 60)
                        end
                        if _G.KiroBombTimer then
                            _G.KiroBombTimer.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                            _G.KiroBombTimer.Text = string.format("💣 %.1fs", timer)
                            _G.KiroBombTimer.Visible = true
                        end
                    end
                elseif _G.KiroBombTimer then
                    _G.KiroBombTimer.Visible = false
                end
            end
        end)
    end

    -- Anti-Flash (удаление BlurEffect и ScreenGui флешек)
    if G("Visuals.AntiFlash", false) then
        task.spawn(function()
            while task.wait(0.1) do
                if not G("Visuals.AntiFlash", false) then continue end
                -- Удаляем BlurEffect из Lighting
                for _, effect in ipairs(Lighting:GetChildren()) do
                    if effect:IsA("BlurEffect") then
                        pcall(function() effect:Destroy() end)
                    end
                end
                -- Удаляем флеш-гуи
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetDescendants()) do
                        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                            local name = gui.Name:lower()
                            if name:find("flash") or name:find("bang") or name:find("stun") then
                                pcall(function()
                                    gui.Visible = false
                                    gui:Destroy()
                                end)
                            end
                        end
                    end
                end
            end
        end)
    end

    -- Auto-Buy (покупка брони и оружия)
    if G("Utility.AutoBuy", false) then
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
end

-- ============================================================
-- RЕЖИМ B: ВЫЖИВАНИЕ (DEGRADE / Rust clone) - Auto-Swing, Auto-Collect
-- ============================================================
if gameId == "fust" or gameId == "trident_survival" then
    -- DEGRADE entity keywords
    local KW_HARVEST = {
        "tree", "oak", "pine", "fir", "birch", "cedar", "stump", "wood", "log",
        "stone", "rock", "ore", "sulfur", "metal", "node", "boulder", "clay",
    }
    local KW_PICKUP = {
        "crate", "barrel", "loot", "drop", "item", "pickup",
        "trash", "supply", "box", "lootbag",
    }

    local function nameHas(name, list)
        for _, k in ipairs(list) do
            if name:find(k, 1, true) then return true end
        end
        return false
    end

    -- Resource cache (TTL 1.5s), split into harvestables and pickups
    local cachedHarvest, cachedPickup = {}, {}
    local lastResUpdate = 0
    local function getResources()
        -- do not sweep the workspace at all while the features are off
        local needHarvest = G("Utility.AutoSwing", false) or G("Utility.AutoFarm", false)
        local needPickup = G("Utility.AutoCollect", false)
        if not needHarvest and not needPickup then return cachedHarvest, cachedPickup end
        if tick() - lastResUpdate < 3 then return cachedHarvest, cachedPickup end
        lastResUpdate = tick()
        local harvest, pickup = {}, {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if nameHas(n, KW_HARVEST) then
                    table.insert(harvest, obj)
                elseif nameHas(n, KW_PICKUP) then
                    table.insert(pickup, obj)
                end
            end
        end
        cachedHarvest, cachedPickup = harvest, pickup
        return harvest, pickup
    end

    -- Auto-Farm is an alias of Auto-Swing (same harvest loop)
    local function farmingOn()
        return G("Utility.AutoSwing", false) or G("Utility.AutoFarm", false)
    end

    -- Auto-Swing / Auto-Farm (авто-удар по ресурсам/деревьям/камням)
    if G("Utility.AutoSwing", false) or G("Utility.AutoFarm", false) then
        local lastSwing = 0
        RunService.Heartbeat:Connect(function()
            if not farmingOn() then return end
            if tick() - lastSwing < 0.3 then return end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not hrp or not tool then return end

            -- Ищем добываемые ресурсы рядом (cached)
            local harvest = getResources()
            local closestResource = nil
            local closestPos = nil
            local closestDist = 15
            for _, obj in ipairs(harvest) do
                local pos = obj:IsA("BasePart") and obj.Position
                    or (obj.PrimaryPart and obj.PrimaryPart.Position)
                    or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position)
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestResource = obj
                        closestPos = pos
                    end
                end
            end

            if closestResource and closestPos then
                -- Поворачиваемся к ресурсу
                local dir = (closestPos - hrp.Position)
                if dir.Magnitude > 0 then
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir.Unit)
                end
                -- Активируем инструмент
                pcall(function() tool:Activate() end)
                lastSwing = tick()
            end
        end)
    end

    -- Auto-Collect (авто-сбор лута/ящиков/предметов)
    if G("Utility.AutoCollect", false) then
        task.spawn(function()
            while task.wait(0.5) do
                if not G("Utility.AutoCollect", false) then continue end

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local _, pickup = getResources()
                for _, obj in ipairs(pickup) do
                    local pos = obj:IsA("BasePart") and obj.Position
                        or (obj.PrimaryPart and obj.PrimaryPart.Position)
                    if pos and (pos - hrp.Position).Magnitude < 20 then
                        -- Пытаемся подобрать через ProximityPrompt
                        local usedPrompt = false
                        for _, desc in ipairs(obj:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                usedPrompt = true
                                pcall(function() desc:InputHoldBegin() end)
                                task.delay(0.1, function()
                                    pcall(function() desc:InputHoldEnd() end)
                                end)
                                break
                            end
                        end
                        -- Если промпта нет - телепортируемся к объекту
                        if not usedPrompt then
                            hrp.CFrame = CFrame.new(pos)
                        end
                    end
                end
            end
        end)
    end
end

-- ============================================================
-- RЕЖИМ C: ХОРРОР (VALIANT DISTRICT) - Auto-Repair, Speed (LinearVelocity)
-- ============================================================
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
                                        if VirtualUser then
                                            pcall(function()
                                                VirtualUser:CaptureController()
                                                VirtualUser:ClickButton1(Vector2.new())
                                            end)
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Speed через LinearVelocity (фикс откатов)
    if G("Misc.Speed", false) then
        RunService.RenderStepped:Connect(function()
            if not G("Misc.Speed", false) then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local lv = hrp:FindFirstChild("SpeedLV")
                if not lv then
                    lv = Instance.new("LinearVelocity")
                    lv.Name = "SpeedLV"
                    lv.MaxForce = 1e9
                    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                    lv.Attachment0 = hrp:FindFirstChild("RootRigAttachment") or Instance.new("Attachment", hrp)
                    lv.Parent = hrp
                end
                lv.VectorVelocity = moveDir * (G("Misc.WalkSpeed", 16) or 16)
            else
                local lv = hrp:FindFirstChild("SpeedLV")
                if lv then lv:Destroy() end
            end
        end)
    end
end

-- ============================================================
-- ОБЩИЕ ФУНКЦИИ (Fullbright для всех игр)
-- ============================================================
if G("Misc.Fullbright", false) then
    RunService.RenderStepped:Connect(function()
        if not G("Misc.Fullbright", false) then return end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end)
end

print("[KIRO UTILITY] Loaded. Game: " .. gameId)
return K