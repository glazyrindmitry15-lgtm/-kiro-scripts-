local K = shared.KIRO
if not K then return end
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Speed
RunService.Heartbeat:Connect(function()
    if K.GetSetting("Misc.Speed") then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = K.GetSetting("Misc.SpeedValue") or 32 end
    end
    if K.GetSetting("Misc.Noclip") then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Fly
local flying = false
local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    if K.GetSetting("Misc.Fly") then
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not flying then
            flying = true
            flyBV = Instance.new("BodyVelocity")
            flyBV.Velocity = Vector3.new(0,0,0)
            flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        flyBV.Velocity = move * (K.GetSetting("Misc.FlySpeed") or 50)
        flyBG.CFrame = cam.CFrame
    else
        if flying then
            flying = false
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if K.GetSetting("Misc.InfiniteJump") then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if K.GetSetting("Misc.AntiAFK") then
            pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
        end
    end)
end)

print("[KIRO MISC] Модуль загружен.")
