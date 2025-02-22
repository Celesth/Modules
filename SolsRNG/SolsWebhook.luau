-- Services
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

-- WebhookUrl
local webhookUrl = "https://discord.com/api/webhooks/id/token"

local function convertToMarkdown(rawText)
    rawText = rawText:gsub('<font color="([^"]+)">', '')
    rawText = rawText:gsub('</font>', '')
    return rawText
end

-- Embed Details
local function EmbedFormat(displayName, username, itemName, chance)
    -- Get the current date and time
    local currentDate = os.date("%d/%m/%y")
    local currentTime = os.date("%I:%M%p"):lower()

    local embed = {
        ["title"] = "Aura Rolled!",
        ["description"] = displayName .. " (@**" .. username .. "**) has found **" .. itemName .. "**!",
        ["color"] = 16711680, -- Red color
        ["fields"] = {
            {
                ["name"] = "Chance",
                ["value"] = chance,
                ["inline"] = true
            },
            {
                ["name"] = "DisplayName",
                ["value"] = displayName,
                ["inline"] = true
            },
            {
                ["name"] = "Username",
                ["value"] = username,
                ["inline"] = true
            },
            {
                ["name"] = "Date",
                ["value"] = currentDate,
                ["inline"] = true
            },
            {
                ["name"] = "Time",
                ["value"] = currentTime,
                ["inline"] = true
            }
        },
        ["footer"] = {
            ["text"] = "made by celesth"
        }
    }

    local data = {
        ["embeds"] = {embed}
    }

    return HttpService:JSONEncode(data)
end

-- Module To Send Webhook
local function sendWebhook(webhookUrl, data)
    local headers = {
        ["content-type"] = "application/json"
    }

    local request = http_request or request or HttpPost
    local webhookRequest = {
        Url = webhookUrl,
        Body = data,
        Method = "POST",
        Headers = headers
    }
    request(webhookRequest)
end

-- Listener
TextChatService.OnIncomingMessage = function(message)
    local keyword = "HAS FOUND"
    if string.find(message.Text, keyword) then
        local cleanedText = convertToMarkdown(message.Text)

        -- Extract the display name and username:>
        local displayName, username = string.match(cleanedText, "^(.-)%(@(.-)%) HAS FOUND")
        displayName = displayName or "Unknown Display Name"
        username = username or "Unknown Username"

        -- Extract the AURA Name and chances :>
        local itemName = string.match(cleanedText, "HAS FOUND (.+), CHANCE OF") or "Unknown Item"
        local chance = string.match(cleanedText, "CHANCE OF (.+)") or "Unknown Chance"

        -- Filters The message
        print("[Filtered]: " .. cleanedText)

        -- Create webhook data and send it
        local webhookData = EmbedFormat(displayName, username, itemName, chance)
        sendWebhook(webhookUrl, webhookData)
    end

    -- Retared Way Of Doing This :p
    local messageProperties = Instance.new("TextChatMessageProperties")
    messageProperties.Text = message.Text
    messageProperties.PrefixText = message.PrefixText
    return messageProperties
end
