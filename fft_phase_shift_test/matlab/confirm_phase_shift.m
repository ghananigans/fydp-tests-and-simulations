% Replace Orig, FFT, and iFFT with values returned from test_phase_shift
% Replace n with value used in test_phase_shift
Orig = []
FFT = []
iFFT = []

n = 64;
Fs = n;
t = 0:(1 / n):0.999999999;

% Original signal
subplot(3, 1, 1);
plot(t, Orig);

% FFT of a signal. This signal may not be exactly the original signal
% though. It could be a hilbert-transformed version of the original signal
% (analytic signal). We may need a hilbert-tranformed version of the
% original signal if the input signal is a real-only signal.
subplot(3, 1, 2);
P2 = abs(FFT/n);
fftt = 0:(Fs/n):(Fs-Fs/n);
plot(fftt, P2);


% This should be the phase shifted signals
% we only care about the real part of the ifft.
subplot(3, 1, 3);
plot(t, real(iFFT));
