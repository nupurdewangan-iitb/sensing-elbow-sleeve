%% MATLAB Real-Time Elbow Tracker (ESP32 / 3.3 V Optimised)

% Setup:
%   32 kΩ Resistor → 3.3 V | Flex Sensor → GND | ADC Pin → D33
%
% Instructions:
%   1. Flash esp32_flex_sensor.ino to the ESP32.
%   2. Close Arduino IDE Serial Monitor (only one app can own the port).
%   3. Update portName below to match your COM port (e.g. "COM3" or "/dev/ttyUSB0").
%   4. Record straightVal and bentVal from the Serial Monitor before running.
%   5. Run this script — the live angle plot will appear.

clear; close all;

portName = "COM9";      % <-- Update to your COM port
baudRate = 115200;

%% --- CALIBRATION VALUES ---
% 1. Open Arduino Serial Monitor first.
% 2. Record the ADC value when elbow is STRAIGHT  --> straightVal
% 3. Record the ADC value when elbow is FULLY BENT --> bentVal
% 4. Close Serial Monitor, then run this script.
straightVal = 1456;   % ADC count at 0° (straight)
bentVal     = 1470;   % ADC count at maxAngle (fully bent)
maxAngle    = 90;     % Maximum expected angle (degrees)

%% --- FILTER SETUP ---
windowSize = 20;
dataBuffer = zeros(1, windowSize);   % Circular buffer for smoothing

%% --- SERIAL CONNECTION ---
try
    s = serialport(portName, baudRate);
    configureTerminator(s, "LF");
    flush(s);
    disp('System Live! Reading from ESP32 Pin D33.');
catch
    error('Cannot open %s. Ensure Arduino Serial Monitor is CLOSED.', portName);
end

%% --- FIGURE SETUP ---
figure('Color', 'w', 'Position', [100, 100, 800, 500]);
hLine = animatedline('Color', [1 0.2 0.2], 'LineWidth', 2);
grid on; grid minor;
ylabel('Elbow Angle (Degrees)');
xlabel('Time (s)');
ylim([-5 110]);
title('Real-Time Elbow Angle | ESP32 D33');

% Angle text annotation
txtDisplay = text(0.5, 100, 'Angle: 0.0 deg', ...
    'FontSize', 24, 'FontWeight', 'bold', 'Color', 'r');

startTime = datetime('now');

%% --- REAL-TIME LOOP ---
while ishandle(hLine)
    if s.NumBytesAvailable > 0
        raw = str2double(readline(s));

        if ~isnan(raw)
            %% Stage 1: Moving Average Filter (MATLAB-side)
            dataBuffer  = [dataBuffer(2:end), raw];
            smoothedRaw = mean(dataBuffer);

            %% Stage 2: Linear Regression Mapping (ADC → degrees)
            currentAngle = ((smoothedRaw - straightVal) / ...
                            (bentVal    - straightVal)) * maxAngle;

            %% Stage 3: Angle Clamping  [0°, maxAngle]
            currentAngle = max(0, min(maxAngle, currentAngle));

            t = seconds(datetime('now') - startTime);

            %% Stage 4: Update Live Plot
            addpoints(hLine, t, currentAngle);

            % Slide text label with the time axis
            set(txtDisplay, 'String', ...
                sprintf('Angle: %.1f deg', currentAngle), ...
                'Position', [max(0, t-9.5), 100, 0]);

            % Debug info in title
            title(['ESP32 D33 | Raw: ', num2str(raw, '%.0f'), ...
                   ' | Smooth: ', num2str(smoothedRaw, '%.1f')]);

            % Rolling 10-second x-axis window
            xlim([t-10, t+1]);
            drawnow limitrate;
        end
    end
end
