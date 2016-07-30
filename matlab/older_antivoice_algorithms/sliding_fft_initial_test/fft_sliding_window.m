%resources: https://books.google.ca/books?id=N7QgBQAAQBAJ&pg=PA40&lpg=PA40&dq=fft+dsp+chip+computation+time&source=bl&ots=FYRRHsqchb&sig=5FZtx4Ul9XSOhE1zqcR8rhBfAqI&hl=en&sa=X&ved=0ahUKEwiCvK7rnMzNAhWrx4MKHRGDCkAQ6AEITTAI#v=onepage&q=fft%20dsp%20chip%20computation%20time&f=false
% %http://link.springer.com/chapter/10.1007%2F3-540-45675-9_83#page-1
% http://www.eed.nctu.edu.tw/files/writing/5223_ded84c73.pdf

clear All;

% Time specifications
fc = 60;                     % hertz
fs = fc * 100;                   % samples per second for constructing the sine wave
dt = 1/fs;                   % seconds per sample
StopTime = 2 * 8 / fc;             % seconds
t = (0:dt:StopTime-dt);     % seconds

%ov is original voice
% Sine wave:

%generate compound test signal
% y = 0;
% for i = 300: 1 : 300 %300 Hz only right now
%     y = y + cos(2*pi*fc*i*t);
% end

y = cos(2*pi*fc*t)';
%y = y';

%[y, fs] = audioread('y.wav');
%y = y(:,1);
%info = audioinfo('y.wav');
%t = 0:seconds(1/fs):seconds(info.Duration);
%t = t(1:end-1);

subplot(4,1,1);
plot(t,y);
title('original');

y = hilbert(y); %make analytical signal
subplot(4,1,2);
plot(t,y);
title('hilbert');


%samples_for_cycle = fs / fc; %unit is samples taken to complete one wavecycle
%d = int32(0.34 * samples_for_cycle); %unit is samples
%latency = double(d) / fs; %seconds

windowsize = 64;
fftsize = 64;
wshft = 1; %samples to advance the sliding window by

w = ones(windowsize,1); %windowing function
%w = hamming(windowsize);

stft_matrix = mystft(y,w,wshft,fftsize);  %matrix containing all the individual frequency points for all window slides
                                    %to optimize to use actual sliding FFT, and not matrix

stft_matrix_original = stft(y,w,wshft,fftsize);  
                                    
istft_matrix = zeros(size(stft_matrix)); %init with zeros

for r = 1 : 1 : size(stft_matrix, 1)
    istft_matrix(r,:) = ifft(stft_matrix(r,:),fftsize);
end


wcenter = floor(windowsize/2);
wstart = wcenter;
if wshft > 1
    wstart = floor(wcenter - wshft / 2);
end

yi = zeros(length(y),1);
yindex = 0; 

for r = 1: 1 : size(istft_matrix,1)
    %reconstruct time domain signal
    yi(yindex + 1 : yindex + wshft) = istft_matrix(r,wstart:(wstart-1)+wshft);
    yindex = yindex + wshft;
end



subplot(4,1,3);
plot(t,yi);
title('yi');

%add latency to the anti-voice relative to the input signal, and mix
%result = y(1+d:length(y)) + yi(1:length(yi) - d);
result = y(wcenter:length(y) -1) - yi(1:length(yi) - wcenter);

subplot(4,1,4);
plot(t(1:length(result)),result);
title('difference signal');

%plot(t, y, 'r');
%hold off;

audiowrite('yi.wav', (yi),fs);
audiowrite('yr.wav', (result),fs);

avgy = mean(abs(y));
avgyi = mean(abs(yi));
avgyr = mean(abs(result));