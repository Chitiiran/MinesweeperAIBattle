clc
%% Changelog
% v2.01 - Made zeroFinder more efficient / compact
% v2.02 - Making hiddenMap & createMap more compact

%% Game Information
% 0  = Empty Area
% 9  = Detected mines
% 10 = Hidden/Locked area
% other numbers works like minesweeper

% Create a bot that would make a prediction where the mines will be
% All valid guesses unlocks an area
% If bot unlocked a mine that bot gets another turn
% If bot unlocks already unlocked area, the bot wasted the turn
% Both bots get to see the game board and all previously unlocked areas
% Current bots are identical and they randomly guess the areas so the game
% could get stuck in infinite loop [ctrl-c @command window]

numberOfMatches = 100;               % Best of 'Odd numberOfMatches'
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
        [x,y] = bot_Chitii_02(gameMap);
        [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
        bot_1_turnCount = bot_1_turnCount + 1;
        while(win && ~winner)
            %bot_1 gets a bonus turn
            bot_1_score = bot_1_score + 1;
            if bot_1_score >= floor(mines/2)
                winner = 1;
            end
            [x,y] = bot_Chitii_02(gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_1_turnCount = bot_1_turnCount + 1;
        end
        
        %Player 2's turn
        [x,y] = bot_KJ_v0_02_Invalidator(gameMap);
        [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
        bot_2_turnCount = bot_2_turnCount + 1;
        
        while(win  && ~winner)
            %bot_2 gets a bonus turn
            bot_2_score = bot_2_score + 1;
            if bot_2_score >= floor(mines/2)
                winner = 1;
            end
            [x,y] = bot_KJ_v0_02_Invalidator(gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_2_turnCount = bot_2_turnCount + 1;
        end
    end
    %% The current match result
    % gameMap
    results(1,gamesPlayed) = bot_1_score;
    results(2,gamesPlayed) = bot_2_score;
    results(3,gamesPlayed) = bot_1_score / bot_1_turnCount;
    results(4,gamesPlayed) = bot_2_score / bot_2_turnCount;
    
end

%% The results
match = 1:numberOfMatches;
subplot(2,1,1);
plot(match , results(1,:) , match , results(2,:));
title('Number of mines found in each match');
legend('Bot 1','Bot 2');
subplot(2,1,2);
plot(match , results(3,:) , match , results(4,:));
title('Average number of mines per turn bots found in each match');
res_avg_bot_1 = sum(results(3,:))/numberOfMatches;
res_avg_bot_2 = sum(results(4,:))/numberOfMatches;
str_bot_1     = strcat('Bot 1 : ',num2str(res_avg_bot_1));
str_bot_2     = strcat('Bot 2 : ',num2str(res_avg_bot_2));
legend(str_bot_1,str_bot_2);

%% Functions for the game
function map = createMap(height, width, numBomb)
    if numBomb < height*width
        map = zeros(height, width);
        if numBomb > 0
            %Find random indicies to place mines and set them
            mine_idx = randperm(numel(map), numBomb);
            map(mine_idx) = 9;
            
            [r_mine, c_mine] = find(map==9);
            
            for i = 1:numel(r_mine)
                %Find valid indicies
                ri = max((r_mine(i)-1),1):min((r_mine(i)+1),arrHeight);
                ci = max((c_mine(i)-1),1):min((c_mine(i)+1),arrWidth);
                %Increment adjacent tiles
                map(ri,ci) = map(ri,ci) + 1;               
            end
            
            %Reset Mines to 9
            map(mine_idx) = 9;
        end
    end
end

function map = hiddenMap(height, width)
    map = zeros(height , width) + 10;
end

function [map,win] = oneTurn(row, col, gameMap, fullMap)
    [arrHeight, arrWidth] = size(gameMap);
    if (row > 0 && row <= arrHeight && col > 0 && col <=arrWidth && gameMap(row,col) == 10)
        if fullMap(row, col) ~=9 %Player didnt find the bomb doesnt get extra turn
            win = 0;
            if fullMap(row, col) ~= 0 %Player found information on map
                gameMap(row, col) = fullMap(row, col);
                map = gameMap;
            else %Player found a piece of empty land, So all the adjacent empty boxes needs to found
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
    
    %Find valid indicies
    ri = max((row-1),1):min((row+1),arrHeight);
    ci = max((col-1),1):min((col+1),arrWidth);
    %Assign
    map(ri,ci) = fullMap(ri,ci);
    %Check for more zeros
    [rx, cx] = find(map(ri,ci)==0);
    %Recall zeroFinder
    for i = 1 : numel(rx)
        map = zeroFinder(rx(i), cx(i), map,fullMap);
    end
end

%% Bots
function [row,col] = bot_1(gameMap)
    [row,col] = bot_RandomValidGuess(gameMap);
end
%% Bots
function [row,col] = bot_2(gameMap)
    [row,col] = bot_RandomValidGuess(gameMap);
end