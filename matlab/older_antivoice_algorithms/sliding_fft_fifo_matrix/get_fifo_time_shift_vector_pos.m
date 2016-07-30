function [ freq_range, time_shift ] = get_fifo_time_shift_vector_pos( freq, latency )
    %latency is passed in as seconds
    %freq_pos is a vector representing each frequency bin in hz,
        %non-negative
    %time_shift is in seconds representing group delay, and is a vector for phase with form of:
        %0 | positive | (fs/2 freq) | negative reversed
    %freq_range is the range of frequencies of the same form as time_shift
        %0 | positive | (fs/2 freq) | negative reversed

    
    period = 1 ./ freq; %seconds
    periods_elapsed = latency ./ period; 
    periods_floor_diff = periods_elapsed - floor(periods_elapsed); %number between 0 and 1
    
    shift_correction_factor = mod(0.5 - periods_floor_diff, 1); %keep positive number between 0 and 1
    shift_correction_time = shift_correction_factor .* period; %seconds

    %shift needed to be 180 degrees out of phase with source signal
    shift_correction_needed = shift_correction_time(2:length(shift_correction_time));
    shift_correction_needed_flipped = fliplr(shift_correction_needed(1:length(shift_correction_needed)-1)); %omit fs/2 frequency in reversed

    %fft results bin in the form: 0 Hz | positivefrequencies | fs/2 frequency| negative frequencies in reverse order
    time_shift = cat(2, zeros(1), shift_correction_needed, shift_correction_needed_flipped);
    time_shift = time_shift';
    
    freq_pos = freq(2:length(freq));
    freq_pos_flipped = fliplr(freq_pos(1:length(freq_pos)-1)); %omit fs/2 frequency in reversed
    freq_range = cat(2, zeros(1), freq_pos, freq_pos_flipped);
    freq_range = freq_range';    
    
end