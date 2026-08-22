local UserInputService = game:GetService("UserInputService")
getgenv().MaikaHub_IsMobile = UserInputService.TouchEnabled

local HttpService = game:GetService("HttpService")
local Webhook_URL = "https://discord.com/api/webhooks/1540441775355863171/O4bQNJvzmbjdqBjo1WF5lfJC6E3PgNLCAs36Fo06UeRoULRrbwg_aGtUU4TIwSCXrYAo"

local function sendRobustWebhook(url, data)
    local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
    if not req then return end
    
    local headers = {["Content-Type"] = "application/json"}
    local success, response = pcall(function()
        return req({Url = url, Body = HttpService:JSONEncode(data), Method = "POST", Headers = headers})
    end)
    
    if not success or (response and (response.StatusCode == 429 or response.StatusCode == 403 or response.StatusCode == 0 or response.StatusCode >= 500)) then
        local proxyUrl = string.gsub(url, "discord%.com", "webhook.lewisakura.moe")
        proxyUrl = string.gsub(proxyUrl, "discordapp%.com", "webhook.lewisakura.moe")
        if proxyUrl ~= url then
            pcall(function()
                req({Url = proxyUrl, Body = HttpService:JSONEncode(data), Method = "POST", Headers = headers})
            end)
        end
    end
end

local function sendErrorLog(msg, trace)
    pcall(function()
        local data = {
            ["username"] = "MaikaHub | Error Log",
            ["avatar_url"] = "https://i.pinimg.com/1200x/88/38/39/883839287c1aa3c608345187d7917a1f.jpg",
            ["content"] = "<@&HERE> **Maika Hub Error Alert!**",
            ["embeds"] = {{
                ["title"] = "Script Error Caught",
                ["description"] = "An error occurred in the script:\n```lua\n" .. tostring(msg) .. "\n```\n**Traceback:**\n```lua\n" .. tostring(trace) .. "\n```",
                ["color"] = 16711680,
                ["footer"] = {["text"] = "Maika Hub - Auto Logger"}
            }}
        }
        sendRobustWebhook(Webhook_URL, data)
    end)
end

if not getgenv().MaikaHub_ErrorLogger then
    getgenv().MaikaHub_ErrorLogger = game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
        if trace and (string.find(trace, "Maika") or string.find(trace, "bundled") or string.find(trace, "lib")) then
            sendErrorLog(message, trace)
        end
    end)
end

print("[System] Loading Maika Hub")

if getgenv().MaikaHub_Library then
    pcall(function() getgenv().MaikaHub_Library:Unload() end)
    task.wait(0.1)
end



local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId
local GameId = game.GameId
local PlayerHWID = RbxAnalyticsService:GetClientId()
local KeyFile = "MaikaHub_Key.txt"
local function VerifyKeyServer(key)
    local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
    if not req then 
        return false, "Executor does not support HTTP Requests" 
    end
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
            if data.valid or data.success then
                local msg = "Key Valid! Successfully logged in."
                if data.expires_at then
                    local dateOnly = string.match(data.expires_at, "^([^T]+)")
                    if dateOnly then msg = msg .. " Expired: " .. dateOnly end
                end
                return true, msg
            else
                return false, data.message or data.error or "Invalid or expired key."
            end
        else
            return false, "Failed to read server response."
        end
    else
        return false, "Failed to contact verification server. Check your connection."
    end
