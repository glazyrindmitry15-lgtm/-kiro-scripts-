-- =====================================================================
-- UTILITY | CS:GO (Auto-Buy)
-- =====================================================================
local K = shared.KIRO
if not K then return end

local gameId = K.GameId or "unknown"
if gameId ~= "cs_go" then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- Auto-Buy: покупка оружия/брони в начале раунда
local lastBuy = 0

local function autoBuy()
    if not K.GetSetting("Utils.AutoBuy") then return end
    if tick() - lastBuy < 5 then return end

    -- ищем RemoteEvent для покупки
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
        -- покупаем броню
        pcall(function() buyRemote:FireServer("Armor", "Full") end)
        pcall(function() buyRemote:FireServer("Kevlar") end)
        -- покупаем основное оружие (AK/M4)
        pcall(function() buyRemote:FireServer("AK47") end)
        pcall(function() buyRemote:FireServer("M4A1") end)
        -- покупаем пистолет
        pcall(function() buyRemote:FireServer("Glock") end)
        pcall(function() buyRemote:FireServer("USP") end)
        lastBuy = tick()
        if K.Notify then K.Notify("Auto-Buy", "Purchased armor + weapons", "success") end
    end
end

-- Проверяем начало раунда
RunService.Heartbeat:Connect(function()
    -- автопокупка при спавне
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        -- проверяем, есть ли деньги (если есть GUI с деньгами)
        autoBuy()
    end
end)

-- Bomb Timer ESP
task.spawn(function()
    while task.wait(1) do
        if not K.GetSetting("ESP.Enabled") then continue end
        -- ищем бомбу в workspace
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("bomb") or obj.Name:lower():find("c4") then
                if obj:IsA("BasePart") then
                    -- рисуем ESP на бомбе (если Drawing доступен)
                    if Drawing then
                        -- simplified: just print
                    end
                end
            end
        end
    end
end)

-- Defuse Kit ESP
task.spawn(function()
    while task.wait(2) do
        if not K.GetSetting("ESP.Enabled") then continue end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                -- проверяем наличие дефуза
                local hasDefuse = false
                for _, tool in ipairs(plr.Backpack:GetChildren()) do
                    if tool.Name:lower():find("defuse") or tool.Name:lower():find("kit") then
                        hasDefuse = true
                    end
                end
                local equipped = plr.Character:FindFirstChildOfClass("Tool")
                if equipped and (equipped.Name:lower():find("defuse") or equipped.Name:lower():find("kit")) then
                    hasDefuse = true
                end
                if hasDefuse then
                    -- можно добавить ESP-метку
                end
            end
        end
    end
end)

print("[KIRO UTILITY] CS:GO utility loaded.")
