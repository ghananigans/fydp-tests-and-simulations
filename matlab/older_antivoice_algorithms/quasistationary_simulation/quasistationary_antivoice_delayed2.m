clear All;

%About simulation
%idealness used: 
%LPF, no equalization, effect of sound
%attenuation over 5cms-ish, microphone/speaker non-idealness in sensitivity,
%the effect of speaker output entering back into microphone


%First read in the input audio file into a vector of all the samples
%this vector will have all the samples of the audio file
%http://www.mathworks.com/help/matlab/ref/audioread.html?requestedDomain=www.mathworks.com

[ov, fs] = audioread('Testing_123-left-channel.wav');

%WAV is 2 channel, convert it into 1 for analysis
ov_single = ov(:,1);
ov_single_num_samples = length(ov_single);
%t = linspace(0, ov_single_num_samples/fs, ov_single_num_samples);
%figure;
%plot(t, ov_single);

%generate 1 kHz test signal

% Time specifications
%fs = 500000;                   % samples per second
%dt = 1/fs;                   % seconds per sample
%StopTime = 5;             % seconds
%t = (0:dt:StopTime-dt)';     % seconds

% Sine wave:
%fc = 1;                     % hertz
%ov = sin(2*pi*fc*t);

%ov_single = ov';
%hold on;
%plot(t,ov_single);

%tshared = t;


%Use LPF to bandlimit signal to 4 kHz
filtertype = 'FIR';
Fpass = 3.5e3;
Fstop = 4.5e3;
Rp = 0.1;
Astop = 80;
FIRLPF = dsp.LowpassFilter('SampleRate',fs,...
                            'FilterType',filtertype,... 
                           'PassbandFrequency',Fpass,...
                             'StopbandFrequency',Fstop,...
                             'PassbandRipple',Rp,...
                             'StopbandAttenuation',Astop);

lpFilt = designfilt('lowpassfir','PassbandFrequency',0.45, ...
         'StopbandFrequency',0.55,'PassbandRipple',0.5, ...
         'StopbandAttenuation',50,'DesignMethod','kaiserwin');
                         

%NOTE: filtfilt makes a HUGE idealization by making the phase difference 0
%and making it an ideal LPF, in practice will have phase delay that is
%frequency dependent when filtering.
ov_filtered = filtfilt(lpFilt, ov_single);
ov_filtered_num_samples = length(ov_filtered);
t = linspace(0, ov_filtered_num_samples/fs, ov_filtered_num_samples);
%figure;
%plot(t, ov_filtered);

hundred_us_num_samples = double(fs) / 10000;
delayinc = round(hundred_us_num_samples);

%delay d is measured in number of samples
for d = 0 : delayinc * 1: 2 * hundred_us_num_samples %go until 0.2 ms delay at increments of about 0.1 ms

    latency = double(d) / fs;  %FUTURE: change latency to frequency specific vector
    
    %Generate anti-signal (180 degrees out of phase)
    ov_negative = zeros(length(ov_filtered),1);
    fftsize = 2048;
    while fftsize < 50000
        fftsize = fftsize * 2; %iterate over different FFT sizes
        for i = 1:fftsize:length(ov_filtered) - fftsize
            time_bins = ov_filtered(i:i+fftsize - 1);
            n = 2^nextpow2(length(time_bins));
            freq_bins = fft(time_bins, n);               %Perform the fft

            %freq_bins_pos = freq_bins(1:length(freq_bins)/2+1);
            freq_pos = 0:double(fs/length(freq_bins)):fs/2; % frequency vector from 0 to the Nyquist

            %plot(freq_pos, freq_bins_pos);

            %https://www.dsprelated.com/showthread/matlab/5198-1.php
            %apply phase shift of 180 degrees to each frequency

            phase = get_latency_adaptive_phase_vector_pos(freq_pos, latency); 
            %phase = pi;
            shifted_bins = abs(freq_bins) .* exp(1i*angle(freq_bins) + 1i * phase); %apply the phase delay

            time_final_bins = ifft(shifted_bins,fftsize);
            ov_negative(i:i+fftsize - 1) = time_final_bins;

        end
        
         %export anti-voice result to file
        audiowrite(sprintf('antivoice-out/antivoice_d%d_f%d.wav', int32(d/hundred_us_num_samples), fftsize), ov_negative, fs);

        %plot(tshared, ov_negative);

        %Generate a resultant signal combining voice samples and antivoice samples
        result = ov_single(1+d:length(ov_single)) + ov_negative(1:length(ov_negative) - d);

        %export resultant signal to file
        audiowrite(sprintf('result-out/result_d%d_f%d.wav', int32(d/hundred_us_num_samples), fftsize),result, fs);
    end
end

avgy = mean(abs(ov_single));
avgyi = mean(abs(ov_negative));
avgyr = mean(abs(result));


