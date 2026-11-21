local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local lastClock = os.clock()

local function makeVisible(char)
    -- games hide the local character in first person by setting
    -- LocalTransparencyModifier on every part; that is why you could not see yourself
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.LocalTransparencyModifier ~= 0 then
            pcall(function() p.LocalTransparencyModifier = 0 end)
        end
    end
end

-- Runs at Camera priority; the aimbot (Camera + 1) can still override rotation.
RunService:BindToRenderStep("KiroThirdPerson", Enum.RenderPriority.Camera.Value, function()
    local cam = workspace.CurrentCamera
    if not cam then return end

    if not K.GetSetting("ThirdPerson.Enabled") then
        if cam.CameraType == Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Custom
        end
        return
    end

    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
    if not hrp then return end

    makeVisible(char)

    local now = os.clock()
    local dt = now - lastClock
    lastClock = now
    if dt <= 0 or dt > 0.1 then dt = 1 / 60 end

    local dist = tonumber(K.GetSetting("ThirdPerson.Distance")) or 8
    local target = hrp.CFrame * CFrame.new(0, 2, dist)

    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = cam.CFrame:Lerp(target, 1 - math.exp(-12 * dt))
    cam.Focus = hrp.CFrame
end)

print("[KIRO THIRDPERSON] Loaded.")
return K