% Function called by: Experiment.m
% Role of function is to run a trial of the experiment
% color_list.grey: 
%   - Parameters    (Things to be used for the experiment)
%   - Cpu           (The opponent that will be used for this trial)
%   - Duration      (How long the player has to react to the events on screen)
%   - Score_Row     (A list with the scores shuffled order for this Trial
%   - Instance_Idx  (Where in the trial we are)
%   - Layout        (Which layout to use)
%   - Trial_Total   (How much the player has scored so far in the trial)
% Return Values: 
%   - player_data   (Data on the player's performance)
%   - Trial_Total   (The updated total of all the trials)

function [player_data, Trial_Total] = RunTrial(Parameters, Cpu, Duration, Score_Row, Instance_Idx, Layout, Trial_Total)
    load('colors.mat','color_list');

    %% PRE STAGE - Before the timer of the activity starts
    % Create a list of he targets and the data that will be used for them (Assume first layout)       
    targets = [struct('Text', 'Split', 'TextColor', Parameters.target.split.text,...
                      'FillColor', Parameters.target.split.circle, 'Value', true, ...
                      'Coords', [0, Parameters.screen.window_height], 'Icon', 'Split_iconW.png', ...
                      'TextCoords', [70, Parameters.screen.window_height - 40], ...
                      'IconRect', [70, Parameters.screen.window_height - 450, ...
                                   370, Parameters.screen.window_height - 150]), ...
               struct('Text', 'Steal', 'TextColor', Parameters.target.steal.text,...
                      'FillColor', Parameters.target.steal.circle, 'Value', false, ...
                      'Coords', Parameters.screen.window_dims, 'Icon', 'Steal_iconB.png', ...
                      'TextCoords', [Parameters.screen.window_width - 300, Parameters.screen.window_height - 40], ...
                      'IconRect', [Parameters.screen.window_width-370, Parameters.screen.window_height - 450, ...
                                   Parameters.screen.window_width-70, Parameters.screen.window_height - 150])];
    % If the layout is different, adjust the variables.
    if Layout == 2
        targets(1).Coords = Parameters.screen.window_dims;
        targets(1).TextCoords = [Parameters.screen.window_width - 300, ...
                                 Parameters.screen.window_height - 40];
        targets(1).IconRect = [Parameters.screen.window_width-370, Parameters.screen.window_height - 450, ...
                               Parameters.screen.window_width-70, Parameters.screen.window_height - 150];
        targets(2).Coords = [0, Parameters.screen.window_height];
        targets(2).TextCoords = [70, Parameters.screen.window_height - 40];
        targets(2).IconRect = [70, Parameters.screen.window_height - 450, ...
                               370, Parameters.screen.window_height - 150];
    end
    
    % Generate the rect value for the targets
    for idx = 1:length(targets)
        targets(idx).Rect = [targets(idx).Coords(1) - Parameters.target.radius, ...
                             targets(idx).Coords(2) - Parameters.target.radius,...
                             targets(idx).Coords(1) + Parameters.target.radius, ...
                             targets(idx).Coords(2) + Parameters.target.radius];
    end
    
    prizebox_height = 70;
    timebar_height = 10;
    
    % -1 = Player did nothing. 0 = Player Stole. 1 = Player Split
    player_data = struct('choice', -1, 'dir', "", 'score', NaN, 'time', NaN);
    
    %% LOOP STAGE
    start_time = GetSecs();
    elapsed_time = 0;
    while elapsed_time < Duration
        % Calculate the player movements
        [Parameters.player.pos, player_rect] = MovePlayer(Parameters.player.pos, Parameters.player.speed, ...
                                                            Parameters.player.radius, Parameters.screen.window_dims,...
                                                            [0, Parameters.screen.window_width; ...
                                                                timebar_height+prizebox_height, ...
                                                                Parameters.screen.window_height]);

        % Detect collisions between objects
        [player_target_collision, player_data.choice] = DetectCollision(Parameters.player, targets, Parameters.target.radius);

        % If player has collided with target, end trial
        if player_target_collision
            break;
        end


        % PAINT THE PICTURE
        % Print Upper Info
        % Print the current money
        % DrawPrizes(Parameters.screen.window, [Parameters.screen.window_width, prizebox_height], ...
        %            Parameters.trial.scores, Score_Row, Score_Row(Instance_Idx), Parameters.text.size.prizes);
        DrawPrize2(Parameters.screen.window, [Parameters.screen.window_width, prizebox_height], ...
                   Parameters.trial.scores, Score_Row, Score_Row(Instance_Idx), Parameters.text.size.prizes, Trial_Total);
        Screen('TextSize', Parameters.screen.window, Parameters.text.size.default);
        
        % Print the time bar
        time_percent = 1 - elapsed_time/Duration;
        if time_percent <= 0; time_percent = 0.002; end
        timebar_color = [0.75*(min(255*2*(1-time_percent),255)),...
                        0.75*(min(round(255*2*time_percent),255)), 0, 255];
        timeRect = [(1-time_percent)*Parameters.screen.window_width/2 , prizebox_height, ...
                    Parameters.screen.window_width/2 + Parameters.screen.window_width/2 * time_percent, ...
                    prizebox_height+timebar_height];
        Screen('FillRect', Parameters.screen.window, color_list.black, ...
               [0,prizebox_height,Parameters.screen.window_width,prizebox_height+timebar_height]);
        Screen('FillRect', Parameters.screen.window, timebar_color, timeRect);
        
        % % Print the total player_data.score
        % player_data.score_text = sprintf('Total player_data.score: %d', Trial_Total.player);
        % DrawFormattedText(Parameters.screen.window, player_data.score_text, 0, prizebox_height+timebar_height+20, [200, 200, 200, 255]);

        % Draw all the targets
        for target_idx=1:length(targets)
            Screen('FillOval', Parameters.screen.window, targets(target_idx).FillColor, targets(target_idx).Rect);
            Screen('TextSize', Parameters.screen.window, Parameters.text.size.target);
            DrawFormattedText( Parameters.screen.window,targets(target_idx).Text,...
                               targets(target_idx).TextCoords(1),targets(target_idx).TextCoords(2), ...
                               targets(target_idx).TextColor);
            Screen('TextSize', Parameters.screen.window, Parameters.text.size.default);
            DrawIcon(Parameters.screen.window, targets(target_idx).Icon, targets(target_idx).IconRect);
        end

        % Draw the playable character in the new position
        Screen('FillOval', Parameters.screen.window, Parameters.player.color, player_rect);

        % Update the Screen
        Screen('Flip', Parameters.screen.window);

        % Update the timer
        elapsed_time = GetSecs()-start_time;
        player_data.time = elapsed_time;
    end
    
    %% POST LOOP player_data.score GIVING
    % Get the cpu's choice
    cpu_splits = Cpu.getResponce();
    [player_data.score, cpu_player_data.score] = deal(0);
    result_text = '';
    
    % Based on the player's choice, determine which direction the player took    
    if Layout == 1; directions = ["Nowhere", "Right", "Left"];
    else; directions = ["Nowhere", "Left", "Right"];
    end
    player_data.dir = directions(player_data.choice+2);

    % Based on the player's and cpu's choice, determine outcome and scoring
    switch player_data.choice
        case -1         %If we failed to make a choice, give the money to the cpu
            player_data.score = 0;
            cpu_player_data.score = Score_Row(Instance_Idx);
            result_text = sprintf('You picked no option and thus forfeited the money to the other player');
            result_text = sprintf('%s\n. The prize of $%d goes to your opponent', result_text, Score_Row(Instance_Idx));
        case 0          % Steal scenario
            result_text = sprintf('You chose to steal. ');
            cpu_player_data.score = 0;
            if cpu_splits   
                player_data.score = Score_Row(Instance_Idx);
                result_text = sprintf('%sYour opponent chose to split.\n',result_text);
                result_text = sprintf('%sYou earn all $%d.',result_text, Score_Row(Instance_Idx));
            else
                player_data.score = 0;
                result_text = sprintf('%sYour opponent chose to steal also.\n',result_text);
                result_text = sprintf('%sBoth of you earn nothing.',result_text);
            end
        case 1          % Split scenario
            result_text = sprintf('You chose to split. ');
            if cpu_splits
                player_data.score = Score_Row(Instance_Idx)/2;
                cpu_player_data.score = Score_Row(Instance_Idx)/2;
                result_text = sprintf('%sSo did your opponent.\n',result_text);
                result_text = sprintf('%sBoth of you earn $%d each.',result_text, Score_Row(Instance_Idx));
            else
                player_data.score = 0;
                cpu_player_data.score = Score_Row(Instance_Idx);
                result_text = sprintf('%sBut your opponent chose to steal.\n',result_text);
                result_text = sprintf('%sYour opponent earns $%d, and you get nothing.',result_text, Score_Row(Instance_Idx));
            end
    end

    % Update the total scores of the trial
    Trial_Total.player = Trial_Total.player + player_data.score;
    Trial_Total.cpu = Trial_Total.cpu + cpu_player_data.score;
    
    total_text = sprintf('You haved earned $%d so far!\n Your opponent has earned $%d', Trial_Total.player, Trial_Total.cpu);
    skip_text = 'Press any button to skip.';
   
    
    % Let the participant know what they player_data.scored
    Screen('TextSize', Parameters.screen.window, Parameters.text.size.default);
    DrawFormattedText(Parameters.screen.window, result_text, 'center', 'center', color_list.white);
    DrawFormattedText(Parameters.screen.window, skip_text, Parameters.screen.center(1), ...
        Parameters.screen.center(2) + 100, color_list.white);
    Screen('Flip', Parameters.screen.window);

    text_start = GetSecs();
    skip_selected = false;
    while GetSecs()-text_start < 2 && ~skip_selected
        if KbCheck() || GetXBox().AnyButton; skip_selected = true; end
    end

    % Let the participant know what their total player_data.score is
    Screen('TextSize', Parameters.screen.window, Parameters.text.size.default);
    DrawFormattedText(Parameters.screen.window, total_text, 'center', 'center', color_list.white);
    DrawFormattedText(Parameters.screen.window, skip_text, Parameters.screen.center(1), ...
        Parameters.screen.center(2) + 100, color_list.white);
    Screen('Flip', Parameters.screen.window);

    text_start = GetSecs();
    while GetSecs()-text_start < 2 && ~skip_selected
        if KbCheck() || GetXBox().AnyButton; skip_selected = true; end
    end
    WaitSecs(0.3);
end

%% HELPER FUNCTIONS
function DrawPrizes(Win, Dims, Norm_Prizes, Sfld_Prizes, Curr_Prize, Text_Size)
    load('colors.mat','color_list'); 
    Screen('TextSize', Win, Text_Size);

    % Get the index of the current player_data.score
    curr_prize_idx = find(Sfld_Prizes == Curr_Prize);
    
    prizebox_dims = [Dims(1)/length(Norm_Prizes), Dims(2)];
    xaxis_offset = 0;
    
    % Draw the text and the line
    for prize_idx = 1:length(Norm_Prizes)
        if Norm_Prizes(prize_idx) == Curr_Prize
            Screen('FillRect', Win, color_list.green, [xaxis_offset, 0, ...
                    prizebox_dims(1)+xaxis_offset, prizebox_dims(2)])
        end

        Screen('FrameRect', Win, color_list.gold, [xaxis_offset, 0, ...
            prizebox_dims(1)+xaxis_offset, prizebox_dims(2)], 5)

        text = sprintf('%d$',Norm_Prizes(prize_idx));
        DrawFormattedText(Win, text, xaxis_offset + 5, ...
                Text_Size, color_list.white);
        
        if find(Sfld_Prizes == Norm_Prizes(prize_idx)) < curr_prize_idx
            Screen('BlendFunction', Win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            Screen('FillRect', Win, [60,60,60,128], [xaxis_offset+5, 5, ...
                    prizebox_dims(1)+xaxis_offset-5, prizebox_dims(2)-5]);
        end
        
        xaxis_offset = prizebox_dims(1)+xaxis_offset;
    end
end

function DrawPrize2(Win, Dims, Norm_Prizes, Sfld_Prizes, Curr_Prize, Text_Size, Trial_Total)
    load('colors.mat','color_list'); 
    Screen('TextSize', Win, Text_Size);

    % Draw a blue background
    Screen('FillRect', Win, color_list.blue, [0, 0, Dims]);

    part_dims = [round(Dims(1)/3), Dims(2)];
    part_xoffset = 0;
    
    % Draw your current total:
    your_player_data.score_text = sprintf('Your Total: $%d', Trial_Total.player);
    DrawFormattedText(Win, your_player_data.score_text, part_xoffset + 10, Text_Size + 7, color_list.gold);
    Screen('FrameRect', Win, color_list.gold, [part_xoffset, 0, part_dims(1)+part_xoffset, part_dims(2)], 5);
    part_xoffset = part_xoffset + part_dims(1);


    % Draw Current Prize
    prize_text = sprintf('$ %d', Curr_Prize);
    DrawFormattedText(Win, prize_text, (Dims(1)-length(prize_text)*Text_Size*0.5)/2, Text_Size + 10, color_list.gold);
    Screen('FrameRect', Win, color_list.gold, [part_xoffset, 0, part_dims(1)+part_xoffset, part_dims(2)], 5);
    
    % Draw the text and the line
    xaxis_offset = part_xoffset+round( part_dims(1)/(length(Norm_Prizes) + 1) );
    for prize_idx = 1:length(Norm_Prizes)
        dot_color = color_list.white;
        if find(Sfld_Prizes == Norm_Prizes(prize_idx)) < find(Sfld_Prizes == Curr_Prize)
            dot_color = color_list.grey;
        elseif find(Sfld_Prizes == Norm_Prizes(prize_idx)) == find(Sfld_Prizes == Curr_Prize)
            dot_color = color_list.green;
        end
        
        Screen('DrawDots', Win, [xaxis_offset, 10], 10, dot_color);
    
        xaxis_offset = xaxis_offset + round( part_dims(1)/(length(Norm_Prizes) + 1) );
    end
    part_xoffset = part_xoffset + part_dims(1);

    % Draw your current total:
    cpu_player_data.score_text = sprintf('Opponent Total: $%d', Trial_Total.cpu);
    DrawFormattedText(Win, cpu_player_data.score_text, part_xoffset + 10, Text_Size + 7, color_list.gold);
    Screen('FrameRect', Win, color_list.gold, [part_xoffset, 0, Dims(1), part_dims(2)], 5);
end