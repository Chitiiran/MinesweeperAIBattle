clc
?
global goodTurn OOBTurn
goodTurn = 0;
OOBTurn = 0;
%% Game Information
% 0  = Empty Area
% 9  = Detected mines
% 10 = Hidden/Locked area
% other numbers works like minesweeper
?
% Create a bot that would make a prediction where the mines will be
% All valid guesses unlocks an area
% If bot unlocked a mine that bot gets another turn
% If bot unlocks already unlocked area, the bot wasted the turn
% Both bots get to see the game board and all previously unlocked areas
% Current bots are identical and they randomly guess the areas so the game
% could get stuck in infinite loop [ctrl-c @command window]
?
numberOfMatches = 20;               % Best of 'Odd numberOfMatches'
results = zeros(4,numberOfMatches); % Final results
height  = 10;                       % variable parameter
width   = 10;                       % variable parameter
diff    = 0.2;                      % portion of area that are mines
matchTime = 2;                      % Single match duration [sec]
for gamesPlayed = 1:numberOfMatches
    %% Game parameters
    height    = height + 1;                     %variable parameter
    width     = width + 1;                      %variable parameter
    mines     = floor(diff*height*width);       %variable parameter
    
    fullMap   = createMap(height , width, mines);% Open this for God Eye's View
    gameMap   = hiddenMap(height , width);
    winner    = 0;
    startTime = cputime;
    %% Player parameters
    bot_1_score = 0;
    bot_2_score = 0;
    bot_1_turnCount = 0;
    bot_2_turnCount = 0;
    
    %% Current match
    while(~winner && (cputime-startTime) < matchTime)
        %Player 1's turn
        [x,y] = bot_1(gameMap);
        [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
        bot_1_turnCount = bot_1_turnCount + 1;
        while(win)
            %bot_1 gets a bonus turn
            bot_1_score = bot_1_score + 1;
            if bot_1_score >= floor(mines/2)
                winner = 1;
            end
            [x,y] = bot_1(gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_1_turnCount = bot_1_turnCount + 1;
        end
        
        %Player 2's turn
        [x,y] = bot_2(gameMap);
        [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
        bot_2_turnCount = bot_2_turnCount + 1;
        
        while(win)
            %bot_2 gets a bonus turn
            bot_2_score = bot_2_score + 1;
            if bot_2_score >= floor(mines/2)
                winner = 1;
            end
            [x,y] = bot_2(gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_2_turnCount = bot_2_turnCount + 1;
        end
    end
    %% The current match result
    % gameMap
    results(1,gamesPlayed) = bot_1_score;
    results(2,gamesPlayed) = bot_2_score;
    results(3,gamesPlayed) = bot_1_turnCount;
    results(4,gamesPlayed) = bot_2_turnCount;
    
end
?
%% The results
match = 1:numberOfMatches;
subplot(2,1,1);
plot(match , results(1,:) , match , results(2,:));
title('Number of mines found in each match');
legend('Bot 1','Bot 2');
subplot(2,1,2);
plot(match , results(3,:) , match , results(4,:));
title('Number of turns bots took found in each match');
legend('Bot 1','Bot 2');
?
%% Functions for the game
function map = createMap(height, width, numBomb)
    if numBomb < height*width
        map = zeros(height, width);
        if numBomb > 0
            for i = 1:numBomb %Place some bomb in place
                x = randi(width,1);
                y = randi(height,1);
                map(y,x) = 9;
            end
            
            for x = 1 : (width) %Find the mines
                for y = 1: (height)
                    if (map(y,x) == 9)
                        %Count surrounding bombs (9)
                        for i = x-1:x+1 %populating the array with numbers
                            for j = y-1:y+1
                                if (i~=x || j~=y)
                                    if (i>=1 && i<=width && j>=1 && j<=height)% boundary conditions
                                        if map(j,i) ~= 9
                                            map(j,i) = map(j,i)+1;
                                        end
                                    end
                                end
                            end
                        end
                    else
                        %do nothing
                    end
                end
            end
        end
    else
        ones(height,width);
    end
end
function map = hiddenMap(height, width)
    map = zeros(height , width);
    for x = 1:width
        for y = 1:height
            map(y,x) = 10;
        end
    end
end
function [map,win] = oneTurn(row, col, gameMap, fullMap)
    [arrHeight, arrWidth] = size(gameMap);
    if (row <= arrHeight && col <=arrWidth && gameMap(row,col) == 10)
        if fullMap(row, col) ~=9 %Player didnt find the bomb doesnt get extra turn
            win = 0;
            if fullMap(row, col) ~= 0 %Player found information on map
                gameMap(row, col) = fullMap(row, col);
                map = gameMap;
            else %Player found a piece of empty land, So all the adjacent empty boxes needs to found
                %             fprintf('found a zero\n');
                %             gameMap(row,col) = fullMap(row,col);
                map = zeroFinder(row, col, gameMap,fullMap);
            end
        else %Player found a mine
            win = 1;
            gameMap(row, col) = fullMap(row, col);
            map = gameMap;
        end
    else
        win = 0; % the spot is already open or out of bounds
        map = gameMap;
    end
end
function map = zeroFinder(row, col, gameMap,fullMap)
    [arrHeight, arrWidth] = size(gameMap);
    gameMap(row,col) = fullMap(row,col);
    map = gameMap;
    % reveal top
    if col > 1 && gameMap(row,col-1) == 10
        map(row,col-1) = fullMap(row,col-1);
        if map(row,col-1) == 0
            map = zeroFinder(row, col-1, map,fullMap);
        end
    end
    % reveal bot
    if col  < arrWidth && gameMap(row,col+1) == 10
        map(row,col+1) = fullMap(row,col+1);
        if map(row,col+1) == 0
            map = zeroFinder(row, col+1, map,fullMap);
        end
    end
    
    % reveal left
    if row  > 1 && gameMap(row-1,col) == 10
        map(row-1,col) = fullMap(row-1,col);
        if map(row-1,col) == 0
            map = zeroFinder(row-1, col, map,fullMap);
        end
    end
    %reveal right
    if row  < arrHeight && gameMap(row+1,col) == 10
        map(row+1,col) = fullMap(row+1,col);
        if map(row+1,col) == 0
            map = zeroFinder(row+1, col, map,fullMap);
        end
    end
    %reveal North East
    if col > 1 && row  > 1 && gameMap(row-1,col-1) == 10
        map(row-1,col-1) = fullMap(row-1,col-1);
        if map(row-1,col-1) == 0
            map = zeroFinder(row-1, col-1, map,fullMap);
        end
    end
    %reveal North West
    if col > 1 && row  < arrHeight && gameMap(row+1,col-1) == 10
        map(row+1,col-1) = fullMap(row+1,col-1);
        if map(row+1,col-1) == 0
            map = zeroFinder(row+1, col-1, map,fullMap);
        end
    end
    %reveal South East
    if col  < arrWidth && row  > 1 && gameMap(row-1,col+1) == 10
        map(row-1,col+1) = fullMap(row-1,col+1);
        if map(row-1,col+1) == 0
            map = zeroFinder(row-1, col+1, map,fullMap);
        end
    end
    % reveal South West
    if col  < arrWidth && row  < arrHeight && gameMap(row+1,col+1) == 10
        map(row+1,col+1) = fullMap(row+1,col+1);
        if map(row+1,col+1) == 0
            map = zeroFinder(row+1, col+1, map,fullMap);
        end
    end
end
?
%% Bots
function [row,col] = bot_1(gameMap)
%     [row,col] = bot_KJ_v0_02(gameMap);
%     [row,col] = bot_KJ_v0_03(gameMap);
    [row,col] = bot_RandomValidGuess(gameMap);
%     [row,col] = bot_RandomTile(gameMap);
    
end
?
function [row,col] = bot_2(gameMap)
%     [row,col] = bot_KJ_v0_02(gameMap);
%     [row,col] = bot_KJ_v0_03(gameMap);
%     [row,col] = bot_RandomValidGuess(gameMap);
    [row,col] = bot_RandomTile(gameMap);
end
