
%About simulation
%idealness used: 
%LPF, no equalization, effect of sound
%attenuation over 5cms-ish, microphone/speaker non-idealness in sensitivity,
%the effect of speaker output entering back into microphone


%First read in the input audio file into a vector of all the samples
%this vector will have all the samples of the audio file
%http://www.mathworks.com/help/matlab/ref/audioread.html?requestedDomain=www.mathworks.com

[ov, Fs] = audioread('Testing_123-left-channel.wav');

%WAV is 2 channel, convert it into 1 for analysis
ov_single = ov(:,1);
ov_single_num_samples = length(ov_single);
t = linspace(0, ov_single_num_samples/Fs, ov_single_num_samples);
%figure;
%plot(t, ov_single);

%Use LPF to bandlimit signal to 4 kHz
filtertype = 'FIR';
Fpass = 3.5e3;
Fstop = 4.5e3;
Rp = 0.1;
Astop = 80;
FIRLPF = dsp.LowpassFilter('SampleRate',Fs,...
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
t = linspace(0, ov_filtered_num_samples/Fs, ov_filtered_num_samples);
figure;
plot(t, ov_filtered);

%Generate anti-signal (180 degrees out of phase)
ov_negative = zeros(length(ov_filtered),1);
fftsize = 31;
for i = 1:fftsize:length(ov_filtered)
    time_bins = ov_filtered(i:i+fftsize - 1);
    n = 2^nextpow2(length(time_bins));
    freq_bins = fft(time_bins, n);               %Perform the fft

    %https://www.dsprelated.com/showthread/matlab/5198-1.php
    %apply phase shift of 180 degrees to each frequency
    phase = pi; 
    shifted_bins = freq_bins * exp((complex(0,phase )));
    
    time_final_bins = ifft(shifted_bins,fftsize);
    ov_negative(i:i+fftsize - 1) = time_final_bins;
end

%Generate a resultant signal combining voice samples and antivoice samples
result = ov_single + ov_negative;

%plot result
result_num_samples = length(result);
t = linspace(0, result_num_samples/Fs, result_num_samples);
figure; 
plot(t, result);

%export anti-voice result to file
audiowrite('antivoice-out/antivoice0.wav', ov_negative, Fs);

%export resultant signal to file
audiowrite('result-out/result0.wav', result, Fs)
