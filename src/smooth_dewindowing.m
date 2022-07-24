function [trimmed_signal, amp_scaling] = smooth_dewindowing(orig_sig, clustering, ...
                                       smoothing_extension, parabolic_center, ...
                                       preserve_length)
% SMOOTH_DDEWINDOWING smoothes the transition between useful and useless
% parts while de-windowing to the original signal
% 
% Inputs:
%   orig_signal         : the signal that was windowed originally
%   clustering          : the clustering to perform the process on
%   smoothing_extension : percentage timestamps to extend on each side of 
%                         the useful pulse
%   parabolic_center    : the central y-coordinate for the parabola in the
%                         polyfit
%   preserve_length     : specifies whether the output should be trimmed or
%                         kept the same length as the orig_sig
%
% Outputs:
%   trimmed_signal      : useful part of the original signal
%   amp_scaling         : the amplitude scaling for each timestamp
    
    N = length(orig_sig);                   % length of original signal
    len = length(clustering);               % length of the clustering

    % repeating elements in the cluster to regain the same size as the
    % original signal
    rem = mod(N, len);
    repeat = floor(N/len);
    r = repmat(clustering, 1, repeat)';
    r = [reshape(r, [N - rem, 1]); zeros([rem, 1])];
    r = double(r);
    
    % determing the location and size of useful pulse widths
    [p_widths, starts, finishes] = pulsewidth(r);
    starts = ceil(starts);
    finishes = floor(finishes);
    
    for i = 1: length(p_widths)
        
        % determining the extension to each side, even number to ease calc
        extension = ceil(N * smoothing_extension/100);
        if mod(extension, 2) ~= 0
            extension = extension + 1;
        end
        
        % fitting a quadratic polynomial
        x = [0, extension/2, extension];
        
        % for the left of the pulse
        y = [0, parabolic_center, 1];
        p = polyfit(x, y, 2);

        % for colliding smoothing zones
        prev = 0;
        if i > 1
            prev = finishes(i - 1);
        end

        if starts(i) - extension < 1
            r(1: starts(i) - 1) = polyval(p, extension - starts(i) + 1 : extension - 1);
        else
            if starts(i) - extension/2 <= prev + extension/2
                r(starts(i) - extension/2: starts(i) - 1) = polyval(p, extension/2: extension - 1);
            else
                r(starts(i) - extension: starts(i) - 1) = polyval(p, 0: extension - 1);
        
            end  
        end

        % for the right of the pulse
        y = [1, parabolic_center, 0];
        p = polyfit(x, y, 2);
        
        if finishes(i) + extension > N
            r(finishes(i) + 1: N) = polyval(p, 0: N - finishes(i) - 1);
        else
            r(finishes(i) + 1: finishes(i) + extension) = polyval(p, 0: extension - 1);
        end
    end
    
    % forcing the pulses to be 1 - sanity check
    for i = 1: length(p_widths)
        r(starts(i): finishes(i)) = 1;
    end

    % multiplying resulting amplitude scales and
    % extracting the useful part
    amp_scaling = r;
    trimmed_signal = orig_sig .* amp_scaling;

    % output type
    if preserve_length == 0
        trimmed_signal = trimmed_signal(r ~= 0);
    end
end

