-- Test script for the chess engine
local ChessEngine = loadstring(readfile("chess_engine.lua"))()

print("Testing Chess Engine...")

-- Test FEN parsing
local testFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
local position = ChessEngine.parseFEN(testFEN)

if position then
    print("✓ FEN parsing successful")
    print("Turn: " .. position.turn)
    print("Castling: " .. position.castling)
else
    print("✗ FEN parsing failed")
end

-- Test position evaluation
local score = ChessEngine.evaluatePosition(position)
print("Position evaluation score: " .. score)

-- Test move generation
local moves = ChessEngine.generateMoves(position)
print("Generated " .. #moves .. " moves:")
for i, move in ipairs(moves) do
    if i <= 5 then -- Show first 5 moves
        print("  " .. move)
    end
end
if #moves > 5 then
    print("  ... and " .. (#moves - 5) .. " more")
end

-- Test best move calculation
local bestMove = ChessEngine.getBestMove(testFEN, 1000)
print("Best move: " .. (bestMove or "none found"))

-- Test FEN generation
local generatedFEN = ChessEngine.generateFEN(position)
print("Generated FEN: " .. generatedFEN)

print("Test completed!")
