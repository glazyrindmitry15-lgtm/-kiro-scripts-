-- KIRO HACK | ADVANCED SECURITY CORE (ANTI-DETECTION)
local K = shared.KIRO
if not K then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- 1. СПУФИНГ СВОЙСТВ (Property Spoofing)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and typeof(self) == "Instance" then
        if self:IsA("Humanoid") and (key == "WalkSpeed" or key == "JumpPower") then
            return 16 -- Возвращаем стандартную скорость
        end
        if self:IsA("BasePart") and key == "Size" and K.OriginalSizes[self] then
            return K.OriginalSizes[self] -- Скрываем измененный размер (Big Head)
        end
    end
    return oldIndex(self, key)
end)

-- 2. БЛОКИРОВКА REMOTE-СОБЫТИЙ АНТИЧИТА (Remote Blocking)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "FireServer" then
        local name = self.Name:lower()
        -- Блокируем отправку "палевных" логов на сервер
        if name:find("anticheat") or name:find("detect") or name:find("ban") or name:find("report") then
            return
        end
    end
    return oldNamecall(self, ...)
end)

-- 3. БЕЗОПАСНАЯ СИМУЛЯЦИЯ ВВОДА (Safe Input)
-- Вместо VirtualUser используем менее заметный метод
function K.SafeInput(key)
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new()) -- ClickButton2 менее палевный, чем ClickButton1
    end)
end

-- 4. АНТИ-ДАМП (Anti-Dump)
-- Скрываем наши функции от анализа
local oldInfo = debug.info
debug.info = function(...)
    local args = {...}
    if typeof(args[1]) == "function" and getfenv(args[1]).KIRO_PROTECTED then
        return "C", "C", 1, 1 -- Притворяемся нативной C-функцией
    end
    return oldInfo(...)
end

-- 5. ОЧИСТКА СЛЕДОВ (Cleanup)
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            -- Восстанавливаем оригинальные размеры, если Big Head выключен
            if not K.Settings.Utils.HeadExpander then
                for part, size in pairs(K.OriginalSizes) do
                    if part and part.Parent then part.Size = size end
                end
                K.OriginalSizes = {}
            end
        end)
    end
end)

print("[KIRO SECURITY] Продвинутое ядро защиты активировано.")
