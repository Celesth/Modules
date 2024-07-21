local player = game.Players.LocalPlayer
local level = tonumber(player.PlayerFolder.Stats.Level.Value)
local team = tostring(player.PlayerFolder.Customization.Team.Value)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "S1nse",
    SubTitle = "private 0.1",
    TabWidth = 90,
    Size = UDim2.fromOffset(480, 310),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})



--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "file-code-2" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
do
    Fluent:Notify({
        Title = "S1nse",
        Content = "Injecting Module",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    Tabs.Main:AddParagraph({
        Title = "Username:",
        Content = (player)
     })

    Tabs.Main:AddParagraph({
        Title = "Level:",
        Content = (level)
    })

    Tabs.Main:AddParagraph({
        Title = "Team",
        Content = (team)
    })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("S1nse")
SaveManager:SetFolder("S1nse/Ro-Ghoul")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(nil)
Window:SelectTab(1)


Fluent:Notify({
    Title = "S1nse.sh",
    Content = "Module Injected",
    Duration = 2
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

end
