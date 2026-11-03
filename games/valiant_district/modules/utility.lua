-- =====================================================================
-- UTILITY | Valiant District (Auto-Repair, Auto-Skill Check)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local gameId = K.GameId or "unknown"
if gameId ~= "valiant_district" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- Auto-Repair Generators
local cachedGens = {}
local lastGenUpdate = 0

local function findGenerators()
    if tick() - lastGenUpdate < 3 then return cachedGens end
    lastGenUpdate = tick()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("generator") or name:find("gen") or name:find("repair") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                table.insert(gens, obj)
            end
        end
    end
    -- также ищем ProximityPrompts рядом с генераторами
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
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

local function autoRepair()
    if not K.GetSetting("Utils.AutoRepair") then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

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
                -- ищем ProximityPrompt
                for _, desc in ipairs(gen:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        -- автоматически зажимаем E
                        pcall(function()
                            desc:InputHoldBegin()
                        end)
                        task.delay(0.1, function()
                            pcall(function() desc:InputHoldEnd() end)
                        end)
                    end
                end
            elseif dist < 100 then
                -- двигаемся к генератору
                local dir = (genPos - hrp.Position).Unit
                hrp.CFrame = hrp.CFrame + dir * 2
            end
        end
    end
end

-- Auto-Skill Check (QTE)
local function autoSkillCheck()
    if not K.GetSetting("Utils.AutoSkillCheck") then return end
    -- ищем GUI-элементы проверки на экране
    local playerGui = LP:FindFirstChild("PlayerGui")
    if not playerGui then return end
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = gui.Name:lower()
            if name:find("skill") or name:find("check") or name:find("qte") or name:find("prompt") then
                -- пытаемся нажать в нужную зону
                -- ищем кнопку/зону успеха
                for _, child in ipairs(gui:GetDescendants()) do
                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                        pcall(function()
                            -- симулируем клик
                            local vu = game:GetService("VirtualUser")
                            vu:CaptureController()
                        end)
                    end
                end
            end
        end
    end
    -- также проверяем ProximityPrompts с SkillCheck
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            -- если это skill check prompt, автоматически выполняем
            if prompt.Name:lower():find("skill") or prompt.Name:lower():find("check") then
                pcall(function()
                    prompt:InputHoldBegin()
                end)
                task.delay(0.05, function()
                    pcall(function() prompt:InputHoldEnd() end)
                end)
            end
        end
    end
end

local lastSkillCheck = 0
RunService.Heartbeat:Connect(function()
    autoRepair()
    if tick() - lastSkillCheck > 0.5 then
        lastSkillCheck = tick()
        autoSkillCheck()
    end
end)
end)

-- Auto-Collect (сбор предметов)
task.spawn(function()
    while task.wait(0.5) do
        if not K.GetSetting("Utils.AutoCollect") then continue end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("item") or obj.Name:lower():find("loot") or obj.Name:lower():find("pickup")) then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < 50 then
                    -- двигаемся к предмету
                    local dir = (obj.Position - hrp.Position).Unit
                    hrp.CFrame = hrp.CFrame + dir * 3
                end
            end
        end
    end
end)

print("[KIRO UTILITY] Valiant utility loaded.")
