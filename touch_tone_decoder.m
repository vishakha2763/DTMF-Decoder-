function [phone_number] = touch_tone_decoder(input)
    fs = 8000;
    L_frame = 0.005 * fs; % the length of window according to the gap between each tone
    % Padding zeros to input signal to make sure it's divisible into frames
    N = length(input);
    x = [input zeros(1, ceil(N/L_frame) * L_frame - N)];
    % Break signal into segments
    input_frame = reshape(x, L_frame, []).';
    % Calculate power of each segment
    power = sum(abs(input_frame).^2, 2);
    % Threshold of power (average power)
    P_threshold = mean(power);
    % Locate the start and end points of the valid signal
    signal_start_point = [];
    signal_end_point = [];
    in_signal = false;
    for ii = 1:length(power)
        if ~in_signal && power(ii) >= P_threshold
            signal_start_point = [signal_start_point, (ii - 1) * L_frame + 1];
            in_signal = true;
        elseif in_signal && power(ii) < P_threshold
            signal_end_point = [signal_end_point, ii * L_frame];
            in_signal = false;
        end
    end
    % If the last segment is part of the signal
    if in_signal
        signal_end_point = [signal_end_point, length(input)];
    end
    % Decode each detected signal segment
    phone_number = '';
    for iii = 1:length(signal_start_point)
        symbol = dtmf_decode(input(signal_start_point(iii):signal_end_point(iii)));
        phone_number = [phone_number, symbol];
    end
end