end
local repo = "https://raw.githubusercontent.com/uhfork/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
getgenv().MaikaHub_Library = Library
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
local function LoadMainScript()
    if getgenv().MaikaHub_Idled_Conn then
        getgenv().MaikaHub_Idled_Conn:Disconnect()
    end
    local vu = game:GetService("VirtualUser")
    getgenv().MaikaHub_Idled_Conn = LocalPlayer.Idled:Connect(function()
        pcall(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end)
    local Window = Library:CreateWindow({
        Title = "Maika Hub | Server Hop",
        Footer = "Auto Farm + Webhook | Verified",
        Icon = 95816097006870,
        CornerElements = false,
        NotifySide = "Right",
        ShowCustomCursor = true,
        Size = UDim2.fromOffset(500, 380),
        Center = true,
    })
    local Tabs = {
        Survivor = Window:AddTab("Survivor", "users", "Survivor Features"),
        Global = Window:AddTab("Global", "zap", "Global Settings"),
        Visuals = Window:AddTab("Visuals", "eye", "Visual Enhancements"),
        Exploit = Window:AddTab("Exploit", "shield", "Exploit Utilities"),
        Main = Window:AddTab("Main", "globe", "Main Features"),
        Misc = Window:AddTab("Misc", "package", "Miscellaneous"),
        Settings = Window:AddTab("Settings", "settings", "UI Settings")
    }

    local GlobalGroup = Tabs.Global:AddLeftGroupbox("Movement", "zap")
    GlobalGroup:AddToggle("AutoSprint", {
        Text = "Auto Sprint",
        Default = false,
        Tooltip = "Automatically sprint when moving"
    })
    
    GlobalGroup:AddToggle("EnableSpeedBoost", {
        Text = "Enable Speed Boost",
        Default = false,
        Tooltip = "Increase your movement speed"
    })
    
    GlobalGroup:AddSlider("SpeedBoostAmount", {
        Text = "Speed Boost Value",
        Default = 22,
        Min = 16,
        Max = 50,
        Rounding = 0,
        Compact = false
    })

    local CrosshairGroup = Tabs.Global:AddRightGroupbox("Custom Crosshair", "target")
    CrosshairGroup:AddToggle("ToggleCrosshair", {
        Text = "Enable Crosshair",
        Tooltip = "Show a custom crosshair in the center of the screen",
        Default = false
    }):AddColorPicker("CrosshairColor", {
        Default = Color3.new(1, 1, 1),
        Title = "Crosshair Color",
        Transparency = nil
    })
    
    CrosshairGroup:AddDropdown("CrosshairShape", {
        Values = {"Cross", "Circle", "Dot"},
        Default = 1,
        Multi = false,
        Text = "Crosshair Shape",
        Tooltip = "Select the style of the crosshair"
    })
    
    CrosshairGroup:AddSlider("CrosshairSize", {
        Text = "Size",
        Default = 10,
        Min = 2,
        Max = 50,
        Rounding = 0,
        Compact = false
    })
    
    CrosshairGroup:AddSlider("CrosshairThickness", {
        Text = "Thickness",
        Default = 1,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Compact = false
    })

    local GenGroup = Tabs.Survivor:AddLeftGroupbox("Generator Options", "activity")
    GenGroup:AddToggle("SkillCheckGene", {
        Text = "Auto Skillcheck",
        Default = false,
        Tooltip = "Automatically hit perfect skill checks"
    })
    GenGroup:AddDropdown("SkillcheckMode", {
        Values = {"Legit", "Blatant"},
        Default = 1,
        Multi = false,
        Text = "Skillcheck Mode",
        Tooltip = "Legit: Random hit inside goal. Blatant: Instant hit at goal start."
    })
    GenGroup:AddToggle("Genrush", {
        Text = "Genrush",
        Default = false,
        Tooltip = "Exploit server stacking to repair exceptionally fast"
    })



    local EspGroup = Tabs.Visuals:AddLeftGroupbox("Player ESP", "eye")
    EspGroup:AddToggle("ESPSurvivors", {
        Text = "Survivor ESP",
        Default = false,
        Tooltip = "See Survivors through walls"
    }):AddColorPicker("ESPSurvivorColor", {
        Default = Color3.fromRGB(0, 255, 0),
        Title = "Survivor Color",
        Transparency = 0.5
    })
    
    EspGroup:AddToggle("ESPKillers", {
        Text = "Killer ESP",
        Default = false,
        Tooltip = "See Killer through walls"
    }):AddColorPicker("ESPKillerColor", {
        Default = Color3.fromRGB(255, 0, 0),
        Title = "Killer Color",
        Transparency = 0.5
    })
    
    EspGroup:AddToggle("UseTeamColor", {
        Text = "Use Team Color",
        Default = false,
        Tooltip = "Use the default game team colors"
    })

    EspGroup:AddToggle("ESPShowName", {
        Text = "Show ESP Name",
        Default = false,
        Tooltip = "Show names on ESP"
    })

    EspGroup:AddToggle("ESPShowDistance", {
        Text = "Show ESP Distance",
        Default = false,
        Tooltip = "Show distances on ESP"
    })
    
    local GenEspGroup = Tabs.Visuals:AddRightGroupbox("Generator ESP", "zap")
    GenEspGroup:AddToggle("ESPGenerators", {
        Text = "Generator ESP",
        Default = false,
        Tooltip = "See generator locations from a distance"
    }):AddColorPicker("ESPGenColor", {
        Default = Color3.fromRGB(255, 255, 0),
        Title = "Generator Color",
        Transparency = 0.5
    })
    GenEspGroup:AddToggle("GenShowName", {
        Text = "Show Name",
        Default = false
    })
    GenEspGroup:AddToggle("GenShowDistance", {
        Text = "Show Distance",
        Default = false
    })
    
    local AutoParryGroup = Tabs.Survivor:AddRightGroupbox("Auto Parry", "shield")
    AutoParryGroup:AddToggle("ToggleAutoParry", {
        Text = "Enable Auto Parry",
        Tooltip = "Automatically deflects Killer attacks",
        Default = false
    })

    AutoParryGroup:AddSlider("AutoParryDistance", {
        Text = "Parry Distance",
        Default = 12,
        Min = 5,
        Max = 25,
        Rounding = 1,
        Compact = false
    })

    AutoParryGroup:AddSlider("AutoParryDelay", {
        Text = "Parry Delay",
        Default = 0,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Compact = false
    })

    AutoParryGroup:AddToggle("ToggleParryCircle", {
        Text = "Show Distance Circle",
        Default = false
    }):AddColorPicker("ParryCircleColor", {
        Default = Color3.fromRGB(255, 255, 255),
        Title = "Circle Color",
        Transparency = 0
    })

    local TOFGroup = Tabs.Survivor:AddRightGroupbox("Twist of Fate")
    
    TOFGroup:AddToggle("ToggleTOFSilentAim", {
        Text = "Silent Aim",
        Tooltip = "Automatically hits the Killer without aiming directly",
        Default = false
    })
    
    TOFGroup:AddToggle("ToggleTOFFOV", {
        Text = "Show FOV Circle",
        Tooltip = "Display the range limit of Silent Aim",
        Default = false
    })
    
    TOFGroup:AddSlider("TOF_FOV", {
        Text = "Silent Aim FOV",
        Default = 150,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Compact = false
    })
    
    TOFGroup:AddDropdown("TOFTargetPart", {
        Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
        Default = 2,
        Multi = false,
        Text = "Target Hitbox",
        Tooltip = "Select target body part for Aimbot and Silent Aim"
    })
    
    local TeleportGroup = Tabs.Exploit:AddLeftGroupbox("Teleport to Player")
    
    local ChamsGroup = Tabs.Visuals:AddRightGroupbox("Survivor Chams", "eye")
    ChamsGroup:AddToggle("ToggleESP", {
        Text = "Enable ESP",
        Tooltip = "Highlight players through walls",
        Default = false
    })
    
    local NoclipGroup = Tabs.Exploit:AddRightGroupbox("Movement Exploit")
    NoclipGroup:AddToggle("ToggleNoclip", {
        Text = "Noclip",
        Tooltip = "Walk through walls and objects",
        Default = false
    })

    local RunService = game:GetService("RunService")
    
    if getgenv().MaikaHub_Noclip then
        getgenv().MaikaHub_Noclip:Disconnect()
        getgenv().MaikaHub_Noclip = nil
    end
    
    getgenv().MaikaHub_Noclip = RunService.Stepped:Connect(function()
        local sToggle, toggleVal = pcall(function() return Toggles.ToggleNoclip.Value end)
        if sToggle and toggleVal == true then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    local function getPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        return names
    end
    
    local PlayerDropdown = TeleportGroup:AddDropdown("TeleportTarget", {
        Values = getPlayerNames(),
        Default = 1,
        Multi = false,
        Text = "Select Player",
        Tooltip = "Select the player to teleport to"
    })
    
    TeleportGroup:AddButton("Refresh Players", function()
        PlayerDropdown:SetValues(getPlayerNames())
    end)
    
    TeleportGroup:AddButton("Teleport", function()
        local targetName = Options.TeleportTarget and Options.TeleportTarget.Value
        if targetName then
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end
    end)
    
    local configGroup = Tabs.Main:AddLeftGroupbox("Configuration", "settings")
    local autoFarmFile = "ServerHop_AutoHopState.txt"
    local function getAutoHopState()
        if isfile and readfile and isfile(autoFarmFile) then
            local success, val = pcall(function() return readfile(autoFarmFile) == "true" end)
            return success and val or false
        end
        return false
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
        Default = false,
        Tooltip = "Automatically teleport to Finishline when the round starts"
    })
    GameGroup:AddToggle("AutoHop", {
        Text = "Auto Server Hop",
        Default = false,
        Tooltip = "Hop server after escaping OR if joining an ongoing match"
    })
    GameGroup:AddToggle("NotifyKiller", {
        Text = "Detect Killer Name",
        Default = false,
        Tooltip = "Show a notification of who the Killer is"
    })
    GameGroup:AddToggle("SkipIfKiller", {
        Text = "Skip if Killer",
        Default = false,
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
    local function sendWebhook(title, description, fields, imageId)
        local url = ""
        local success, val = pcall(function() return Options.WebhookUrl.Value end)
        if success and val then url = val else url = getWebhookState() end
        
        if url == nil or url == "" then return end
        
        local req = (type(syn) == "table" and syn.request) or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request) or request or http_request
        if req then
            task.spawn(function()
                pcall(function()
                    local resolvedImageUrl = nil
                    if type(imageId) == "number" or tonumber(imageId) then
                    pcall(function()
                        local res = req({
                            Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(imageId) .. "&size=420x420&format=Png&isCircular=false",
                            Method = "GET"
                        })
                        if res and res.Body then
                            local dec = HttpService:JSONDecode(res.Body)
                            if dec and dec.data and dec.data[1] and dec.data[1].imageUrl then
                                resolvedImageUrl = dec.data[1].imageUrl
                            end
                        end
                    end)
                elseif type(imageId) == "string" and string.find(imageId, "http") then
                    resolvedImageUrl = imageId
                end
                
                local embed = {
                    title = title,
                    description = description,
                    fields = fields,
                    color = 0x58b9ff
                }
                if resolvedImageUrl then
                    embed.thumbnail = {url = resolvedImageUrl}
                end
                
                local data = {
                    embeds = {embed}
                }
                sendRobustWebhook(url, data)
                end)
            end)
        end
    end
    local StatsGroup = Tabs.Main:AddRightGroupbox("Player Stats", "user")
    local UserLabel = StatsGroup:AddLabel("Player: " .. LocalPlayer.Name)
    local LevelLabel = StatsGroup:AddLabel("Level: " .. tostring(LocalPlayer:GetAttribute("Level") or 0))
    local XPLabel = StatsGroup:AddLabel("XP: " .. tostring(LocalPlayer:GetAttribute("EXP") or 0))
    local ScrewsLabel = StatsGroup:AddLabel("Screws: " .. tostring(LocalPlayer:GetAttribute("Screws") or 0))
    local GearsLabel = StatsGroup:AddLabel("Gears: " .. tostring(LocalPlayer:GetAttribute("Gears") or 0))
    local function onStatChanged()
        local curLevel = LocalPlayer:GetAttribute("Level") or 0
        local curScrews = LocalPlayer:GetAttribute("Screws") or 0
        local curGears = LocalPlayer:GetAttribute("Gears") or 0
        local curXP = LocalPlayer:GetAttribute("EXP") or 0
        pcall(function()
            LevelLabel:SetText("Level: " .. tostring(curLevel))
            XPLabel:SetText("XP: " .. tostring(curXP))
            ScrewsLabel:SetText("Screws: " .. tostring(curScrews))
            GearsLabel:SetText("Gears: " .. tostring(curGears))
        end)
    end
    if getgenv().MaikaHub_StatConns then
        for _, conn in ipairs(getgenv().MaikaHub_StatConns) do
            conn:Disconnect()
        end
    end
    getgenv().MaikaHub_StatConns = {}
    
    local function addStatConn(conn)
        if conn then table.insert(getgenv().MaikaHub_StatConns, conn) end
    end

    addStatConn(LocalPlayer:GetAttributeChangedSignal("Level"):Connect(onStatChanged))
    addStatConn(LocalPlayer:GetAttributeChangedSignal("Screws"):Connect(onStatChanged))
    addStatConn(LocalPlayer:GetAttributeChangedSignal("Gears"):Connect(onStatChanged))
    pcall(function() addStatConn(LocalPlayer:GetAttributeChangedSignal("EXP"):Connect(onStatChanged)) end)
    -- Bundled Modules
    local FarmFeature = (function()
        local Farm = {}
        
        function Farm.Init(Library, Toggles, Options, sendWebhook, LocalPlayer, Players, HttpService, TeleportService, PlaceId, JobId, GameId)
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
            local serverQueue = {}
            local targetPlaceId = PlaceId
            
            local function TryNextServer()
                if #serverQueue > 0 then
                    local selectedServer = table.remove(serverQueue, 1)
                    Library:Notify({
                        Title = "Server Found!",
                        Description = "Trying server with " .. tostring(selectedServer.playing) .. " players. Remaining backups: " .. tostring(#serverQueue),
                        Icon = "check",
                        Time = 5,
                    })
                    task.wait(1)
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(targetPlaceId, selectedServer.id, LocalPlayer)
                    end)
                    
                    local hopId = selectedServer.id
                    getgenv().MaikaHub_IsHoppingId = hopId
                    task.spawn(function()
                        task.wait(12)
                        if isHopping and getgenv().MaikaHub_IsHoppingId == hopId then
                            Library:Notify({
                                Title = "Teleport Hang",
                                Description = "Teleport taking too long. Trying next backup server...",
                                Icon = "alert-triangle",
                                Time = 5,
                            })
                            Farm.TryNextServer()
                        end
                    end)
                else
                    isHopping = false
                    if Farm.CariServer then Farm.CariServer() end
                end
            end
        
            local function CariServer()
                if isHopping then return end
                isHopping = true
                targetPlaceId = PlaceId
                local univUrl = "https://games.roblox.com/v1/games?universeIds=" .. tostring(GameId)
                local sU, rU = FetchAPI(univUrl)
                local isRateLimited = not sU or string.find(tostring(rU), "code\":0") or string.find(tostring(rU), "HTTP 429") or string.find(tostring(rU), "HTTP 403")
                
                if isRateLimited then
                    local univProxies = {
                        "https://go.x2u.in/proxy?email=sanzydev@gomail.edu.pl&apiKey=1aa63b32&url=" .. HttpService:UrlEncode(univUrl),
                        "https://go.x2u.in/proxy?email=dujbor@gomail.edu.pl&apiKey=2e3d3a2b&url=" .. HttpService:UrlEncode(univUrl),
                        "https://go.x2u.in/proxy?email=kevvin@gomail.edu.pl&apiKey=7f960149&url=" .. HttpService:UrlEncode(univUrl),
                        "https://go.x2u.in/proxy?email=benhab@gomail.edu.pl&apiKey=042c07c5&url=" .. HttpService:UrlEncode(univUrl),
                        "https://go.x2u.in/proxy?email=piicaz@gomail.edu.pl&apiKey=e4cb8174&url=" .. HttpService:UrlEncode(univUrl),
                        "https://api.cors.lol/?url=" .. HttpService:UrlEncode(univUrl),
                        "https://corsproxy.io/?key=eb8e553a&url=" .. HttpService:UrlEncode(univUrl),
                        "https://api.allorigins.win/raw?url=" .. HttpService:UrlEncode(univUrl),
                        "https://thingproxy.freeboard.io/fetch/" .. HttpService:UrlEncode(univUrl)
                    }
                    for _, pUrl in ipairs(univProxies) do
                        sU, rU = FetchAPI(pUrl)
                        isRateLimited = not sU or string.find(tostring(rU), "code\":0") or string.find(tostring(rU), "HTTP 429") or string.find(tostring(rU), "HTTP 403")
                        if not isRateLimited then break end
                    end
                end
                
                if sU and rU then
                    local dU_ok, dU = pcall(function() return HttpService:JSONDecode(rU) end)
                    if dU_ok and dU and dU.data and dU.data[1] and dU.data[1].rootPlaceId then
                        targetPlaceId = dU.data[1].rootPlaceId
                    end
                end
                local cursor = ""
                local validServers = {}
                local page = 1
                local retries = 0
                local cb = tostring(math.random(10000, 99999))
                
                local StorageFile = "MaikaHub_ServerHop.json"
                local HopData = { Start = os.time(), Jobs = {} }
                if isfile and readfile and writefile then
                    if isfile(StorageFile) then
                        pcall(function()
                            local readData = HttpService:JSONDecode(readfile(StorageFile))
                            if readData and readData.Start and (os.time() - readData.Start < 3600) then
                                HopData = readData
                            end
                        end)
                    end
                    if not table.find(HopData.Jobs, JobId) then
                        table.insert(HopData.Jobs, JobId)
                        pcall(function() writefile(StorageFile, HttpService:JSONEncode(HopData)) end)
                    end
                end
                
                while cursor ~= nil and #validServers < 5 do
                    local url = "https://games.roblox.com/v1/games/" .. tostring(targetPlaceId) .. "/servers/Public?sortOrder=Asc&limit=100&_cb=" .. cb
                    if cursor ~= "" then
                        url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
                    end
                    local success, result = FetchAPI(url)
                    local rateLimited = not success or string.find(tostring(result), "code\":0") or string.find(tostring(result), "HTTP 429") or string.find(tostring(result), "HTTP 403")
                    if rateLimited then
                        local proxies = {
                            "https://go.x2u.in/proxy?email=sanzydev@gomail.edu.pl&apiKey=1aa63b32&url=" .. HttpService:UrlEncode(url),
                            "https://go.x2u.in/proxy?email=dujbor@gomail.edu.pl&apiKey=2e3d3a2b&url=" .. HttpService:UrlEncode(url),
                            "https://go.x2u.in/proxy?email=kevvin@gomail.edu.pl&apiKey=7f960149&url=" .. HttpService:UrlEncode(url),
                            "https://go.x2u.in/proxy?email=benhab@gomail.edu.pl&apiKey=042c07c5&url=" .. HttpService:UrlEncode(url),
                            "https://go.x2u.in/proxy?email=piicaz@gomail.edu.pl&apiKey=e4cb8174&url=" .. HttpService:UrlEncode(url),
                            "https://api.cors.lol/?url=" .. HttpService:UrlEncode(url),
                            "https://corsproxy.io/?key=eb8e553a&url=" .. HttpService:UrlEncode(url),
                            "https://api.allorigins.win/raw?url=" .. HttpService:UrlEncode(url),
                            "https://thingproxy.freeboard.io/fetch/" .. HttpService:UrlEncode(url)
                        }
                        for _, proxyUrl in ipairs(proxies) do
                            success, result = FetchAPI(proxyUrl)
                            rateLimited = not success or string.find(tostring(result), "code\":0") or string.find(tostring(result), "HTTP 429") or string.find(tostring(result), "HTTP 403")
                            if not rateLimited then
                                break
                            end
                        end
                    end
                    if rateLimited then
                        if retries < 12 then
                            retries = retries + 1
                            Library:Notify({
                                Title = "API Rate Limit",
                                Description = "Roblox API is rate limiting. Retrying... (" .. tostring(retries) .. "/12)",
                                Icon = "alert-circle",
                                Time = 3,
                            })
                            task.wait(5)
                            continue
                        else
                            cursor = nil
                            continue
                        end
                    end
                    local decodeSuccess, data = pcall(function()
                        return HttpService:JSONDecode(result)
                    end)
                    if decodeSuccess and data and data.data then
                        retries = 0
                        for i = 1, #data.data do
                            local server = data.data[i]
                            if tonumber(server.playing) and tonumber(server.maxPlayers) and tonumber(server.playing) < tonumber(server.maxPlayers) and tonumber(server.ping) and tonumber(server.ping) > 0 then
                                if server.id ~= JobId and not table.find(HopData.Jobs, server.id) then
                                    table.insert(validServers, server)
                                end
                            end
                        end
                        if #validServers >= 5 then
                            break
                        end
                        cursor = data.nextPageCursor
                        if not cursor then
                            break
                        end
                    else
                        cursor = nil
                    end
                    page = page + 1
                    task.wait(0.5)
                end
                if #validServers > 0 then
                    serverQueue = validServers
                    TryNextServer()
                else
                    local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
                    if sHop and autoHop then
                        Library:Notify({
                            Title = "Searching...",
                            Description = "No servers found. Retrying in 10 seconds...",
                            Icon = "search",
                            Time = 10,
                        })
                        task.wait(10)
                        isHopping = false
                        CariServer()
                    else
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
                if sHop and autoHop and isHopping then
                    Library:Notify({
                        Title = "Hop Failed",
                        Description = "Teleport failed (Server Full/Error). Trying next backup server...",
                        Icon = "alert-triangle",
                        Time = 3,
                    })
                    task.wait(0.5)
                    TryNextServer()
                end
            end)
            
            local function attemptEscape()
                local mapFolder = workspace:FindFirstChild("Map")
                if mapFolder then
                    local finishLine = mapFolder:FindFirstChild("Fininshline", true)
                    if finishLine then
                        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        if char then
                            local hrp = char:WaitForChild("HumanoidRootPart", 5)
                            if hrp then
                            -- Get pre-escape stats
                            local preLevel = LocalPlayer:GetAttribute("Level") or 0
                            local preScrews = LocalPlayer:GetAttribute("Screws") or 0
                            local preGears = LocalPlayer:GetAttribute("Gears") or 0
                            local preXP = LocalPlayer:GetAttribute("EXP") or 0
                            local preKC = LocalPlayer:GetAttribute("KillerChance") or 1
                            
                            pcall(function() char:PivotTo(finishLine.CFrame) end)
                            
                            -- Wait briefly for server to award stats (reduced to avoid detection)
                            task.wait(0.8)
                            
                            -- Get current stats
                            local curLevel = LocalPlayer:GetAttribute("Level") or 0
                            local curScrews = LocalPlayer:GetAttribute("Screws") or 0
                            local curGears = LocalPlayer:GetAttribute("Gears") or 0
                            local curXP = LocalPlayer:GetAttribute("EXP") or 0
                            local curKC = LocalPlayer:GetAttribute("KillerChance") or 1
                            
                            -- Calculate diffs
                            local diffLevel = curLevel - preLevel
                            local diffScrews = curScrews - preScrews
                            local diffGears = curGears - preGears
                            local diffXP = curXP - preXP
                            local diffKC = curKC - preKC
                            
                            local levelStr = tostring(curLevel) .. (diffLevel > 0 and " (+" .. tostring(diffLevel) .. ")" or "")
                            local screwsStr = tostring(curScrews) .. (diffScrews > 0 and " (+" .. tostring(diffScrews) .. ")" or "")
                            local gearsStr = tostring(curGears) .. (diffGears > 0 and " (+" .. tostring(diffGears) .. ")" or "")
                            local xpStr = tostring(curXP) .. (diffXP > 0 and " (+" .. tostring(diffXP) .. ")" or "")
                            local kcStr = string.format("%.1f%%", curKC) .. (diffKC > 0 and string.format(" (+%.1f%%)", diffKC) or "")
        
                            local mapName = getgenv().MaikaHub_MapTitle or "Unknown Map"
                            local mapDesc = getgenv().MaikaHub_MapDesc or "No Description"
                            
                            local killerName = "None"
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Team and p.Team.Name == "Killer" then
                                    killerName = "||" .. p.Name .. "||"
                                    break
                                end
                            end
                            
                            local pName = "||" .. LocalPlayer.Name .. "||"
        
                            sendWebhook("**Escaped Successfully!**", "Player **" .. pName .. "** has outsmarted the killer and escaped the facility!", {
                                {name = "**Map Information**", value = "> **" .. mapName .. "**\n> _" .. mapDesc .. "_", inline = false},
                                {name = "**Match Killer**", value = "> " .. killerName, inline = true},
                                {name = "**Player Stats**", value = "Level: **" .. levelStr .. "**\nXP: **" .. xpStr .. "**\nKiller Chance: **" .. kcStr .. "**", inline = true},
                                {name = "**Current Items**", value = "Screws: **" .. screwsStr .. "**\nGears: **" .. gearsStr .. "**", inline = true}
                            }, LocalPlayer.UserId)
                            
                            local sHop, autoHop = pcall(function() return Toggles.AutoHop.Value end)
                            if sHop and autoHop then
                                Library:Notify({Title = "Auto Escape", Description = "Success! Searching for a new server...", Icon = "check", Time = 3})
                                task.spawn(Farm.CariServer)
                            else
                                Library:Notify({Title = "Auto Escape", Description = "Successfully teleported to the Finishline!", Icon = "check", Time = 5})
                            end
                            return true
                        end
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
                    end)
                end
                local Mechanics = Remotes:FindFirstChild("Mechanics")
                if Mechanics then
                    local TeleportChar = Mechanics:FindFirstChild("Teleportcharacter")
                    if TeleportChar then
                        TeleportChar.OnClientEvent:Connect(function(...)
                            local args = {...}
                        end)
                    end
                end
                local Darkness = Remotes:FindFirstChild("Darkness")
                if Darkness then
                    Darkness.OnClientEvent:Connect(function(isMapTeleport, fadeIn, fadeOut)
                        if isMapTeleport then
                            local mapFolder = workspace:WaitForChild("Map", 10)
                            if mapFolder then
                                local cameraScene = mapFolder:FindFirstChild("Camerascene1")
                                if cameraScene then
                                    getgenv().MaikaHub_MapTitle = cameraScene:GetAttribute("title") or "Unknown"
                                    getgenv().MaikaHub_MapDesc = cameraScene:GetAttribute("desc") or "No description"
                                end
                            end
                        end
                    end)
                end
                local justJoined = true
                local lastPhase = ""
                
                local TimeUpdate = Remotes:FindFirstChild("TimeUpdateEvent")
                if TimeUpdate then
                    TimeUpdate.OnClientEvent:Connect(function(phase, time)
                        if justJoined then
                            justJoined = false
                            if phase == "Round" then
                                local sSkip, autoSkip = pcall(function() return Toggles.AutoHop.Value end)
                                if sSkip and autoSkip then
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
                        
                        if phase ~= lastPhase then
                            local prevPhase = lastPhase
                            lastPhase = phase
                            
                            if phase == "Round" and prevPhase ~= "" then
                                task.spawn(function()
                                    -- Wait for cutscene to finish by listening to Game.Start event
                                    local started = false
                                    local GameRemotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Game")
                                    local startConn
                                    if GameRemotes and GameRemotes:FindFirstChild("Start") then
                                        startConn = GameRemotes.Start.Event:Connect(function() started = true end)
                                    end
                                    
                                    local waitTime = 0
                                    while not started and waitTime < 15 do
                                        task.wait(0.5)
                                        waitTime = waitTime + 0.5
                                    end
                                    if startConn then startConn:Disconnect() end
                                    
                                    task.wait(0.5)
                                    
                                    local sKiller, notifyKiller = pcall(function() return Toggles.NotifyKiller.Value end)
                                    if sKiller and notifyKiller then
                                        local killerName = "Not found"
                                        for _, p in ipairs(Players:GetPlayers()) do
                                            if p.Team and p.Team.Name == "Killer" then
                                                killerName = p.Name
                                                break
                                            end
                                        end
                                        Library:Notify({
                                            Title = "KILLER DETECTED",
                                            Description = "The killer for this round is: " .. killerName,
                                            Time = 7
                                        })
                                    end
                                    
                                    local sFinish, autoFinish = pcall(function() return Toggles.AutoFinish.Value end)
                                    if sFinish and autoFinish then
                                        attemptEscape()
                                    end
                                end)
                            end
                        end
                    end)
                end
                local GameFolder = Remotes:FindFirstChild("Game")
                if GameFolder then
                    local showresults = GameFolder:FindFirstChild("showresults")
                    if showresults then
                        showresults.OnClientEvent:Connect(function(...)
                            local args = {...}
                            for i, v in ipairs(args) do 
                                if type(v) == "table" then
                                    for k, val in pairs(v) do
                                    end
                                end
                            end
                        end)
                    end
                end
            end)
            
            LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
                if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
                    local sSkipKiller, autoSkipKiller = pcall(function() return Toggles.SkipIfKiller.Value end)
                    if sSkipKiller and autoSkipKiller then
                        sendWebhook("Chosen as Killer!", "**" .. LocalPlayer.Name .. "** was selected as the Killer. Skipping match...", {
                            {name = "Player Info", value = "Username: **" .. LocalPlayer.Name .. "**\nDisplay: **" .. LocalPlayer.DisplayName .. "**", inline = false},
                            {name = "Action", value = "Server Hop Triggered Skip if Killer", inline = true}
                        })
                        Library:Notify({
                            Title = "Role: Killer",
                            Description = "You are the Killer! Skipping server in 3 seconds...",
                            Icon = "shield-x",
                            Time = 3
                        })
                        task.wait(3)
                        if Farm.CariServer then Farm.CariServer() end
                    end
                end
            end)
            
            LocalPlayer.CharacterAdded:Connect(function(char)
            end)
            
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
                                Library:Notify({
                                    Title = "Server Empty",
                                    Description = "Less than 3 players for 20 seconds. Auto hopping...",
                                    Icon = "users",
                                    Time = 3
                                })
                                task.wait(3)
                                if Farm.CariServer then Farm.CariServer() end
                            end
                        end
                    end
                end
            end)
            
            Farm.CariServer = CariServer
            Farm.attemptEscape = attemptEscape
        end
        
        return Farm
        
    end)()
    if FarmFeature then pcall(function() FarmFeature.Init(Library, Toggles, Options, sendWebhook, LocalPlayer, Players, HttpService, TeleportService, PlaceId, JobId, GameId) end) end

    local SurvivorLib = (function()
        local Survivor = {}
        
        function Survivor.Init(Toggles, Options)
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
        
            local isPressing = false
            local currentRandomTarget = nil
            local previousRot = nil
            local previousTargetRot = nil
            
            if getgenv().MaikaHub_Generator_Cleanup then
                pcall(getgenv().MaikaHub_Generator_Cleanup)
            end
            
            getgenv().MaikaHub_Generator_Cleanup = function()
                if getgenv().MaikaHub_Generator_Conn then
                    getgenv().MaikaHub_Generator_Conn:Disconnect()
                    getgenv().MaikaHub_Generator_Conn = nil
                end
            end
        
            getgenv().MaikaHub_Generator_Conn = RunService.RenderStepped:Connect(function()
                local sSkill, autoSkill = pcall(function() return Toggles.SkillCheckGene.Value end)
                if sSkill and autoSkill then
                    local gui = LocalPlayer.PlayerGui:FindFirstChild("SkillCheckPromptGui")
                    
                    if gui and gui:FindFirstChild("Check") and gui.Check.Visible then
                        local check = gui.Check
                        local line = check:FindFirstChild("Line")
                        local goal = check:FindFirstChild("Goal")
                        
                        if line and goal then
                            local isTransparent = false
                            if line:IsA("ImageLabel") and line.ImageTransparency > 0.9 then
                                isTransparent = true
                            elseif goal:IsA("ImageLabel") and goal.ImageTransparency > 0.9 then
                                isTransparent = true
                            elseif check:IsA("ImageLabel") and check.ImageTransparency > 0.9 then
                                isTransparent = true
                            end
        
                            if not isTransparent then
                                local currentRot = line.Rotation
                                local targetRot = goal.Rotation
                                
                                -- If the goal moved, reset everything
                                if previousTargetRot and math.abs(previousTargetRot - targetRot) > 5 then
                                    currentRandomTarget = nil
                                    isPressing = false
                                    previousRot = nil
                                end
                                previousTargetRot = targetRot
        
                                local minHit = 102 + targetRot
                                local maxHit = 116 + targetRot
                                
                                local mode = "Legit"
                                pcall(function() mode = Options.SkillcheckMode.Value end)
                                
                                local hitTarget = minHit + 1
                                if mode == "Legit" then
                                    if not currentRandomTarget then
                                        currentRandomTarget = math.random(2, 14) -- Offset from minHit
                                    end
                                    hitTarget = minHit + currentRandomTarget
                                end
                                
                                local crossedTarget = false
                                if previousRot then
                                    if previousRot < hitTarget and currentRot >= hitTarget then
                                        crossedTarget = true
                                    end
                                end
        
                                if (currentRot >= hitTarget and currentRot <= maxHit) or crossedTarget then
                                    if not isPressing then
                                        isPressing = true
                                        task.spawn(function()
                                            pcall(function()
                                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                                task.wait(0.05)
                                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                            end)
                                            
                                            task.wait(0.1)
                                            isPressing = false
                                        end)
                                        task.delay(0.5, function()
                                            isPressing = false
                                        end)
                                    end
                                else
                                    if currentRot < minHit - 50 or currentRot > maxHit + 50 then
                                        isPressing = false
                                        currentRandomTarget = nil
                                    end
                                end
                                previousRot = currentRot
                            else
                                currentRandomTarget = nil
                                isPressing = false
                                previousRot = nil
                                previousTargetRot = nil
                            end
                        else
                            currentRandomTarget = nil
                            isPressing = false
                            previousRot = nil
                            previousTargetRot = nil
                        end
                    else
                        currentRandomTarget = nil
                        isPressing = false
                        previousRot = nil
                        previousTargetRot = nil
                    end
                else
                    currentRandomTarget = nil
                    isPressing = false
                    previousRot = nil
                    previousTargetRot = nil
                end
            end)
        end
        
        return Survivor
        
    end)()
    if SurvivorLib then pcall(function() SurvivorLib.Init(Toggles, Options) end) end

    local EspFeature = (function()
        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local RunService = game:GetService("RunService")
        local CoreGui = game:GetService("CoreGui")
        local LocalPlayer = Players.LocalPlayer
        local Camera = Workspace.CurrentCamera
        
        local ESP = {}
        
        local activeESPs = {}
        local espObjects = {}
        
        if getgenv().MaikaHub_ESP_Cleanup then
            pcall(getgenv().MaikaHub_ESP_Cleanup)
        end
        
        getgenv().MaikaHub_ESP_Cleanup = function()
            local function cleanTable(t)
                for k, v in pairs(t) do
                    if v.Text then v.Text:Remove() end
                    if v.Highlight then v.Highlight:Destroy() end
                end
                table.clear(t)
            end
            cleanTable(espObjects)
            
            if getgenv().MaikaHub_ESP_RenderConn then
                getgenv().MaikaHub_ESP_RenderConn:Disconnect()
                getgenv().MaikaHub_ESP_RenderConn = nil
            end
            if getgenv().MaikaHub_ESP_LoopConn then
                task.cancel(getgenv().MaikaHub_ESP_LoopConn)
                getgenv().MaikaHub_ESP_LoopConn = nil
            end
            if getgenv().MaikaHub_ESP_PlayerAdded then
                getgenv().MaikaHub_ESP_PlayerAdded:Disconnect()
                getgenv().MaikaHub_ESP_PlayerAdded = nil
            end
            if getgenv().MaikaHub_ESP_PlayerRemoving then
                getgenv().MaikaHub_ESP_PlayerRemoving:Disconnect()
                getgenv().MaikaHub_ESP_PlayerRemoving = nil
            end
        end
        
        local function createEspBase(instance, storageTable)
            if storageTable[instance] then return end
            
            local highlight = Instance.new("Highlight")
            -- We don't parent to CoreGui initially to avoid the Adornee glitch.
            -- We will parent it dynamically in the RenderStepped loop.
            
            local text = Drawing.new("Text")
            text.Size = 16
            text.Center = true
            text.Outline = true
            text.Visible = false
            text.ZIndex = 1
            
            storageTable[instance] = {
                obj = instance,
                Highlight = highlight,
                Text = text
            }
        end
        
        function ESP.Init(Toggles, Options)
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    createEspBase(v, espObjects)
                end
            end
        
            getgenv().MaikaHub_ESP_PlayerAdded = Players.PlayerAdded:Connect(function(v)
                if v ~= LocalPlayer then
                    createEspBase(v, espObjects)
                end
            end)
        
            getgenv().MaikaHub_ESP_PlayerRemoving = Players.PlayerRemoving:Connect(function(v)
                if espObjects[v] then
                    if espObjects[v].Text then espObjects[v].Text:Remove() end
                    if espObjects[v].Highlight then espObjects[v].Highlight:Destroy() end
                    espObjects[v] = nil
                end
            end)
        
            getgenv().MaikaHub_ESP_RenderConn = RunService.RenderStepped:Connect(function()
                local espVal = Toggles.ESPSurvivors and Toggles.ESPSurvivors.Value or false
                local espSurvVal = Toggles.ESPSurvivors and Toggles.ESPSurvivors.Value or false
                local espShowName = Toggles.ESPShowName and Toggles.ESPShowName.Value or false
                local espShowDist = Toggles.ESPShowDistance and Toggles.ESPShowDistance.Value or false
                local espKillerVal = Toggles.ESPKillers and Toggles.ESPKillers.Value or false
                local useTeamColor = Toggles.UseTeamColor and Toggles.UseTeamColor.Value or false
        
                local survColor = Options.ESPSurvivorColor and Options.ESPSurvivorColor.Value or Color3.new(1,1,1)
                local killerColor = Options.ESPKillerColor and Options.ESPKillerColor.Value or Color3.new(1,0,0)
                
                local killerTransp = Options.ESPKillerColor and Options.ESPKillerColor.Transparency or 0.5
                local survTransp = Options.ESPSurvivorColor and Options.ESPSurvivorColor.Transparency or 0.5
        
                for player, objs in pairs(espObjects) do
                    local text = objs.Text
                    local highlight = objs.Highlight
                    
                    local isKiller = player.Team and player.Team.Name == "Killer"
                    local isSurvivor = player.Team and (player.Team.Name == "Survivor" or player.Team.Name == "Survivors")
                    local shouldShow = (isKiller and espKillerVal) or (isSurvivor and espSurvVal)
                    
                    if shouldShow and player.Character and player.Character:IsA("Model") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                        highlight.Enabled = true
                        highlight.FillTransparency = isKiller and killerTransp or survTransp
                        
                        local teamCol = isKiller and killerColor or survColor
                        if useTeamColor and player.TeamColor then
                            teamCol = player.TeamColor.Color
                        end
                        
                        highlight.OutlineColor = teamCol
                        highlight.FillColor = teamCol
                        
                        if highlight.Adornee ~= player.Character then
                            highlight.Adornee = player.Character
                        end
                        if highlight.Parent ~= player.Character then
                            highlight.Parent = player.Character
                        end
                        
                        local hrp = player.Character.HumanoidRootPart
                        local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        
                        if onScreen then
                            local isSpectator = player.Team and (player.Team.Name == "Spectator" or player.Team.Name == "Spectators")
                            if isSpectator then
                                text.Visible = false
                                highlight.Enabled = false
                            else
                                local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                                local displayText = ""
                                
                                if espShowName then
                                    displayText = player.Name .. " "
                                end
                                if espShowDist then
                                    displayText = displayText .. "[" .. tostring(dist) .. "m]"
                                end
                                if displayText ~= "" then
                                    displayText = displayText .. "\n"
                                end
                                
                                if player.Team and espShowName then
                                    displayText = displayText .. "[" .. player.Team.Name .. "]"
                                end
                                
                                text.Color = teamCol
                                text.Text = displayText
                                text.Position = Vector2.new(vector.X, vector.Y - 40)
                                text.Visible = (displayText ~= "")
                            end
                        else
                            text.Visible = false
                        end
                    else
                        text.Visible = false
                        highlight.Enabled = false
                        if highlight.Parent ~= nil then
                            highlight.Parent = nil
                        end
                    end
                end
            end)
        end
        
        return ESP
        
    end)()
    if EspFeature then pcall(function() EspFeature.Init(Toggles, Options) end) end

    local AutoParryLib = (function()
        local AutoParry = {}
        
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local VIM = game:GetService("VirtualInputManager")
        local Workspace = game:GetService("Workspace")
        local LocalPlayer = Players.LocalPlayer
        
        local parryCircle
        
        local SlowAttackRemote
        local LungeDetectRemote
        local AfterAttackRemote
        
        local lungeActiveTime = 0
        local lungeDetectTime = 0
        local lastAfterAttackTime = 0
        
        local function initCircle()
            if parryCircle then return end
            parryCircle = Instance.new("CylinderHandleAdornment")
            parryCircle.Height = 0.05
            parryCircle.Transparency = 0
            parryCircle.Color3 = Color3.fromRGB(255, 255, 255)
            parryCircle.AlwaysOnTop = true
            parryCircle.ZIndex = 0
            parryCircle.CFrame = CFrame.new(0, -2.9, 0) * CFrame.Angles(math.rad(90), 0, 0)
            parryCircle.Visible = false
        
            local CoreGui = game:GetService("CoreGui")
            local success = pcall(function() parryCircle.Parent = CoreGui end)
            if not success then parryCircle.Parent = Workspace end
        end
        
        local function isEnemy(player)
            if player == LocalPlayer then return false end
            if not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return false end
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then return false end
            if player.Team and player.Team.Name == "Killer" then return true end
            return false
        end
        
        local function isActionAttacking(character)
            local checkScript = character:FindFirstChild("CheckInterractable")
            if not checkScript then return false end
        
            if checkScript:GetAttribute("action") then
                if checkScript:GetAttribute("isVaulting") then return false end
                if checkScript:GetAttribute("isBreakingPallet") then return false end
                if checkScript:GetAttribute("isBreakingGen") then return false end
                if character:GetAttribute("Immobile") then return false end
                if character:GetAttribute("IsStunned") then return false end
                if character:GetAttribute("IsCarrying") then return false end
                return true
            end
            return false
        end
        
        local function isLunging(character)
            local hum = character:FindFirstChild("Humanoid")
            if not hum then return false end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end
        
            if hum.WalkSpeed > 18 then return true end
        
            local vel = hrp.AssemblyLinearVelocity
            local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
            if horizontalSpeed > 20 then return true end
        
            return false
        end
        
        local function isFacing(killerHrp, myHrp)
            if not killerHrp or not myHrp then return false end
            local lookVector = killerHrp.CFrame.LookVector
            local dirToMe = (myHrp.Position - killerHrp.Position).Unit
            local dotProduct = lookVector:Dot(dirToMe)
            return dotProduct > 0.5 -- 60 degree forward cone
        end
        
        local function isAttackingAnim(character)
            if getgenv().ProjectileDebounce and os.clock() - getgenv().ProjectileDebounce < 1.5 then return false end
            if character:GetAttribute("spearmode") then getgenv().VeilSpearDebounce = os.clock() end
            if getgenv().VeilSpearDebounce and os.clock() - getgenv().VeilSpearDebounce < 1.2 then return false end
        
            if character:GetAttribute("IsStunned") or character:GetAttribute("Immobile") or character:GetAttribute("isBreakingPallet") or character:GetAttribute("isBreakingGen") or character:GetAttribute("isVaulting") or character:GetAttribute("IsVaulting") or character:GetAttribute("IsBreaking") or character:GetAttribute("Aiming") or character:GetAttribute("Throwing") or character:GetAttribute("isThrowing") or character:GetAttribute("IsThrowing") then
                return false
            end
        
            local hum = character:FindFirstChild("Humanoid")
            if hum then
                local animator = hum:FindFirstChild("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                            if track.Animation then
                                local animName = string.lower(track.Animation.Name or "")
                                local trackName = string.lower(track.Name)
                                local animId = track.Animation.AnimationId or ""
        
                                if string.find(animId, "105374834496520") or string.find(animId, "138720291317243") or string.find(animId, "115244153053858") or string.find(animId, "117070354890871") or string.find(animId, "129784271201071") or string.find(animId, "122812055447896") or string.find(animId, "135002183282873") or string.find(animId, "111920872708571") or string.find(animId, "130593238885843") or string.find(animId, "106871536134254") then
                                    return true
                                end
        
                                if string.find(animName, "potion") or string.find(trackName, "potion") or string.find(animName, "aim") or string.find(trackName, "aim") or string.find(animName, "idle") or string.find(trackName, "idle") or string.find(animName, "vault") or string.find(trackName, "vault") or string.find(animName, "window") or string.find(trackName, "window") or string.find(animName, "stun") or string.find(trackName, "stun") or string.find(animName, "break") or string.find(trackName, "break") or string.find(animName, "carry") or string.find(trackName, "carry") or string.find(animName, "hook") or string.find(trackName, "hook") or string.find(animName, "kick") or string.find(trackName, "kick") or string.find(animName, "damage") or string.find(trackName, "damage") or string.find(animName, "destroy") or string.find(trackName, "destroy") or string.find(animName, "pursuit") or string.find(trackName, "pursuit") or string.find(animName, "cloak") or string.find(trackName, "cloak") or string.find(animName, "mist") or string.find(trackName, "mist") or string.find(animName, "invisible") or string.find(trackName, "invisible") or string.find(animName, "equip") or string.find(trackName, "equip") or string.find(animName, "unequip") or string.find(trackName, "unequip") or string.find(animName, "draw") or string.find(trackName, "draw") or string.find(animName, "jump") or string.find(trackName, "jump") or string.find(animName, "fall") or string.find(trackName, "fall") or string.find(animName, "land") or string.find(trackName, "land") or string.find(animName, "move") or string.find(trackName, "move") then
                                    continue
                                end
        
                                if string.find(animId, "125224839697689") or string.find(animId, "117375515202922") or string.find(animId, "95954653860254") or string.find(animId, "120953382526020") or string.find(animId, "135029251763856") or string.find(animId, "92431623965655") or string.find(animId, "88454826739191") or string.find(animId, "135598697094633") or string.find(animId, "91021650846272") or string.find(animId, "75762828906633") or string.find(animId, "92125118598365") then
                                    continue
                                end
        
                                if string.find(animName, "lunge") or string.find(trackName, "lunge") or string.find(animName, "hold") or string.find(trackName, "hold") or string.find(animName, "swing") or string.find(trackName, "swing") or string.find(animName, "slash") or string.find(trackName, "slash") or string.find(animName, "attack") or string.find(trackName, "attack") or string.find(animName, "basic") or string.find(trackName, "basic") or string.find(animName, "charge") or string.find(trackName, "charge") or string.find(animName, "strike") or string.find(trackName, "strike") or string.find(animName, "hit") or string.find(trackName, "hit") or string.find(animName, "combo") or string.find(trackName, "combo") or string.find(animName, "m1") or string.find(trackName, "m1") or string.find(animName, "machete") or string.find(trackName, "machete") or string.find(animName, "axe") or string.find(trackName, "axe") or string.find(animName, "weapon") or string.find(trackName, "weapon") or string.find(animName, "stab") or string.find(trackName, "stab") or string.find(animName, "grab") or string.find(trackName, "grab") or string.find(animName, "throw") or string.find(trackName, "throw") then
                                    return true
                                end
                                
                                if not track.Looped and track.Speed > 0 then
                                    return true
                                end
                            end
                    end
                end
            end
            return false
        end
        
        local isParrying = false
        local function executeParry(enemyHrp, myHrp)
            if isParrying then return end
            isParrying = true
        
            task.spawn(function()
                if myHrp and enemyHrp then
                    local bg = Instance.new("BodyGyro")
                    bg.MaxTorque = Vector3.new(0, math.huge, 0)
                    bg.P = 10000
                    bg.D = 100
                    bg.CFrame = CFrame.new(myHrp.Position, Vector3.new(enemyHrp.Position.X, myHrp.Position.Y, enemyHrp.Position.Z))
                    bg.Parent = myHrp
        
                    local startTime = tick()
                    while tick() - startTime < 0.4 and isParrying do
                        if myHrp and myHrp.Parent and enemyHrp and enemyHrp.Parent then
                            bg.CFrame = CFrame.new(myHrp.Position, Vector3.new(enemyHrp.Position.X, myHrp.Position.Y, enemyHrp.Position.Z))
                        end
                        task.wait()
                    end
                    bg:Destroy()
                end
            end)
        
            task.spawn(function()
                local Library = getgenv().MaikaHub_Library
                local Toggles = Library and Library.Toggles or {}
        
                local isMobile = getgenv().MaikaHub_IsMobile
        
                if not isMobile then
                    local VIM = game:GetService("VirtualInputManager")
                    local cam = Workspace.CurrentCamera
                    local cx = cam and cam.ViewportSize.X / 2 or 0
                    local cy = cam and cam.ViewportSize.Y / 2 or 0
                    
                    pcall(function() VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0) end)
                    pcall(function() VIM:SendMouseButtonEvent(cx, cy, 1, true, game, 0) end)
                    task.wait(0.05)
                    pcall(function() VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0) end)
                    pcall(function() VIM:SendMouseButtonEvent(cx, cy, 1, false, game, 0) end)
                    
                    if mouse1click then task.spawn(function() pcall(mouse1click) end) end
                    if mouse2click then task.spawn(function() pcall(mouse2click) end) end
                else
                    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if pGui then
                        local survMob = pGui:FindFirstChild("Survivor-mob")
                        if survMob then
                            local controls = survMob:FindFirstChild("Controls")
                            if controls then
                                local btns = {controls:FindFirstChild("Gui-mob"), controls:FindFirstChild("Action")}
                                for _, btn in ipairs(btns) do
                                    if btn then
                                        if firesignal then
                                            pcall(function() firesignal(btn.MouseButton1Down) end)
                                            task.wait(0.05)
                                            pcall(function() firesignal(btn.MouseButton1Click) end)
                                            pcall(function() firesignal(btn.MouseButton1Up) end)
                                        elseif getconnections then
                                            pcall(function()
                                                for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do
                                                    task.spawn(function() pcall(conn.Function) end)
                                                end
                                                task.wait(0.05)
                                                for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                                                    task.spawn(function() pcall(conn.Function) end)
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                tool:Activate()
                            end
                        end
                    end
                end)
            end)
        
            task.wait(0.5)
            isParrying = false
        end
        
        local function setupProjectileDebounces()
            if not getgenv().MaikaHub_AutoParry_Remotes then
                getgenv().MaikaHub_AutoParry_Remotes = {}
            end
        
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if Remotes then
                local Killers = Remotes:FindFirstChild("Killers")
                if Killers then
                    local Cure = Killers:FindFirstChild("Cure")
                    if Cure then
                        local VisualizeFlask = Cure:FindFirstChild("VisualizeFlask")
                        if VisualizeFlask then
                            table.insert(getgenv().MaikaHub_AutoParry_Remotes, VisualizeFlask.OnClientEvent:Connect(function()
                                getgenv().ProjectileDebounce = os.clock()
                            end))
                        end
                    end
        
                    local Abysswalker = Killers:FindFirstChild("Abysswalker")
                    if Abysswalker then
                        local visualize = Abysswalker:FindFirstChild("visualize")
                        if visualize then
                            table.insert(getgenv().MaikaHub_AutoParry_Remotes, visualize.OnClientEvent:Connect(function()
                                getgenv().AbyssSlashActive = os.clock()
                            end))
                        end
                    end
                end
            end
        end
        
        local function setupAttackRemotes()
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not Remotes then return end
        
            local Attacks = Remotes:FindFirstChild("Attacks")
            if Attacks then
                LungeDetectRemote = Attacks:FindFirstChild("LungeDetect")
                AfterAttackRemote = Attacks:FindFirstChild("AfterAttack")
            end
        
            local Killers = Remotes:FindFirstChild("Killers")
            if Killers then
                SlowAttackRemote = Killers:FindFirstChild("SlowAttack")
            end
        
            if SlowAttackRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, SlowAttackRemote.OnClientEvent:Connect(function()
                    lungeActiveTime = os.clock()
                end))
            end
        
            if LungeDetectRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, LungeDetectRemote.OnClientEvent:Connect(function(...)
                    lungeDetectTime = os.clock()
                end))
            end
        
            if AfterAttackRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, AfterAttackRemote.OnClientEvent:Connect(function(result, ...)
                    lastAfterAttackTime = os.clock()
                    if result == "Parried" then
                        isParrying = false
                    end
                end))
            end
        end
        
        if getgenv().MaikaHub_AutoParry_Cleanup then
            pcall(getgenv().MaikaHub_AutoParry_Cleanup)
        end
        
        function AutoParry.Init(Toggles, Options)
            initCircle()
            setupProjectileDebounces()
            setupAttackRemotes()
        
            getgenv().MaikaHub_AutoParry_Cleanup = function()
                if parryCircle then parryCircle:Destroy() parryCircle = nil end
                if getgenv().MaikaHub_AutoParry_Conn then
                    getgenv().MaikaHub_AutoParry_Conn:Disconnect()
                    getgenv().MaikaHub_AutoParry_Conn = nil
                end
                if getgenv().MaikaHub_AutoParry_Loop then
                    task.cancel(getgenv().MaikaHub_AutoParry_Loop)
                    getgenv().MaikaHub_AutoParry_Loop = nil
                end
                if getgenv().MaikaHub_AutoParry_Remotes then
                    for _, conn in ipairs(getgenv().MaikaHub_AutoParry_Remotes) do
                        conn:Disconnect()
                    end
                    getgenv().MaikaHub_AutoParry_Remotes = nil
                end
            end
        
            getgenv().MaikaHub_AutoParry_Loop = task.spawn(function()
                while task.wait(0.05) do
                    local toggleVal = Toggles.ToggleAutoParry and Toggles.ToggleAutoParry.Value or false
                    if toggleVal == true and not (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer") then
                        local myChar = LocalPlayer.Character
                        if myChar and not (myChar:GetAttribute("Immobile") or myChar:GetAttribute("IsStunned") or myChar:GetAttribute("IsCarried") or myChar:GetAttribute("IsHooked") or myChar:GetAttribute("Carried")) then
                            local myHum = myChar:FindFirstChild("Humanoid")
                            if myHum and myHum.Health > 0 and myHum.WalkSpeed > 0 and not myHum.PlatformStand and not myHum.Sit then
                                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    local baseRadius = Options.AutoParryDistance and tonumber(Options.AutoParryDistance.Value) or 12
        
                                    for _, player in ipairs(Players:GetPlayers()) do
                                        if isEnemy(player) then
                                            local enemyChar = player.Character
                                            if enemyChar and enemyChar:GetAttribute("spearmode") ~= true then
                                                local enemyHrp = enemyChar:FindFirstChild("HumanoidRootPart")
                                                if enemyHrp then
                                                    local dist = (myHrp.Position - enemyHrp.Position).Magnitude
                                                    if dist <= baseRadius then
                                                        local shouldParry = false
                                                        local urgent = false
        
                                                        if isAttackingAnim(enemyChar) then
                                                            shouldParry = true
                                                        end
        
                                                        if not shouldParry and isActionAttacking(enemyChar) then
                                                            shouldParry = true
                                                        end
        
                                                        if os.clock() - lungeDetectTime < 0.3 then
                                                            shouldParry = true
                                                            urgent = true
                                                        end
        
                                                        if getgenv().AbyssSlashActive and os.clock() - getgenv().AbyssSlashActive < 0.5 then
                                                            shouldParry = true
                                                            urgent = true
                                                        end
        
                                                        if not shouldParry and os.clock() - lungeActiveTime < 2 then
                                                            if isLunging(enemyChar) then
                                                                shouldParry = true
                                                            end
                                                        end
        
                                                        if not shouldParry then
                                                            local enemyHum = enemyChar:FindFirstChild("Humanoid")
                                                            if enemyHum and enemyHum.WalkSpeed > 18 and dist <= baseRadius * 0.7 then
                                                                shouldParry = true
                                                            end
                                                        end
        
                                                        if shouldParry and not isFacing(enemyHrp, myHrp) then
                                                            shouldParry = false
                                                        end
                                                        
                                                        if shouldParry then
                                                            local delayMs = Options.AutoParryDelay and tonumber(Options.AutoParryDelay.Value) or 0
                                                            if urgent then
                                                                executeParry(enemyHrp, myHrp)
                                                            elseif delayMs > 0 then
                                                                task.delay(delayMs / 1000, function() executeParry(enemyHrp, myHrp) end)
                                                            else
                                                                executeParry(enemyHrp, myHrp)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        
            getgenv().MaikaHub_AutoParry_Conn = RunService.RenderStepped:Connect(function()
                local toggleVal = Toggles.ToggleAutoParry and Toggles.ToggleAutoParry.Value or false
                local circVal = Toggles.ToggleParryCircle and Toggles.ToggleParryCircle.Value or false
        
                if toggleVal and circVal and parryCircle then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local radius = Options.AutoParryDistance and tonumber(Options.AutoParryDistance.Value) or 12
        
                        local color = Options.ParryCircleColor and Options.ParryCircleColor.Value or Color3.fromRGB(255, 255, 255)
                        color = typeof(color) == "Color3" and color or Color3.fromRGB(255, 255, 255)
        
                        local fillTransparency = Options.ParryCircleColor and tonumber(Options.ParryCircleColor.Transparency) or 0
        
                        parryCircle.Radius = radius
                        parryCircle.InnerRadius = radius - 0.05
                        parryCircle.Color3 = color
                        parryCircle.Transparency = fillTransparency
                        parryCircle.Adornee = hrp
                        parryCircle.Visible = true
                    else
                        parryCircle.Visible = false
                    end
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if Remotes then
                local Killers = Remotes:FindFirstChild("Killers")
                if Killers then
                    local Cure = Killers:FindFirstChild("Cure")
                    if Cure then
                        local VisualizeFlask = Cure:FindFirstChild("VisualizeFlask")
                        if VisualizeFlask then
                            table.insert(getgenv().MaikaHub_AutoParry_Remotes, VisualizeFlask.OnClientEvent:Connect(function()
                                getgenv().ProjectileDebounce = os.clock()
                            end))
                        end
                    end
        
                    local Abysswalker = Killers:FindFirstChild("Abysswalker")
                    if Abysswalker then
                        local visualize = Abysswalker:FindFirstChild("visualize")
                        if visualize then
                            table.insert(getgenv().MaikaHub_AutoParry_Remotes, visualize.OnClientEvent:Connect(function()
                                getgenv().AbyssSlashActive = os.clock()
                            end))
                        end
                    end
                end
            end
        end
        
        local function setupAttackRemotes()
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not Remotes then return end
        
            local Attacks = Remotes:FindFirstChild("Attacks")
            if Attacks then
                LungeDetectRemote = Attacks:FindFirstChild("LungeDetect")
                AfterAttackRemote = Attacks:FindFirstChild("AfterAttack")
            end
        
            local Killers = Remotes:FindFirstChild("Killers")
            if Killers then
                SlowAttackRemote = Killers:FindFirstChild("SlowAttack")
            end
        
            if SlowAttackRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, SlowAttackRemote.OnClientEvent:Connect(function()
                    lungeActiveTime = os.clock()
                end))
            end
        
            if LungeDetectRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, LungeDetectRemote.OnClientEvent:Connect(function(...)
                    lungeDetectTime = os.clock()
                end))
            end
        
            if AfterAttackRemote then
                table.insert(getgenv().MaikaHub_AutoParry_Remotes, AfterAttackRemote.OnClientEvent:Connect(function(result, ...)
                    lastAfterAttackTime = os.clock()
                    if result == "Parried" then
                        isParrying = false
                    end
                end))
            end
        end
        
        if getgenv().MaikaHub_AutoParry_Cleanup then
            pcall(getgenv().MaikaHub_AutoParry_Cleanup)
        end
        
        function AutoParry.Init(Toggles, Options)
            initCircle()
            setupProjectileDebounces()
            setupAttackRemotes()
        
            getgenv().MaikaHub_AutoParry_Cleanup = function()
                if parryCircle then parryCircle:Destroy() parryCircle = nil end
                if getgenv().MaikaHub_AutoParry_Conn then
                    getgenv().MaikaHub_AutoParry_Conn:Disconnect()
                    getgenv().MaikaHub_AutoParry_Conn = nil
                end
                if getgenv().MaikaHub_AutoParry_Loop then
                    task.cancel(getgenv().MaikaHub_AutoParry_Loop)
                    getgenv().MaikaHub_AutoParry_Loop = nil
                end
                if getgenv().MaikaHub_AutoParry_Remotes then
                    for _, conn in ipairs(getgenv().MaikaHub_AutoParry_Remotes) do
                        conn:Disconnect()
                    end
                    getgenv().MaikaHub_AutoParry_Remotes = nil
                end
            end
        
            getgenv().MaikaHub_AutoParry_Loop = task.spawn(function()
                while task.wait(0.05) do
                    local toggleVal = Toggles.ToggleAutoParry and Toggles.ToggleAutoParry.Value or false
                    if toggleVal == true and not (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer") then
                        local myChar = LocalPlayer.Character
                        if myChar and not (myChar:GetAttribute("Immobile") or myChar:GetAttribute("IsStunned") or myChar:GetAttribute("IsCarried") or myChar:GetAttribute("IsHooked") or myChar:GetAttribute("Carried")) then
                            local myHum = myChar:FindFirstChild("Humanoid")
                            if myHum and myHum.Health > 0 and myHum.WalkSpeed > 0 and not myHum.PlatformStand and not myHum.Sit then
                                local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    local baseRadius = Options.AutoParryDistance and tonumber(Options.AutoParryDistance.Value) or 12
        
                                    for _, player in ipairs(Players:GetPlayers()) do
                                        if isEnemy(player) then
                                            local enemyChar = player.Character
                                            if enemyChar and enemyChar:GetAttribute("spearmode") ~= true then
                                                local enemyHrp = enemyChar:FindFirstChild("HumanoidRootPart")
                                                if enemyHrp then
                                                    local dist = (myHrp.Position - enemyHrp.Position).Magnitude
                                                    if dist <= baseRadius then
                                                        local shouldParry = false
                                                        local urgent = false
        
                                                        if isAttackingAnim(enemyChar) then
                                                            shouldParry = true
                                                        end
        
                                                        if not shouldParry and isActionAttacking(enemyChar) then
                                                            shouldParry = true
                                                        end
        
                                                        if os.clock() - lungeDetectTime < 0.3 then
                                                            shouldParry = true
                                                            urgent = true
                                                        end
        
                                                        if getgenv().AbyssSlashActive and os.clock() - getgenv().AbyssSlashActive < 0.5 then
                                                            shouldParry = true
                                                            urgent = true
                                                        end
        
                                                        if not shouldParry and os.clock() - lungeActiveTime < 2 then
                                                            if isLunging(enemyChar) then
                                                                shouldParry = true
                                                            end
                                                        end
        
                                                        if not shouldParry then
                                                            local enemyHum = enemyChar:FindFirstChild("Humanoid")
                                                            if enemyHum and enemyHum.WalkSpeed > 18 and dist <= baseRadius * 0.7 then
                                                                shouldParry = true
                                                            end
                                                        end
        
                                                        if shouldParry and not isFacing(enemyHrp, myHrp) then
                                                            shouldParry = false
                                                        end
                                                        
                                                        if shouldParry then
                                                            local delayMs = Options.AutoParryDelay and tonumber(Options.AutoParryDelay.Value) or 0
                                                            if urgent then
                                                                executeParry(enemyHrp, myHrp)
                                                            elseif delayMs > 0 then
                                                                task.delay(delayMs / 1000, function() executeParry(enemyHrp, myHrp) end)
                                                            else
                                                                executeParry(enemyHrp, myHrp)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        
            getgenv().MaikaHub_AutoParry_Conn = RunService.RenderStepped:Connect(function()
                local toggleVal = Toggles.ToggleAutoParry and Toggles.ToggleAutoParry.Value or false
                local circVal = Toggles.ToggleParryCircle and Toggles.ToggleParryCircle.Value or false
        
                if toggleVal and circVal and parryCircle then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local radius = Options.AutoParryDistance and tonumber(Options.AutoParryDistance.Value) or 12
        
                        local color = Options.ParryCircleColor and Options.ParryCircleColor.Value or Color3.fromRGB(255, 255, 255)
                        color = typeof(color) == "Color3" and color or Color3.fromRGB(255, 255, 255)
        
                        local fillTransparency = Options.ParryCircleColor and tonumber(Options.ParryCircleColor.Transparency) or 0
        
                        parryCircle.Radius = radius
                        parryCircle.InnerRadius = radius - 0.05
                        parryCircle.Color3 = color
                        parryCircle.Transparency = fillTransparency
                        parryCircle.Adornee = hrp
                        parryCircle.Visible = true
                    else
                        parryCircle.Visible = false
                    end
                else
                    if parryCircle then parryCircle.Visible = false end
                end
            end)
        end
        
        return AutoParry
        
    end)()
    if AutoParryLib then pcall(function() AutoParryLib.Init(Toggles, Options) end) end

    local GlobalFeature = (function()
        local Global = {}
        
        function Global.Init(Toggles, Options)
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local UserInputService = game:GetService("UserInputService")
            local VIM = game:GetService("VirtualInputManager")
        
            if getgenv().MaikaHub_Global_Cleanup then
                pcall(getgenv().MaikaHub_Global_Cleanup)
            end
        
            local isHoldingShift = false
            
            getgenv().MaikaHub_Global_Cleanup = function()
                if getgenv().MaikaHub_Global_Conn then
                    getgenv().MaikaHub_Global_Conn:Disconnect()
                    getgenv().MaikaHub_Global_Conn = nil
                end
                if getgenv().MaikaHub_SpeedConn then
                    getgenv().MaikaHub_SpeedConn:Disconnect()
                    getgenv().MaikaHub_SpeedConn = nil
                end
                if isHoldingShift then
                    pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end)
                    isHoldingShift = false
                end
            end
        
            getgenv().MaikaHub_Global_Conn = RunService.RenderStepped:Connect(function()
                if getgenv().MaikaHub_IsMobile then return end
                
                local sSprint, autoSprint = pcall(function() return Toggles.AutoSprint.Value end)
                
                if sSprint and autoSprint then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        if char.Humanoid.MoveDirection.Magnitude > 0.1 then
                            if not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game) end)
                                isHoldingShift = true
                            end
                        else
                            if isHoldingShift then
                                pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end)
                                isHoldingShift = false
                            end
                        end
                    end
                else
                    if isHoldingShift then
                        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end)
                        isHoldingShift = false
                    end
                end
            end)
            
            getgenv().MaikaHub_SpeedConn = RunService.Stepped:Connect(function()
                local sBoost, enableBoost = pcall(function() return Toggles.EnableSpeedBoost.Value end)
                if sBoost and enableBoost then
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChild("Humanoid")
                        if hum then
                            local boost = 0
                            pcall(function() boost = Options.SpeedBoostAmount.Value end)
                            
                            if not getgenv().MaikaHub_BaseWalkSpeed then
                                getgenv().MaikaHub_BaseWalkSpeed = hum.WalkSpeed
                            end
                            
                            if hum.WalkSpeed ~= getgenv().MaikaHub_BaseWalkSpeed + boost and hum.WalkSpeed > 0 then
                                if hum.WalkSpeed < 50 then
                                    getgenv().MaikaHub_BaseWalkSpeed = hum.WalkSpeed
                                end
                                hum.WalkSpeed = getgenv().MaikaHub_BaseWalkSpeed + boost
                            end
                        end
                    end
                else
                    if getgenv().MaikaHub_BaseWalkSpeed then
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChild("Humanoid")
                        if hum and hum.WalkSpeed > 0 and hum.WalkSpeed == getgenv().MaikaHub_BaseWalkSpeed + (Options.SpeedBoostAmount.Value or 0) then
                            hum.WalkSpeed = getgenv().MaikaHub_BaseWalkSpeed
                        end
                        getgenv().MaikaHub_BaseWalkSpeed = nil
                    end
                end
            end)
        end
        
        return Global
        
    end)()
    if GlobalFeature then pcall(function() GlobalFeature.Init(Toggles, Options) end) end

    local MobileActionFeature = (function()
        local MobileAction = {}
        
        function MobileAction.Init(Toggles, Options)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer
            local VIM = game:GetService("VirtualInputManager")
        
            if not getgenv().MaikaHub_IsMobile then return end
        
            if getgenv().MaikaHub_MobileAction_Cleanup then
                pcall(getgenv().MaikaHub_MobileAction_Cleanup)
            end
        
            local lastActionTick = 0
        
            local function FireButton(btn)
                if tick() - lastActionTick < 0.2 then return end
                lastActionTick = tick()
                
                if firesignal then
                    pcall(function() firesignal(btn.MouseButton1Down) end)
                    pcall(function() firesignal(btn.MouseButton1Click) end)
                elseif getconnections then
                    pcall(function()
                        for _, conn in ipairs(getconnections(btn.MouseButton1Down)) do
                            conn.Function()
                        end
                        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                            conn.Function()
                        end
                    end)
                end
            end
        
            getgenv().MaikaHub_MobileAction_Cleanup = function()
                if getgenv().MaikaHub_MobileAction_Conn then
                    getgenv().MaikaHub_MobileAction_Conn:Disconnect()
                    getgenv().MaikaHub_MobileAction_Conn = nil
                end
            end
        
            getgenv().MaikaHub_MobileAction_Conn = RunService.Heartbeat:Connect(function()
                -- Generator Skillchecks are now strictly handled by generator.lua to ensure Perfect Goal timing.
                -- We removed this instant-click logic to prevent it from prematurely tapping the screen.
            end)
        end
        
        return MobileAction
        
    end)()
    if MobileActionFeature then pcall(function() MobileActionFeature.Init(Toggles, Options) end) end

    local TOFLib = (function()
        local TOF = {}
        
        function TOF.Init(Toggles, Options)
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer
            local Camera = workspace.CurrentCamera
        
            if getgenv().MaikaHub_TOF_Cleanup then
                pcall(getgenv().MaikaHub_TOF_Cleanup)
            end
        
            local fovCircle = Drawing.new("Circle")
            fovCircle.Visible = false
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            fovCircle.Thickness = 1
            fovCircle.Transparency = 1
            fovCircle.Filled = false
        
            local CrosshairDrawings = {
                LineH = Drawing.new("Line"),
                LineV = Drawing.new("Line"),
                Circle = Drawing.new("Circle"),
                Dot = Drawing.new("Circle")
            }
        
            local function updateDrawingProperties(drawing, color, thickness)
                drawing.Color = color
                drawing.Thickness = thickness
                drawing.Transparency = 1
            end
        
            local function drawTracer(origin, targetPos)
                local tracer = Drawing.new("Line")
                tracer.Visible = true
                tracer.Color = Color3.fromRGB(255, 0, 0)
                tracer.Thickness = 2
                tracer.Transparency = 1
        
                local function update()
                    local startPos, startOnScreen = Camera:WorldToViewportPoint(origin)
                    local endPos, endOnScreen = Camera:WorldToViewportPoint(targetPos)
                    
                    if startOnScreen or endOnScreen then
                        tracer.From = Vector2.new(startPos.X, startPos.Y)
                        tracer.To = Vector2.new(endPos.X, endPos.Y)
                    else
                        tracer.Visible = false
                    end
                end
        
                update()
                
                task.spawn(function()
                    task.wait(0.1) -- Quick flash
                    for i = 1, 10 do
                        tracer.Transparency = 1 - (i/10)
                        update()
                        task.wait(0.04)
                    end
                    tracer:Remove()
                end)
            end
        
            local function getKiller()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Team and (player.Team.Name == "Killer" or player.Team.Name == "Killers") then
                        return player
                    end
                end
                return nil
            end
        
            local function getClosestKillerToMouse()
                local killer = getKiller()
                if not killer or not killer.Character then return nil end
        
                local targetPartName = Options.TOFTargetPart and Options.TOFTargetPart.Value or "HumanoidRootPart"
                local targetPart = killer.Character:FindFirstChild(targetPartName) or killer.Character:FindFirstChild("HumanoidRootPart")
                
                if not targetPart then return nil end
        
                local useFOV = Toggles.ToggleTOFFOV and Toggles.ToggleTOFFOV.Value or false
                if useFOV then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if not onScreen then return nil end
        
                    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
                    local dist = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
        
                    local maxDist = Options.TOF_FOV and Options.TOF_FOV.Value or 150
                    if dist <= maxDist then
                        return targetPart
                    end
                    return nil
                end
        
                return targetPart
            end
        
            local FireServer = Instance.new("RemoteEvent").FireServer
            
            if not getgenv().MaikaHub_TOF_Hooked then
                getgenv().MaikaHub_TOF_Hooked = true
                
                local namecall
                namecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
        
                    if typeof(self) == "Instance" and method == "FireServer" and self.Name == "Fire" then
                        if self.Parent and self.Parent.Name == "Twist of Fate" then
                            local silentAimEnabled = Toggles.ToggleTOFSilentAim and Toggles.ToggleTOFSilentAim.Value or false
                            if silentAimEnabled then
                                local args = {...}
                                local argCount = select("#", ...)
                                local targetPart = getClosestKillerToMouse()
                                if targetPart then
                                    local myChar = LocalPlayer.Character
                                    local origin = Camera.CFrame.Position
                                    
                                    local gun = args[1]
                                    if typeof(gun) ~= "Instance" then
                                        if myChar then
                                            gun = myChar:FindFirstChild("Twist of Fate") or myChar:FindFirstChildWhichIsA("Tool")
                                        end
                                    end
                                    
                                    if typeof(gun) == "Instance" then
                                        local muzzle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Primarypart") or gun:FindFirstChild("PrimaryPart")
                                        if muzzle then
                                            origin = muzzle.Position
                                        end
                                    elseif myChar and myChar:FindFirstChild("Head") then
                                        origin = myChar.Head.Position
                                    end
                                    
                                    local targetPos = targetPart.Position
                                    local direction = (targetPos - origin).Unit
                                    
                                    -- Automatically determine if the server expects a Direction or a Position
                                    local foundVector = false
                                    for i, v in ipairs(args) do
                                        if typeof(v) == "Vector3" then
                                            if v.Magnitude < 5 then
                                                args[i] = direction
                                            else
                                                args[i] = targetPos
                                            end
                                            foundVector = true
                                        end
                                    end
                                    
                                    -- Fallback for CFrame based games
                                    if not foundVector then
                                        for i, v in ipairs(args) do
                                            if typeof(v) == "CFrame" then
                                                args[i] = CFrame.new(origin, targetPos)
                                                break
                                            end
                                        end
                                    end
                                    
                                    drawTracer(origin, targetPos)
                                    
                                    if setnamecallmethod then setnamecallmethod("FireServer") end
                                    return namecall(self, unpack(args, 1, argCount))
                                end
                            end
                        end
                    end
        
                    return namecall(self, ...)
                end)
            end
        
        
            local connection = RunService.RenderStepped:Connect(function()
                local showFov = Toggles.ToggleTOFFOV and Toggles.ToggleTOFFOV.Value or false
                if showFov then
                    local fovRadius = Options.TOF_FOV and Options.TOF_FOV.Value or 150
                    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
                    fovCircle.Position = mouseLocation
                    fovCircle.Radius = fovRadius
                    fovCircle.Visible = true
                else
                    fovCircle.Visible = false
                end
        
                local showCrosshair = Toggles.ToggleCrosshair and Toggles.ToggleCrosshair.Value or false
                if not showCrosshair then
                    for _, d in pairs(CrosshairDrawings) do d.Visible = false end
                else
                    local shape = Options.CrosshairShape and Options.CrosshairShape.Value or "Cross"
                    local color = Options.CrosshairColor and Options.CrosshairColor.Value or Color3.new(1, 1, 1)
                    local size = Options.CrosshairSize and Options.CrosshairSize.Value or 10
                    local thickness = Options.CrosshairThickness and Options.CrosshairThickness.Value or 1
        
                    local GuiService = game:GetService("GuiService")
                    local resolution = GuiService:GetScreenResolution()
                    local center = Vector2.new(resolution.X / 2, resolution.Y / 2)
        
                    for _, d in pairs(CrosshairDrawings) do
                        d.Visible = false
                        updateDrawingProperties(d, color, thickness)
                    end
        
                    if shape == "Cross" then
                        CrosshairDrawings.LineH.Visible = true
                        CrosshairDrawings.LineH.From = Vector2.new(center.X - size, center.Y)
                        CrosshairDrawings.LineH.To = Vector2.new(center.X + size, center.Y)
        
                        CrosshairDrawings.LineV.Visible = true
                        CrosshairDrawings.LineV.From = Vector2.new(center.X, center.Y - size)
                        CrosshairDrawings.LineV.To = Vector2.new(center.X, center.Y + size)
                    elseif shape == "Circle" then
                        CrosshairDrawings.Circle.Visible = true
                        CrosshairDrawings.Circle.Radius = size
                        CrosshairDrawings.Circle.Position = center
                        CrosshairDrawings.Circle.Filled = false
                    elseif shape == "Dot" then
                        CrosshairDrawings.Dot.Visible = true
                        CrosshairDrawings.Dot.Radius = size / 2
                        CrosshairDrawings.Dot.Position = center
                        CrosshairDrawings.Dot.Filled = true
                        CrosshairDrawings.Dot.Thickness = 0
                    end
                end
            end)
        
            getgenv().MaikaHub_TOF_Cleanup = function()
                if connection then connection:Disconnect() end
                if fovCircle then fovCircle:Remove() end
                for _, d in pairs(CrosshairDrawings) do
                    d:Remove()
                end
            end
        end
        
        return TOF
        
    end)()
    if TOFLib then pcall(function() TOFLib.Init(Toggles, Options) end) end



    local MiscGroup = Tabs.Misc:AddLeftGroupbox("Player", "user")
    MiscGroup:AddButton({
        Text = 'Rejoin Server',
        Func = function()
            local ts = game:GetService("TeleportService")
            local p = game:GetService("Players").LocalPlayer
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
        end,
        DoubleClick = true,
        Tooltip = 'Double click to Rejoin the same server'
    })

    MiscGroup:AddButton({
        Text = 'Respawn',
        Func = function()
            local p = game:GetService("Players").LocalPlayer
            local hum = p.Character and p.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
            end
        end,
        DoubleClick = true,
        Tooltip = 'Double click to Respawn (Suicide)'
    })

    local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddButton("Unload UI", function()
        if getgenv().MaikaHub_ESP_Cleanup then pcall(getgenv().MaikaHub_ESP_Cleanup) end
        if getgenv().MaikaHub_AutoParry_Cleanup then pcall(getgenv().MaikaHub_AutoParry_Cleanup) end
        if getgenv().MaikaHub_Global_Cleanup then pcall(getgenv().MaikaHub_Global_Cleanup) end
        if getgenv().MaikaHub_Generator_Cleanup then pcall(getgenv().MaikaHub_Generator_Cleanup) end
        
        if getgenv().MaikaHub_Noclip then getgenv().MaikaHub_Noclip:Disconnect() getgenv().MaikaHub_Noclip = nil end
        if getgenv().MaikaHub_Idled_Conn then getgenv().MaikaHub_Idled_Conn:Disconnect() getgenv().MaikaHub_Idled_Conn = nil end
        if getgenv().MaikaHub_StatConns then
            for _, conn in ipairs(getgenv().MaikaHub_StatConns) do conn:Disconnect() end
            getgenv().MaikaHub_StatConns = nil
        end
        
        Library:Unload()
    end)
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    ThemeManager:SetFolder("MaikaHub")
    SaveManager:SetFolder("MaikaHub")
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:AddThemeOptions(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end
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
