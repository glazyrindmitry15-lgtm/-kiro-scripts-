--[[
================================================================================
KIRO HACK | ADVANCED ANTI-DETECTION SECURITY CORE (security.lua)
================================================================================
Описание функций:

1. spoofProperties() — Перехват __index для спуфинга свойств объектов:
   WalkSpeed, JumpPower, Size, Velocity, Health, MaxHealth, HipHeight.
   Сохраняет оригинальные значения в K.OriginalProps для возврата античиту.
   Использует cloneref для сервисов и checkcaller для исключения собственных вызовов.

2. blockRemotes() — Перехват __namecall для умной блокировки ремоутов:
   Проверяет аргументы FireServer на паттерны (flag, ban, kick, exploit, speed).
   Логирует блокировки в консоль. Использует newcclosure для скрытия от debug.getinfo.

3. protectGUI() — Защита ScreenGui через gethui() / syn.protect_gui().
   Функция protectInstance(instance) переносит объект в безопасное место.

4. disableAnticheatConnections() — Отключение соединений античита через getconnections
   для событий PlayerAdded, CharacterAdded, Humanoid.Changed.

5. monitorNewScripts() — Мониторинг game.DescendantAdded на подозрительные LocalScript.

6. neutralizeSpecificAC() — Нейтрализация Adonis и IAC античитов через блокировку ремоутов.

7. simulateInput() — Безопасная симуляция ввода через keypress/keyrelease с задержками.
================================================================================
]]

local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Безопасные ссылки на сервисы через cloneref (если доступно)
local function safeClone(service)
    local ok, res = pcall(function() return cloneref(service) end)
    return ok and res or service
end

local SafePlayers = safeClone(Players)
local SafeRunService = safeClone(RunService)
local SafeWorkspace = safeClone(Workspace)
local SafeReplicatedStorage = safeClone(ReplicatedStorage)
local SafeCoreGui = safeClone(CoreGui)
local SafeLighting = safeClone(Lighting)

-- Таблица оригинальных свойств для спуфинга
K.OriginalProps = K.OriginalProps or {}

--==============================================================================
-- 1. РАСШИРЕННЫЙ СПУФИНГ СВОЙСТВ (__index)
--==============================================================================
local function spoofProperties()
    if not hookmetamethod then return end

    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        local isCaller = false
        pcall(function() isCaller = checkcaller() end)

        -- Не ломаем собственные вызовы чита
        if isCaller then return oldIndex(self, key) end

        if typeof(self) == "Instance" then
            -- Humanoid свойства
            if self:IsA("Humanoid") then
                if key == "WalkSpeed" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return 16 -- Возвращаем нормальную скорость античиту
                end
                if key == "JumpPower" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return 50
                end
                if key == "HipHeight" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return 2
                end
                if key == "Health" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return oldIndex(self, key)
                end
                if key == "MaxHealth" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return oldIndex(self, key)
                end
            end

            -- BasePart свойства
            if self:IsA("BasePart") then
                if key == "Size" then
                    if K.OriginalProps[self] == nil then
                        K.OriginalProps[self] = oldIndex(self, key)
                    end
                    return K.OriginalProps[self]
                end
                if key == "Velocity" then
                    return Vector3.new(0, 0, 0)
                end
            end
        end

        return oldIndex(self, key)
    end))
end

