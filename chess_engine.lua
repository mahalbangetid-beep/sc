local M = {}

-- Piece values for evaluation
M.PIECE_VALUES = {
    ['P'] = 100,   -- Pawn
    ['N'] = 320,   -- Knight
    ['B'] = 330,   -- Bishop
    ['R'] = 500,   -- Rook
    ['Q'] = 900,   -- Queen
    ['K'] = 20000, -- King
}

-- Piece-square tables for positional evaluation
M.PIECE_SQUARE_TABLES = {
    -- Pawn (middle game)
    P = {
        {0,   0,   0,   0,   0,   0,   0,   0},
        {50,  50,  50,  50,  50,  50,  50,  50},
        {10,  10,  20,  30,  30,  20,  10,  10},
        {5,   5,  10,  25,  25,  10,   5,   5},
        {0,   0,   0,  20,  20,   0,   0,   0},
        {5,  -5, -10,   0,   0, -10,  -5,   5},
        {5,  10,  10, -20, -20,  10,  10,   5},
        {0,   0,   0,   0,   0,   0,   0,   0}
    },
    
    -- Knight
    N = {
        {-50, -40, -30, -30, -30, -30, -40, -50},
        {-40, -20,   0,   0,   0,   0, -20, -40},
        {-30,   0,  10,  15,  15,  10,   0, -30},
        {-30,   5,  15,  20,  20,  15,   5, -30},
        {-30,   0,  15,  20,  20,  15,   0, -30},
        {-30,   5,  10,  15,  15,  10,   5, -30},
        {-40, -20,   0,   5,   5,   0, -20, -40},
        {-50, -40, -30, -30, -30, -30, -40, -50}
    },
    
    -- Bishop
    B = {
        {-20, -10, -10, -10, -10, -10, -10, -20},
        {-10,   0,   0,   0,   0,   0,   0, -10},
        {-10,   0,  10,  10,  10,  10,   0, -10},
        {-10,   5,  10,  10,  10,  10,   5, -10},
        {-10,   0,  10,  10,  10,  10,   0, -10},
        {-10,   5,   5,  10,  10,   5,   5, -10},
        {-10,   0,   5,   0,   0,   5,   0, -10},
        {-20, -10, -10, -10, -10, -10, -10, -20}
    },
    
    -- Rook
    R = {
        {0,   0,   0,   0,   0,   0,   0,   0},
        {5,  10,  10,  10,  10,  10,  10,   5},
        {-5,   0,   0,   0,   0,   0,   0,  -5},
        {-5,   0,   0,   0,   0,   0,   0,  -5},
        {-5,   0,   0,   0,   0,   0,   0,  -5},
        {-5,   0,   0,   0,   0,   0,   0,  -5},
        {-5,   0,   0,   0,   0,   0,   0,  -5},
        {0,   0,   0,   5,   5,   0,   0,   0}
    },
    
    -- Queen
    Q = {
        {-20, -10, -10,  -5,  -5, -10, -10, -20},
        {-10,   0,   0,   0,   0,   0,   0, -10},
        {-10,   0,  10,  10,  10,  10,   0, -10},
        {-5,   0,  10,  10,  10,  10,   0,  -5},
        {0,   0,  10,  10,  10,  10,   0,  -5},
        {-10,  10,  10,  10,  10,  10,   0, -10},
        {-10,   0,  10,   0,   0,   0,   0, -10},
        {-20, -10, -10,  -5,  -5, -10, -10, -20}
    },
    
    -- King (middle game)
    K = {
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-30, -40, -40, -50, -50, -40, -40, -30},
        {-20, -30, -30, -40, -40, -30, -30, -20},
        {-10, -20, -20, -20, -20, -20, -20, -10},
        {20,  20,   0,   0,   0,   0,  20,  20},
        {20,  30,  10,   0,   0,  10,  30,  20}
    }
}

-- Opening book moves (simplified)
M.OPENING_BOOK = {
    ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"] = {"e2e4", "d2d4", "g1f3"},
    ["rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"] = {"e7e5", "c7c5", "e7e6"},
    ["rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2"] = {"g1f3", "f1c4", "f2f4"},
}

-- Transposition table for caching positions
M.transpositionTable = {}

