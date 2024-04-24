% Clear command window, workspace, and close all figures
clc; 
clear;
close all;

% Load the selected file
[file, path] = uigetfile('*.*', 'Select the ECG file');
load(fullfile(path, file));
disp('File loaded successfully');
disp(file);

% Sampling frequency
Fs = 250;

% Normalize the signal , co. of variation
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
ylabel('strength');
title('ECG Frequency');



% Filter Features
orden = 200;
Fp1 = 1.2;   % Lower passband frequency
Fp2 = 49;  % Upper passband frequency

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
[peaks_squared, locations] = findpeaks(ecg_squared, 'MinPeakHeight', 4,'MinPeakDistance', 0.2 * Fs);


%irregular heart rhythm by checking the standard deviation of R-R intervals (higher deviation suggests irregularity).
rr_intervals = diff(peaks_squared);
rr_intervals_std = std(rr_intervals);


% Convert peak locations to time values
peak_times_squared = locations / Fs;

% Plot ECG signal with R peaks
figure;
plot(t, ecg_squared);
xlim([0 4])
hold on;
plot(peak_times_squared, peaks_squared, 'r*', 'MarkerSize', 6);
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
if  (heartt > 100) 
    disp('ECG signal has tachycardia (fast heart rate)');
    msg = sprintf('ECG signal has tachycardia (fast heart rate). \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');
elseif (heartt < 60)
    
    disp('ECG signal has bradycardia (slow heart rate)');
    msg = sprintf('ECG signal has bradycardia (slow heart rate) \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');

elseif  (heartt < 100) || (heartt > 60)
   disp('ECG signal is normal');
    msg = sprintf('ECG signal is normal \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');


elseif (rr_intervals_std > 0.2 * mean(rr_intervals)) 
    disp('ECG signal is irrigular');
    msg = sprintf('ECG signal is irrigular \nHeart rate: %s beats per minute', heart_rate_str);
    msgbox(msg, 'ECG', 'modal');
end




