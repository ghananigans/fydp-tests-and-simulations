clear All;

%% Step 1: Generate voice signal (as seen by MCU)
% Time specifications
fc = 300;                     % hertz
fs = 8000;                % samples per second for constructing the sine wave
dt = 1/fs;                   % seconds per sample
StopTime = 2 * 8 / fc;       % seconds
t = (0:dt:StopTime-dt);     % seconds

%test signal generation
v = cos(2*pi*fc*t);
v = v';

% [y, fs] = audioread('two.wav');
% y = y(:,1);
% info = audioinfo('two.wav');
% y=resample(y,8000,fs); %resample so that fs=8000
% fs = 8000;
% t = 0:seconds(1/fs):seconds(info.Duration);
% t = t(1:length(y));

subplot(5,1,1);
plot(t,v);
title('original');

v = hilbert(v); %make analytical signal
subplot(5,1,2);
plot(t,v);
title('hilbert');

%% Step 2: Model antivoice contribution to obs input
%trans_obs signal will have a delay and attenuation relative to voice signal
trans_obs_sep = double(0.02); %meters

av_air_gain = double(0.8); %scalar factor of how much sound attenuates from transducer to obs
av_delay_secs = double(0.00333 /6); %total air+internal processing delay in seconds
av_delay_samples = int32(av_delay_secs * fs); %number of samples delayed by

%apply delay and attenuation (air gain)
% trans_obs = zeros(size(y));
% trans_obs(1 + trans_obs_delay_samples: end) = y(1:end - trans_obs_delay_samples); %delay
% trans_obs = trans_obs .* trans_obs_air_gain; %attenuation
eff = zeros(size(v));
av = zeros(size(v));

%TODO: apply antivoice generation algorithm above for correct phase
%calculation


%% Step : Model obs input (voice + antivoice)

obs = zeros(size(v));

%How to generate effective voice signal
    %Want eff(i) to be equal to v(i)
    %therefore eff(i)=v(i) = obs(i) - av(i)

%i is the sample number since start of time
for i = 1: length(v)
    v(i) = v(i);                            %just for future causality
    if i - av_delay_samples > 0
        eff(i) =  obs(i - av_delay_samples) - av(i - av_delay_samples);
    else
        eff(i) = 0;
    end
    av(i) = eff(i) * av_air_gain;  
    obs(i) = v(i) + av(i);                  %superposition
end

%plot eff
subplot(5,1,3);
plot(t,eff);
title('eff');

%plot av
subplot(5,1,4);
plot(t,av);
latencystr = sprintf('av delayed by %0.6f seconds', av_delay_secs);
title(latencystr );

%plot obs
subplot(5,1,5);
plot(t,obs);
title('obs');