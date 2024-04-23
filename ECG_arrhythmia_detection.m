% Clear command window, workspace, and close all figures
clc; 
clear; 
close all;

% Open a dialog box to select a file
[file, path] = uigetfile('*.*', 'Select the ECG file');

% Load the selected file
load(fullfile(path, file));
disp('File loaded successfully');
disp(file);

% Sampling frequency
Fs = 250;

% Normalize the signal
val = (val - mean(val))/std(val);
t = (1:1:length(val))*(1/Fs);

% Plot ECG in time domain
figure;
plot(t, val)
xlim([0 4])
xlabel('time (s)')
ylabel('amplitude (mV)')
title('ECG in Time Domain')

%% FFT
F = fft(val);
F = abs(F);
F = F(1:ceil(end/2));
F = F/max(F);
L = length(F);
f = (1:1:L)*((Fs/2)/L);

% Plot ECG Frequency
figure;
plot(f, F)
xlabel('Frequency (Hz)');
ylabel('strength');val
title('ECG Frequency');

% Filter FIR
% Filter Features
orden = 200;
Fp1 = 2;   % Lower passband frequency
Fp2 = 45;  % Upper passband frequency

% Normalize frequencies
Fp1_n = Fp1 / (Fs / 2);
Fp2_n = Fp2 / (Fs / 2);

% Create bandpass filter
a = 1;
b = fir1(orden, [Fp1_n, Fp2_n], 'bandpass');

% Filter Signal
filterated_ecg = filtfilt(b, a, val);

% Plot original and filtered ECG in time domain
figure;
subplot(2,2,1);
plot(t, val);
xlim([0 4])
xlabel('time (s)')
ylabel('amplitude (mV)')
title('Original ECG signal')

subplot(2,2,3);
plot(t, filterated_ecg);
xlim([0 4])
xlabel('time (s)')
ylabel('amplitude (mV)')
title('FIR filtered ECG signal')

% Plot original and filtered ECG in HZ
F = fft(val);
F = abs(F);
F = F(1:ceil(end/2));
F = F/max(F);

subplot(2,2,2);
plot(f, F)
xlabel('Frequency (Hz)');
ylabel('strength');
title('Original ECG in HZ');

F = fft(filterated_ecg);
F = abs(F);
F = F(1:ceil(end/2));
F = F/max(F);

subplot(2,2,4);
plot(f, F)
xlabel('Frequency (Hz)');
ylabel('strength');
title('Filtered ECG in HZ');

%% Square the ECG signal
filterated_ecg_abs = abs(filterated_ecg);
ecg_squared = filterated_ecg_abs.^2;

figure;
plot(t, filterated_ecg_abs);
xlim([0 4])
xlabel('time (s)');
ylabel('amplitude (mV^2)');
title('absolute ECG');


% Find R peaks using the findpeaks function
[peaks_squared, locations_squared] = findpeaks(ecg_squared, 'MinPeakHeight', 10,'MinPeakDistance', 0.2 * Fs);

% Convert peak locations to time values
peak_times_squared = locations_squared / Fs;

% Plot ECG signal with R peaks
figure;
plot(t, ecg_squared);
xlim([0 4])
hold on;
plot(peak_times_squared, peaks_squared, 'r*', 'MarkerSize', 8);
xlim([0 4])
xlabel('time (s)');
ylabel('amplitude (mV^2)');
title('Squared ECG with R Peaks');
legend('Squared ECG', 'R Peaks');

% Calculate the number of peaks
num_peaks = length(peaks_squared);

% Calculate the duration of the ECG signal in minutes
duration_minutes = length(val) / (Fs*60);

% Calculate the heart rate (number of peaks per minute)
heart_rate = num_peaks / duration_minutes;
heartt = round(heart_rate);
heart_rate_str = num2str(heartt);

% Display the heart rate
disp(['Heart Rate: ', heart_rate_str, ' beats per minute']);

% Check for arrhythmia
if  (heartt > 100) || (heartt < 60)
    disp('ECG signal has arrhythmia.');
    msg = sprintf('ECG signal has arrhythmia. \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');
else
    disp('ECG signal does not have arrhythmia.');
    msg = sprintf('ECG signal does not have arrhythmia. \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');
end




