function [ adj_phase ] = get_latency_adaptive_phase_vector_pos( freq_pos, latency )
    %latency is passed in as seconds
    %frequencies is a vector representing each frequency bin in hz, positve
    %and not including zero
    %adj_phase is in radians, and is a vector for phase of:
        %0 | positive | (fs/2 freq) | negative reversed
    
    %Using 340 because sound travels at 340 meters per second
    
    if latency > 0
        wavelengths = 340 ./ freq_pos;
        wavecycles_elapsed = 340 * latency ./ wavelengths;
        wavecycles_floor_diff = wavecycles_elapsed - floor(wavecycles_elapsed);
        phase_relative_to_origin = wavecycles_floor_diff * 2 * pi;
        out_phase_correction = mod(pi - phase_relative_to_origin, 2 * pi); %ensure positive
        out_phase_correction_needed = out_phase_correction(2:length(out_phase_correction)); %we want to leave out the zero frequency
        out_phase_correction_needed_flipped = fliplr(out_phase_correction_needed(1:length(out_phase_correction_needed)-1)); %omit fs/2 frequency in reversed

        %fft results bin in the form: 0 Hz | positivefrequencies | fs/2 frequency| negative frequencies in reverse order
        adj_phase = cat(2, zeros(1), out_phase_correction_needed, out_phase_correction_needed_flipped);
        adj_phase = adj_phase';
    else
        adj_phase = pi;
    end
end