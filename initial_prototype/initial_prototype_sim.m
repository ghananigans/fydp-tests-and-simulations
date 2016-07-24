%
% NAME:        initial_prototype_sim
%
% DESCRIPTION: Runs a simulation for the intial prototype of FYDP Project,
%              CommBlocker (reduce ambient noise at source).
%
% PARAMETERS:
%   window_size (unsigned int)
%     - Number of samples that will be fft-ed.
%
% RETURNS:
%   N/A
%
function [] = initial_prototype_sim( window_size, window_step_size )
    sampling_frequency = 8192; % Hz.
    signal_time_length = 1; % seconds.
    
    % <signal_time_length> * <sampling_frequency> samples.
    x = 0:( 1 / sampling_frequency ):( signal_time_length - ( 1 / sampling_frequency ) );
    input_signal = cos( 1 * 2 * pi * x) + cos( 5 * 2 * pi * x ); % 1 kHz signal
    [ input_signal, audio_file_fs ] = audioread( 'Testing_123.wav' );
    input_signal = resample( input_signal, sampling_frequency, audio_file_fs );
    input_signal = hilbert(input_signal);
    input_signal = input_signal( 1:( signal_time_length * sampling_frequency ) );
    
    subplot(4, 1, 1);
    plot( x, input_signal );
    
    %ffted_signal = fft( input_signal( oldest_sample_index:newest_sample_index ) );
    %P2 = abs( ffted_signal / window_size );
    %P1 = P2( 1:( window_size / 2 + 1 ) );
    %P1( 2:( end - 1 ) ) = 2 * P1( 2:( end - 1 ) );
    %f = sampling_frequency * ( 0:( window_size / 2 ) ) / window_size;
    %subplot(2, 1, 2);
    %plot( f, P1 );
    
    % Initialize output signal.
    output_signal = zeros( 1, length( input_signal ) );
    
    subplot(4,1,2);
    
    % For each sample after the first <window_size>.
    for oldest_sample_index = 1:window_step_size:( length( input_signal ) - window_size + 1 )
        newest_sample_index = oldest_sample_index + window_size - 1;
        
        ffted_signal = fft( input_signal( oldest_sample_index:newest_sample_index ) );
        shifted_signal = ffted_signal .* exp( 1i .* ( - pi ) );
        iffted_signal = ifft( shifted_signal );
        
        output_signal( oldest_sample_index:( oldest_sample_index + window_step_size - 1 ) ) = iffted_signal( 1:window_step_size );
    end
    
    subplot(4, 1, 3);
    plot(x, output_signal);
    
    subplot(4, 1, 4)
    plot(x, input_signal + output_signal);
    
    sound(real(output_signal));
end

