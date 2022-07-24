function f_clustering = ign_useless_sig(clustering, threshold)
% IGN_USELESS_SIG: Ignores minor parts of useless signal if they are
% embedded in the useful parts of the signal. In simpler words, remove
% infiltrado useless signal.
%
% Inputs:
%   clustering  : the input clustering to perform this process on
%   threshold   : any useless part of signal with width below this
%                 threshold will be merged with the useful part, expressed
%                 in percentage, later converted to timestamps
%
% Outputs:
%   f_clustering: the clustering returned after completion of the process
%
% Note:
%   the "danger" zone in the proceeding code is the area when an upcoming
%   useless signal may be potentially infiltrating, the boolean danger
%   keeps track of it
    
    danger = false;             % flag to check we are in the danger zone
    num_danger = 0;             % length of infiltrating cluster
    clust_before = clustering;  % history for merge stopping
    
    % threshold in timestamps
    threshold = round(threshold/100 * length(clustering));
    
    % perform the merging in a loop until no more change is detected
    while(true)
        for i = 1: length(clustering)
            if clustering(i) == 1
                if ~danger, danger = true;
                else
                    if num_danger == 0, continue, end
                    
                    % the merge is simply making useless signal useful
                    if num_danger <= threshold
                        clustering(i - num_danger: i - 1) = 1;
                    end

                    danger = false;
                    num_danger = 0;
                end
            else
                if danger
                    num_danger = num_danger + 1;
                    
                    % if useless signal is bigger than threshold,
                    % it does not need to be merged
                    if num_danger > threshold
                        danger = false;
                        num_danger = 0;
                    end
                end
            end
        end
    
        % break if no more change in the clustering
        if isequal(clust_before, clustering), break, end
        clust_before = clustering;
    end

    % the final clustering
    f_clustering = clustering;
end

