function [row,col] = bot_RandomTile(gameMap)
    % Guesses a random tile on the map
    % Will likely choose an uncovered tile
    [arrHeight, arrWidth] = size(gameMap);
    row = randi(arrHeight,1);
    col = randi(arrWidth,1);
end