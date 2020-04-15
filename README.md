# MinesweeperAIBattle
This is a AI battle for the minesweeper game among the S.P.A.R.C Lab, York University

Create a bot that would make a prediction where the mines will be

All valid guesses unlocks an area

If bot unlocked a mine that bot gets another turn

If bot unlocks already unlocked area, the bot wasted the turn

Both bots get to see the game board and all previously unlocked areas

AI should return `[rowGuess, colGuess]`


# Game Information
* Empty Area = 0
* Detected mines = 9
* Hidden/Locked area = 10
* Other numbers works like minesweeper

# AI Included
We have included simple AIs to test your program against

## Simple AI
Name | Description
--- | ---
bot_HumanGuess | Allows Human input for guesses
bot_RandomTile | Choosing a random tile as guess
bot_RandomValidGuess | Chooses only valid guesses (won't choose an empty or existing mine)

## KJ's Bots
These bots have different strategies increasing in difficulty to beat.

Name | Description
--- | ---
bot_KJ_v0_02_Invalidator | Targets tiles it 100% knows to be mines  and will choose invalid guesses to pass to next turn
bot_KJ_v0_03_Discoverer | Targets tiles it knows to be mines and will choose any guess to pass to next turn
bot_KJ_v0_04_Discoverer | 
bot_KJ_v0_05_Probabalator | This bot will click on tiles it knows to be mines and will determine probabilities for the best mine and choose that next
bot_KJ_v0_06_Probabalator |
bot_KJ_v0_07_Sniper | Targets known mines and will determine probabilities for the best mine and choose that next. If the highest probability mine is too low, then choose a mine that won't give too much information
bot_KJ_v0_071_Sniper |
bot_KJ_v0_08_Zilcher |

## Chitiiran's Bots
These bots builds on skill-set of previous bot.

Name | Description
--- | ---
bot_Chitii_01 | randomly picks the first tile to start the game
bot_Chitii_02 | random guesses subsequent tiles to provide baseline to compare future bot's performance
bot_Chitii_03 | Calculates the probability of mines for tiles immediately (Horizontal) beside uncovered tiles
bot_Chitii_04 | Calculates the probability of mines for tiles (Vertical & diagonal) beside uncovered tiles
bot_Chitii_05 | Mines probability map computed for different clusters and combined
bot_Chitii_06 | Chooses tile closer to more uncovered tiles when similar probabilities exist
