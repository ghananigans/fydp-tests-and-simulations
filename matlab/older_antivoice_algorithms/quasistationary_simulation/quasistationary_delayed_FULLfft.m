clear All;

%About simulation
%idealness used: 
%LPF, no equalization, effect of sound
%attenuation over 5cms-ish, microphone/speaker non-idealness in sensitivity,
%the effect of speaker output entering back into microphone


%First read in the input audio file into a vector of all the samples
%this vector will have all the samples of the audio file
%http://www.mathworks.com/help/matlab/ref/audioread.html?requestedDomain=www.mathworks.com

%NOTICE: in this simulation, when a delay of 0.5seconds is applied,
    %the first 0.5 seconds is played at the end of the anti-voice
    %therefore matlab uses a circular buffer whose tail output
    %should be discarded when choosing FFT sizes
    


%WAV is 2 channel, convert it into 1 for analysis
[ov, fs] = audioread('Testing_123-left-channel.wav');
ov_single = ov(:,1);

%hilbert transform so that can manipulate phase in frequency domain
ov_single = hilbert(ov_single);

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

hundred_us_num_samples = double(fs) / 10000; %approximately gets number of samples in 100 us
delayinc = round(hundred_us_num_samples);   %amount to increment d by

%delay d is measured in number of samples
for d = 0 : delayinc * 1: 100 * hundred_us_num_samples %go every 10ms until 1000 ms (only works with fullfft)
    latency = double(d) / fs;  %FUTURE: change latency to frequency specific vector to account filtering delays
     
    freq_bins = fft(ov_filtered);               %Perform the fft
    freq_pos = 0:double(fs/length(freq_bins)):fs/2; % frequency vector from 0 to the Nyquist

    phase = get_latency_adaptive_phase_vector_pos(freq_pos, latency); 
    shifted_bins = abs(freq_bins) .* exp(1i*angle(freq_bins) + 1i *(phase)); %apply the phase delay

    ov_negative = ifft(shifted_bins);

    %export anti-voice result to file
    audiowrite(sprintf('antivoice-out/antivoice_d%.9f.wav', latency), ov_negative, fs);

    %Generate a resultant signal combining voice samples and antivoice samples
    if length(phase) > 0 %check if constant or frequency specific vector
        %MATLAB glitch: the ov_negative that comes out of the ifft is
        %already shifted by the latency amount somehow, but not when a
        %constant is used
        result = ov_single + ov_negative; %TODO, need to model reality of latency for validating quasistationary
    else
        %the phase value is a scalar, hence good for checking inverter only configuration
        result = ov_single(1:length(ov_single) -d) + ov_negative(1 + d:length(ov_negative));
    end
    
    %export resultant signal to file
    audiowrite(sprintf('result-out/result_latencyd%.9f.wav', latency),result, fs);

end

%just for fun: checking average signal values to get an estimate of how good the cancellation is
avgy = mean(abs(ov_single));
avgyi = mean(abs(ov_negative));
avgyr = mean(abs(result));
