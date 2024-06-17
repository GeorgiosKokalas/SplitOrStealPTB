% Function called by: main.m
% Role of function is to run the experiment, start to finish 
% Parameters: parameters (Things to be used for the experiment)
% Return Values: None

function Experiment(parameters)
    %% Do some precalculations
    cpu_list = [CpuPlayer(1),CpuPlayer(2)];
    
    combos = [];
    combos_str = [];

    % Get a list of all the possible combinations we may have
    for cpu_idx = 1:width(cpu_list)
        for time_idx = 1:width(parameters.trial.duration_s)
            time_val = parameters.trial.duration_s(time_idx);
            for rep_idx = 1:parameters.trial.num_reps
                combos = [combos;sprintf('%d%d%d',cpu_idx,time_idx,rep_idx)];
                combos_str = [combos_str, string(sprintf("CPU-%d_%ds_Trial%d",cpu_idx,time_val,rep_idx))];
            end
        end
    end
    [mix_choices, mix_scores, mix_times] = deal(table('Size', [length(parameters.trial.scores), length(combos_str)],...
                                    'VariableTypes', repmat("double", 1, length(combos_str)), ...
                                    'VariableNames',combos_str));
    [ord_choices, ord_scores, ord_times] = deal(table('Size', [length(parameters.trial.scores), length(combos_str)],...
                                    'VariableTypes', repmat("double", 1, length(combos_str)), ...
                                    'VariableNames',combos_str));
    [mix_dirs, ord_dirs] = deal(table('Size', [length(parameters.trial.scores), length(combos_str)],...
                                    'VariableTypes', repmat("string", 1, length(combos_str)), ...
                                    'VariableNames',combos_str));
    total_scores = table('Size', [1, length(combos_str)],...
                       'VariableTypes', repmat("double", 1, length(combos_str)), ...
                       'VariableNames',combos_str);
    
    % Randomize the combos
    random_order = randperm(height(combos));
    combos = combos(random_order, :);
    combos_str = combos_str(random_order);
   
    % Layout 1 = Split Steal, Layout 2 = Steal Split
    layouts = ones(1, height(combos)*length(parameters.trial.scores));
    layouts(1:round(length(layouts)/2)) = 2;
    layouts = layouts(randperm(length(layouts)));
    layouts = reshape(layouts, [height(combos), length(parameters.trial.scores)]);
    
    % Create a scoreboard with randomized placements
    scoreboard = repmat(parameters.trial.scores, height(combos),1);
    for board_row = 1:height(scoreboard)
        scoreboard(board_row,:) = scoreboard(board_row, randperm(width(scoreboard)));
    end

    if numel(scoreboard) ~= numel(layouts)
        error('Scores and layouts have been miscalculated');
    end
    

    % Carry out the Introduction to the task
    if parameters.trial.show_intro
        Introduction(parameters.screen, parameters.player, parameters.text);
    end

    cd(parameters.trial.output_dir);

    for trial_idx = 1:height(scoreboard)
        table_name = combos_str(trial_idx);
        trial_total = struct('player', 0, 'cpu', 0);
        for instance_idx = 1:width(scoreboard)
            [pl_data, trial_total] = RunTrial(parameters,cpu_list(str2double(combos(trial_idx,1))),...
                                              parameters.trial.duration_s(str2double(combos(trial_idx,2))), ...
                                              scoreboard(trial_idx,:), instance_idx, layouts(trial_idx,instance_idx), ...
                                              trial_total);
            mix_choices.(table_name)(instance_idx) = pl_data.choice;
            mix_scores.(table_name)(instance_idx) = pl_data.score;
            mix_dirs.(table_name)(instance_idx) = pl_data.dir;
            mix_times.(table_name)(instance_idx) = pl_data.time;

            real_prize_idx = find(parameters.trial.scores == scoreboard(trial_idx, instance_idx));
            ord_choices.(table_name)(real_prize_idx) = pl_data.choice;
            ord_scores.(table_name)(real_prize_idx) = pl_data.score;
            ord_dirs.(table_name)(real_prize_idx) = pl_data.dir;
            ord_times.(table_name)(real_prize_idx) = pl_data.time;
            
        end
        TrialSwitch(parameters.screen.window,trial_idx, height(scoreboard));

         total_scores.(table_name) = trial_total.player;
        
        % Save the trial results
        trial_filename = sprintf('%s.mat', table_name);
        mix_trial_choices = mix_choices.(table_name);
        mix_trial_scores  = mix_scores.(table_name);
        mix_trial_dirs = mix_dirs.(table_name);
        mix_trial_times = mix_times.(table_name);
        ord_trial_choices = ord_choices.(table_name);
        ord_trial_scores = ord_scores.(table_name);
        ord_trial_dirs = ord_dirs.(table_name);
        ord_trial_times = ord_times.(table_name);
        score_order = scoreboard(trial_idx,:);
        trial_layouts =  layouts(trial_idx, :);
        save(trial_filename, "mix_trial_scores", "mix_trial_choices", "mix_trial_dirs", "mix_trial_times", ...
            "ord_trial_choices", "ord_trial_scores", "ord_trial_dirs", "ord_trial_times", "score_order", ...
            "trial_layouts", "-mat");
    end
    
    save("All_trials.mat", "mix_choices", "mix_scores", "mix_dirs", "mix_times", "ord_choices", "ord_scores", ...
        "ord_dirs", "ord_times", "scoreboard", "combos", "combos_str", "layouts", "total_scores", "-mat");

    % Cleanup
    for idx = length(cpu_list):-1:1
        delete(cpu_list(idx));
    end
    

    % Debrief(parameters.screen, [sum(prison_score_table), sum(hunt_score_table)], ["Prisoner Task", "Hunting Trip"]);

end