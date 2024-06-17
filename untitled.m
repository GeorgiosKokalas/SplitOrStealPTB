% tic
% for i = 1:10000
%     GetXBox().LMovement;
% end
% toc
% 
% tic
% for i = 1:10000
%     jst();
% end
% toc
% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
[window, windowRect] = Screen('OpenWindow', 2, [128 128 128]); % Set background to gray

% Enable alpha blending
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Load the PNG image with transparency
[image, ~, alpha] = imread('Split_icon2.png');

% Combine the RGB image with the alpha channel
image(:,:,4) = alpha;

% Make the texture
texture = Screen('MakeTexture', window, image);

% Get the size of the image
[s1, s2, ~] = size(image);

% Define the destination rectangle (position it without centering)
dstRect = [100, 100, 100 + s2, 100 + s1]; % Adjust (100, 100) to the desired top-left position

% Draw the texture to the window
Screen('DrawTexture', window, texture);

% Show the result
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Close screen
Screen('CloseAll');