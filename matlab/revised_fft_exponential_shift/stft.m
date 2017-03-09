function [stft1] = stft(x,w,wshft,nfft)
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

n = 0; %current time/sample location base within x
r = 1; %row/window number
stft1 = single(zeros(nwin,nfft));
while n+wlen<=length(x)
  s = single(x(n+(1:wlen)).*w);     %apply windowing function to segment of x
  sfft = fft(single(s),nfft); %take fft of segment
  stft1(r,:) = single(sfft);
  n = n+wshft;              %next window start location
  r = r+1;                  %next matrix row
end
end