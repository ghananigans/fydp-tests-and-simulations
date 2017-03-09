function [ adj_phase ] = get_antiphase_vector_pos( freq, latency )
    %latency is passed in as seconds, vector in production code
    %freq is a ROW vector representing each frequency bin in hz, positve
        %and includes zero
    %adj_phase is in radians, and is a ROW vector for phase of:
        %0 | positive | (fs/2 freq) | negative reversed
    
    if latency > 0
        period = 1 ./ freq; %seconds
        periods_elapsed = latency ./ period; %this is the number of periods source is ahead of antisignal
        periods_floor_diff = periods_elapsed - floor(periods_elapsed); %number between 0 and 1
        
        %since source signal is ahead of antisignal by latency seconds, 
            %0.5 PLUS as opposed to minus is used
            %Equivalent to 1 - mod(0.5 - periods_floor_diff,1)
        shift_correction_factor = mod(0.5 + periods_floor_diff, 1); %keep positive number between 0 and 1
        out_phase_correction = shift_correction_factor*2*pi;
        out_phase_correction_needed = out_phase_correction(2:length(out_phase_correction)); %we want to leave out the zero frequency
        out_phase_correction_needed_flipped = fliplr(out_phase_correction_needed(1:length(out_phase_correction_needed)-1)); %omit fs/2 frequency in reversed

        %fft results bin in the form: 0 Hz | positivefrequencies | fs/2 frequency| negative frequencies in reverse order
        adj_phase = cat(2, zeros(1), out_phase_correction_needed, out_phase_correction_needed_flipped);
    else
        adj_phase = pi;
    end
end