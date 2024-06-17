% Function called by: InsertParams.m
% Role of function is to validate all user-inserted parameters
% Parameters: in_pars (struct that contains all inserted parameters)
% Return Values: in_pars (in_pars after validation)
% Function that is aimed to validate all inserted parameters by the user. 
%   If values are invalid they are updated. More parameters are also added.

function in_pars = ValidateInsertParams(in_pars, Patient_Name)
    load('colors.mat','color_list');
    
    %in_pars.screen extra variables (dependent on user-defined variables)
    in_pars.screen.custom_screen_ = false;         % dependent on start_point, height and width
    in_pars.screen.window = -1;                    % will be used to hold the window (-1 is a placeholder)
    in_pars.screen.center = [0,0];                 % will be used to represent the center of the window
    in_pars.screen.screen_width = 0;               % the width of the screen in which the window will be housed 
    in_pars.screen.screen_height = 0;              % the height of the screen in which the window will be housed 
    in_pars.screen.window_dims = [0,0];            % the dimensions of the window (combines width and height)    

    % in_pars.screen - VALUE EVALUATION
    % Evaluating color
    if ~isrgba(in_pars.screen.color)
        disp("Inoperable value provided for in_pars.screen.color. Applying default...");
        in_pars.screen.color = color_list.grey;
    end
    
    % Evaluating screen (must be within the acceptable range of the available Screens
    if ~isnat(in_pars.screen.screen) || in_pars.screen.screen > max(Screen('Screens'))
        disp("Inoperable value provided for in_pars.screen.screen. Applying default...");
        in_pars.screen.screen = max(Screen('Screens'));
    end

    % change the value of screen_width and screen_height based on the screen
    [in_pars.screen.screen_width, in_pars.screen.screen_height] = Screen('WindowSize', in_pars.screen.screen);
    
    % change the value of custom_screen_ based on the value of start_point 
    dims = [in_pars.screen.screen_width, in_pars.screen.screen_height];
    if ~isloc(in_pars.screen.start_point, dims)
        disp("Inoperable value provided for in_pars.screen.start_point. Applying default...");
        in_pars.screen.start_point = [0, 0];
    end
    
    % change the value of custom_screen_ based on the value of height and width
    make_custom_screen = isnat(in_pars.screen.window_height) && ...          & too long for 1 line 
        isnat(in_pars.screen.window_width) && ...
        in_pars.screen.window_height <= in_pars.screen.screen_height && ...
        in_pars.screen.window_width <= in_pars.screen.screen_width;
    if make_custom_screen   
        disp("Custom Valus provided for Width and Length. Abandoning FullScreen Mode...");
        in_pars.screen.custom_screen_ = true;
    else 
        disp("Assuming FullScreen Mode.");
        [in_pars.screen.window_width, in_pars.screen.window_height] = Screen('WindowSize', in_pars.screen.screen);
    end

    % change the value of in_pars.screen.center, based on screen width and height
    in_pars.screen.center = [in_pars.screen.window_width / 2, in_pars.screen.window_height / 2];

    % change the value of in_pars.screen.window_dims
    in_pars.screen.window_dims = [in_pars.screen.window_width, in_pars.screen.window_height];

    %in_pars.text- VALUE EVALUATION
    % Get all the size parameters
    all_sizes = fieldnames(in_pars.text.size);
    for size_idx = 1:length(all_sizes)
        if ~isnat(in_pars.text.size.(all_sizes{size_idx}))
            disp(sprinf("Inoperable value provided for in_pars.target.size.%s. Applying default...",all_sizes{size_idx}));
            in_pars.text.size.(all_sizes{size_idx}) = 40;
        end
    end

    %in_pars.target - VALUE EVALUATION
    %Evaluating size.circle
    if ~isnat(in_pars.target.radius)
        disp("Inoperable value provided for in_pars.target.radius. Applying default...");
        in_pars.target.radius = 200;
    end


    % Evaluating split.circle
    if ~isrgba(in_pars.target.split.circle)
        disp("Inoperable value provided for in_pars.target.split.circle. Applying default...");
        in_pars.target.split.circle = color_list.light_blue;
    end

    % Evaluating split.text
    if ~isrgba(in_pars.target.split.text)
        disp("Inoperable value provided for in_pars.target.split.text. Applying default...");
        in_pars.target.split.text = color_list.white;
    end

    % Evaluating steal.circle
    if ~isrgba(in_pars.target.steal.circle)
        disp("Inoperable value provided for in_pars.target.steal.circle. Applying default...");
        in_pars.target.steal.circle = color_list.red;
    end

    % Evaluating steal.text
    if ~isrgba(in_pars.target.steal.text)
        disp("Inoperable value provided for in_pars.target.steal.text. Applying default...");
        in_pars.target.steal.text = color_list.black;
    end

    
    % Extra values for in_pars.player
    in_pars.player.speed = 0;
    in_pars.player.pos = [0,0];

    %in_pars.player - VALUE EVALUATION
    % Evaluating radius (must be a positive number)
    if ~isnat(in_pars.player.radius)
        disp("Inoperable value provided for in_pars.player.radius. Applying default...");
        in_pars.player.radius = 10;
    end
    
    %Evaluating color (must be an rgba value)
    if ~isrgba(in_pars.player.color)
        disp("Inoperable value provided for in_pars.player.color. Applying default...");
        in_pars.player.color = color_list.blue;
    end

    % Evaluating speed_percent (must be a whole number)
    if ~iswhole(in_pars.player.speed_percent)
        disp("Inoperable value provided for in_pars.player.speed_percent. Applying default...");
        in_pars.player.speed_percent = 100;
    end

    % Evaluating start_pos (must be a vector of 2 strings) and changing the value of pos 
    win_dims = [in_pars.screen.window_width, in_pars.screen.window_height];
    if length(in_pars.player.start_pos) ~= 2
        disp("Inoperable value provided for in_pars.player.start_pos. Applying default...");
        in_pars.player.start_pos = ["bottom", "center"];
    end
    for idx=1:numel(win_dims)
        switch in_pars.player.start_pos(idx)
            case "top"
                in_pars.player.pos(idx) = in_pars.player.radius + 20;
            case "center"
                in_pars.player.pos(idx) = win_dims(idx) / 2;
            case "bottom"
                in_pars.player.pos(idx) = win_dims(idx) - (in_pars.player.radius + 20);
            otherwise
                disp("Inoperable value provided for one of in_pars.player.start_pos. Applying default...")
                in_pars.player.pos(idx) = win_dims(idx) / 2;
        end
    end

    % change the value of speed (dependent on speed percent)
    in_pars.player.speed = (in_pars.player.speed_percent / 100) + 1; 



    %inin_pars.cross - VALUE EVALUATION
    %Evaluating in_pars.cross.color (must be a rgba value)
    if ~isrgba(in_pars.cross.color)
        disp("Inoperable value provided for in_pars.cross.color. Applying default...");
        in_pars.cross.color = color_list.white;
    end

    % Evaluating in_pars.cross.thickness
    if ~isnat(in_pars.cross.thickness)
        disp("Inoperable value provided for in_pars.cross.thickness. Applying default...");
        in_pars.cross.thickness = 3;
    end

    % Evaluating in_pars.cross.width
    if ~isnat(in_pars.cross.width)
        disp("Inoperable value provided for in_pars.cross.width. Applying default...");
        in_pars.cross.width = 30;
    end

    % Extra Values for in_pars.cross
    in_pars.cross.coords = [-in_pars.cross.width / 2, in_pars.cross.width / 2, 0, 0; ...
        0, 0, -in_pars.cross.width / 2, in_pars.cross.width / 2];



    %in_pars.trial - VALUE EVALUATION
    % Evaluating num_reps (must be a natural number)
    if ~isnat(in_pars.trial.num_reps)
        disp("Inoperable value provided for in_pars.trial.num_reps. Applying default...");
        in_pars.trial.num_reps = 3;
    end
    
    % Evaluating duration_s (must be a vector of natural numbers)
    if ~isnumlist(in_pars.trial.duration_s, 'nat')
        disp("Inoperable value provided for in_pars.trial.duration_s. Applying default...");
        in_pars.trial.duration_s = [20,5];
    end

    % Evaluating show_intro
    if ~islogical(in_pars.trial.show_intro) || ~isscalar(in_pars.trial.show_intro)
        disp("Inoperable value provided for in_pars.trial.show_intro. Applying default...");
        in_pars.trial.show_intro = true;
    end

    % Evaluating scores (must be a natural number)
    if ~isnumlist(in_pars.trial.scores, 'nat')
        disp("Inoperable value provided for in_pars.trial.scores. Applying default...");
        in_pars.trial.scores = [50, 75, 100, 150, 200, 250, 350, 500, 750, 1000] * 1000;
    end

    % Extra values for in_pars.trial
    in_pars.trial.output_dir = fullfile(pwd(),'Output', [Patient_Name, '_' ,datestr(datetime('now'), 'yyyymmdd-HHMM')]);
end




% Custom functions to make the code above more readable
%Checks if a value is a single number
function result = isnum(input)
    result = isscalar(input) && isnumeric(input);
end


%Checks if a value is a whole number (including 0 and positive integers)
function result = iswhole(input)
    % I define naturals as any number equal to or above 0
    result = isnum(input) && input >= 0 && round(input) == input;
end


%Checks if a value is a natural number (integers > 0)
function result = isnat(input)
    %Check if this is a number above 0
    result = isnum(input) && input > 0 && round(input) == input;
end

% Check if a value is composed of numbers
function result = isnumlist(input, Option)
    check_option = exist("Option", "var");
    if check_option
        check_option = check_option && (...
                        strcmpi(char(Option), 'num') || ...
                        strcmpi(char(Option), 'whole') || ...
                        strcmpi(char(Option), 'nat'));
    end
    if ~check_option; Option = 'num'; end

    result = isvector(input);
    try
        for idx = 1:length(input)
            if strcmpi(Option, 'num')
                result = result && isnum(input(idx));
            elseif strcmpi(Option, 'nat')
                result = result && isnat(input(idx));
            elseif strcmpi(Option, 'whole')
                result = result && iswhole(input(idx));
            else
                result = false;
            end
        end
    catch ME
        result = false;
    end
end

% Checks if a value is a vector pretaining to a specific color
function result = isrgba(input)
    % RGBA values are represented as vectors of 4 elements (numbers)
    result = isvector(input) && numel(input) == 4 && isnumlist(input, 'whole');

    % If this is a vector, check if every element is a whole number no greater than 255 
    if result
        for idx = 1:numel(input)
            if input(idx) > 255; result = false; end
        end
    end
end


function result = isloc(input, Dimensions)
    % Locations are vectors of x and y axes
    result = isvector(input) && numel(input) == 2 && isnumlist(input, 'whole');

    %Check if the values of the x and y axis are within the acceptable value for our screen  
    % [screen_width, screen_height] = Screen('WindowSize', Screen_Number);
    if result
        result = input(1)<Dimensions(1) && input(2)<Dimensions(2);
    end
end