--==============================================================================
-- 2. УМНАЯ БЛОКИРОВКА РЕМОУТОВ (__namecall)
--==============================================================================
local function blockRemotes()
    if not hookmetamethod then return end

    local blockedPatterns = {
        "flag", "ban", "kick", "exploit", "speed", "detect", "anticheat",
        "cheat", "hack", "report", "log", "stat", "warn"
    }

    local function shouldBlockRemote(remote, args)
        local name = tostring(remote.Name):lower()
        -- Проверка по имени ремоута
        for _, pattern in ipairs(blockedPatterns) do
            if name:find(pattern) then
                return true, "remote_name:" .. pattern
            end
        end

        -- Проверка аргументов FireServer на подозрительные паттерны
        if args and type(args) == "table" then
            for i, arg in ipairs(args) do
                local argStr = tostring(arg):lower()
                for _, pattern in ipairs(blockedPatterns) do
                    if argStr:find(pattern) then
                        return true, "arg_" .. i .. ":" .. pattern
                    end
                end
            end
        end

        return false, nil
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local isCaller = false
        pcall(function() isCaller = checkcaller() end)

        if (not isCaller) and method == "FireServer" then
            local args = { ... }
            local blocked, reason = shouldBlockRemote(self, args)
            if blocked then
                -- Логируем блокировку (ограниченно, не спамим)
                if not K._remoteLog then K._remoteLog = {} end
                if not K._remoteLog[tostring(self)] then
                    K._remoteLog[tostring(self)] = true
                    print(string.format("[KIRO SECURITY] Blocked remote: %s (reason: %s)", tostring(self.Name), reason or "unknown"))
                end
                return
            end
        end

        return oldNamecall(self, ...)
    end))
end

--==============================================================================
-- 3. ЗАЩИТА GUI (gethui, protect_gui)
--==============================================================================
local function protectGUI()
    local function protectInstance(instance)
        if not instance then return end
        -- Пробуем syn.protect_gui
        local ok = pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(instance)
                return true
            end
        end)
        if ok then return end

        -- Пробуем перенести в gethui
        local gethuiOk, gethuiRes = pcall(function() return gethui() end)
        if gethuiOk and gethuiRes then
            pcall(function()
                instance.Parent = gethuiRes
            end)
        end
    end

    K.protectInstance = protectInstance

    -- Защищаем существующие ScreenGui в PlayerGui
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") or gui:IsA("GuiMain") then
                    protectInstance(gui)
                end
            end
        end
    end)
end

--==============================================================================
-- 4. ОТКЛЮЧЕНИЕ СОЕДИНЕНИЙ АНТИЧИТА (getconnections)
--==============================================================================
local function disableAnticheatConnections()
    if not getconnections then return end

    local suspiciousNames = {
        "anticheat", "anticheat", "detection", "detect", "guard", "shield",
        "ac_", "ban", "kick", "exploit", "cheat", "report", "monitor"
    }

    local function isSuspiciousScript(script)
        if not script then return false end
        local name = script.Name:lower()
        for _, pattern in ipairs(suspiciousNames) do
            if name:find(pattern) then return true end
        end
        return false
    end

    local events = {
        "PlayerAdded", "CharacterAdded", "ChildAdded", "DescendantAdded",
        "Humanoid.Changed", "HealthChanged", "Died", "Touching"
    }

    local function scanObject(obj)
        if not obj then return end
        for _, eventName in ipairs(events) do
            local ok, connections = pcall(function()
                return getconnections(obj[eventName])
            end)
            if ok and connections then
                for _, conn in ipairs(connections) do
                    local fn = conn.Function
                    if fn then
                        local info = pcall(function() return debug.getinfo(fn) end)
                        local src = ""
                        if info then src = info.short_src or "" end
                        if src:lower():find("anticheat") or src:lower():find("detection") or isSuspiciousScript(script) then
                            pcall(function() conn:Disable() end)
                        end
                    end
                end
            end
        end
    end

    -- Сканируем ключевые объекты
    scanObject(Players)
    scanObject(Workspace)
    scanObject(ReplicatedStorage)
    scanObject(LocalPlayer)

    -- Сканируем Humanoid в персонаже
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then scanObject(hum) end
    end
end

