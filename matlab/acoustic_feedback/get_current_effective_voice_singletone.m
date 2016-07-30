function [ ret, OBS_buf, AV_buf ] = get_current_effective_voice_singletone( i, av, obs, eff, av_delay_samples, OBS_buf, AV_buf, fftsize)
%return the effective voice at time/sample i
%   args: 
    %i is the current time/sample, scalar
    %av is the antivoice, column vector
    %eff is the effective voice, column vector
    %av_delay_samples is number of samples eff is delayed relative to obs
    ret = 0;
        
    %ret = obs(i - av_delay_samples) - av(i - av_delay_samples);
    %in reality, want to keep the fft versions in memory for the last
    %few samples to avoid recomputing it
    wstart = i - fftsize + 1;
    wend = i;

    if wstart > 0 && wend < length(obs)
        if av_delay_samples > 0 %then past history buffering is valid
            OBS = fft(obs(wstart :wend), fftsize); %fft tail at [i - av_delay_samples]
            AV = fft(av(wstart:wend), fftsize);
            EFF = OBS_buf(:,1) - AV_buf(:,1);            %obs(i - av_delay_samples) - av(i - av_delay_samples);  
            eff_i = ifft(EFF, fftsize);
            ret = eff_i(1);

            %Update matrix with most recent
            OBS_buf(:,1:end - 1) = OBS_buf(:,2:end);
            OBS_buf(:,end) = OBS;    
            AV_buf(:,1:end - 1) = AV_buf(:,2:end);
            AV_buf(:,end) = AV;
        else
            ret = obs(i) - av(i);
        end
    else
        ret = 0;
    end
end

