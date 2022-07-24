close all

% This code will show three plots: 
% 1. Spectrogram of provided noisy signal
% 2. Plots of the clustering at intermediate and final steps. If Jaccard involved
%    the plots will also include the ground truth
% 3. The color coded spectrogram of the useful and useless signal
% 
% The useful signal output is sotred in useful_audios with a similar name to the
% input file. The input file should be place in annotated_audios folder, while
% the ground truth (determining useful signal manually) should be a binary vector 
% in the format .mat with the same basename as the input file put in the folder 
% annotated_audios. 
%
% The output may be kept the same length as the input (preserve_length = 1), 
% or different (preserve_length = 0, meaning only the useful part will be kept, 
% the rest will be trimmed.
% To measure performance (Jaccard Index), it is necessary to provide the ground
% truth in the annotated_audios folder, and also to set the variable as
% follows: measure_performance = 1
%
% To change parameters affecting performance, head over to the "Parameters
% Section" which is a few lines (about 40) ahead.

% set to 1 if a ground truth signal available in folder: annotated
measure_performance = 1;

% specify whether the output audio file should be of the same length as the
% input file, for same length, the noisy part would just be 0.
% 1 to keep input and output lengths the same, 0 for vice versa
preserve_length = 1;

% specify which noisy audio file to use, they are in the folder: "noisy_audios"
audio_file = "glas-11025-fixed.wav";
% audio_file = "vaccum_cleaner_plus_bottle_throwing.wav";
file_name = audio_file.split(".");
file_name = file_name(1);

% check if measuring performance is possible, if so update number of plots
num_plots = 4;
if measure_performance == 1
    file_check = "annotated_audios/" + file_name + ".mat";
    if ~isfile(file_check)
        disp("To enable measurement of performance via Jaccard Index, " + ...
            "provide the following ground truth file: " + file_check);
        return
    end
    num_plots = 5;
end

% get data from the sound file - mono sound expected
[X, fs] = audioread("noisy_audios/" + audio_file);  % read the file
X = X(:, 1);                                        % first channel (in case of stereo)
N = length(X);                                      % signal length

% Parameters Section
% parameters affecting performance of the clustering and the postprocessing
window_size = 128;                   % window size for the spectrogram
overlap_ratio = 0.70;               % overlap for windowing (* with window size)
num_clust_iters = 70;               % number of iterations of k-means
merge_threshold = 1.50;             % threshold (% timestamps) below which infiltrating 
                                    % useless clusters are merged with useful part
weeding_threshold = 0.20;           % threshold (% timestamps) below which useful 
                                    % part of the signal is removed (weeded out)
smoothing_extension = 2.50;         % percent timestamps to include on each side
                                    % of the useful cluster pulses
parabolic_center = 0.25;            % a value (0<v<1) that determines the shape of the
                                    % smoothing, higher value -> higher weightage 
                                    % given in general to the smoothing region
amp_thresh = 0.50;                  % amplitude scale below which signal is ignored
                                    % while calculating Jacardian

% computing the spectrogram
disp("Creating a spectrogram");
overlap = ceil(overlap_ratio * window_size);
[S, F, T] = spectrogram(X, window_size, overlap, [], fs, 'yaxis');

% plot the spectrogram
figure;
spectrogram(X, window_size, overlap, [], fs, 'yaxis');
grid on
xlabel('Time (s)');
ylabel('Frequency (Hz)');
h = colorbar;
ylabel(h, 'Magnitude (dB)');
title(['Spectrogram of the signal (Window size: ' num2str(window_size) ')']);
view(45, 45);
hold off

t_after_window = size(S, 2);        % num of ts after windowing
data = zeros([t_after_window, 4]);  % stores intermediate post-processing results

% perform K-means multiple times and choose the clustering with least loss
% set the index of useful cluster to 1, number of clusters fixed to 2
f_clustering = opt_kmeans(S, num_clust_iters);

% plot the result just after clustering
figure;
data(:, 1) = f_clustering;
Title = "Initial Clustering";
plot_inter(f_clustering, Title, 1, num_plots);

% now merge very small portions of useless signal to useful ones
% useless signal portions smaller than a threshold are merged into useful
disp("Started post-processing of clustering results");
f_clustering = ign_useless_sig(f_clustering, merge_threshold);

% plot the result after the first proceesing step
data(:, 2) = f_clustering;
Title = "Clustering after removing infiltrating useless signals";
plot_inter(f_clustering, Title, 2, num_plots);

% now remove very small portions of useful signal if they exist
f_clustering = weeding(f_clustering, weeding_threshold);

data(:, 3) = f_clustering;
Title = "Clustering after removing very small portions of useful signal";
plot_inter(f_clustering, Title, 3, num_plots);

% smoothing and de-windowing to prevent the output from just being
% impulses, the whole period of the actual useful signal should be included
[trimmed_signal, amp_scaling] = smooth_dewindowing(X, f_clustering, ...
                                smoothing_extension, parabolic_center, ...
                                preserve_length);

% plot the trimmed signal
Title = "Amplitude scaling after smoothing around boundaries of useful cluster";
plot_inter(amp_scaling, Title, 4, num_plots);
disp("Finished post-processing of clustering");

% converting useful cluster to audio
file_out = "useful_audios/" + file_name + "_useful.wav";
disp("Writing to an audio file: " + file_out);
audiowrite(file_out, trimmed_signal, fs);

% measure performance using the Jaccard Index
if measure_performance == 1   
    true_data = load("annotated_audios/" + file_name + ".mat");
    true_data = true_data.dataset;
    amplitudes = double(amp_scaling > amp_thresh);
    
    % plot ground truth
    Title = "Ground Truth";
    plot_inter(true_data, Title, 5, num_plots);
    
    % compute Jaccard Index of similarity b/w ground truth and results
    j = jaccard(true_data, amplitudes);
    disp("Jaccard Index: " + num2str(j));
end

disp("Plotting intermediate and final results along with the spectrogram");
plotspec(2, S, T, F, data(:, 3) + 1);