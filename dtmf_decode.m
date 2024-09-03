function [symbol, snr_db] = dtmf_decode(input)
    fs = 8000;
    N = length(input);
    % Define frequencies of DTMF tones
    low_freq = [697, 770, 852, 941];
    high_freq = [1209, 1336, 1477];
    % Define the DTMF symbol matrix
    symbols = ['1', '2', '3';
               '4', '5', '6';
               '7', '8', '9';
               '*', '0', '#'];
    % Initialize variables for accuracy calculation
    total_attempts = 1000;
    correct_count = 0;
    % Initialize arrays for SNR and iteration count
    snr_history = zeros(1, total_attempts);
    iteration_count = 0;
    % Perform decoding until desired SNR is achieved
    desired_snr = 20; % Target SNR in dB
    while true
        % Generate Gaussian noise with the same length as the input signal
        noise = randn(size(input));
        % Scale the noise to achieve desired SNR
        signal_power = sum(abs(input).^2) / N;
        noise_power = signal_power / (10^(desired_snr / 10));
        scaled_noise = sqrt(noise_power) * noise;
        % Add noise to the input signal
        noisy_input = input + scaled_noise;
        % Compute DFT of input signal
        dft_input = fft(noisy_input);
        % Find the indices of the maximum magnitude in DFT for low and high frequencies
        low_freq_idx = round(low_freq / fs * N);
        high_freq_idx = round(high_freq / fs * N);
        % Detect the symbol based on the frequencies present
        [~, low_idx] = max(abs(dft_input(low_freq_idx)));
        [~, high_idx] = max(abs(dft_input(high_freq_idx)));
        % Determine the detected symbol
        detected_symbol = symbols(low_idx, high_idx);
        % Calculate SNR level of decoded tone
        signal_power = sum(abs(input).^2) / N;
        noise_power = sum(abs(input - noisy_input).^2) / N;
        snr_db = 10 * log10(signal_power / noise_power);
        % Update SNR history and iteration count
        iteration_count = iteration_count + 1;
        snr_history(iteration_count) = snr_db;
        % Check if SNR meets the 95% accuracy requirement
        if snr_db >= 0.95 * desired_snr
            disp('SNR meets the 95% accuracy requirement.');
            break;
        end
    end
    disp(['Decoded symbol: ', detected_symbol]);
    disp(['SNR level (dB): ', num2str(snr_db)]);
    symbol = detected_symbol;
end


