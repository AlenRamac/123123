clear all; close all;
load('HASHTABLE.mat');
load('SONGID.mat');

SNR_range = -15:3:15;
clip_lengths = [5, 10, 15];
num_tests = 5; % Povećaj na 10 ili 20 za preciznije grafove (ali traje duže)

results = zeros(length(clip_lengths), length(SNR_range));

for l_idx = 1:length(clip_lengths)
    L = clip_lengths(l_idx);
    for s_idx = 1:length(SNR_range)
        SNR = SNR_range(s_idx);
        correct = 0;
        
        fprintf('Testiranje: Duljina=%ds, SNR=%ddB\n', L, SNR);
        
        for t = 1:num_tests
            [true_id, ~] = extract_random_song(L);
            [clip, fs] = audioread('test.wav');
            clip = corrupt_with_noise(clip, SNR);
            
            % Logika prepoznavanja
            clip_features = make_table(clip, fs);
            matches = [];
            for i = 1:size(clip_features, 1)
                h = compute_hash(clip_features(i,:));
                if h>0 && h<=length(HASHTABLE) && ~isempty(HASHTABLE{h})
                    hits = HASHTABLE{h};
                    % hits(:,3) je t1_song, hits(:,5) je song_id
                    matches = [matches; hits(:, 5), hits(:, 3) - clip_features(i, 3)];
                end
            end
            
            if ~isempty(matches)
                match_data = [matches(:, 1), round(matches(:, 2), 1)];
                [u, ~, idx] = unique(match_data, 'rows');
                counts = histcounts(idx, 1:size(u,1)+1);
                [~, m_idx] = max(counts);
                if u(m_idx, 1) == true_id, correct = correct + 1; end
            end
        end
        results(l_idx, s_idx) = (correct / num_tests) * 100;
    end
end

% Crtanje grafa
figure;
plot(SNR_range, results(1,:), '-ro', 'LineWidth', 1.5); hold on;
plot(SNR_range, results(2,:), '-bs', 'LineWidth', 1.5);
plot(SNR_range, results(3,:), '-g^', 'LineWidth', 1.5);
grid on;
xlabel('SNR [dB]'); ylabel('Točnost [%]');
legend('5 sekundi', '10 sekundi', '15 sekundi');
title('Robusnost sustava na šum i duljinu isječka');