function M.parseFEN(fen)
    local board = {}
    local parts = {}
    
    for part in fen:gmatch("%S+") do
        table.insert(parts, part)
    end
    
    if #parts < 4 then return nil end
    
    local boardStr = parts[1]
    local turn = parts[2]
    local castling = parts[3]
    local enPassant = parts[4]
    
    -- Parse board
    local rank = 8
    local file = 1
    
    for char in boardStr:gmatch(".") do
        if char == '/' then
            rank = rank - 1
            file = 1
        elseif tonumber(char) then
            for i = 1, tonumber(char) do
                board[(rank-1)*8 + file] = " "
                file = file + 1
            end
        else
            board[(rank-1)*8 + file] = char
            file = file + 1
        end
    end
    
    return {
        board = board,
        turn = turn,
        castling = castling,
        enPassant = enPassant,
        halfMove = tonumber(parts[5]) or 0,
        fullMove = tonumber(parts[6]) or 1
    }
end

function M.generateFEN(position)
    local fen = ""
    local emptyCount = 0
    
    for rank = 8, 1, -1 do
        for file = 1, 8 do
            local idx = (rank-1)*8 + file
            local piece = position.board[idx]
            
            if piece == " " then
                emptyCount = emptyCount + 1
            else
                if emptyCount > 0 then
                    fen = fen .. emptyCount
                    emptyCount = 0
                end
                fen = fen .. piece
            end
        end
        
        if emptyCount > 0 then
            fen = fen .. emptyCount
            emptyCount = 0
        end
        
        if rank > 1 then
            fen = fen .. "/"
        end
    end
    
    fen = fen .. " " .. position.turn
    fen = fen .. " " .. position.castling
    fen = fen .. " " .. position.enPassant
    fen = fen .. " " .. position.halfMove
    fen = fen .. " " .. position.fullMove
    
    return fen
end

function M.evaluatePosition(position)
    local score = 0
    local pieceCount = 0
    
    -- Material evaluation
    for idx = 1, 64 do
        local piece = position.board[idx]
        if piece ~= " " then
            pieceCount = pieceCount + 1
            local pieceType = piece:upper()
            local value = M.PIECE_VALUES[pieceType] or 0
            
            -- Add positional value
            local rank = math.floor((idx-1)/8) + 1
            local file = ((idx-1) % 8) + 1
            
            if piece == pieceType then -- White piece
                value = value + (M.PIECE_SQUARE_TABLES[pieceType][rank][file] or 0)
            else -- Black piece (flip the board)
                local flippedRank = 9 - rank
                value = value + (M.PIECE_SQUARE_TABLES[pieceType][flippedRank][file] or 0)
            end
            
            if piece == pieceType then
                score = score + value
            else
                score = score - value
            end
        end
    end
    
    -- Endgame scaling (simplified)
    local endgameFactor = math.max(0, (32 - pieceCount) / 32)
    
    -- King safety in endgame
    if pieceCount < 10 then
        -- Encourage king to center in endgame
        for idx = 1, 64 do
            local piece = position.board[idx]
            if piece == "K" then
                local rank = math.floor((idx-1)/8) + 1
                local file = ((idx-1) % 8) + 1
                local centerDist = math.abs(rank - 4.5) + math.abs(file - 4.5)
                score = score + (20 - centerDist * 4) * endgameFactor
            elseif piece == "k" then
                local rank = math.floor((idx-1)/8) + 1
                local file = ((idx-1) % 8) + 1
                local centerDist = math.abs(rank - 4.5) + math.abs(file - 4.5)
                score = score - (20 - centerDist * 4) * endgameFactor
            end
        end
    end
    
    return score
end

function M.alphaBeta(position, depth, alpha, beta, maximizingPlayer)
    if depth == 0 then
        return M.evaluatePosition(position)
    end
    
    -- Generate pseudo-legal moves (simplified)
    local moves = M.generateMoves(position)
    
    if #moves == 0 then
        -- Checkmate or stalemate
        return maximizingPlayer and -99999 or 99999
    end
    
    if maximizingPlayer then
        local maxEval = -math.huge
        for _, move in ipairs(moves) do
            local newPosition = M.makeMove(position, move)
            local eval = M.alphaBeta(newPosition, depth - 1, alpha, beta, false)
            maxEval = math.max(maxEval, eval)
            alpha = math.max(alpha, eval)
            if beta <= alpha then
                break -- Beta cutoff
            end
        end
        return maxEval
    else
        local minEval = math.huge
        for _, move in ipairs(moves) do
            local newPosition = M.makeMove(position, move)
            local eval = M.alphaBeta(newPosition, depth - 1, alpha, beta, true)
            minEval = math.min(minEval, eval)
            beta = math.min(beta, eval)
            if beta <= alpha then
                break -- Alpha cutoff
            end
        end
        return minEval
    end
