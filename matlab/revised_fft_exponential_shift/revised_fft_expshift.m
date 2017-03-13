%resources: https://books.google.ca/books?id=N7QgBQAAQBAJ&pg=PA40&lpg=PA40&dq=fft+dsp+chip+computation+time&source=bl&ots=FYRRHsqchb&sig=5FZtx4Ul9XSOhE1zqcR8rhBfAqI&hl=en&sa=X&ved=0ahUKEwiCvK7rnMzNAhWrx4MKHRGDCkAQ6AEITTAI#v=onepage&q=fft%20dsp%20chip%20computation%20time&f=false
% %http://link.springer.com/chapter/10.1007%2F3-540-45675-9_83#page-1
% http://www.eed.nctu.edu.tw/files/writing/5223_ded84c73.pdf
% http://stackoverflow.com/questions/6663222/doing-fft-in-realtime/8575259#8575259


clear All;

% Time specifications
fc = 300;                     % hertz
fs = 8000;                % samples per second for constructing the sine wave
dt = 1/fs;                   % seconds per sample
StopTime = 2 * 8 / fc;       % seconds
t = (0:dt:StopTime-dt);     % seconds

%compound signal generation
y = cos(2*pi*fc*t) + cos(2*pi*(fc*2)*t)+ cos(2*pi*(fc*3)*t);
y = y';

% [y, fs] = audioread('two.wav');
% y = y(:,1);
% info = audioinfo('two.wav');
% y=resample(y,8000,fs); %resample so that fs=8000
% fs = 8000;
% t = 0:seconds(1/fs):seconds(info.Duration);
t = t(1:length(y));


subplot(4,1,1);
plot(t,y);
title('original');

y = hilbert(y); %make analytical signal
subplot(4,1,2);
plot(t,y);
title('hilbert');

y = single(y);

windowsize = 256;
fftsize = windowsize;
SLIDE_BY_1 = 1; %samples to advance the sliding window by (hop size)

w = ones(windowsize,1); %windowing function (ones work with SLIDE_BY_1 = 1 only)

stft_matrix = stft(y,w,SLIDE_BY_1,fftsize);  %matrix containing all the individual frequency points for all window slides

freq_pos = 0:fs/fftsize:fs/2; % frequency vector from 0 to the Nyquist

wcenter = 26; %calculated to be the sample offset for taking output samples
wlatency = (wcenter +1)/ fs; %in seconds
alatency = 0.001;
air_latency = single(alatency);
total_latency = single(wlatency + alatency);
%latency = single(0.001); %our test value in seconds
d = int32(air_latency * fs); % samples
                                    
%phase  is a ROW vector with length == number of freq bins
[phase] = get_antiphase_vector_pos(freq_pos, total_latency);

shifted_matrix = single(zeros(size(stft_matrix)));
%shift each sample in the matrix by phase amount
matrix_size = size(stft_matrix);
% each iteration of this loop represents the elapse of 1 sample (1/8000th
% second)
for r = 1:(matrix_size(1))
    Y = stft_matrix(r,:); %Y is FFT of the current audio data at hand
    shifted_matrix(r,:) = Y.*exp(+1i* (phase)); %negative sign for moving yi to the left wrt y
end

%STUB: shifted_matrix contains the frequency domain data that it ready
%for ifft at each sample interval
%We place that into isft_matrix for convenience, but in C code
%we will not have a matrix and just send it to DAC for output
istft_matrix = single(zeros(size(shifted_matrix))); %init with zeros
for r = 1 : 1 : size(shifted_matrix, 1)
    istft_matrix(r,:) = ifft(shifted_matrix(r,:),fftsize);
end

%Since using sliding fft, we output samples from the middle of window
%otherwise fourier transform is cyclical and we'll pick up garbage
%but this adds its own time domain global latency which needs to be accounted for
%by the calibration sw



yi = single(zeros(length(y),1));
yindex = 1; 
for r = 1: 1 : size(istft_matrix,1)
    %reconstruct time domain signal using those precomputed in istft_matrix
    yi(yindex) = istft_matrix(r,wcenter+1);
    yindex = yindex + SLIDE_BY_1;
end

subplot(4,1,3);
plot(t,yi);
latencystr = sprintf('yi delayed by %0.6f seconds', latency);
title(latencystr );

result = y(1+d:end) + yi(1:end -d);

subplot(4,1,4);
plot(t(1:length(result)),result);
title('original + yi signal');

%audiowrite('y.wav', (yi),fs);
audiowrite('yi.wav', (yi),fs);
audiowrite('yr.wav', (result),fs);

%just some statistics on signal level
avgy = mean(abs(y));
avgyi = mean(abs(yi));
avgyr = mean(abs(result));