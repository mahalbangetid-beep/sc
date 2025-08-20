local modules = {}

if _G.__CHESS_AI_LOADED__FULL then
    warn("Script already loaded.")
    return
end
_G.__CHESS_AI_LOADED__FULL = true

-- Load modules with error handling - simplified approach
local function loadModule(fallbackName)
    -- Try to load from GitHub first
    local success, result = pcall(function()
        if not game or not game.HttpGet then
            error("HttpGet not available")
        end
        
        local url = "https://raw.githubusercontent.com/mahalbangetid-beep/sc/refs/heads/main/" .. fallbackName .. ".lua"
        local httpContent = game:HttpGet(url, true) -- true for async might help
        
        if not httpContent or httpContent == "" then
            error("Empty content from GitHub for " .. fallbackName)
        end
        
        local loadedFunction = loadstring(httpContent)
        if not loadedFunction then
            error("Failed to compile content from GitHub for " .. fallbackName)
        end
        
        return loadedFunction()
    end)
    
    if success and result then
        return result
    else
        warn("Failed to load " .. fallbackName .. " from GitHub, using local fallback: " .. tostring(result))
        return require(script.Parent[fallbackName])
    end
end

-- Load all modules with fallback
modules.config = loadModule("config")
modules.state = loadModule("state") 
modules.ai = loadModule("ai")
modules.gui = loadModule("gui")
modules.chess_engine = loadModule("chess_engine")

modules.gui.init(modules)
