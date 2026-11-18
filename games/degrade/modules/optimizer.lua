-- optimizer.lua | DEGRADE FPS optimizer
-- Removes grass/foliage, particles, shadows, terrain decoration and drops
-- render quality. Fully reversible: every change is stored and restored.
local K = shared.KIRO
if not K then return end
if K.GameId ~= "degrade" then return end

local Workspace = workspace
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- ============================================================
-- CONFIG
-- ============================================================
local GRASS_KEYWORDS = {
    "grass", "weed", "bush", "fern", "plant", "foliage", "shrub",
    "ivy", "leaf", "leaves", "flower", "petal", "vine", "sapling",
}

local PARTICLE_CLASSES = {
    "ParticleEmitter", "Trail", "Beam", "Fire", "Sparkles",
}

local function nameHas(name, list)
    for _, k in ipairs(list) do
        if name:find(k, 1, true) then return true end
    end
    return false
end

-- ============================================================
-- STATE
-- ============================================================
local culledParts = {}            -- [BasePart] = originalCanCollidable
local culledDecals = {}           -- [Decal/Texture] = originalTransparency
local disabledParticles = {}      -- [Instance] = originalEnabled
local originalLighting = nil
local originalDecoration = nil
local originalQuality = nil
local originalRadius = nil
local originalWater = nil
local applied = false
local generation = 0

-- ============================================================
-- RESTORE
-- ============================================================
local function restore()
    generation += 1
    for part, wasCollidable in pairs(culledParts) do
        pcall(function()
            part.LocalTransparencyModifier = 0
            part.CastShadow = true
            part.CanCollide = wasCollidable and true or false
        end)
    end
    culledParts = {}

    for obj, wasEnabled in pairs(disabledParticles) do
        pcall(function() obj.Enabled = wasEnabled end)
    end
    disabledParticles = {}

    for obj, wasTransparency in pairs(culledDecals) do
        pcall(function() obj.Transparency = wasTransparency end)
    end
    culledDecals = {}

    if originalWater then
        pcall(function()
            Workspace.Terrain.WaterWaveSize = originalWater[1]
            Workspace.Terrain.WaterReflectance = originalWater[2]
            Workspace.Terrain.WaterTransparency = originalWater[3]
        end)
        originalWater = nil
    end

    if originalLighting then
        pcall(function() Lighting.GlobalShadows = originalLighting end)
        originalLighting = nil
    end

    if originalDecoration ~= nil then
        pcall(function() Workspace.Terrain.Decoration = originalDecoration end)
        originalDecoration = nil
    end

    if originalQuality ~= nil then
        pcall(function() settings().Rendering.QualityLevel = originalQuality end)
        originalQuality = nil
    end

    if originalRadius then
        pcall(function() Workspace.StreamingTargetRadius = originalRadius end)
        originalRadius = nil
    end

    applied = false
end

-- ============================================================
-- APPLY (chunked so a huge map never freezes the client)
-- ============================================================
local function sweep(callback)
    local myGen = generation
    local i = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if myGen ~= generation then return end
        i += 1
        if i % 400 == 0 then task.wait() end
        pcall(callback, obj)
    end
end

local function applyGrass()
    sweep(function(obj)
        if not obj:IsA("BasePart") then return end
        if not nameHas(obj.Name:lower(), GRASS_KEYWORDS) then return end
        if culledParts[obj] ~= nil then return end

        local wasCollidable = true
        pcall(function() wasCollidable = obj.CanCollide end)
        culledParts[obj] = wasCollidable
        if obj.LocalTransparencyModifier < 1 then
            obj.LocalTransparencyModifier = 1
        end
        pcall(function()
            obj.CastShadow = false
            obj.CanCollide = false
        end)
    end)
end

local function applyParticles()
    sweep(function(obj)
        for _, cls in ipairs(PARTICLE_CLASSES) do
            if obj:IsA(cls) then
                if not disabledParticles[obj] then
                    local wasEnabled = true
                    pcall(function() wasEnabled = obj.Enabled end)
                    disabledParticles[obj] = wasEnabled
                end
                pcall(function() obj.Enabled = false end)
                return
            end
        end
    end)
end

local function applyDecals()
    sweep(function(obj)
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if culledDecals[obj] == nil then
                culledDecals[obj] = obj.Transparency
                pcall(function() obj.Transparency = 1 end)
            end
        end
    end)
