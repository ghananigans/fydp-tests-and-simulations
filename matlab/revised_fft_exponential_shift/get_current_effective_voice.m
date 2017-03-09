function [ ret ] = get_current_effective_voice( i, av, obs, eff )
%return the effective voice at time/sample i
%   args: 
    %i is the current time/sample, scalar
    %av is the antivoicem, column vector
    %eff is the effective voice, column vector

    ret = obs(i) - av(i);

end

