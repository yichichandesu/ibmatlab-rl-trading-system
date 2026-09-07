function S = Signal_VolumeSpike(volume, n, threshold)
    avgVol = movmean(volume, n);
    spike = volume ./ (avgVol + eps);
    S = zeros(length(volume), 1);
    S(spike > threshold) = 1;  % Surge of interest
end