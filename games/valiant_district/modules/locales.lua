-- locales.lua | Kiro Scripts Localization
local K = shared.KIRO or {}
K.Locales = K.Locales or {}

K.Languages = {"RU", "EN", "JA"}
K.Lang = K.Lang or "RU"

local Translations = {
    RU = {
        Tab_Combat = "Бой",
        Tab_Visuals = "Визуалы",
        Tab_Utility = "Утилиты",
        Tab_Misc = "Разное",

        Sec_Aimbot = "АИМБОТ И ОРУЖИЕ",
        Sec_CSGO = "CS:GO ФУНКЦИИ",
        Sec_ESP = "ESP И ПОДСВЕТКА",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST ФУНКЦИИ",
        Sec_Movement = "ПЕРЕДВИЖЕНИЕ",
        Sec_World = "МИР И ИГРОК",
        Sec_Radar = "РАДАР",

        Aimbot = "Включить Аимбот",
        SilentAim = "Сайлент Аим",
        ShowFOV = "Показать радиус FOV",
        FOV = "Радиус FOV",
        Smoothness = "Плавность наводки",
        WallCheck = "Проверка стен",
        TeamCheck = "Проверка команды",

        Triggerbot = "Триггербот",
        TriggerDelay = "Задержка триггера (мс)",
        RCS = "Контроль отдачи (RCS)",
        RCSStrength = "Сила контроля отдачи (%)",
        AutoBuy = "Авто-Закуп",

        ESPEnabled = "Включить ESP",
        BoxESP = "Боксы",
        NameESP = "Имена игроков",
        HealthESP = "Полоска здоровья",
        Tracers = "Линии до игроков",
        Chams = "Чамсы",
        Radar = "Радар",
        MaxDistance = "Макс. дистанция ESP",

        AutoRepair = "Авто-Починка",
        AutoSkillCheck = "Авто Скилл-Чек",
        KillerESP = "ESP на Маньяка",
        GeneratorESP = "ESP на Генераторы",

        AutoFarm = "Авто-Фарм",
        Speed = "Ускорение",
        ChestESP = "ESP на сундуки",

        Fly = "Полет",
        FlySpeed = "Скорость полета",
        Noclip = "Сквозь стены",
        InfJump = "Бесконечный прыжок",
        WalkSpeed = "Скорость ходьбы",
        JumpPower = "Сила прыжка",
        BunnyHop = "Баннихоп",
        Fullbright = "Яркое освещение"
    },
    EN = {
        Tab_Combat = "Combat",
        Tab_Visuals = "Visuals",
        Tab_Utility = "Utility",
        Tab_Misc = "Misc",

        Sec_Aimbot = "AIMBOT & WEAPON",
        Sec_CSGO = "CS:GO FEATURES",
        Sec_ESP = "ESP & VISUALS",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST FEATURES",
        Sec_Movement = "MOVEMENT",
        Sec_World = "WORLD & PLAYER",
        Sec_Radar = "RADAR",

        Aimbot = "Enable Aimbot",
        SilentAim = "Silent Aim",
        ShowFOV = "Show FOV Circle",
        FOV = "FOV Radius",
        Smoothness = "Aim Smoothness",
        WallCheck = "Wall Check",
        TeamCheck = "Team Check",

        Triggerbot = "Triggerbot",
        TriggerDelay = "Trigger Delay (ms)",
        RCS = "Recoil Control (RCS)",
        RCSStrength = "RCS Strength (%)",
        AutoBuy = "Auto-Buy Gear",

        ESPEnabled = "Enable ESP",
        BoxESP = "Box ESP",
        NameESP = "Name ESP",
        HealthESP = "Health Bar",
        Tracers = "Tracers",
        Chams = "Chams Highlight",
        Radar = "Radar",
        MaxDistance = "ESP Max Distance",

        AutoRepair = "Auto Repair",
        AutoSkillCheck = "Auto Skill Check",
        KillerESP = "Killer ESP",
        GeneratorESP = "Generator ESP",

        AutoFarm = "Auto-Farm",
        Speed = "Speed Hack",
        ChestESP = "Chest ESP",

        Fly = "Fly",
        FlySpeed = "Fly Speed",
        Noclip = "Noclip",
        InfJump = "Infinite Jump",
        WalkSpeed = "WalkSpeed",
        JumpPower = "JumpPower",
        BunnyHop = "BunnyHop",
        Fullbright = "Fullbright"
    },
    JA = {
        Tab_Combat = "戦闘",
        Tab_Visuals = "ビジュアル",
        Tab_Utility = "ユーティリティ",
        Tab_Misc = "その他",

        Sec_Aimbot = "エイムボット & 武器",
        Sec_CSGO = "CS:GO 機能",
        Sec_ESP = "ESP & ビジュアル",
        Sec_Valiant = "VALIANT DISTRICT",
        Sec_FUST = "FUST 機能",
        Sec_Movement = "移動",
        Sec_World = "ワールド & プレイヤー",
        Sec_Radar = "レーダー",

        Aimbot = "エイムボット有効",
        SilentAim = "サイレントエイム",
        ShowFOV = "FOV表示",
        FOV = "FOV半径",
        Smoothness = "滑らかさ",
        WallCheck = "壁チェック",
        TeamCheck = "チームチェック",

        Triggerbot = "トリガーボット",
        TriggerDelay = "トリガー遅延 (ms)",
        RCS = "反動制御 (RCS)",
        RCSStrength = "RCS強度 (%)",
        AutoBuy = "自動購入",

        ESPEnabled = "ESP有効",
        BoxESP = "ボックスESP",
        NameESP = "名前表示",
        HealthESP = "ヘルスバー",
        Tracers = "トレーサー",
        Chams = "チャンムス",
        Radar = "レーダー",
        MaxDistance = "ESP最大距離",

        AutoRepair = "自動修理",
        AutoSkillCheck = "自動スキルチェック",
        KillerESP = "キラーESP",
        GeneratorESP = "発電機ESP",

        AutoFarm = "自動ファーム",
        Speed = "スピードハック",
        ChestESP = "チェストESP",

        Fly = "飛行",
        FlySpeed = "飛行速度",
        Noclip = "ノックリップ",
        InfJump = "無限ジャンプ",
        WalkSpeed = "移動速度",
        JumpPower = "ジャンプ力",
        BunnyHop = "バニーホップ",
        Fullbright = "フルブライト"
    }
}

function K.L(key)
    local lang = K.Lang or "RU"
    local t = Translations[lang] or Translations.RU
    return t[key] or key
end

-- Cycle language
function K.CycleLanguage()
    local idx = 1
    for i, l in ipairs(K.Languages) do
        if l == K.Lang then idx = i break end
    end
    idx = idx % #K.Languages + 1
    K.Lang = K.Languages[idx]
    return K.Lang
end

print("[KIRO LOCALES] Loaded. Lang: " .. K.Lang)
return K