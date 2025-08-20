local M = {}

function M.start(modules)
    local config = modules.config
    local state = modules.state

    -- Start new instance
    state.aiLoaded = true
    state.aiRunning = true
    state.gameConnected = false

    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ChessLocalUI = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("ChessLocalUI")

    -- Use the chess engine module loaded in main.lua
    local ChessEngine = modules.chess_engine

    local function getGameType(clockText)
        return config.CLOCK_NAME_MAPPING[clockText] or "unknown"
    end

    local function getSmartWait(clockText, moveCount)
        local configRange = config.CLOCK_WAIT_MAPPING[clockText]
        if not configRange then 
            configRange = config.CLOCK_WAIT_MAPPING["bullet"] -- temporary fix
        end
    
        local baseWait = math.random(math.random(0, configRange.min), math.random(configRange.min, configRange.max))
        local gameType = getGameType(clockText)
    
        if moveCount < math.random(7, 12) then
            return baseWait * 0.5 -- opening
        elseif moveCount < math.random(12, 40) then
            return (gameType ~= "bullet") and baseWait * 4.0 or baseWait * 2.0
        else
            return baseWait * 1.2
        end
    end

    local function getFunction(funcName, moduleName)
        local retryCount = 0
        local func = nil
    
        while retryCount < 10 and not func do
            for _, f in ipairs(getgc(true)) do
                if typeof(f) == "function" and debug.getinfo(f).name == funcName then
                    if string.sub(debug.getinfo(f).source, -#moduleName) == moduleName then
                        func = f
                        break
                    end
                end
            end
            if not func then
                retryCount = retryCount + 1
                task.wait(0.1)
            end
        end
    
        if not func then
            warn("Failed to find " .. funcName .. " after 10 retries.")
        end
        return func
    end

    local function initializeFunctions()
        local PlayMove = getFunction("PlayMove", "ChessLocalUI")
        return PlayMove
    end

    -- Main part
    local function startGameHandler(board)
        local PlayMove = initializeFunctions()
        local boardLoaded = false
        local Fen = nil
        local move = nil
        local gameEnded = false
        local nbMoves = 0
        local randWaitFromGameType = 0
        local clockText = nil

        local isLocalWhite = localPlayer.Name == board.WhitePlayer.Value
        local clockLabel = board:WaitForChild("Clock")
            :WaitForChild("MainBody")
            :WaitForChild("SurfaceGui")
            :WaitForChild(isLocalWhite and "WhiteTime" or "BlackTime")

        -- wait for clock to initialize
        task.wait(0.1)
        clockText = clockLabel.ContentText
        randWaitFromGameType = getSmartWait(clockText, nbMoves)
        boardLoaded = true

        -- speaks for itself
        local function isLocalPlayersTurn()
            local isLocalWhite = localPlayer.Name == board.WhitePlayer.Value
            return isLocalWhite == board.WhiteToPlay.Value
        end

    -- Check for playable moves until game ends
        local function gameLoop()
            task.wait(3) -- game initialisation time

            while not gameEnded do
                if boardLoaded and board then
                    Fen = board.FEN.Value

                    if isLocalPlayersTurn() and Fen and state.aiRunning then 
                        -- Use our advanced chess engine instead of Sunfish
                        move = ChessEngine.getBestMove(Fen, 5000)
                        if move then
                            task.wait(randWaitFromGameType)
                            PlayMove(move)

                            nbMoves += 1
                            randWaitFromGameType = getSmartWait(clockText, nbMoves)
                        end
                    end
                end
                task.wait(0.2)
            end
        end

        state.aiThread = coroutine.create(gameLoop)
        coroutine.resume(state.aiThread)

        ReplicatedStorage.Chess:WaitForChild("EndGameEvent").OnClientEvent:Once(function(board)
                gameEnded = true
                state.gameConnected = false
                print("[LOG]: Game ended.")
        end)
    end

    -- Listener to get the board object
    if not state.gameConnected then
        ReplicatedStorage.Chess:WaitForChild("StartGameEvent").OnClientEvent:Connect(function(board)
            if board then
                if localPlayer.Name == board.WhitePlayer.Value or localPlayer.Name == board.BlackPlayer.Value then
                    print("[LOG]: New game started.")
                    startGameHandler(board)
                end
            else
                warn("Invalid board, try restarting a chess game.")
            end
        end)
        state.gameConnected = true
    else
        warn("Game instance already existing, restart chess club")
    end
end

return M
