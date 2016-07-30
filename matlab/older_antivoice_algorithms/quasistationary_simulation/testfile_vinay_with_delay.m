clear All;

% Time specifications
fs = 10000;                   % samples per second for constructing the sine wave
dt = 1/fs;                   % seconds per sample
StopTime = 2;             % seconds
t = (0:dt:StopTime-dt);     % seconds

%ov is original voice
% Sine wave:
fc = 60;                     % hertz

%generate compound test signal
% y = 0;
% for i = 300: 1 : 300 %300 Hz only right now
%     y = y + cos(2*pi*fc*i*t);
% end

y = cos(2*pi*fc*t)';
%y = y';

%[y, fs] = audioread('y.wav');


subplot(4,1,1);
plot(t,y);
title('original');

y = hilbert(y); %make analytical signal
subplot(4,1,2);
plot(t,y);
title('hilbert');


samples_for_cycle = fs / fc; %unit is samples taken to complete one wavecycle
d = int32(0.34 * samples_for_cycle); %unit is samples
latency = double(d) / fs; %seconds

Y = fft(y);

freq_pos = 0:fs/length(Y):fs/2; % frequency vector from 0 to the Nyquist
phase = get_latency_adaptive_phase_vector_pos(freq_pos, latency); 
%phase = 303 / 360 * 2 * pi;

Y = abs(Y).*exp(1i*angle(Y)+1i* (phase));
yi = ifft(Y);

subplot(4,1,3);
plot(t,yi);
title('yi');

%add latency to the anti-voice relative to the input signal, and mix
%result = y(1+d:length(y)) + yi(1:length(yi) - d);
result = y(1:length(y) -d) + yi(1 + d:length(yi));

subplot(4,1,4);
plot(t(1:length(result)),result);
title('result');

%plot(t, y, 'r');
%hold off;

audiowrite('y.wav', (y),fs);
audiowrite('yi.wav', (yi),fs);
audiowrite('yr.wav', (result),fs);

avgy = mean(abs(y));
avgyi = mean(abs(yi));
avgyr = mean(abs(result));