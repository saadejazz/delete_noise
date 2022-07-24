function plotspec(num_clusters, S, T, F, clustering)
% PLOTSPEC plots the spectrogram in different colours depending on the
% index of the cluster
%
% Inputs:
%   num_clusters          : the number of clusters in the data
%   S                     : result of the spectrogram (short-time FT)
%   T                     : vector of times
%   F                     : vector of frequecies
%   clustering            : the clustering to plot 
%   useful_cluster        : which cluster index is the useful one

    colors = ["red", "blue"];
    figure;
    for i = 1: num_clusters
        s = S;
        for j = 1: length(clustering)
            if clustering(j) ~= i
                s(:, j) = 0;
            end 
        end
        surf(T, F, 20 * log10(abs(s)), 'FaceAlpha', 1, ...
            'EdgeColor', colors(i));
        view(45,45)
        hold on
    end
    title("Clustering: Useful (Blue)")
    legend(["Discarded Signal", "Useful Signal"], "Location", "northwest");
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    zlabel('Magnitude (dB)');
    hold off
end