end

function M.getBestMove(fen, maxTime)
    local position = M.parseFEN(fen)
    if not position then return nil end
    
    -- Check opening book
    local bookMoves = M.OPENING_BOOK[fen]
    if bookMoves then
        return bookMoves[math.random(#bookMoves)]
    end
    
    local bestMove = nil
    local bestValue = -math.huge
    local moves = M.generateMoves(position)
    
    -- Iterative deepening with time management
    local startTime = os.clock()
    local maxDepth = 4 -- Start with reasonable depth
    
    for depth = 1, maxDepth do
        if os.clock() - startTime > maxTime / 1000 then
            break -- Time's up
        end
        
        local currentBestMove = nil
        local currentBestValue = -math.huge
        
        for _, move in ipairs(moves) do
            local newPosition = M.makeMove(position, move)
            local value = -M.alphaBeta(newPosition, depth - 1, -math.huge, math.huge, false)
            
            if value > currentBestValue then
                currentBestValue = value
                currentBestMove = move
            end
        end
        
        if currentBestMove then
            bestMove = currentBestMove
            bestValue = currentBestValue
        end
    end
    
    return bestMove
end

-- Simplified move generation (placeholder - real implementation would be more complex)
function M.generateMoves(position)
    local moves = {}
    
    -- This is a simplified move generator
    -- In a real implementation, this would generate all legal moves
    -- For now, return some basic moves
    for idx = 1, 64 do
        local piece = position.board[idx]
        if piece ~= " " and ((position.turn == "w" and piece:upper() == piece) or 
                             (position.turn == "b" and piece:lower() == piece)) then
            -- Generate some basic moves (simplified)
            local rank = math.floor((idx-1)/8) + 1
            local file = ((idx-1) % 8) + 1
            
            if piece:upper() == "P" then
                -- Pawn moves
                local direction = (piece == "P") and 1 or -1
                local newRank = rank + direction
                
                if newRank >= 1 and newRank <= 8 then
                    -- Forward move
                    local newIdx = (newRank-1)*8 + file
                    if position.board[newIdx] == " " then
                        table.insert(moves, string.char(96+file) .. rank .. string.char(96+file) .. newRank)
                    end
                end
            else
                -- Other pieces (simplified)
                local directions = {}
                if piece:upper() == "N" then
                    directions = {{-2,-1}, {-2,1}, {-1,-2}, {-1,2}, {1,-2}, {1,2}, {2,-1}, {2,1}}
                elseif piece:upper() == "K" then
                    directions = {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}}
                end
                
                for _, dir in ipairs(directions) do
                    local newRank = rank + dir[1]
                    local newFile = file + dir[2]
                    
                    if newRank >= 1 and newRank <= 8 and newFile >= 1 and newFile <= 8 then
                        local newIdx = (newRank-1)*8 + newFile
                        local target = position.board[newIdx]
                        
                        if target == " " or ((position.turn == "w" and target:lower() == target) or 
                                           (position.turn == "b" and target:upper() == target)) then
                            table.insert(moves, string.char(96+file) .. rank .. string.char(96+newFile) .. newRank)
                        end
                    end
                end
            end
        end
    end
    
    return moves
end

function M.makeMove(position, move)
    -- Simplified move making
    -- In real implementation, this would properly update the board state
    local newPosition = {
        board = {},
        turn = position.turn == "w" and "b" or "w",
        castling = position.castling,
        enPassant = position.enPassant,
        halfMove = position.halfMove + 1,
        fullMove = position.fullMove
    }
    
    -- Copy board
    for i = 1, 64 do
        newPosition.board[i] = position.board[i]
    }
    
    -- Apply move (simplified)
    if move and #move >= 4 then
        local fromFile = string.byte(move:sub(1, 1)) - 96
        local fromRank = tonumber(move:sub(2, 2))
        local toFile = string.byte(move:sub(3, 3)) - 96
        local toRank = tonumber(move:sub(4, 4))
        
        local fromIdx = (fromRank-1)*8 + fromFile
        local toIdx = (toRank-1)*8 + toFile
        
        newPosition.board[toIdx] = newPosition.board[fromIdx]
        newPosition.board[fromIdx] = " "
    end
    
    return newPosition
end

return M
