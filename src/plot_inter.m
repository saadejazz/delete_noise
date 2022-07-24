function plot_inter(f_clustering, titl, num_sub_plot, num_plots)
% PLOT_INTER: plots the clustering at intermediate (and also final) steps
% 
% Inputs:
%   f_clustering    : the clustering to plot  
%   titl            : the title of the plot  
%   num_sub_plot    : the index of the current subplot
%   num_plots       : the total number of plots
%

    subplot(num_plots, 1, num_sub_plot);
    plot(f_clustering);
    title(titl);
    xlabel("timestamp");
    ylabel("1 -> useful cluster");
    ylim([0, 1.1]);
    xlim([0, length(f_clustering)]);
end

