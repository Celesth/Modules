local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local saveKey = "FPS_Ping_GUI_Position"
local savedPosition = nil
pcall(function()
    savedPosition = HttpService:JSONDecode(player:GetAttribute(saveKey) or "")
end)

-- 🖤 Main Frame (Properly Curved & Fixed Blur)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 30)
frame.Position = savedPosition and UDim2.new(0, savedPosition.X, 0, savedPosition.Y) or UDim2.new(0.5, -80, 0.02, 0)
frame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true -- ✅ This fixes the overflow issue!

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 15)

-- ✅ **Fix for Non-Curved Box Issue** ✅
local blur = Instance.new("ImageLabel", frame)
blur.Size = UDim2.new(1, 0, 1, 0)
blur.Position = UDim2.new(0, 0, 0, 0)
blur.BackgroundTransparency = 1
blur.Image = "rbxassetid://1316045217"
blur.ImageColor3 = Color3.fromRGB(0, 0, 0)
blur.ImageTransparency = 0.8
blur.ScaleType = Enum.ScaleType.Slice
blur.SliceCenter = Rect.new(10, 10, 90, 90)
blur.ZIndex = -1 -- ✅ Makes sure it doesn’t interfere with text

-- ➖ Divider Line
local divider = Instance.new("Frame", frame)
divider.Size = UDim2.new(0, 1, 0.8, 0)
divider.Position = UDim2.new(0.5, 0, 0.1, 0)
divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

-- 🎮 FPS Label
local fpsLabel = Instance.new("TextLabel", frame)
fpsLabel.Size = UDim2.new(0.5, -10, 1, 0)
fpsLabel.Position = UDim2.new(0, 5, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 10
fpsLabel.Text = "FPS: --"
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- 📶 Ping Label
local pingLabel = Instance.new("TextLabel", frame)
pingLabel.Size = UDim2.new(0.5, -10, 1, 0)
pingLabel.Position = UDim2.new(0.5, 5, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
pingLabel.Font = Enum.Font.Code
pingLabel.TextSize = 10
pingLabel.Text = "Ping: --"
pingLabel.TextXAlignment = Enum.TextXAlignment.Right

-- 🎯 Update FPS & Ping
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    fpsLabel.Text = "FPS: " .. fps
    pingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
end)

-- 🔥 Auto-Save Position Every 1 Minute
task.spawn(function()
    while task.wait(60) do
        local pos = frame.Position
        local data = {X = pos.X.Offset, Y = pos.Y.Offset}
        pcall(function()
            player:SetAttribute(saveKey, HttpService:JSONEncode(data))
        end)
    end
end)

print("✅ Dynamic Island-Style FPS & Ping GUI Fixed & Loaded!")