--==============================================================================
-- 5. МОНИТОРИНГ НОВЫХ СКРИПТОВ (DescendantAdded)
--==============================================================================
local function monitorNewScripts()
    local suspiciousNames = {
        "anti", "detect", "ac_", "guard", "shield", "ban", "kick",
        "exploit", "cheat", "report", "monitor", "watch"
    }

    Workspace.DescendantAdded:Connect(function(obj)
        if not obj:IsA("LocalScript") and not obj:IsA("Script") then return end

        local name = obj.Name:lower()
        for _, pattern in ipairs(suspiciousNames) do
            if name:find(pattern) then
                -- Мгновенно удаляем подозрительный скрипт
                pcall(function() obj:Destroy() end)
                print(string.format("[KIRO SECURITY] Destroyed suspicious script: %s", obj.Name))
                return
            end
        end
    end)

    -- Также мониторим ReplicatedStorage
    ReplicatedStorage.DescendantAdded:Connect(function(obj)
        if not obj:IsA("LocalScript") and not obj:IsA("Script") then return end
        local name = obj.Name:lower()
        for _, pattern in ipairs(suspiciousNames) do
            if name:find(pattern) then
                pcall(function() obj:Destroy() end)
                print(string.format("[KIRO SECURITY] Destroyed suspicious script in RS: %s", obj.Name))
                return
            end
        end
    end)
end

--==============================================================================
-- 6. НЕЙТРАЛИЗАЦИЯ КОНКРЕТНЫХ АНТИЧИТОВ (Adonis, IAC)
--==============================================================================
local function neutralizeSpecificAC()
    -- Adonis
    pcall(function()
        local adonis = ReplicatedStorage:FindFirstChild("Adonis")
        if adonis then
            -- Блокируем ремот Adonis.Detected
            local detected = adonis:FindFirstChild("Detected", true)
            if detected and detected:IsA("RemoteEvent") then
                local oldFire = detected.FireServer
                detected.FireServer = function(...) return end
                print("[KIRO SECURITY] Neutralized Adonis.Detected remote")
            end
        end
    end)

    -- IAC (Infinite Anti Cheat)
    pcall(function()
        local iac = ReplicatedStorage:FindFirstChild("IAC")
        if iac then
            local report = iac:FindFirstChild("Report", true)
            if report and report:IsA("RemoteEvent") then
                local oldFire = report.FireServer
                report.FireServer = function(...) return end
                print("[KIRO SECURITY] Neutralized IAC.Report remote")
            end
        end
    end)

    -- Общий античит по имени
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("anticheat") or name:find("detection") or name:find("ban") or name:find("kick") then
                    pcall(function()
                        local oldFire = obj.FireServer
                        obj.FireServer = function(...) return end
                    end)
                end
            end
        end
    end)
end

--==============================================================================
-- 7. БЕЗОПАСНАЯ СИМУЛЯЦИЯ ВВОДА
--==============================================================================
local function simulateInput(keyCode, holdTime)
    holdTime = holdTime or 0.1
    pcall(function()
        -- Попытка через keypress/keyrelease (если доступно)
        if keypress and keyrelease then
            keypress(keyCode)
            task.wait(holdTime)
            keyrelease(keyCode)
        elseif VirtualInputManager then
            -- Альтернатива через VirtualInputManager
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, keyCode, false, game)
            task.wait(holdTime)
            vim:SendKeyEvent(false, keyCode, false, game)
        end
    end)
end

local function simulateMouseClick()
    pcall(function()
        if VirtualInputManager then
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)
end

K.simulateInput = simulateInput
K.simulateMouseClick = simulateMouseClick

--==============================================================================
-- ИНИЦИАЛИЗАЦИЯ ВСЕХ МОДУЛЕЙ
--==============================================================================
task.spawn(function()
    spoofProperties()
    blockRemotes()
    protectGUI()
    disableAnticheatConnections()
    monitorNewScripts()
    neutralizeSpecificAC()
end)

print("[KIRO SECURITY] Advanced anti-detection loaded (spoofing, remote blocking, GUI protection, connection disabling, script monitoring, AC neutralization, input simulation).")
return K