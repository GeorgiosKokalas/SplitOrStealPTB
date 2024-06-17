% Function called by: RunTrial.m
% Role of function is to detect collisions between entities
% Parameters: 
%   - player (data from the player)
%   - targets (data from the targets)
% Return Values: 
%   - player_target_collision (vector of logicals - shows if and
%       with which targets the player has collided)

function [player_target_collision, cooperated] = DetectCollision(player, targets, target_radius)
    cooperated = -1;
    player_target_collision = false;

    % Detect if player has collided with each of the targets
    for target_idx=1:length(targets)
         % The screen is like a grid. thus I use the Pythagorean Theorem to get the distance between the 2 centers  
        p_t_dist = sqrt((player.pos(1) - targets(target_idx).Coords(1))^2 + ...
                        (player.pos(2) - targets(target_idx).Coords(2))^2);
        player_target_collision = p_t_dist <= (player.radius + target_radius);

        if player_target_collision
            cooperated = double(targets(target_idx).Value);
            return;
        end
    end
end

