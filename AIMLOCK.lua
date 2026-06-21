-- POTATO'S MOBILE AIMLOCK + ESP (ARCEUS X)
-- Double-tap right side to toggle aimlock
-- Triple-tap left side to toggle smooth/instant

local TARGET_NAME = nil
local SMOOTH_MODE = true
local SMOOTH_SPEED = 0.35
local ESP_ENABLED = true
local WALL_CHECK = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local screenSize = Camera.ViewportSize

local aimlockActive = false
local tapCountRight = 0
local tapCountLeft = 0
local lastTapTimeRight = 0
local lastTapTimeLeft = 0

UserInputService.TouchTap:Connect(function(touch, processed)
    if processed then return end
    local pos = touch.Position
    local isRight = pos.X > screenSize.X / 2
    local time = tick()

    if isRight then
        if time - lastTapTimeRight < 0.4 then
            tapCountRight = tapCountRight + 1
        else
            tapCountRight = 1
        end
        lastTapTimeRight = time
        if tapCountRight >= 2 then
            aimlockActive = not aimlockActive
            print("Aimlock: " .. tostring(aimlockActive))
            tapCountRight = 0
        end
    else
        if time - lastTapTimeLeft < 0.4 then
            tapCountLeft = tapCountLeft + 1
        else
            tapCountLeft = 1
        end
        lastTapTimeLeft = time
        if tapCountLeft >= 3 then
            SMOOTH_MODE = not SMOOTH_MODE
            print("Smooth mode: " .. tostring(SMOOTH_MODE))
            tapCountLeft = 0
        end
    end
end)

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if TARGET_NAME and plr.Name ~= TARGET_NAME then continue end
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            if WALL_CHECK then
                local ray = Ray.new(camPos, (root.Position - camPos).unit * 1000)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                if hit and not hit:IsDescendantOf(plr.Character) then continue end
            end
            local d = (root.Position - camPos).magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end
    return closest
end

local espObjects = {}
local function createESP(plr)
    if not ESP_ENABLED then return end
    if espObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.new(1,0,0)
    box.Filled = false
    local healthBar = Drawing.new("Line")
    healthBar.Thickness = 3
    healthBar.Color = Color3.new(0,1,0)
    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Color = Color3.new(1,1,1)
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0,0,0)
    espObjects[plr] = {box = box, healthBar = healthBar, nameTag = nameTag}
end

local function updateESP()
    for plr, objs in pairs(espObjects) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.Humanoid.Health <= 0 then
            objs.box.Visible = false
            objs.healthBar.Visible = false
            objs.nameTag.Visible = false
            continue
        end
        local root = plr.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then
            objs.box.Visible = false
            objs.healthBar.Visible = false
            objs.nameTag.Visible = false
            continue
        end
        local size = 4 / (pos.Z / 10)
        local x, y = pos.X, pos.Y
        objs.box.Visible = true
        objs.box.Size = Vector2.new(size * 2, size * 3)
        objs.box.Position = Vector2.new(x - size, y - size * 1.5)
        local hp = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
        objs.healthBar.Visible = true
        objs.healthBar.From = Vector2.new(x - size, y + size * 1.8)
        objs.healthBar.To = Vector2.new(x - size + size * 2 * hp, y + size * 1.8)
        objs.healthBar.Color = Color3.new(1 - hp, hp, 0)
        objs.nameTag.Visible = true
        objs.nameTag.Position = Vector2.new(x, y - size * 2.2)
        objs.nameTag.Text = plr.Name .. " [" .. math.floor(plr.Character.Humanoid.Health) .. "HP]"
    end
end

local target = nil
local function aimlock()
    if not aimlockActive then
        target = nil
        return
    end
    local plr = getClosestPlayer()
    if not plr then target = nil; return end
    target = plr
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local targetPos = root.Position + Vector3.new(0, 1.5, 0)
    local camPos = Camera.CFrame.Position
    local lookVec = (targetPos - camPos).unit
    local newCF = CFrame.new(camPos, camPos + lookVec)
    if SMOOTH_MODE then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, SMOOTH_SPEED)
    else
        Camera.CFrame = newCF
    end
end

RunService.RenderStepped:Connect(function()
    aimlock()
    if ESP_ENABLED then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                createESP(plr)
            end
        end
        updateESP()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do obj:Remove() end
        espObjects[plr] = nil
    end
end)

print("📱 MOBILE AIMLOCK + ESP LOADED. Double-tap right side to toggle. Triple-tap left side to toggle smooth.")
