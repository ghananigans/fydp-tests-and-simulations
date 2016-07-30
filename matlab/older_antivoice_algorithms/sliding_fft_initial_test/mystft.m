function [stft1] = mystft(x,w,wshft,nfft)
% args:
    %x: input data signal (column vector)
    %w: windowing function vector (column vector)
    %wshft: the number of samples to shift the window/signal by
        %wshft of 1 means mostly overlap, sliding window
    %nfft: number of fft points
    
% returns short term fourier transform of entire input x in variable stft1
    %returns sft1 as matrix
    %suboptimal to fft sliding since no previous window re-use, works.
        %rows are the progression of time, nwin many
        %columns: each row is filled by the fft of that particular windowed segment of x

    
wlen = length(w);

nwin = fix((length(x)-wlen+wshft)/wshft);   %number of windows to complete x
                                            %fix is the same as floor()
%http://link.springer.com/chapter/10.1007%2F3-540-45675-9_83#page-1

n = 0; %current time/sample location base within x
r = 1; %row/window number within matrix
stft1 = zeros(nwin,nfft);

%do first segment using FFT
s = x(n+(1:wlen)).*w;     %apply windowing function to segment of x
stft1(r,:) = fft(s,nfft); %take fft of segment
n = n+wshft;              %next window start location
r = r+1;                  %next matrix row

%perform recursive optimal implementation for remain rows
while n+wlen<=length(x)
  s = x(n+(1:wlen)).*w;     %apply windowing function to segment of x
  
  for k = 1:nfft %iterate over all frequency bins
      E = exp((1i*2*pi*k)/nfft);
      stft1(r,k) = E * (stft1(r-1,k) + s(end) - s(1));
  end
  
  n = n+wshft;              %next window start location
  r = r+1;                  %next matrix row
end


%function [ x ] = myistft( input_args )
%returns a vector containing the inverse short time fourier transform
%   


%end
