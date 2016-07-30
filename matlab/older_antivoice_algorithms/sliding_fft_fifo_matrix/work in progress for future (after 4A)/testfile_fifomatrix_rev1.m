clear All;
%this file status:
    
    
%fifo matrix potential optimizations:
    %when filling the fifo matrix, can iterate over positive and negative
        %frequency bins at the same time since their w_index would be the same
        %also leeads to memory savings
    %Rather than modulus 2*pi (360*), can do in terms of 180 and thereafter
        %multiply the frequency bin by -1.  Cuts matrix memory in half.
    


% Time specifications
fs = 2000;                   % samples per second for constructing the sine wave
dt = 1/fs;                   % seconds per sample
StopTime = 5;             % seconds
t = (0:dt:StopTime-dt)';     % seconds

%ov is original voice
% Sine wave:
fc = 60;                     % hertz
ov = cos(2*pi*fc*t)';
subplot(4,1,1);
plot(t(1:end/fc),ov(1:end/fc));
title('ov');
hold on;


fftsize = 4096;

minfreq = 50; %Hertz
maxfreq = 100; %Hertz

gd_precision = 2; %higher factor means more matrix columns and DAC rate, more precision on frequency specific delay (group delay)
latency = 0; %our test value in seconds

t = (0: dt/gd_precision : StopTime-dt/gd_precision)';     % seconds
d = int32(latency * fs * gd_precision);

%resample for gd_precision matrix scaling
%ov_resampled is gd_precision factor larger than ov
ov_resampled = resample(ov, fs * gd_precision, fs);
subplot(4,1,2);
plot(t(1:end/fc), ov_resampled(1:end/fc));
title('ov_resampled');

%w is an integer representing the number of columns in the fifo matrix
% each column is spaced logically apart in time by t_shift_granularity
%until it reaches the lowest freq's period
    %w = ceil( (fs / maxfreq * gd_precision) * (maxfreq / minfreq) );
        % maxfreq cancels
w = ceil( fs * gd_precision / minfreq );

%create a matrix with fftsize rows, and w columns
fifomatrix = zeros(fftsize, w);


freq_pos = 0:fs/fftsize:fs/2; % frequency vector from 0 to the Nyquist

%time_shift is a column vector with length == number of freq bins
[freq_range, time_shift] = get_fifo_time_shift_vector_pos(freq_pos, latency);

%w_indexes determines which column a given frequency's data point should be
    %placed in so that it obtains the correct amount of time shift
    %map the time in seconds to the nearest column of w columns
    %each index represents Tminfreq / w seconds == 1 / (minfreq * w))
    %must: time_shift * minfreq less than or equal 1, w_indexes <= w
w_indexes = int32(time_shift * (minfreq * w));

ov_shifted = zeros(fftsize, 1);
ov_negative = zeros(length(ov_resampled),1);
 
for i = 1 : fftsize : length(ov_resampled) - fftsize
    
    %rows are frequencies (or freq bins)
    %column calculation = a time shift of 0 would be column 1
        %a time shift equal to period of lowest freq would be column w
        %first column is transmitted first.  
        %New packets arrive at back of matrix and shifted towards the front
        %Packets are sent gd_precision more often than arrived,
            %thus uses last known value if values unchanged
    
    ov_fft = fft(ov_resampled( i : i+fftsize - 1 ), fftsize);
    
    bin_num = 0;
    for bin = freq_range %bin is essentially the freq (center frequency of that bin)
        bin_num = bin_num + 1;
        %w_indexes accepts bin as index into it to determine column number
        if abs(bin) > minfreq
            fifomatrix(bin_num,1+min(floor(w_indexes(bin_num)),w)) = ov_fft(bin_num); %place data points in correct location in  matrix
        else
            fifomatrix(bin_num,1+0) = ov_fft(bin_num); %place data points in correct location in  matrix
        end
    end
    
    column_with_zeros = fifomatrix(:,1);
        
    %copy over values which are non-zero
    for k = 1 : 1 : fftsize
        if column_with_zeros(k) ~= 0
            ov_shifted(k) = column_with_zeros(k);
        end
    end
    ov_ifft = ifft(ov_shifted, fftsize); %convert current packet to time domain
    ov_negative(i : i+ (fftsize - 1)) = ov_ifft;
    
    %shift matrix towards front before new packet arrives into queue 
    fifomatrix(:,1:w - 1) = fifomatrix(:,1 + 1:w);
end

subplot(4,1,3);
plot(t(1:end/fc), ov_negative(1:end/fc));
title('ov_negative');

result = ov_resampled(1:end - d) + ov_negative(1 + d: end);

subplot(4,1,4);
plot(t(1:end/fc), result(1:end/fc));
title('result');

hold off;