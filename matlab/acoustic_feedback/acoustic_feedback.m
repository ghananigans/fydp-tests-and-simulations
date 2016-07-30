%resources: https://books.google.ca/books?id=N7QgBQAAQBAJ&pg=PA40&lpg=PA40&dq=fft+dsp+chip+computation+time&source=bl&ots=FYRRHsqchb&sig=5FZtx4Ul9XSOhE1zqcR8rhBfAqI&hl=en&sa=X&ved=0ahUKEwiCvK7rnMzNAhWrx4MKHRGDCkAQ6AEITTAI#v=onepage&q=fft%20dsp%20chip%20computation%20time&f=false
% %http://link.springer.com/chapter/10.1007%2F3-540-45675-9_83#page-1
% http://www.eed.nctu.edu.tw/files/writing/5223_ded84c73.pdf
% http://stackoverflow.com/questions/6663222/doing-fft-in-realtime/8575259#8575259


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

subplot(4,1,1);
plot(t,v);
title('original');

v = hilbert(v); %make analytical signal
subplot(4,1,2);
plot(t,v);
title('hilbert');

%% Step 2: Model antivoice contribution to obs input
%trans_obs signal will have a delay and attenuation relative to voice signal
trans_obs_sep = double(0.02); %meters

av_air_gain = double(0.8); %scalar factor of how much sound attenuates from transducer to obs
av_delay_secs = double(0.000833*4); %total air+internal processing delay in seconds
av_delay_samples = int32(av_delay_secs * fs); %number of samples delayed by

%apply delay and attenuation (air gain)
% trans_obs = zeros(size(y));
% trans_obs(1 + trans_obs_delay_samples: end) = y(1:end - trans_obs_delay_samples); %delay
% trans_obs = trans_obs .* trans_obs_air_gain; %attenuation

av = zeros(length(v));

%TODO: apply antivoice generation algorithm above for correct phase
%calculation


%% Step : Model obs input (voice + antivoice)

obs = zeros(length(v));

%i is the sample number since time = 0
for i = 1 : length(v)
    obs(i) = v(i) + av(i);                  %superposition
    av(i + av_delay_samples) = obs(i);      %TODO: feedback filter and av algorithm
end

%plot av
subplot(4,1,3);
plot(t,av);
latencystr = sprintf('av delayed by %0.6f seconds aka 179 degrees', av_delay_secs);
title(latencystr );

%plot obs
subplot(4,1,4);
plot(t,obs);
title('obs');

% % 
% % 
% % 
% % 
% % windowsize = 64;
% % fftsize = windowsize;
% % wshft = 1; %samples to advance the sliding window by (hop size)
% % 
% % w = ones(windowsize,1); %windowing function (ones work with wshft = 1 only)
% % 
% % stft_matrix = stft(v,w,wshft,fftsize);  %matrix containing all the individual frequency points for all window slides
% %                                     %to optimize to use actual sliding FFT, and not matrix
% % 
% % freq_pos = 0:fs/fftsize:fs/2; % frequency vector from 0 to the Nyquist
% % latency = double(0.001); %our test value in seconds
% % d = int32(latency * fs); % samples
% %                                     
% % %phase  is a ROW vector with length == number of freq bins
% % [phase] = get_antiphase_vector_pos(freq_pos, latency);
% % 
% % shifted_matrix = zeros(size(stft_matrix));
% % %shift each sample in the matrix by sample_shift amount
% % matrix_size = size(stft_matrix);
% % for r = 1:(matrix_size(1))
% %     Y = stft_matrix(r,:);
% %     shifted_matrix(r,:) = Y.*exp(+1i* (phase)); %plus sign for delay as opposed to advancement
% % end
% % 
% % istft_matrix = zeros(size(shifted_matrix)); %init with zeros
% % 
% % for r = 1 : 1 : size(shifted_matrix, 1)
% %     istft_matrix(r,:) = ifft(shifted_matrix(r,:),fftsize);
% % end
% % 
% % %Since using sliding fft, we output samples from the middle of window
% % %otherwise fourier transform is cyclical and we'll pick up garbage
% % %but this adds its own time domain global latency which needs to be accounted for
% % %by the calibration sw
% % 
% % wcenter = floor(windowsize/2);
% % wstart = wcenter;
% % 
% % yi = zeros(length(v),1);
% % yindex = 0; 
% % 
% % for r = 1: 1 : size(istft_matrix,1)
% %     %reconstruct time domain signal
% %     yi(yindex + 1 : yindex + wshft) = istft_matrix(r,wstart:(wstart-1)+wshft);
% %     yindex = yindex + wshft;
% % end
% % 
% % subplot(4,1,3);
% % plot(t,yi);
% % latencystr = sprintf('yi delayed by %0.6f seconds', latency);
% % title(latencystr );
% % 
% % %below ignores/idealizes the windowing time domain latency
% % y_centered = v(wcenter:length(v) -1);
% % yi_centered = yi(1:length(yi) - wcenter);
% % result = y_centered(1+d:end) + yi_centered(1:end -d); %advance y by d, and leave yi in-place
% % 
% % subplot(4,1,4);
% % plot(t(1:length(result)),result);
% % title('original + yi signal');
% % 
% % %audiowrite('y.wav', (yi),fs);
% % audiowrite('yi.wav', (yi),fs);
% % audiowrite('yr.wav', (result),fs);
% % 
% % %just some statistics on signal level
% % avgy = mean(abs(v));
% % avgyi = mean(abs(yi));
% % avgyr = mean(abs(result));