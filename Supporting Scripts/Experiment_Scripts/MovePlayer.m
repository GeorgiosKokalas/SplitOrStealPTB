% Function called by:
%   - Introduction.m
%   - RunTrial.m
% Role of function is to introduce the participant to the experiment
% Parameters: 
%   - Start_Pos (position before movement)
%   - Speed (the Speed multiplier of the player)
%   - Radius (the Radius of the player)
%   - Win_Dims (the dimensions of the window in which the experiment takes place)
% Return Values: 
%   - end_pos (vector of 2 | position after movement)
%   - player_rect (vector of 4 | used by Screen to draw the player)

function [end_pos, player_rect] = MovePlayer(Start_Pos, Speed, Radius, Win_Dims, Limits)
    if ~exist("Limits", "var")
        Limits = [0, Win_Dims(1);
                  0, Win_Dims(2)];
    end
    
    joystick = GetXBox().LMovement;
    
    % Calculate the new Position based on the previous one and the joystick movement
    % end_pos, Start_Pos and joystick are vectors of 2
    end_pos = floor(Start_Pos + joystick*Speed);
    
    % Check if the player is going out of bounds
    for idx = 1:numel(end_pos)
        out_of_bounds = end_pos(idx) < Limits(idx,1) + Radius || ...
            end_pos(idx) > Limits(idx,2) - Radius;
        if out_of_bounds
            end_pos(idx) = Start_Pos(idx);
        end
    end
    
    % Calculate the values Screen needs to draw the player
    player_rect = [end_pos(1) - Radius, end_pos(2) - Radius, ...
        end_pos(1) + Radius, end_pos(2) + Radius];
end

