local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId
local GameId = game.GameId

-- Dapatkan HWID (Client ID unik dari mesin player)
local PlayerHWID = RbxAnalyticsService:GetClientId()
local KeyFile = "MaikaHub_Key.txt"

-- ==========================================
-- SISTEM VERIFIKASI KEY & HWID
-- ==========================================
local function VerifyKeyServer(key)
    local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
    
    if not req then 
        return false, "Executor tidak mendukung fitur HTTP Request!" 
    end

    -- Dapatkan nama game asli dari Roblox API
    local gameName = "Unknown Game"
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(PlaceId).Name
    end)

    local success, res = pcall(function()
        return req({
            Url = "https://maikahub.my.id/api/keys/verify-ingame",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                key = key,
                hwid = PlayerHWID,
                username = LocalPlayer.Name,
                userid = tostring(LocalPlayer.UserId),
                game_name = gameName
            })
        })
    end)

    if success and res then
        local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if decodeSuccess then
            -- API me-return 'success' bukan 'valid', jadi kita cek dua-duanya
            if data.valid or data.success then
                local msg = "Key Valid! Berhasil masuk."
                if data.expires_at then
                    local dateOnly = string.match(data.expires_at, "^([^T]+)")
                    if dateOnly then msg = msg .. " (Expired: " .. dateOnly .. ")" end
                end
                return true, msg
            else
                return false, data.message or data.error or "Key tidak valid atau kadaluarsa."
            end
        else
            return false, "Gagal membaca response dari server."
        end
    else
        return false, "Gagal menghubungi server verifikasi. Cek koneksi Anda."
    end
end

