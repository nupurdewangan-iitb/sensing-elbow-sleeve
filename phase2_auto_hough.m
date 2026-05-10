%% Phase 2 – Automated Hough-Transform Angle Detection in MATLAB

% Instructions:
%   1. Place your elbow image (e.g. A1.png) in the same folder as this script.
%      The sleeve should have a visible cyan/colored marking along the arm segments.
%   2. Run the script — no manual clicks required.
%   3. Acute and obtuse angles are overlaid on the detected line segments.

% 1. Read and Isolate Cyan channel (sleeve color marker)
img = imread('A1.png');
I = double(img);
cyan_only = (I(:,:,2) + I(:,:,3)) - 1.5 * I(:,:,1);

% 2. Clean & Binarise
binary_map = bwareaopen(rescale(cyan_only) > 0.45, 30);

% 3. Hough Transform to detect two dominant line segments
[H, T, R] = hough(binary_map);
peaks = houghpeaks(H, 2, 'Threshold', 0.2*max(H(:)));
lines = houghlines(binary_map, T, R, peaks, ...
    'FillGap', 80, 'MinLength', 30);
if length(lines) < 2
    error('Could not find both lines. Adjust threshold or image.');
end

% 4. Direction vectors of the two detected lines
v1 = lines(1).point2 - lines(1).point1;
v2 = lines(2).point2 - lines(2).point1;

% 5. Angle Calculation via dot product
cosTheta = dot(v1, v2) / (norm(v1) * norm(v2));
angle1 = acosd(min(max(cosTheta, -1), 1));   % degrees

% Standardise to Acute vs Obtuse pair
acute_angle  = min(angle1, 180 - angle1);
obtuse_angle = 180 - acute_angle;

% 6. Find Intersection Point (for label placement)
p1 = lines(1).point1;  p3 = lines(2).point1;
A  = [v1', -v2'];
b  = (p3 - p1)';
t  = A \ b;
intersect_pt = p1 + t(1) * v1;

% 7. Visualisation
figure; imshow(img); hold on;
for k = 1:2
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'LineWidth', 4, 'Color', 'yellow');
end
plot(intersect_pt(1), intersect_pt(2), 'gx', ...
    'MarkerSize', 15, 'LineWidth', 2);
text(intersect_pt(1)+10, intersect_pt(2)-20, ...
    sprintf('Acute: %.2f deg', acute_angle), ...
    'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold');
text(intersect_pt(1)+10, intersect_pt(2)+20, ...
    sprintf('Obtuse: %.2f deg', obtuse_angle), ...
    'Color', 'cyan', 'FontSize', 12, 'FontWeight', 'bold');
title(['Geometry Analysis: ', ...
    num2str(acute_angle, '%.2f'), ' deg and ', ...
    num2str(obtuse_angle, '%.2f'), ' deg']);
fprintf('Acute Angle:  %.4f deg\n', acute_angle);
fprintf('Obtuse Angle: %.4f deg\n', obtuse_angle);