end

local function applyWater()
    if originalWater == nil then
        local ok, a, b, c = pcall(function()
            return Workspace.Terrain.WaterWaveSize,
                Workspace.Terrain.WaterReflectance,
                Workspace.Terrain.WaterTransparency
        end)
        if ok then originalWater = { a, b, c } end
    end
    pcall(function()
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 1
    end)
end

local function applyLighting()
    if originalLighting == nil then
        local ok, val = pcall(function() return Lighting.GlobalShadows end)
        originalLighting = ok and val or true
    end
    pcall(function() Lighting.GlobalShadows = false end)
end

local function applyTerrain()
    if originalDecoration == nil then
        local ok, val = pcall(function() return Workspace.Terrain.Decoration end)
        originalDecoration = ok and val or true
    end
    pcall(function() Workspace.Terrain.Decoration = false end)
end

local function applyQuality()
    if originalQuality == nil then
        pcall(function() originalQuality = settings().Rendering.QualityLevel end)
    end
    pcall(function() settings().Rendering.QualityLevel = 1 end)
end

local function applyStreaming()
    local ok, enabled = pcall(function() return Workspace.StreamingEnabled end)
    if not ok or not enabled then return end
    if originalRadius == nil then
        pcall(function() originalRadius = Workspace.StreamingTargetRadius end)
    end
    pcall(function()
        if Workspace.StreamingTargetRadius > 600 then
            Workspace.StreamingTargetRadius = 600
        end
    end)
end

-- ============================================================
-- PUBLIC API
-- ============================================================
local Optimizer = {}

function Optimizer.Apply()
    if applied then return end
    applied = true
    generation += 1

    if G("Optimizer.Grass", true) then applyGrass() end
    if G("Optimizer.Particles", true) then applyParticles() end
    if G("Optimizer.Decals", true) then applyDecals() end
    if G("Optimizer.Water", true) then applyWater() end
    if G("Optimizer.Shadows", true) then applyLighting() end
    if G("Optimizer.Terrain", true) then applyTerrain() end
    if G("Optimizer.Quality", true) then applyQuality() end
    if G("Optimizer.Streaming", false) then applyStreaming() end

    if K.Notify then
        K.Notify("Optimizer", "Applied: grass/particles/shadows trimmed", "success")
    end
end

function Optimizer.Restore()
    restore()
    if K.Notify then
        K.Notify("Optimizer", "Original visuals restored", "info")
    end
end

function Optimizer.IsActive()
    return applied
end

K.Optimizer = Optimizer

-- ============================================================
-- WATCH SETTINGS (poll: no conflict with other OnSettingChanged users)
-- ============================================================
local function signature()
    return table.concat({
        tostring(G("Optimizer.Grass", true)),
        tostring(G("Optimizer.Particles", true)),
        tostring(G("Optimizer.Decals", true)),
        tostring(G("Optimizer.Water", true)),
        tostring(G("Optimizer.Shadows", true)),
        tostring(G("Optimizer.Terrain", true)),
        tostring(G("Optimizer.Quality", true)),
        tostring(G("Optimizer.Streaming", false)),
    }, "|")
end

local wasEnabled = false
local lastSig = nil

task.spawn(function()
    while true do
        task.wait(0.4)

        local enabled = G("Optimizer.Enabled", false) and true or false

        if enabled ~= wasEnabled then
            wasEnabled = enabled
            if enabled then
                Optimizer.Apply()
                lastSig = signature()
            else
                Optimizer.Restore()
                lastSig = nil
            end
        elseif enabled and applied then
            -- sub-toggles changed while master is on -> rebuild
            local sig = signature()
            if sig ~= lastSig then
                Optimizer.Restore()
                Optimizer.Apply()
                lastSig = sig
            end
        end
    end
end)

-- re-sweep periodically so streamed-in foliage/particles get culled too
task.spawn(function()
    while true do
        task.wait(8)
        if applied and wasEnabled then
            if G("Optimizer.Grass", true) then applyGrass() end
            if G("Optimizer.Particles", true) then applyParticles() end
            if G("Optimizer.Decals", true) then applyDecals() end
        end
    end
end)

print("[KIRO OPTIMIZER] Loaded (DEGRADE).")
return K