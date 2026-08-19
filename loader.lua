local PlaceId = game.PlaceId

local Scripts = {
    [93978595733734] = "https://raw.githubusercontent.com/MaikaVerse/MaikaHub/refs/heads/main/VD.lua"
}

print("[Maika Hub] Checking environment...")

if Scripts[PlaceId] then
    print("[Maika Hub] Game supported! Initializing...")
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(Scripts[PlaceId]))()
    end)
    
    if not success then
        warn("[Maika Hub] Execution failed: " .. tostring(err))
    end
else
    warn("[Maika Hub] Unsupported Game! PlaceId: " .. tostring(PlaceId))
end
