-- Get the LocalPlayer and initialize animation information
local lp = game.Players.LocalPlayer
local animationInfo = {}

-- Function to retrieve product information from the MarketplaceService
function getInfo(id)
    local success, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(id)
    end)
    if success then
        return info
    end
    return {Name=''} -- Return a default empty name if retrieval fails
end

-- Function to simulate blocking action
function block(player)
    keypress(0x46) -- Press the 'F' key
    wait() -- Wait for a short duration
    keyrelease(0x46) -- Release the 'F' key
end

-- List of animation names to detect
local AnimNames = {
    'Slash',
    'Swing',
    'Sword'
}

-- Function to handle when a player is added
function playerAdded(v)
    -- Function to handle when a character is added
    local function charadded(char)
        local humanoid = char:WaitForChild("Humanoid", 5) -- Wait for the Humanoid to be present
        if humanoid then
            -- Connect to the AnimationPlayed event
            humanoid.AnimationPlayed:Connect(function(track)
                local info = animationInfo[track.Animation.AnimationId] -- Retrieve animation info from cache
                if not info then
                    info = getInfo(tonumber(track.Animation.AnimationId:match("%d+"))) -- Retrieve animation info from MarketplaceService
                    animationInfo[track.Animation.AnimationId] = info -- Cache animation info
                end

                -- Check if both LocalPlayer and the other player have heads and are close enough
                if (lp.Character and lp.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Head")) then
                    local mag = (v.Character.Head.Position - lp.Character.Head.Position).Magnitude -- Calculate distance between heads
                    if mag < 15  then -- If the distance is less than 15 units
                        for _, animName in pairs(AnimNames) do
                            if info.Name:match(animName) then -- If the animation name matches one in the list
                                pcall(block, v) -- Execute the block function
                            end
                        end
                    end
                end
            end)
        end
    end

    -- If the player already has a character, handle it
    if v.Character then
        charadded(v.Character)
    end
    v.CharacterAdded:Connect(charadded) -- Connect the function to the CharacterAdded event
end

-- Loop through existing players and add event handlers
for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= lp then -- Exclude the LocalPlayer
        playerAdded(v)
    end
end

-- Connect the playerAdded function to the PlayerAdded event to handle new players
game.Players.PlayerAdded:Connect(playerAdded)
