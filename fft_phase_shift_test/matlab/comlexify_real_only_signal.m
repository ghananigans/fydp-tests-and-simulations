n = 100;
x = 0:(1/n):1;
a = cos(2*pi*x);
ha = hilbert(a);
hold off;
% Plot original signal
subplot(4,1,1);
plot(x, a);
hold on;

% Plot hilbert-transformed signal
subplot(4,1,2);
plot(x, ha);

% Get fft of original signal and hilbert-tranformed signal
b = fft(a);
hb = fft(ha);

% Attempt a pi/2 phase shift in the freq. domain using the ffts from above
b = abs(b) .* exp(1i * (angle(b) - pi/2));
hb = abs(hb) .* exp(1i * (angle(hb) - pi/2));

% Convert the phase-shifted fft signals to time domain
c = ifft(b);
hc = ifft(hb);

% Plot orignal signal that was attempted to be phase shifted in freq
% domain.
subplot(4,1,3);
plot(x, c);

% Plot hilbert transformed orignal signal that was attempted to be phase
% shifted in freq domain.
subplot(4,1,4);
plot(x, hc);

% This test shows that if we get a hilbert transform of a real-part only
% signal, we can do fft manipulations such as phase shifting.
