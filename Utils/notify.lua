-- ModernNotifyModule.lua
-- Module: pink glass notifications (bottom-right)
-- Features:
--  * bottom-right stacking
--  * progress bar for timed toasts
--  * auto-updating text (returns updater)
--  * interactive buttons (Yes / No / Close) -> persistent until clicked
--  * top-right X close button
--  * icons (named or custom rbxassetid)
--  * Code font for all text (Enum.Font.Code)
--  * queue + maxVisible + configurable

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local ModernNotify = {}
ModernNotify.__index = ModernNotify

-- == Default config (can be changed via Configure)
local cfg = {
    width        = 340,
    spacing      = 10,
    margin       = 18,
    maxVisible   = 5,
    bgColor      = Color3.fromHex("#0d222f"),
    borderColor  = Color3.fromHex("#f1c8d6"),
    accentColor  = Color3.fromHex("#f178a1"),
    titleColor   = Color3.fromHex("#f1c8d6"),
    bodyColor    = Color3.fromHex("#4d5963"),
    borderTrans  = 0.4,
    cornerRadius = 12,
    enterTween   = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    exitTween    = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    progressTween = Enum.EasingStyle.Linear,
    font         = Enum.Font.Code,
    defaultDuration = 6,
    icons = { -- built-in icon ids; can be overridden
        info    = "rbxassetid://7072719145",
        success = "rbxassetid://7072719190",
        warn    = "rbxassetid://7072719232",
        error   = "rbxassetid://7072719270"
    }
}

-- internal state
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernNotifyGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- container (bottom-right)
local container = Instance.new("Frame")
container.Name = "NotifyContainer"
container.Size = UDim2.new(0, cfg.width, 1, -cfg.margin*2)
container.Position = UDim2.new(1, -cfg.margin - cfg.width, 1, -cfg.margin)
container.AnchorPoint = Vector2.new(0, 1)
container.BackgroundTransparency = 1
container.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Name = "NotifyList"
listLayout.Parent = container
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, cfg.spacing)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

-- queue + active
local queue = {}
local active = {}

-- helpers
local function deepCopy(t)
    local ok, s = pcall(function() return game:GetService("HttpService"):JSONEncode(t) end)
    if not ok then return {} end
    return game:GetService("HttpService"):JSONDecode(s)
end

local function clamp(n, a, b) if n < a then return a elseif n > b then return b else return n end end

local function measureToastHeight(titleText, bodyText)
    -- rough measurement using TextService. Use font = cfg.font and TextSize defaults (title 14, body 13)
    local w = cfg.width - 24 - 48 -- padding left/right + icon area
    local titleSize = TextService:GetTextSize(titleText or "", 14, cfg.font, Vector2.new(w, 9999))
    local bodySize = TextService:GetTextSize(bodyText or "", 13, cfg.font, Vector2.new(w, 9999))
    local total = 8 + titleSize.Y + 4 + bodySize.Y + 12 + 6 -- padding + title + spacing + body + bottom padding + progress height
    total = clamp(total, 60, 220)
    return math.ceil(total)
end

local function chooseIcon(iconOpt, typ)
    if not iconOpt and typ and cfg.icons[typ] then
        return cfg.icons[typ]
    elseif type(iconOpt) == "string" then
        return iconOpt
    end
    return nil
end

