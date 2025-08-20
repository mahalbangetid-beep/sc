local modules = {}

if _G.__CHESS_AI_LOADED__FULL then
    warn("Script already loaded.")
    return
end
_G.__CHESS_AI_LOADED__FULL = true

modules.config = loadstring(game:HttpGet("https://raw.githubusercontent.com/mahalbangetid-beep/cb/refs/heads/main/config.lua"))()
modules.state = loadstring(game:HttpGet("https://raw.githubusercontent.com/mahalbangetid-beep/cb/refs/heads/main/state.lua"))()
modules.ai = loadstring(game:HttpGet("https://raw.githubusercontent.com/mahalbangetid-beep/cb/refs/heads/main/ai.lua"))()
modules.gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/mahalbangetid-beep/cb/refs/heads/main/gui.lua"))()
modules.chess_engine = loadstring(game:HttpGet("https://raw.githubusercontent.com/mahalbangetid-beep/cb/refs/heads/main/chess_engine.lua"))()

modules.gui.init(modules)
