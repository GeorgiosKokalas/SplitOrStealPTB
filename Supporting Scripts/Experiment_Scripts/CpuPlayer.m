classdef CpuPlayer < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Behavior_Mode   % Mode of Behavior, each mode interprets and reacts to the player's actions differently    
        Cooperation     % How likely the cpu is to cooperate with the player overall

        % Personality Profile
        Guilt           % How guilty the cpu may feel at its choices
        Trust           % How much the cpu trusts the player (may not be needed based on Mode)

        % Knowledge Base
        Choice_Hist    % History of cpu's choices (True -> good for player, False -> bad for player)
    end

    methods
        % Constructor
        function obj = CpuPlayer(behavior_mode,cooperation,guilt, trust)
            if ~exist("behavior_mode", "var"); behavior_mode = 1; end
            if ~exist("cooperation","var"); cooperation = 100; end
            if ~exist("benevolence", "var"); guilt = 0; end
            if ~exist("trust", "var"); trust = 100; end
            
            obj.Behavior_Mode = behavior_mode;
            obj.Cooperation = cooperation;
            obj.Guilt = guilt;
            obj.Trust = trust;
            obj.Choice_Hist = [];
        end
        
        % Method that changes the behavior of the cpu based on the
        % participant's prior choices.
        function changeBehavior(obj, player_nice)
            if ~islogical(player_nice) || ~isscalar(player_nice)
                error("Wrong value for player choice")
            end

            switch obj.Behavior_Mode
                case 1
                    % No action is taken
                case 2 % Random Player
                    % No action is taken
            end
        end

        % Method that gives the cpu's responce
        function will_cooperate = getResponce(obj)
            switch obj.Behavior_Mode
                % cases 1-9 are for the Prisoner's Dilema experiment
                case 1
                    will_cooperate = rand*100 > 35;
                case 2
                    will_cooperate = rand*100 > 50;
            end
            obj.Choice_Hist(end+1) = will_cooperate;
        end
    end
end