%% Phase 1 – Manual 3-Point Angle Measurement in MATLAB

%
% Instructions:
%   1. Place your elbow image (e.g. A1.png) in the same folder as this script.
%   2. Run the script.
%   3. Click 3 points: End1 (upper arm), Vertex (elbow), End2 (forearm).
%   4. The computed angle is displayed on the image and printed to the console.

% 1. Read and display the image
img = imread('A1.png');
imshow(img);
title('Click 3 points: End 1, then Vertex (Corner), then End 2');
hold on;

% 2. Get user input
[x, y] = ginput(3);

% Plot the clicked points to verify placement
plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
line(x, y, 'Color', 'red', 'LineWidth', 1.5);

% 3. Define Points (P2 must be the vertex/corner)
P1 = [x(1), y(1)];
P2 = [x(2), y(2)];
P3 = [x(3), y(3)];

% 4. Vector math for high accuracy
v1 = P1 - P2;
v2 = P3 - P2;

% Calculate angle using atan2 for numerical stability
% Formula: theta = atan2(||v1 x v2||, v1.v2)
angle_rad = atan2(abs(v1(1)*v2(2) - v1(2)*v2(1)), dot(v1, v2));
angle_deg = rad2deg(angle_rad);

% 5. Display result on image and in command window
text(P2(1), P2(2)-10, sprintf('%.2f deg', angle_deg), ...
    'Color', 'yellow', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('The measured angle is: %.4f degrees\n', angle_deg);
