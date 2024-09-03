function [output] = TouchToneDialler(digits, SNR_dB, Fs)
    % Define touch tone frequencies
    tones = [697, 1209;   % Frequencies for digit 1
             697, 1336;   % Frequencies for digit 2
             697, 1477;   % Frequencies for digit 3
             770, 1209;   % Frequencies for digit 4
             770, 1336;   % Frequencies for digit 5
             770, 1477;   % Frequencies for digit 6
             852, 1209;   % Frequencies for digit 7
             852, 1336;   % Frequencies for digit 8
             852, 1477;   % Frequencies for digit 9
             941, 1209;   % Frequencies for digit *A
             941, 1336;   % Frequencies for digit 0
             941, 1477];  % Frequencies for digit #
    % Duration parameters
    min_tone_duration = 0.1; % seconds
    max_tone_duration = 0.2; % seconds
    min_gap_duration = 0.05; % seconds
    % Validate input parameters
    if ~ischar(digits)
        error('Input digits must be a character array.');
    end
    if ~isscalar(SNR_dB) || ~isnumeric(SNR_dB) || SNR_dB < 0
        error('SNR_dB must be a non-negative scalar.');
    end
    if ~isscalar(Fs) || ~isnumeric(Fs) || Fs <= 0
        error('Sampling frequency (Fs) must be a positive scalar.');
    end
    % Generate tones and gaps
    output = [];
    for i = 1:length(digits)
        digit = digits(i);
        if digit == '*'
            digit_index = 10;
        elseif digit == '#'
            digit_index = 12;
        elseif digit == '0'
            digit_index = 11;
        else
            digit_index = str2double(digit);
        end
        % Check if the digit is within the valid range
        if digit_index < 1 || digit_index > 12
            error('Invalid digit: %s', digit);
        end
        % Get frequencies for the digit
        frequency_pair = tones(digit_index, :);
        % Generate tone for the digit
        tone_duration = (max_tone_duration - min_tone_duration) * rand + min_tone_duration;
        t = 0:1/Fs:tone_duration;
        tone = sin(2*pi*frequency_pair(1)*t) + sin(2*pi*frequency_pair(2)*t);
        % Calculate noise power
        tone_power = sum(tone.^2) / length(tone);
        noise_power = 10^(-SNR_dB/10) * tone_power;
        % Generate noise
        noise = sqrt(noise_power) * randn(size(tone));
        % Combine tone and noise
        signal = tone + noise;
        % Concatenate signal with gap
        output = [output, signal, zeros(1, round(Fs * min_gap_duration))];
    end
    % Normalize output
    output = output / max(abs(output));
    % Plot the generated sound
    t_total = (0:length(output)-1) / Fs;
    plot(t_total, output);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Generated Sound');
    grid on;
    % Play the sound
    sound(output, Fs);
end



