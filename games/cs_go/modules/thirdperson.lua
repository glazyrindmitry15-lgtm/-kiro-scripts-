local K = shared.KIRO
if not K then return end
if not K.GetSetting then K.GetSetting = function(path) return nil end end
if not K.SetSetting then K.SetSetting = function(path, v) end end
if not K.Notify then K.Notify = function(title, text, ntype) end end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Third person camera
local function setThirdPerson(on)
    if on then
        Camera.CameraType = Enum.CameraType.Custom
        -- offset behind player
        local dist = K.GetSetting("ThirdPerson.Distance") or 8
        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, dist)
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end

RunService.RenderStepped:Connect(function()
    if not K.GetSetting("ThirdPerson.Enabled") then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = K.GetSetting("ThirdPerson.Distance") or 8
    -- smooth follow behind
    local target = hrp.CFrame * CFrame.new(0, 2, dist)
    Camera.CFrame = Camera.CFrame:Lerp(target, 0.25)
    Camera.Focus = hrp.CFrame
end)

-- Character preview in menu (ViewportFrame)
local function createPreview(parent)
    if not K.GetSetting("ThirdPerson.Preview") then return end
    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(0, 160, 0, 200)
    viewport.Position = UDim2.new(1, -170, 0, 60)
    viewport.BackgroundColor3 = Color3.fromRGB(20,20,28)
    viewport.BorderSizePixel = 0
    viewport.Parent = parent
    Instance.new("UICorner", viewport).CornerRadius = UDim.new(0,8)

    local world = Instance.new("WorldModel", viewport)
    local cam = Instance.new("Camera")
    cam.Parent = viewport
    viewport.CurrentCamera = cam

    local function update()
        world:ClearAllChildren()
        local char = LP.Character
        if not char then return end
        local clone = char:Clone()
        clone.Parent = world
        -- remove scripts
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") then d:Destroy() end
        end
        local hrp = clone:FindFirstChild("HumanoidRootPart")
        if hrp then
            cam.CFrame = hrp.CFrame * CFrame.new(0, 2, 6) * CFrame.Angles(0, math.pi, 0)
            cam.Focus = hrp.CFrame
        end
    end

    update()
    LP.CharacterAdded:Connect(function() task.wait(1); update() end)
    task.spawn(function()
        while viewport.Parent do
            update()
            task.wait(1)
        end
    end)
end

-- attach preview when UI exists
task.spawn(function()
    task.wait(2)
    local gui = K.ScreenGui
    if gui and K.GetSetting("ThirdPerson.Preview") then
        createPreview(gui)
    end
end)

print("[KIRO THIRDPERSON] Модуль загружен.")
