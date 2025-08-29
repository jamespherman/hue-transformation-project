% --- HUE EXPANSION SCRIPT ---
%
% This script takes a narrow band of hues from an input image and expands
% them across the entire hue spectrum. Other pixels are desaturated.

% close open windows and clear workspace
clear; close all;

% 1. LOAD THE IMAGE AND CONVERT TO HSV
% ======================================
try
    originalRGB = imread('your_endoscopic_image.jpg'); % Change to your image file
catch
    disp('Cannot find image file. Using a sample image instead.');
    originalRGB = imread('peppers.png'); % A good sample image with lots of red
end

originalHSV = rgb2hsv(originalRGB);

% Separate the H, S, V channels for easier manipulation
H = originalHSV(:,:,1);
S = originalHSV(:,:,2);
V = originalHSV(:,:,3);

% 2. DEFINE THE TARGET HUE RANGE AND OTHER THRESHOLDS
% ====================================================
% These are the "knobs" you'd want in a GUI for Dr. Snyderman.

% --- Define the Red Range (wraps around 0/1) ---
% Hues are 0-1. Red is at the beginning and end of this range.
hue_center = 0; % 0 corresponds to red
hue_width = 0.1; % We'll capture hues +/- 0.1 from the center

% --- Define minimum saturation/value to be considered ---
% This avoids amplifying noise in near-black or near-white areas.
saturation_threshold = 0.2;
value_threshold = 0.2;

% 3. CREATE THE LOGICAL MASK
% ============================
% Find all pixels that are "red enough" and not too dark/pale.

% Handle the hue wrap-around for red
lower_bound = mod(hue_center - hue_width + 1, 1);
upper_bound = mod(hue_center + hue_width, 1);

if lower_bound > upper_bound
    % This means the range crosses the 0/1 boundary (e.g., 0.9 to 0.1)
    mask = (H >= lower_bound | H <= upper_bound) & ...
           (S >= saturation_threshold) & ...
           (V >= value_threshold);
else
    % This means the range is contiguous (e.g., 0.4 to 0.6 for green)
    mask = (H >= lower_bound & H <= upper_bound) & ...
           (S >= saturation_threshold) & ...
           (V >= value_threshold);
end


% 4. PROCESS THE PIXELS
% =====================
% Create new H and S channels to hold the modified data
H_new = H;
S_new = S;

% --- A) Handle the pixels OUTSIDE the mask ---
% Desaturate them by setting their saturation to 0.
S_new(~mask) = 0;

% --- B) Handle the pixels INSIDE the mask ---
% Get the hue values of only the target pixels
target_hues = H(mask);

% Remap the hues to expand them across the full 0-1 range.
% This is the core of the "stretching" operation.
% We first need to "unwrap" the hues if they cross the 0 boundary.
if lower_bound > upper_bound
    target_hues(target_hues > 0.5) = target_hues(target_hues > 0.5) - 1;
    min_hue = lower_bound - 1;
    max_hue = upper_bound;
else
    min_hue = lower_bound;
    max_hue = upper_bound;
end

% Perform the linear expansion
expanded_hues = (target_hues - min_hue) / (max_hue - min_hue);
expanded_hues = mod(expanded_hues + 0.5, 1); % <-- ADD THIS LINE

% Place the newly expanded hues back into our new Hue channel
H_new(mask) = expanded_hues;


% 5. RECOMBINE CHANNELS AND CONVERT BACK TO RGB
% ===============================================
processedHSV = cat(3, H_new, S_new, V);
processedRGB = hsv2rgb(processedHSV);


% 6. DISPLAY THE RESULTS
% ======================
fig = figure('Color', [1 1 1], 'Position', [600 600 1024 384]);
ax1 = subplot(1, 2, 1);
imshow(originalRGB);
title('Original Image');

ax2 = subplot(1, 2, 2);
imshow(processedRGB);
title('Processed: Red Hues Expanded');

% adjust axes properties:
ax1.Position = [0.01 0.01 0.4800 0.95];
ax2.Position = [0.51 0.01 0.4800 0.95];