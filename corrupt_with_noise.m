function noisy_clip = corrupt_with_noise(clip, SNR_db)
    % Dodaje bijeli Gaussov šum prema zadanom SNR-u
    P_signal = mean(clip.^2);
    P_noise = P_signal / (10^(SNR_db/10));
    sigma = sqrt(P_noise);
    noise = sigma * randn(size(clip));
    noisy_clip = clip + noise;
end
