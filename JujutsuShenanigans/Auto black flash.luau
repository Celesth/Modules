pcall(function()
        blackflash()
        wait(0.32)
        blackflash()
    end)

    if not success then
        blueflash()
    end
end

local function run_blackflashsmg()
local success, err = pcall(function()
        blackflashsmg()
        wait(0.32)
        blackflashsmg()
    end)

    if not success then
        blueflash()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local ServerHopButton = Instance.new("TextButton")
ServerHopButton.Text = "Black Flash"
ServerHopButton.Size = UDim2.new(0, 200, 0, 50)
ServerHopButton.Position = UDim2.new(0.5, -100, 0.25, 0)
ServerHopButton.Active = true
ServerHopButton.Draggable = true
ServerHopButton.ClipsDescendants = true
ServerHopButton.Parent = ScreenGui

ServerHopButton.MouseButton1Click:Connect(function()
    task.spawn(run_blackflashgojo)
    task.spawn(run_blackflashsmg)
    task.spawn(run_blackflash)
end)
