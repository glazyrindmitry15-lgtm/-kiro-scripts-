local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local lastClock = os.clock()

-- Runs at Camera priority so the aimbot (Camera + 1) can still override the
-- rotation. Using RenderStepped here used to fight the aimbot every frame.
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
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not hrp then return end

    local now = os.clock()
    local dt = now - lastClock
    lastClock = now
    if dt <= 0 or dt > 0.1 then dt = 1 / 60 end

    local dist = tonumber(K.GetSetting("ThirdPerson.Distance")) or 8
    local target = hrp.CFrame * CFrame.new(0, 2, dist)

    cam.CameraType = Enum.CameraType.Scriptable
    -- frame-rate independent follow
    cam.CFrame = cam.CFrame:Lerp(target, 1 - math.exp(-12 * dt))
    cam.Focus = hrp.CFrame
end)

print("[KIRO THIRDPERSON] Loaded.")