-- List of owner IDs
local ownerIDs = {
    3545789960,
}

-- Function to check if a user ID is an owner ID
local function isOwner(userID)
    for _, id in ipairs(ownerIDs) do
        if id == userID then
            return true
        end
    end
    return false
end

-- Function to give owner rank to a player
local function giveOwnerRank(player)
    -- Implement your logic to set the player's rank here
    print("Player " .. player.UserId .. " has been given the owner rank.")
    -- Example: player:SetRank("Owner")
end

-- Main function to check and assign owner rank to the local player
local function checkAndAssignOwnerRank()
    local player = game.Players.LocalPlayer
    local userID = player.UserId
    if isOwner(userID) then
        giveOwnerRank(player)
        local level = tonumber(player.PlayerFolder.Stats.Level.Value)
        local team = tostring(player.PlayerFolder.Customization.Team.Value)
        local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
        local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

        local Window = Fluent:CreateWindow({
         Title = "S1nse.private",
         SubTitle = "d1vnity",
         TabWidth = 90,
         Size = UDim2.fromOffset(380, 260),
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

SaveManager:LoadAutoloadConfig()


    else
        print("Player " .. userID .. " is not an owner.")
    end
end

-- Run the function when the local player joins the game
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    checkAndAssignOwnerRank()
end)

-- Run the function immediately in case the player's character is already loaded
if game.Players.LocalPlayer.Character then
    checkAndAssignOwnerRank()
end
