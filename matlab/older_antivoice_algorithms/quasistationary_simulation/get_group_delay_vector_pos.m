function [ time_shift ] = get_group_delay_vector_pos( freq_pos, latency )
    %latency is passed in as seconds
    %frequencies is a vector representing each frequency bin in hz
        %(non-negative)
    %time_shift is in seconds representing group delay itemwise in freq_pos 
    
    period = 1 ./ freq_pos; %seconds
    periods_elapsed = latency ./ period; 
    periods_floor_diff = periods_elapsed - floor(periods_elapsed); %number between 0 and 1
    
    %shift needed to be 180 degrees out of phase with source signal
    shift_correction_factor = mod(0.5 - periods_floor_diff, 1); %keep positive number between 0 and 1
    shift_correction_time = shift_correction_factor .* period; %seconds
    
    time_shift = shift_correction_time';
end