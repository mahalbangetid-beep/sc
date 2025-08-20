# Smarter Chess Bot for Roblox

This is an enhanced chess AI bot for Roblox that replaces the simple Sunfish engine with a much more intelligent chess engine.

## Features

### Advanced Chess Engine
- **Alpha-Beta Pruning**: Efficient search algorithm that eliminates unnecessary branches
- **Iterative Deepening**: Gradually increases search depth with time management
- **Positional Evaluation**: Uses piece-square tables for better positional understanding
- **Material Counting**: Proper piece values (Pawn=100, Knight=320, Bishop=330, Rook=500, Queen=900, King=20000)
- **Opening Book**: Plays strong opening moves from established chess theory
- **Endgame Awareness**: Better king positioning in endgame situations

### Technical Improvements
- **Better Search Algorithm**: Alpha-beta pruning with iterative deepening
- **Enhanced Evaluation**: Piece activity, king safety, and positional factors
- **Time Management**: Adjusts search depth based on available time
- **Transposition Table**: Caches positions for faster evaluation (future enhancement)

## How It Works

1. **FEN Parsing**: Parses chess positions from FEN notation
2. **Move Generation**: Generates legal moves for the current position
3. **Position Evaluation**: Evaluates positions using material and positional factors
4. **Search Algorithm**: Uses alpha-beta pruning to find the best move
5. **Time Management**: Uses iterative deepening to make the most of available time

## Installation

1. Replace the existing `ai.lua` file with the enhanced version
2. Add the `chess_engine.lua` file to your project
3. The bot will automatically use the smarter engine when enabled

## File Structure

- `main.lua` - Main entry point (unchanged)
- `ai.lua` - Modified to use the new chess engine
- `chess_engine.lua` - New advanced chess AI implementation
- `config.lua` - Configuration settings (unchanged)
- `state.lua` - State management (unchanged)
- `gui.lua` - User interface (unchanged)

## Performance

The new chess engine provides:
- **Better Opening Play**: Uses established opening theory
- **Stronger Middlegame**: Better positional understanding and tactics
- **Improved Endgame**: Better king positioning and endgame technique
- **Faster Response**: Efficient algorithms with time management

## Comparison with Sunfish

| Feature | Sunfish | New Engine |
|---------|---------|------------|
| Search Algorithm | Simple | Alpha-Beta Pruning |
| Position Evaluation | Basic | Advanced (material + positional) |
| Opening Knowledge | None | Opening Book |
| Endgame Play | Weak | Improved |
| Time Management | Basic | Iterative Deepening |

## Usage

The bot works exactly like before - simply enable the AI toggle in the game UI. The improved engine will automatically provide smarter moves.

## Credits

Enhanced by AI assistant to provide significantly improved chess gameplay over the original Sunfish implementation.
