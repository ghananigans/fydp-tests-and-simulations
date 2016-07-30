
%About simulation
%idealness used: 
%LPF, no equalization, effect of sound
%attenuation over 5cms-ish, microphone/speaker non-idealness in sensitivity,
%the effect of speaker output entering back into microphone


%First read in the input audio file into a vector of all the samples
%this vector will have all the samples of the audio file
%http://www.mathworks.com/help/matlab/ref/audioread.html?requestedDomain=www.mathworks.com

[oV, Fs] = audioread('Testing_123-left-channel.wav');
oVnumsamples = length(oV);

%WAV is 2 channel, convert it into 1 for analysis
oVsingle = oV(:,1);
oVsinglenumsamples = length(oVsingle);
t = linspace(0, oVsinglenumsamples/Fs, oVsinglenumsamples);
figure;
plot(t, oVsingle);

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
ovFiltered = filtfilt(lpFilt, oVsingle);

%Base case: create an antivoice signal which is the direct inversion of the
%signal we have produced
%store this antivoice in a second vector (and also output to a new wavefile
%called anti-voice

ovNegative = -1.* ovFiltered;
ovNegativenumsamples = length(ovNegative);
t = linspace(0, ovNegativenumsamples/Fs, ovNegativenumsamples);
%figure; 
%plot(t, ovNegative);

%Generate a resultant signal combining voice samples and antivoice samples
result = oVsingle + ovNegative;

resultsamples = length(result);
t = linspace(0, resultsamples/Fs, resultsamples);
figure; 
plot(t, result);

