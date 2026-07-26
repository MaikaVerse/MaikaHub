local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")

print("==============================")
print("  Maika Hub - Authentication  ")
print("==============================")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Window = Library:CreateWindow({
	Title = "Maika Hub - Verifying",
	Footer = "version: 1.0",
	Icon = 122601226403829,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local function GetHWID()
    local success, result = pcall(function()
        return RbxAnalytics:GetClientId()
    end)
    return success and result or "UNKNOWN_HWID"
end

local KeyTab = Window:AddTab("Key System", "key")
local KeyGroup = KeyTab:AddLeftGroupbox("Authentication", "lock")

KeyGroup:AddLabel({
	Text = "Maika Hub - Premium Access",
	DoesWrap = true,
	Size = 20,
})

KeyGroup:AddLabel({
	Text = "Please enter your valid key to access the script.",
	DoesWrap = true,
	Size = 14,
})

KeyGroup:AddInput("KeyInputBox", {
    Default = "",
    Numeric = false,
    Finished = false,
    Text = "Enter Key",
    Tooltip = "Paste your Maika Hub key here",
    Placeholder = "MAIKA-...",
})

KeyGroup:AddButton({
    Text = "Verify Key",
    Func = function()
        local inputtedKey = Library.Options.KeyInputBox.Value
        if inputtedKey == "" then
            Library:Notify("Please enter a key first!", 3)
            return
        end

        Library:Notify("Verifying key...", 2)

        local dataToSend = {
            key = inputtedKey,
            hwid = GetHWID(),
            username = Players.LocalPlayer.Name,
            userid = tostring(Players.LocalPlayer.UserId)
        }

        local jsonData = HttpService:JSONEncode(dataToSend)

        local requestFunc = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
        if not requestFunc then
            Library:Notify("Your executor does not support HTTP requests!", 5)
            return
        end

        local response = requestFunc({
            Url = "https://maikahub.com/api/keys/verify-ingame",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })

        if response and response.StatusCode == 200 then
            local decodedResponse = HttpService:JSONDecode(response.Body)
            if decodedResponse.success then
                Library:Notify("Key verified! Welcome to Maika Hub.", 5)
                writefile("maika_key.txt", inputtedKey)
                
                -- Tutup UI Loader ini agar tidak menghalangi UI Utama
                Library:Unload()
                
                -- Load Script Utamanya (Violence District)
                -- Opsional: Anda bisa mengubah URL ini sesuai link raw github Anda nanti
                local mainScriptRepo = "https://raw.githubusercontent.com/MaikaVerse/MaikaHub/refs/heads/main/"
                
                local success, err = pcall(function()
                    if isfile and isfile("violencedistrict.lua") then
                        loadstring(readfile("violencedistrict.lua"))()
                    else
                        loadstring(game:HttpGet(mainScriptRepo .. "violencedistrict.lua"))()
                    end
                end)
                
                if not success then
                    warn("Gagal meload script utama: " .. tostring(err))
                end
            else
                Library:Notify("Error: " .. tostring(decodedResponse.error), 5)
            end
        else
            if response.Body then
                 local decodedError = HttpService:JSONDecode(response.Body)
                 if decodedError and decodedError.error then
                     Library:Notify("Error: " .. tostring(decodedError.error), 5)
                 else
                     Library:Notify("Failed to verify key. Server error.", 5)
                 end
            else
                 Library:Notify("Failed to verify key. Network error.", 5)
            end
        end
    end,
    DoubleClick = false,
    Tooltip = "Click to verify your key"
})

if isfile("maika_key.txt") then
    local savedKey = readfile("maika_key.txt")
    Library.Options.KeyInputBox:SetValue(savedKey)
end