-- create visual toast (not yet tweens)
local function createToastFrame(opts)
    local hasButtons = opts and opts.buttons

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = cfg.bgColor
    frame.Size = UDim2.new(1, 0, 0, 0) -- animate to height later
    frame.LayoutOrder = 0
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    -- semi-transparent border (UIStroke)
    local stroke = Instance.new("UIStroke")
    stroke.Color = cfg.borderColor
    stroke.Thickness = 2
    stroke.Transparency = cfg.borderTrans
    stroke.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cfg.cornerRadius)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = frame

    -- close button (top-right X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -6 - 26, 0, 6) -- outside padding slightly
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = Color3.fromRGB(220,220,220)
    closeBtn.AutoButtonColor = true
    closeBtn.ZIndex = 10
    closeBtn.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0,6)
    closeCorner.Parent = closeBtn

    -- left icon area
    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 44, 0, 44)
    iconImg.Position = UDim2.new(0, 2, 0, 6)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = ""
    iconImg.ScaleType = Enum.ScaleType.Fit
    iconImg.Parent = frame

    -- content container
    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -56, 1, 0)
    content.Position = UDim2.new(0, 52, 0, 0)
    content.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -32, 0, 18)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = cfg.font
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = cfg.titleColor
    title.Text = opts.title or "Notification"
    title.Parent = content

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, 0, 0, 36)
    body.Position = UDim2.new(0, 0, 0, 22)
    body.BackgroundTransparency = 1
    body.Font = cfg.font
    body.TextSize = 13
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextColor3 = cfg.bodyColor
    body.Text = opts.text or ""
    body.Parent = content

    -- progress container (thin)
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(1, 0, 0, 4)
    progressContainer.Position = UDim2.new(0, 0, 1, -4)
    progressContainer.BackgroundTransparency = 1
    progressContainer.Parent = frame

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = cfg.accentColor
    progressFill.BorderSizePixel = 0
    progressFill.AnchorPoint = Vector2.new(0, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.Parent = progressContainer

    -- Buttons container (only if provided)
    local buttonsContainer
    if hasButtons then
        buttonsContainer = Instance.new("Frame")
        buttonsContainer.Size = UDim2.new(1, 0, 0, 34)
        buttonsContainer.Position = UDim2.new(0, 0, 1, -40)
        buttonsContainer.BackgroundTransparency = 1
        buttonsContainer.Parent = frame

        local bl = Instance.new("UIListLayout")
        bl.FillDirection = Enum.FillDirection.Horizontal
        bl.HorizontalAlignment = Enum.HorizontalAlignment.Right
        bl.SortOrder = Enum.SortOrder.LayoutOrder
        bl.Padding = UDim.new(0, 8)
        bl.Parent = buttonsContainer
    end

    return {
        frame = frame,
        closeBtn = closeBtn,
        iconImg = iconImg,
        titleLabel = title,
        bodyLabel = body,
        progressFill = progressFill,
        progressContainer = progressContainer,
        buttonsContainer = buttonsContainer,
    }
end

-- animate in/out helpers
local function animateIn(frame, targetHeight)
    frame.Size = UDim2.new(1, 0, 0, 0)
    local tween = TweenService:Create(frame, cfg.enterTween, { Size = UDim2.new(1, 0, 0, targetHeight) })
    tween:Play()
end

local function animateOut(frame, onComplete)
    local tween = TweenService:Create(frame, cfg.exitTween, { Size = UDim2.new(1, 0, 0, 0) })
    tween.Completed:Connect(function()
        pcall(function() frame:Destroy() end)
        if onComplete then pcall(onComplete) end
    end)
    tween:Play()
end

-- queue processing
function ModernNotify.ProcessQueue()
    while (#active < cfg.maxVisible) and (#queue > 0) do
        local opts = table.remove(queue, 1)
        -- create visuals
        local vf = createToastFrame(opts)
        vf.frame.Parent = container

        -- choose icon
        local icon = chooseIcon(opts.icon, opts.type)
        if icon then
            vf.iconImg.Image = icon
            vf.iconImg.Visible = true
        else
            vf.iconImg.Visible = false
        end

        -- compute height
        local h = measureToastHeight(opts.title or "", opts.text or "")
        if opts.buttons then h = h + 44 end -- extra for buttons area
        vf.frame:SetAttribute("TargetHeight", h)

        -- add buttons if present
        local alive = true
        local progressTween = nil
        local closeCalled = false

        -- create buttons
        if opts.buttons and vf.buttonsContainer then
            local bcont = vf.buttonsContainer
            -- create button helper
            local function newButton(txt, color, cb)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(0, 80, 1, 0)
                b.BackgroundColor3 = color or cfg.accentColor
                b.Font = cfg.font
                b.TextSize = 13
                b.Text = txt
                b.TextColor3 = Color3.fromRGB(255,255,255)
                b.AutoButtonColor = true
                b.Parent = bcont
                local rc = Instance.new("UICorner", b)
                rc.CornerRadius = UDim.new(0,6)
                b.MouseButton1Click:Connect(function()
                    if cb then pcall(cb) end
                    if alive then
                        alive = false
                        animateOut(vf.frame, function()
                            -- remove from active list
                            for i,f in ipairs(active) do if f == vf.frame then table.remove(active, i); break end end
                            ModernNotify.ProcessQueue()
                        end)
                    end
                end)
                return b
            end

            if opts.buttons.Yes then newButton("Yes", cfg.accentColor, opts.buttons.Yes) end
            if opts.buttons.No then newButton("No", Color3.fromHex("#6b6b6b"), opts.buttons.No) end
            if opts.buttons.Close then newButton("Close", Color3.fromHex("#9b9b9b"), opts.buttons.Close) end
        end

        -- set texts
        vf.titleLabel.Text = opts.title or "Notification"
        vf.bodyLabel.Text = opts.text or ""

        -- wire close X
        vf.closeBtn.MouseButton1Click:Connect(function()
            if not alive then return end
            alive = false
            animateOut(vf.frame, function()
                for i,f in ipairs(active) do if f == vf.frame then table.remove(active, i); break end end
                ModernNotify.ProcessQueue()
            end)
        end)

        -- show
        local targetH = vf.frame:GetAttribute("TargetHeight") or 70
        animateIn(vf.frame, targetH)

        -- record as active
        table.insert(active, vf.frame)

        -- progress & duration handling
        if opts.duration and (not opts.buttons) then
            -- run progress tween; when complete, dismiss
            local progressTweenObj = TweenService:Create(vf.progressFill, TweenInfo.new(opts.duration, cfg.progressTween), { Size = UDim2.new(0, 0, 1, 0) })
            progressTweenObj.Completed:Connect(function()
                if alive then
                    alive = false
                    animateOut(vf.frame, function()
                        for i,f in ipairs(active) do if f == vf.frame then table.remove(active, i); break end end
                        ModernNotify.ProcessQueue()
                    end)
                end
            end)
            progressTweenObj:Play()
        else
            -- hide progress
            vf.progressContainer.Visible = false
        end

        -- updater function for auto-updating text
        local updater = function(newText)
            if vf.bodyLabel and vf.bodyLabel.Parent then
                vf.bodyLabel.Text = tostring(newText)
                -- recompute height and animate frame to new height
                local newH = measureToastHeight(vf.titleLabel.Text, vf.bodyLabel.Text)
                if opts.buttons then newH = newH + 44 end
                vf.frame:SetAttribute("TargetHeight", newH)
                -- animate size change smoothly
                TweenService:Create(vf.frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, newH) }):Play()
            end
        end

        -- store handle on frame for external control
        vf.frame:SetAttribute("NotifierHandle", true) -- marker

        -- attach handle to opts (so returning returns the handle)
        if opts._resolveHandle then
            opts._resolveHandle({
                Update = updater,
                Close = function()
                    if alive then
                        alive = false
                        animateOut(vf.frame, function()
                            for i,f in ipairs(active) do if f == vf.frame then table.remove(active, i); break end end
                            ModernNotify.ProcessQueue()
                        end)
                    end
                end
            })
        end
    end
