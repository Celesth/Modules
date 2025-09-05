--!strict
-- Modern Notification Library
-- Author: Celesth & Homie

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Notify = {}
Notify.__index = Notify

-- UI Holder
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotifyLib"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local container = Instance.new("Frame")
container.Name = "Container"
container.BackgroundTransparency = 1
container.Size = UDim2.new(1, -20, 1, -20)
container.Position = UDim2.new(0, 0, 0, 0)
container.AnchorPoint = Vector2.new(0, 0)
container.Parent = screenGui

-- Notification stacking
local activeNotifications = {}

-- Create Notification
function Notify.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Notify)

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 90)
    frame.AnchorPoint = Vector2.new(0, 1)
    frame.Position = UDim2.new(0, 20, 1, -20)
    frame.BackgroundColor3 = Color3.fromHex("#0d222f")
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.05
    frame.Parent = container

    -- Border (semi transparent)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.75
    stroke.Thickness = 1.2
    stroke.Parent = frame

    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    -- Icon
    if opts.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 28, 0, 28)
        icon.Position = UDim2.new(0, 10, 0, 10)
        icon.BackgroundTransparency = 1
        icon.Image = opts.Icon
        icon.Parent = frame
    end

    -- Title
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 50, 0, 8)
    title.Size = UDim2.new(1, -60, 0, 20)
    title.Font = Enum.Font.Code
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromHex("#f178a1")
    title.Text = opts.Title or "Notification"
    title.Parent = frame

    -- Message
    local message = Instance.new("TextLabel")
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 15, 0, 35)
    message.Size = UDim2.new(1, -30, 1, -45)
    message.Font = Enum.Font.Code
    message.TextSize = 14
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextYAlignment = Enum.TextYAlignment.Top
    message.TextColor3 = Color3.fromHex("#f1c8d6")
    message.Text = opts.Text or ""
    message.Parent = frame

    -- Close button (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromHex("#f1c8d6")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)

    -- Yes/No Buttons
    if opts.YesNo then
        local yes = Instance.new("TextButton")
        yes.Size = UDim2.new(0.45, -5, 0, 25)
        yes.Position = UDim2.new(0, 10, 1, -35)
        yes.BackgroundColor3 = Color3.fromHex("#f178a1")
        yes.Text = "Yes"
        yes.Font = Enum.Font.Code
        yes.TextSize = 14
        yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        yes.Parent = frame
        yes.MouseButton1Click:Connect(function()
            if opts.OnYes then opts.OnYes() end
            self:Close()
        end)

        local no = yes:Clone()
        no.Text = "No"
        no.Position = UDim2.new(0.55, 0, 1, -35)
        no.Parent = frame
        no.MouseButton1Click:Connect(function()
            if opts.OnNo then opts.OnNo() end
            self:Close()
        end)

        opts.Duration = nil -- disable auto close
    end

    -- Animate in (bottom-right stack)
    table.insert(activeNotifications, 1, frame)
    for i, notif in ipairs(activeNotifications) do
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -320, 1, -(i * 100))
        }):Play()
    end

    -- Store references
    self.Frame = frame
    self.Message = message
    self.Duration = opts.Duration or 5
    self.Destroyed = false

    -- Auto-close timer
    if self.Duration and not opts.YesNo then
        task.spawn(function()
            task.wait(self.Duration)
            if not self.Destroyed then
                self:Close()
            end
        end)
    end

    return self
end

-- Update text
function Notify:UpdateText(newText)
    if self.Message then
        self.Message.Text = newText
    end
end

-- Close notification
function Notify:Close()
    if self.Destroyed then return end
    self.Destroyed = true

    -- Remove from stack
    local index = table.find(activeNotifications, self.Frame)
    if index then table.remove(activeNotifications, index) end

    -- Animate out
    TweenService:Create(self.Frame, TweenInfo.new(0.25), {
        Position = UDim2.new(1, 20, 1, 0)
    }):Play()
    task.delay(0.25, function()
        self.Frame:Destroy()
    end)

    -- Re-stack others
    for i, notif in ipairs(activeNotifications) do
        TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -320, 1, -(i * 100))
        }):Play()
    end
end

return Notify