-- ==========================================
-- LOAD UI LIBRARY
-- ==========================================
local repo = "https://raw.githubusercontent.com/uhfork/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- ==========================================
-- MAIN SCRIPT FUNCTION (Akan dipanggil jika Key Benar)
-- ==========================================
local function LoadMainScript()
    -- Anti AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)

    local Window = Library:CreateWindow({
        Title = "Maika Hub | Server Hop",
        Footer = "Auto Farm + Webhook | Verified",
        Icon = 95816097006870,
        CornerElements = false,
        NotifySide = "Right",
        ShowCustomCursor = true,
    })

    local Tabs = {
        Main = Window:AddTab("Main", "globe", "Main Features"),
        Settings = Window:AddTab("Settings", "settings", "UI Settings"),
    }

    local autoFarmFile = "ServerHop_AutoHopState.txt"
    local function getAutoHopState()
        if isfile and readfile and isfile(autoFarmFile) then
            local success, val = pcall(function() return readfile(autoFarmFile) == "true" end)
            return success and val or true
        end
        return true
    end

    local function setAutoHopState(state)
        if writefile then
            pcall(function() writefile(autoFarmFile, tostring(state)) end)
        end
    end

    local webhookFile = "ServerHop_Webhook.txt"
    local function getWebhookState()
        if isfile and readfile and isfile(webhookFile) then
            local success, val = pcall(function() return readfile(webhookFile) end)
            return success and val or ""
        end
        return ""
    end

    local function setWebhookState(url)
        if writefile then
            pcall(function() writefile(webhookFile, url) end)
        end
    end

    local GameGroup = Tabs.Main:AddLeftGroupbox("Game Features", "gamepad")
    GameGroup:AddToggle("AutoFinish", {
        Text = "Auto Escape",
        Default = true,
        Tooltip = "Automatically teleport to Finishline when the round starts"
    })
    GameGroup:AddToggle("AutoHop", {
        Text = "Auto Server Hop",
        Default = getAutoHopState(),
        Tooltip = "Hop server after escaping OR if joining an ongoing match"
    })
    GameGroup:AddToggle("NotifyKiller", {
        Text = "Detect Killer Name",
        Default = true,
        Tooltip = "Show a notification of who the Killer is"
    })
    GameGroup:AddToggle("SkipIfKiller", {
        Text = "Skip if Killer",
        Default = true,
        Tooltip = "Auto hop to a new server if you are chosen as the Killer"
    })

    Toggles.AutoHop:OnChanged(function(val)
        setAutoHopState(val)
    end)

    local WebhookGroup = Tabs.Main:AddRightGroupbox("Discord Webhook", "link")
    WebhookGroup:AddInput("WebhookUrl", {
        Default = getWebhookState(),
        Numeric = false,
        Finished = false,
        Text = "Webhook URL",
        Tooltip = "Enter your Discord Webhook URL",
        Placeholder = "https://discord.com/api/webhooks/..."
    })
    Options.WebhookUrl:OnChanged(function()
        setWebhookState(Options.WebhookUrl.Value)
    end)

    local DebugGroup = Tabs.Settings:AddRightGroupbox("Developer", "terminal")
    DebugGroup:AddToggle("DebugMode", {
        Text = "Enable Debug Log (F9)",
        Default = false,
        Tooltip = "Print server activity to F9 console"
    })

    local function logInfo(tag, ...)
        local success, isEnabled = pcall(function() return Toggles.DebugMode.Value end)
        if success and isEnabled then
            print(string.format("[%s]", tag), ...)
        end
    end

    local function sendWebhook(title, description, fields)
        local url = ""
        local success, val = pcall(function() return Options.WebhookUrl.Value end)
        if success and val then url = val else url = getWebhookState() end
        
        if url == nil or url == "" then return end
        
        local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
        if req then
            pcall(function()
                req({
                    Url = url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        embeds = {{
                            title = title,
                            description = description,
                            fields = fields,
                            color = 0x58b9ff
                        }}
                    })
                })
            end)
        end
    end

    -- Stats Tracking UI (Screws, Gears, Level, XP)
    local StatsGroup = Tabs.Main:AddRightGroupbox("Player Stats", "user")
    local UserLabel = StatsGroup:AddLabel("Player: " .. LocalPlayer.Name)
    local LevelLabel = StatsGroup:AddLabel("Level: " .. tostring(LocalPlayer:GetAttribute("Level") or 0))
    local XPLabel = StatsGroup:AddLabel("XP: " .. tostring(LocalPlayer:GetAttribute("XP") or LocalPlayer:GetAttribute("Experience") or 0))
    local ScrewsLabel = StatsGroup:AddLabel("Screws: " .. tostring(LocalPlayer:GetAttribute("Screws") or 0))
    local GearsLabel = StatsGroup:AddLabel("Gears: " .. tostring(LocalPlayer:GetAttribute("Gears") or 0))

    local function onStatChanged()
        local curLevel = LocalPlayer:GetAttribute("Level") or 0
        local curScrews = LocalPlayer:GetAttribute("Screws") or 0
        local curGears = LocalPlayer:GetAttribute("Gears") or 0
        local curXP = LocalPlayer:GetAttribute("XP") or LocalPlayer:GetAttribute("Experience") or 0

        pcall(function()
            LevelLabel:SetText("Level: " .. tostring(curLevel))
            XPLabel:SetText("XP: " .. tostring(curXP))
            ScrewsLabel:SetText("Screws: " .. tostring(curScrews))
            GearsLabel:SetText("Gears: " .. tostring(curGears))
        end)
    end

    LocalPlayer:GetAttributeChangedSignal("Level"):Connect(onStatChanged)
    LocalPlayer:GetAttributeChangedSignal("Screws"):Connect(onStatChanged)
    LocalPlayer:GetAttributeChangedSignal("Gears"):Connect(onStatChanged)
    pcall(function() LocalPlayer:GetAttributeChangedSignal("XP"):Connect(onStatChanged) end)
    pcall(function() LocalPlayer:GetAttributeChangedSignal("Experience"):Connect(onStatChanged) end)

    local function FetchAPI(url)
        local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
        
        if req then
            local success, res = pcall(function()
                return req({
                    Url = url,
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                        ["Accept"] = "application/json"
                    }
                })
            end)
            
            if success and type(res) == "table" then
                if res.StatusCode == 200 then
                    return true, res.Body
                else
                    return false, "{\"errors\":[{\"code\":0,\"message\":\"HTTP " .. tostring(res.StatusCode) .. "\"}]}"
                end
            end
        end
        
        return pcall(function() return game:HttpGet(url) end)
    end

    local isHopping = false
    local function CariServer()
        if isHopping then return end
        isHopping = true
        logInfo("ServerHop", "Starting server search...")
        local targetPlaceId = PlaceId
        
        logInfo("ServerHop", "Fetching new data from Roblox API...")
        local univUrl = "https://games.roblox.com/v1/games?universeIds=" .. tostring(GameId)
        local sU, rU = FetchAPI(univUrl)
        
        if sU and rU then
            local dU_ok, dU = pcall(function() return HttpService:JSONDecode(rU) end)
            if dU_ok and dU and dU.data and dU.data[1] and dU.data[1].rootPlaceId then
                targetPlaceId = dU.data[1].rootPlaceId
                logInfo("ServerHop", "Root Place ID Found: " .. tostring(targetPlaceId))
            end
        end
        
        local cursor = ""
        local validServers = {}
        local page = 1
        local retries = 0
        
        while cursor ~= nil and #validServers == 0 do
            logInfo("ServerHop", "Fetching server data page " .. tostring(page))
            local url = "https://games.roblox.com/v1/games/" .. tostring(targetPlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
            
            if cursor ~= "" then
                url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
            end
            
            local success, result = FetchAPI(url)
            local rateLimited = not success or string.find(tostring(result), "code\":0") or string.find(tostring(result), "HTTP 429") or string.find(tostring(result), "HTTP 403")
            
            if rateLimited then
                logInfo("ServerHop", "Roblox API limit. Trying AllOrigins Proxy fallback...")
                local proxyUrl = "https://api.allorigins.win/raw?url=" .. HttpService:UrlEncode(url)
                success, result = FetchAPI(proxyUrl)
                rateLimited = not success or string.find(tostring(result), "code\":0") or string.find(tostring(result), "HTTP 429") or string.find(tostring(result), "HTTP 403")
            end
            
            if rateLimited then
                if retries < 12 then
                    retries = retries + 1
                    logInfo("ServerHop", "All APIs limited. Waiting 5 seconds... (Attempt " .. tostring(retries) .. "/12)")
                    task.wait(5)
                    continue
                else
                    logInfo("ServerHop", "Failed to bypass Rate Limit after 1 minute of waiting. Cancelling search.")
                    cursor = nil
                    continue
                end
            end
            
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if decodeSuccess and data and data.data then
                retries = 0
                logInfo("ServerHop", "Found " .. tostring(#data.data) .. " servers on this page.")
                for i = 1, #data.data do
                    local server = data.data[i]
                    if server.playing and server.playing >= 1 and server.playing <= 4 and server.id ~= JobId and server.ping and server.ping > 0 then
                        table.insert(validServers, server)
                    end
                end
                
                if #validServers > 0 then
                    break
                end
                
                cursor = data.nextPageCursor
                if cursor then
                    logInfo("ServerHop", "No suitable server found, moving to next page...")
                else
                    logInfo("ServerHop", "No more pages available.")
                end
            else
                cursor = nil
            end
            
            page = page + 1
            task.wait(0.5)
        end
        
        if #validServers > 0 then
            local selectedServer = validServers[1]
            logInfo("ServerHop", "Server available.")
            Library:Notify({
                Title = "Server Found!",
                Description = "Found a server with " .. tostring(selectedServer.playing) .. " players. Teleporting...",
                Icon = "check",
                Time = 5,
            })
            task.wait(1)
            local tpSuccess, tpErr = pcall(function()
                TeleportService:TeleportToPlaceInstance(targetPlaceId, selectedServer.id, LocalPlayer)
            end)
            if not tpSuccess then
                logInfo("TELEPORT", "Immediate teleport error:", tostring(tpErr))
                isHopping = false
                task.wait(3)
                if CariServer then CariServer() end
            end
        else
            local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
            if sHop and autoHop then
                logInfo("ServerHop", "Search completed. No servers available. Retrying in 10 seconds...")
                Library:Notify({
                    Title = "Searching...",
                    Description = "No servers found. Retrying in 10 seconds...",
                    Icon = "search",
                    Time = 10,
                })
                task.wait(10)
                isHopping = false
                if CariServer then CariServer() end
            else
                logInfo("ServerHop", "Search completed. No servers available.")
                Library:Notify({
                    Title = "Failed",
                    Description = "Could not find any empty servers.",
                    Icon = "x",
                    Time = 5,
                })
                isHopping = false
            end
        end
    end

    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
        if sHop and autoHop then
            logInfo("TELEPORT", "Server Hop failed! Error: " .. tostring(errorMessage))
            Library:Notify({
                Title = "Hop Failed",
                Description = "Teleport failed. Retrying in 5 seconds...",
                Icon = "alert-triangle",
                Time = 5,
            })
            task.wait(5)
            isHopping = false
            if CariServer then CariServer() end
        end
    end)

    local function attemptEscape()
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            local finishLine = mapFolder:FindFirstChild("Fininshline", true)
            if finishLine then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = finishLine.CFrame
                    logInfo("HUB", "Successfully auto-teleported to Finishline!")
                    
                    -- Webhook notification
                    local curLevel = LocalPlayer:GetAttribute("Level") or 0
                    local curScrews = LocalPlayer:GetAttribute("Screws") or 0
                    local curGears = LocalPlayer:GetAttribute("Gears") or 0
                    local curXP = LocalPlayer:GetAttribute("XP") or LocalPlayer:GetAttribute("Experience") or 0
                    
                    sendWebhook("🚀 Escaped Successfully!", "**" .. LocalPlayer.Name .. "** has escaped the facility.", {
                        {name = "👤 Player Info", value = "Username: **" .. LocalPlayer.Name .. "**\nDisplay: **" .. LocalPlayer.DisplayName .. "**", inline = false},
                        {name = "📊 Stats", value = "Level: **" .. tostring(curLevel) .. "**\nXP: **" .. tostring(curXP) .. "**", inline = true},
                        {name = "🛠️ Items", value = "Screws: **" .. tostring(curScrews) .. "**\nGears: **" .. tostring(curGears) .. "**", inline = true}
                    })
                    
                    local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
                    if sHop and autoHop then
                        Library:Notify({Title = "Auto Escape", Description = "Success! Searching for a new server...", Icon = "check", Time = 3})
                        task.spawn(CariServer)
                    else
                        Library:Notify({Title = "Auto Escape", Description = "Successfully teleported to the Finishline!", Icon = "check", Time = 5})
                    end
                    return true
                end
            end
        end
        return false
    end

    task.spawn(function()
        local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
        if not Remotes then return end

        local Teleport = Remotes:FindFirstChild("Teleport")
        if Teleport then
            Teleport.OnClientEvent:Connect(function(cframeOrArg)
                local pos = "unknown"
                if typeof(cframeOrArg) == "CFrame" then
                    pos = tostring(cframeOrArg.Position)
                elseif typeof(cframeOrArg) == "Vector3" then
                    pos = tostring(cframeOrArg)
                elseif type(cframeOrArg) == "boolean" then
                    pos = cframeOrArg and "ENTER SPECTATE" or "EXIT SPECTATE"
                else
                    pos = tostring(cframeOrArg)
                end
                logInfo("TELEPORT", "Fired! Arg:", pos)
            end)
        end

        local Mechanics = Remotes:FindFirstChild("Mechanics")
        if Mechanics then
            local TeleportChar = Mechanics:FindFirstChild("Teleportcharacter")
            if TeleportChar then
                TeleportChar.OnClientEvent:Connect(function(...)
                    local args = {...}
                    logInfo("TELEPORTCHAR", "Fired! Args length:", #args)
                    for i, v in ipairs(args) do logInfo("TELEPORTCHAR", "  arg[" .. i .. "]:", tostring(v)) end
                end)
            end
        end

        local Darkness = Remotes:FindFirstChild("Darkness")
        if Darkness then
            Darkness.OnClientEvent:Connect(function(isMapTeleport, fadeIn, fadeOut)
                if isMapTeleport then
                    logInfo("HUB", "Darkness: Map teleport detected!")
                    local mapFolder = workspace:WaitForChild("Map", 10)
                    if mapFolder then
                        local cameraScene = mapFolder:FindFirstChild("Camerascene1")
                        if cameraScene then
                            local mapTitle = cameraScene:GetAttribute("title") or "Unknown"
                            local mapDesc = cameraScene:GetAttribute("desc") or "No description"
                            logInfo("HUB", "=== MAP INFO ===")
                            logInfo("HUB", "Map Name:", mapTitle)
                            logInfo("HUB", "Map Desc:", mapDesc)
                        else
                            logInfo("HUB", "Map folder name:", mapFolder.Name)
                        end
                    end
                end
            end)
        end

        local firstCheck = true
        
        local StatusUpdate = Remotes:FindFirstChild("StatusUpdateEvent")
        if StatusUpdate then
            StatusUpdate.OnClientEvent:Connect(function(status)
                if status == "WaitingForPlayers" or status == "IntermissionStarting" then
                    firstCheck = false
                end
            end)
        end

        local TimeUpdate = Remotes:FindFirstChild("TimeUpdateEvent")
        if TimeUpdate then
            TimeUpdate.OnClientEvent:Connect(function(phase, time)
                if firstCheck then
                    firstCheck = false
                    if phase == "Round" then
                        logInfo("HUB", "Joined an ongoing match! Checking if we can escape...")
                        local sFinish, autoFinish = pcall(function() return Toggles.AutoFinish.Value end)
                        local escaped = false
                        if sFinish and autoFinish then
                            escaped = attemptEscape()
                        end
                        
                        if not escaped then
                            local sSkip, autoSkip = pcall(function() return Toggles.AutoHop.Value end)
                            if sSkip and autoSkip then
                                logInfo("HUB", "Could not escape. Auto hopping...")
                                Library:Notify({
                                    Title = "Server Hop",
                                    Description = "Match is already playing. Skipping server in 3 seconds...",
                                    Icon = "fast-forward",
                                    Time = 3,
                                })
                                task.wait(3)
                                CariServer()
                            end
                        end
                    end
                end
            end)
        end

        local Round = Remotes:FindFirstChild("Round")
        if Round then
            Round.OnClientEvent:Connect(function(...)
                local args = {...}
                logInfo("ROUND", "State changed! Args length:", #args)
                for i, v in ipairs(args) do logInfo("ROUND", "  arg[" .. i .. "]:", tostring(v)) end

                local isRoundStart = args[1]
                if isRoundStart == true then
                    task.spawn(function()
                        local sKiller, notifyKiller = pcall(function() return Toggles.NotifyKiller.Value end)
                        if sKiller and notifyKiller then
                            local killerName = "Not found"
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Team and p.Team.Name == "Killer" then
                                    killerName = p.Name
                                    break
                                end
                            end
                            logInfo("HUB", "KILLER IS: " .. killerName)
                            Library:Notify({
                                Title = "⚠️ KILLER DETECTED",
                                Description = "The killer for this round is: " .. killerName,
                                Time = 7
                            })
                        end

                        local sFinish, autoFinish = pcall(function() return Toggles.AutoFinish.Value end)
                        if sFinish and autoFinish then
                            task.wait(4)
                            attemptEscape()
                        end
                    end)
                end
            end)
        end

        local GameFolder = Remotes:FindFirstChild("Game")
        if GameFolder then
            local showresults = GameFolder:FindFirstChild("showresults")
            if showresults then
                showresults.OnClientEvent:Connect(function(...)
                    local args = {...}
                    logInfo("SHOWRESULTS", "Fired! Args length:", #args)
                    for i, v in ipairs(args) do 
                        logInfo("SHOWRESULTS", "  arg[" .. i .. "]:", tostring(v)) 
                        if type(v) == "table" then
                            for k, val in pairs(v) do
                                logInfo("SHOWRESULTS", "    ["..tostring(k).."] = ", tostring(val))
                            end
                        end
                    end
                end)
            end
        end
    end)

    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        logInfo("TEAM", "Player team changed to:", tostring(LocalPlayer.Team))
        
        if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
            local sSkipKiller, autoSkipKiller = pcall(function() return Toggles.SkipIfKiller.Value end)
            if sSkipKiller and autoSkipKiller then
                logInfo("HUB", "Player is Killer! Auto hopping...")
                
                sendWebhook("🔪 Chosen as Killer!", "**" .. LocalPlayer.Name .. "** was selected as the Killer. Skipping match...", {
                    {name = "👤 Player Info", value = "Username: **" .. LocalPlayer.Name .. "**\nDisplay: **" .. LocalPlayer.DisplayName .. "**", inline = false},
                    {name = "⚡ Action", value = "Server Hop Triggered Skip if Killer", inline = true}
                })

                Library:Notify({
                    Title = "Role: Killer",
                    Description = "You are the Killer! Skipping server in 3 seconds...",
                    Icon = "shield-x",
                    Time = 3
                })
                task.wait(3)
                if CariServer then CariServer() end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        logInfo("CHARACTER", "Character spawned:", char.Name)
    end)

    -- Feature: Skip Empty Server
    task.spawn(function()
        while task.wait(5) do
            local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
            if sHop and autoHop then
                if #Players:GetPlayers() < 3 then
                    local waited = 0
                    while #Players:GetPlayers() < 3 and waited < 20 do
                        task.wait(1)
                        waited = waited + 1
                    end
                    
                    if #Players:GetPlayers() < 3 then
                        logInfo("HUB", "Server has < 3 players for 20 seconds. Hopping...")
                        Library:Notify({
                            Title = "Server Empty",
                            Description = "Less than 3 players for 20 seconds. Auto hopping...",
                            Icon = "users",
                            Time = 3
                        })
                        task.wait(3)
                        if CariServer then CariServer() end
                    end
                end
            end
        end
    end)

    local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
    MenuGroup:AddButton("Unload UI", function()
        Library:Unload()
    end)

    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

    Library.ToggleKeybind = Options.MenuKeybind

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("ServerHopScript")
    SaveManager:SetFolder("ServerHopScript/Lobby")
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:AddThemeOptions(Tabs.Settings)
end

-- ==========================================
-- KEY SYSTEM UI
-- ==========================================
local function InitKeySystem()
    local savedKey = ""
    if isfile and readfile and isfile(KeyFile) then
        savedKey = readfile(KeyFile)
    end

    if savedKey ~= "" then
        print("[Maika Hub] Found saved key, verifying automatically...")
        local isValid, msg = VerifyKeyServer(savedKey)
        if isValid then
            print("[Maika Hub] Auto-login success!")
            LoadMainScript()
            return
        end
    end

    local KeyWindow = Library:CreateWindow({
        Title = "Maika Hub | Authentication",
        Center = true,
        AutoShow = true,
        Size = UDim2.fromOffset(400, 250)
    })

    local KeyTab = KeyWindow:AddTab("Login", "key")
    local KeyGroup = KeyTab:AddLeftGroupbox("Key Required", "shield")
    
    KeyGroup:AddInput("InputKey", {
        Default = "",
        Numeric = false,
        Finished = false,
        Text = "Enter Your Premium Key",
        Tooltip = "Get your key from maikahub.my.id",
        Placeholder = "Paste key here..."
    })

    KeyGroup:AddButton({
        Text = "Get Key (Copy Link)",
        Func = function()
            if setclipboard then
                setclipboard("https://maikahub.my.id/get-key")
                Library:Notify({
                    Title = "Link Copied!",
                    Description = "Paste in your browser to get a key.",
                    Icon = "copy",
                    Time = 3,
                })
            end
        end,
        DoubleClick = false
    })

    KeyGroup:AddButton({
        Text = "Verify Key",
        Func = function()
            local input = Options.InputKey.Value
            if not input or input == "" then
                Library:Notify({
                    Title = "Error",
                    Description = "Key cannot be empty!",
                    Icon = "x",
                    Time = 3,
                })
                return
            end
            
            Library:Notify({
                Title = "Verifying",
                Description = "Checking key with server...",
                Icon = "loader",
                Time = 2,
            })
            
            local isValid, msg = VerifyKeyServer(input)
            
            if isValid then
                Library:Notify({
                    Title = "Success!",
                    Description = msg,
                    Icon = "check",
                    Time = 3,
                })
                if writefile then
                    writefile(KeyFile, input)
                end
                
                task.wait(1)
                Library:Unload() 
                task.wait(0.5)
                LoadMainScript() 
            else
                Library:Notify({
                    Title = "Failed",
                    Description = msg,
                    Icon = "x",
                    Time = 5,
                })
            end
        end,
        DoubleClick = false
    })

    ThemeManager:SetLibrary(Library)
    ThemeManager:ApplyToTab(KeyTab)
end

InitKeySystem()
