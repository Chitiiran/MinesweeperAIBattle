clear all
close all
clc

%% Changelog
% v2.01 - Made zeroFinder more efficient / compact
% v2.02 - Making hiddenMap & createMap more compact
% v2.03 - Making MatchLoop more compact
% v2.04 - Making MatchLoop a function
% v2.05 - Making MatchLoop a function that can call bots
% v2.06 - BugFIX - Fixed infinite recursion & logic in zeroFinder
% v2.07 - BugFIX - Major fix in oneTurn + updating graphs

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
results = zeros(6,numberOfMatches); % Final results
height  = 10;                       % variable parameter
width   = 10;                       % variable parameter
diff    = 0.2;                      % portion of area that are mines
matchTime = 20;                      % Single match duration [sec]
bot1Name = 'bot_Chitii_03';
bot2Name = 'bot_KJ_v0_04_Discoverer';

%Graph Parameters
match = 1:numberOfMatches;

subplot(3,1,1);
plotMines = plot(match , results(1,:) , match , results(2,:));
title('Number of mines found in each match');
legend({bot1Name,bot2Name}, 'Interpreter', 'none');

subplot(3,1,2);
plotTurns = plot(match , results(3,:) , match , results(4,:));
title('Number of Turns in match');
legend({bot1Name,bot2Name}, 'Interpreter', 'none');

axAvgMines = subplot(3,1,3);
plotAvgMines = plot(match , results(5,:) , match , results(6,:));
title('Average number of mines per turn bots found in each match');

%Test Animated Line
figure
aniPlotMines(1) = animatedline('Color','red');
aniPlotMines(2) = animatedline('Color','blue');
legend({bot1Name,bot2Name}, 'Interpreter', 'none');
title('Number of mines Found in each Match');
% axis([0,numberOfMatches, 0, (height+numberOfMatches)*(width+numberOfMatches)*diff/2])
% aniPlotAvgMines = animatedline;
% axis([0,numberOfMatches, 0, 0.01])
    
for gamesPlayed = 1:numberOfMatches
    %% Game parameters
    height    = height + 1;                     %variable parameter
    width     = width + 1;                      %variable parameter
    results (:,gamesPlayed) = gameEngine(height, width, diff, matchTime, bot1Name, bot2Name);
        
    %% The results
    for player = 1:numel(plotMines)
        set(plotMines(player), 'YData', results(player, :))
        set(plotTurns(player), 'YData', results(player+2, :))
        set(plotAvgMines(player), 'YData', results(player+4, :))
        
        addpoints(aniPlotMines(player), gamesPlayed, results(player, gamesPlayed))
    end
    
    %Maybe make a running average in the chart (put this in chart, but this slows stuff down
    res_avg_bot_1 = sum(results(5,:))/gamesPlayed;
    res_avg_bot_2 = sum(results(6,:))/gamesPlayed;
    str_bot_1     = strcat(bot1Name,' : ',num2str(res_avg_bot_1));
    str_bot_2     = strcat(bot2Name, ' : ',num2str(res_avg_bot_2));
    legend(axAvgMines, {str_bot_1,str_bot_2}, 'Interpreter', 'none');

    refreshdata
    drawnow
end

%% Functions for the game
function results = gameEngine(height, width, diff, matchTime, bot1Name, bot2Name)
    mines     = floor(diff*height*width);    
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
        win = true;
        while(win && ~winner)
            if bot_1_score >= floor(mines/2)
                winner = 1;
                break
            end
            [x,y] = executeStrAsFun(bot1Name, gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_1_turnCount = bot_1_turnCount + 1;
            if(win)
                %bot_1 gets a bonus turn
                bot_1_score = bot_1_score + 1;
            end
        end
        %Player 2's turn
        win = true;
        while(win && ~winner)
            if bot_2_score >= floor(mines/2)
                winner = 1;
                break
            end
            [x,y] = executeStrAsFun(bot2Name, gameMap);
            [gameMap,win] = oneTurn(x, y, gameMap, fullMap);
            bot_2_turnCount = bot_2_turnCount + 1;
            if(win)
                %bot_2 gets a bonus turn
                bot_2_score = bot_2_score + 1;
            end
        end
    end
    
    %% The current match result
    % gameMap
    results(1) = bot_1_score;
    results(2) = bot_2_score;
    results(3) = bot_1_turnCount;
    results(4) = bot_2_turnCount;
    results(5) = bot_1_score / bot_1_turnCount;
    results(6) = bot_2_score / bot_2_turnCount;
end

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
                ri = max((r_mine(i)-1),1):min((r_mine(i)+1),height);
                ci = max((c_mine(i)-1),1):min((c_mine(i)+1),width);
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

function [gameMap,win] = oneTurn(row, col, gameMap, fullMap)
    [arrHeight, arrWidth] = size(gameMap);
    if (row > 0 && row <= arrHeight && col > 0 && col <=arrWidth && gameMap(row,col) == 10)
        if fullMap(row, col) ~=9 %Player didnt find the bomb doesnt get extra turn
            win = 0;
            if fullMap(row, col) ~= 0 %Player found information on map
                gameMap(row, col) = fullMap(row, col);
            else %Player found a piece of empty land, So all the adjacent empty boxes needs to found
                gameMap = zeroFinder(row, col, gameMap,fullMap);
            end
        else %Player found a mine
            win = 1;
            gameMap(row, col) = fullMap(row, col);
        end
    else
        win = 0; % the spot is already open or out of bounds
    end
end

function gameMap = zeroFinder(row, col, gameMap,fullMap)
    [arrHeight, arrWidth] = size(gameMap);
    gameMap(row,col) = fullMap(row,col);
    
    %Find valid indicies
    ri = max((row-1),1):min((row+1),arrHeight);
    ci = max((col-1),1):min((col+1),arrWidth);
    %Assign
    oldSect = gameMap(ri,ci);
    gameMap(ri,ci) = fullMap(ri,ci);
    
    %Check for new Zeros
    diffSect = oldSect - gameMap(ri,ci);
    [rx, cx] = find(diffSect==10);
    rz = ri(rx);
    cz = ci(cx);
    %Recall zeroFinder
    for i = 1 : numel(rz)
        if(rz(i)~=row || cz(i) ~= col)
            gameMap = zeroFinder(rz(i), cz(i), gameMap, fullMap);
        end
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

function [row,col] = bot_human(gameMap)
   gameMap
   row = input('row?')
   col = input('col?')
end

%% Auxillary Functions
function [row, col] = executeStrAsFun(fname, args)
    try
        fun = str2func(fname);         % convert string to a function
        [row, col] = fun(args);           % run the function
    catch err
        fprintf('Function: %s\n', fname);
        fprintf('Message: %s\n', err.message);
        struct2table(err.stack, 'AsArray', true)
        error(err)
        %results = ['ERROR: Couldn''t run function: ' fname];
    end
end