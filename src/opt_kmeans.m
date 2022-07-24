function f_clustering = opt_kmeans(S, num_iters)
% OPT_KMEANS Returns optimum K-means clustering by choosing the least loss
% over multiple iterations. Also sets the smaller (useful) cluster as 1,
% number of clusters fixed to 2
% 
% Inputs:
%   S           : result of the spectrogram (short-time FT)
%   num_iters   : number of times the K-means clustering is run
%
% Outputs:
%   f_clustering: Final clustering with 0 and 1 representing noise and
%                 useful signal respectively. 
    
    least_loss = -1;                            % store least loss after each run
    f_clustering = zeros([size(S, 2), 1]);      % store the clustering results
    
    disp("Starting K-means Clustering...");

    for i = 1: num_iters
        if mod(i, 10) == 1, disp("Iterations ran: " + num2str(i - 1)), end
        [clustering, ~, loss] = kmeans(abs(S'), 2);
        if (loss <= least_loss) | (least_loss == -1)
            f_clustering = clustering;
            least_loss = loss;
        end
    end

    % determine which of the cluster is the useful part
    % this is done knowing that only a small portion of the signal is useful
    len_of_clusters = zeros([2, 1]);
    len_of_clusters(1) = sum(f_clustering(f_clustering == 1));
    len_of_clusters(2) = sum(f_clustering(f_clustering == 2));
    [~, useful_cluster] = min(len_of_clusters);

    % setting the useful cluster index to 1 for simplicity in further code
    % and reproducability in graph plots
    f_clustering = f_clustering == useful_cluster;
end

