local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vast.sh",
    SubTitle = "Private",
    TabWidth = 110,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({
        Title = "Main", Icon = "home"
    }),
    
    Util = Window:AddTab({
        Title = "Utility", Icon = "hammer"
    }),
    
    Join = Window:AddTab({
        Title = "Join", Icon = "user-round-search"
    }),
    
    Dev = Window:AddTab({
        Title = "Developer", Icon = "eye-off"
    }),
    
    Settings = Window:AddTab({
        Title = "Settings", Icon = "settings"
    })
}

local Options = Fluent.Options

do
Fluent:Notify({
    Title = "Notification",
    Content = "This is a notification",
    SubContent = "SubContent", -- Optional
    Duration = 5 -- Set to nil to make the notification not disappear
})



Tabs.Main:AddParagraph({
    Title = "Paragraph",
    Content = "This is a paragraph.\nSecond line!"
})



Tabs.Main:AddButton({
    Title = "Button",
    Description = "Very important button",
    Callback = function()
    Window:Dialog({
        Title = "Title",
        Content = "This is a dialog",
        Buttons = {
            {
                Title = "Confirm",
                Callback = function()
                print("Confirmed the dialog.")
                end
            },
            {
                Title = "Cancel",
                Callback = function()
                print("Cancelled the dialog.")
                end
            }
        }
    })
    end
})

Tabs.Dev:AddButton({
    Title = "Iframe [Humanoid Position]",
    Description = "Gets You The Iframes Of Your Currently Position.",
    Callback = function()
    Window:Dialog({
        Title = "Iframe [Current]",
        Content = "Gives You Current Standing Location Position",
        Buttons = {
            {
                Title = "Confirm",
                Callback = function()
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:wait()
                local humanoidRootPart = character:WaitForChild('HumanoidRootPart')

                local position = humanoidRootPart.Position
                print(position) -- This would output the position in the output window.
                setclipboard(tostring(Game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position))
                end
            },
            {
                Title = "Cancel",
                Callback = function()
                print("Cancelled the dialog.")
                end
            }
        }
    })
    end
})

local Input = Tabs.Dev:AddInput("Input", {
    Title = "Teleport[Instant]",
    Default = "",
    Placeholder = "UserName",
    Numeric = false, -- Only allows numbers
    Finished = true, -- Only calls callback when you press enter
    Callback = function(modules)
        print(modules)
    local player = game.Players.LocalPlayer
    local usernameToTeleport = modules -- Replace with the desired username

    local function teleportToPlayer()
    local targetPlayer = game.Players:FindFirstChild(usernameToTeleport)
    if targetPlayer then
    player.Character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
    else
        print("Player not found.")
    end
    end

    teleportToPlayer()
    end
})

Input:OnChanged(function()
    print("Input updated:", Input.Value)
    end)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()