end

-- Public API: Notify(opts)
-- opts:
--   title (string)
--   text (string)
--   type (string) - "info","success","warn","error" (affects default icon)
--   icon (string) - custom rbxassetid or URL; if provided overrides type icon
--   duration (number or nil) - if nil and opts.buttons provided, persistent until clicked
--   buttons (table) - { Yes = func, No = func, Close = func } -> presence makes persistent (no duration)
-- returns handle { Update = fn, Close = fn }
function ModernNotify.Notify(options)
    options = options or {}
    -- normalize
    local t = {
        title = tostring(options.title or "Notification"),
        text  = tostring(options.text or ""),
        type  = options.type,
        icon  = options.icon,
        duration = (options.duration and tonumber(options.duration)) or cfg.defaultDuration,
        buttons = options.buttons,
    }

    -- this promise-ish pattern allows create -> ProcessQueue to return handle
    local handleResolved = nil
    local handleObj = nil
    t._resolveHandle = function(h) handleObj = h handleResolved = true end

    -- push to queue
    table.insert(queue, t)
    ModernNotify.ProcessQueue()

    -- wait for ProcessQueue to resolve handle (it resolves synchronously in this implementation when popped)
    -- but to be safe, wait some ticks
    local tries = 0
    while not handleResolved and tries < 10 do
        RunService.Heartbeat:Wait()
        tries = tries + 1
    end

    -- handleObj might still be nil if ProcessQueue didn't pop yet; create a lazy handle that will operate on earliest active frame
    if not handleObj then
        -- fallback handle
        handleObj = {
            Update = function(newText)
                -- try to update last active matching title
                for i = #active, 1, -1 do
                    local f = active[i]
                    if f and f.Parent then
                        local content = f:FindFirstChildWhichIsA("Frame") or f
                        -- try find TextLabel children
                        for _,c in ipairs(f:GetDescendants()) do
                            if c:IsA("TextLabel") and c.Text == t.text then
                                pcall(function() c.Text = newText end)
                                return
                            end
                        end
                    end
                end
            end,
            Close = function() end
        }
    end

    return handleObj
end

-- Configure (merge)
function ModernNotify.Configure(tbl)
    if type(tbl) ~= "table" then return end
    for k,v in pairs(tbl) do
        if cfg[k] ~= nil then cfg[k] = v end
    end
    -- update container position & sizes
    container.Size = UDim2.new(0, cfg.width, 1, -cfg.margin*2)
    container.Position = UDim2.new(1, -cfg.margin - cfg.width, 1, -cfg.margin)
    listLayout.Padding = UDim.new(0, cfg.spacing)
    cfg.maxVisible = cfg.maxVisible or 5
end

function ModernNotify.CloseAll()
    queue = {}
    for _,f in ipairs(active) do
        pcall(function() f:Destroy() end)
    end
    active = {}
end

-- Example usage (comment out when requiring as module)
--[[
local N = ModernNotify
N.Configure({ width = 360 })
local handle = N.Notify({ title = "Checkpoint", text = "Distance: 1000m", type = "info", duration = 8 })
task.spawn(function()
    for i = 1000, 0, -100 do
        handle.Update(("Distance: %dm"):format(i))
        task.wait(0.6)
    end
end)

N.Notify({
    title = "Confirm",
    text = "Do you want to continue?",
    buttons = {
        Yes = function() print("yes pressed") end,
        No = function() print("no pressed") end,
        Close = function() print("closed") end,
    }
})
]]

return ModernNotify