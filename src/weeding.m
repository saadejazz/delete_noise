function f_clustering = weeding(clustering, weeding_threshold)
% WEEDING removes very small parts of the signal assigned to the useful
% cluster
%
% Inputs:
%   clustering          : the clustering to perform process on
%   weeding_threshold   : threshold below which useful part is removed, is
%                         expressed in percentage
%
% Outputs:
%   f_clustering        : the clustering to be returned after weeding

    len = length(clustering);   % length of the clustering
    len_use = 0;                % counter to determine width of each useful part
        
    % weeding threshold in timestamps
    use_thresh = round(weeding_threshold/100 * len);
        
    % perform the weeding process
    for i = 1: len
        if clustering(i) == 1
            len_use = len_use + 1;
        else
            if len_use <= use_thresh & len_use ~= 0
                % the removal
                clustering(i - len_use: i - 1) = clustering(i);
            end
            len_use = 0;
        end
    end

    % final clustering
    f_clustering = clustering;

end

