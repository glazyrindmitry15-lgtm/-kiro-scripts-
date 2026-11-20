-- skins.lua | CS:GO Skin Changer
-- Discovers the game's OWN skin data (folder / Configuration / Model under a
-- name containing "skin") and copies its appearance onto your weapon.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local env = (getgenv and getgenv()) or _G or shared
local K = env.K or _G.K or shared.K or {}
env.K = K
_G.K = K

K.Settings = K.Settings or {}
K.Settings.Skins = K.Settings.Skins or {}
if K.Settings.Skins.ActiveSkin == nil then K.Settings.Skins.ActiveSkin = "Default" end

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
-- SKIN DISCOVERY
-- ============================================================
-- A "skin definition" is any instance under a name containing "skin":
--   * a Model whose BaseParts are the skinned appearance
--   * a Folder / Configuration carrying Color / Material / MeshId attributes
-- Each entry is flattened into a plain table so the UI can list it.
local SkinList = {}

local function attr(obj, ...)
    for _, name in ipairs({ ... }) do
        local ok, v = pcall(function() return obj:GetAttribute(name) end)
        if ok and v ~= nil then return v end
    end
    return nil
end

local function readAppearance(obj)
    local a = {
        color = attr(obj, "Color", "Colour", "color"),
        material = attr(obj, "Material", "material"),
        meshId = attr(obj, "MeshId", "Mesh", "mesh"),
        textureId = attr(obj, "TextureId", "Texture", "TextureID", "texture"),
        weapon = attr(obj, "Weapon", "Tool", "Item", "weapon"),
    }
    return a
end

local function collectParts(obj)
    local parts = {}
    if obj:IsA("BasePart") then
        parts[obj.Name] = obj
    end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("BasePart") then
            parts[d.Name] = parts[d.Name] or d
        end
    end
    return parts
end

local function buildList()
    local found = {}
    local seen = {}

    local roots = {}
    pcall(function()
        for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
            local n = d.Name:lower()
            if (d:IsA("Folder") or d:IsA("Configuration")) and n:find("skin") then
                table.insert(roots, d)
            end
        end
    end)
    pcall(function()
        for _, d in ipairs(workspace:GetDescendants()) do
            local n = d.Name:lower()
            if (d:IsA("Folder") or d:IsA("Configuration")) and n:find("skin") then
                table.insert(roots, d)
            end
        end
    end)

    for _, root in ipairs(roots) do
        local children = root:GetChildren()
        if #children == 0 and (root:IsA("Configuration") or root:IsA("Model")) then
            children = { root }
        end
        for _, child in ipairs(children) do
            if not seen[child] then
                seen[child] = true
                local a = readAppearance(child)
                table.insert(found, {
                    id = child.Name,
                    label = child.Name,
                    weapon = a.weapon and tostring(a.weapon) or nil,
                    object = child,
                    appearance = a,
                    parts = collectParts(child),
                })
            end
        end
    end

    SkinList = found
    return found
end

buildList()

-- refresh in case skins stream in later
task.spawn(function()
    while true do
        task.wait(10)
        pcall(buildList)
    end
end)

local function listLabels()
    local out = {}
    for _, s in ipairs(SkinList) do
        if s.weapon then
            table.insert(out, tostring(s.weapon) .. " : " .. s.label)
        else
            table.insert(out, s.label)
        end
    end
    if #out == 0 then table.insert(out, "Default") end
    return out
end

-- ============================================================
-- APPLY
-- ============================================================
local function findSkin(label)
    for _, s in ipairs(SkinList) do
        local l = s.weapon and (tostring(s.weapon) .. " : " .. s.label) or s.label
        if l == label then return s end
        if s.label == label then return s end
    end
    return nil
end

local function applyToTool(tool, skin)
    if not tool or not skin then return 0 end
    local applied = 0

    -- 1) copy per-part appearance from the skin Model
    for partName, srcPart in pairs(skin.parts or {}) do
        local dst = tool:FindFirstChild(partName, true)
        if dst and dst:IsA("BasePart") and srcPart:IsA("BasePart") then
            pcall(function()
                if srcPart.MeshId ~= "" then dst.MeshId = srcPart.MeshId end
                if srcPart.TextureID ~= "" then dst.TextureID = srcPart.TextureID end
                dst.Color = srcPart.Color
                dst.Material = srcPart.Material
                dst.Size = srcPart.Size
            end)
            applied += 1
        end
    end

    -- 2) apply attribute-style skin (Color / Material / Mesh / Texture)
    local a = skin.appearance or {}
    if a.color or a.material or a.meshId or a.textureId then
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("BasePart") then
                pcall(function()
                    if typeof(a.color) == "Color3" then d.Color = a.color end
                    if a.material then d.Material = a.material end
                    if typeof(a.meshId) == "string" and a.meshId ~= "" then d.MeshId = a.meshId end
                    if typeof(a.textureId) == "string" and a.textureId ~= "" then d.TextureID = a.textureId end
                end)
                applied += 1
            end
        end
    end

    return applied
end

local function getAllTools()
    local tools = {}
    local char = LocalPlayer.Character
    if char then
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then table.insert(tools, equipped) end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    return tools
end

local function applyAll()
    if not G("Skins.Enabled", false) then return end
    local label = G("Skins.ActiveSkin", "Default")
    local skin = findSkin(label)
    if not skin then return end

    for _, tool in ipairs(getAllTools()) do
        -- if the skin declares a weapon, only touch the matching tool
        if not skin.weapon or tool.Name == tostring(skin.weapon) then
            pcall(function() applyToTool(tool, skin) end)
        end
    end
end

K.Skins = {
    Apply = applyAll,
    List = listLabels,
    Find = findSkin,
    Entries = function() return SkinList end,
    Rebuild = buildList,
}

task.spawn(function()
    while true do
        task.wait(2)
        pcall(applyAll)
    end
end)

print(string.format("[KIRO SKINS] Skin changer loaded. Found %d skin definitions.", #SkinList))
for _, s in ipairs(SkinList) do
    print(string.format("   - %s (weapon: %s)", s.label, s.weapon or "any"))
end
return K