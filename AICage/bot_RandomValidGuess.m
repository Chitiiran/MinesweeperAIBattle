function [rowGuess,colGuess] = bot_HumanGuess(gameMap)
    %Guesses an uncovered tile, otherwise 1,1 (broken endgame condition)
    [arrHeight, arrWidth] = size(gameMap);
    guessInvalid = true;    %Set initial condition
    while(guessInvalid)
        % Choose random points
        row = randi(arrHeight,1);
        col = randi(arrWidth,1);
        
        %Check if this is a valid guess (check if this tile is a 10
        if gameMap(row,col) == 10
            %Assign the guess and exit the loop
            rowGuess = row;
            colGuess = col;
            guessInvalid = false;
        end
    end
end