function S = Signal_RSI(bardata, n, overbought, oversold)
% Generate Buy/Sell signals based on RSI
% Inputs: bardata = struct with .Close
%         n = RSI window (typically 14)
%         overbought = e.g., 70
%         oversold   = e.g., 30
% Output: S = -1 (Sell), 0 (Hold), 1 (Buy)

    if ~isfield(bardata, 'Close')
        error('bardata must have Close field');
    end

    closePrices = bardata.Close;
    len = length(closePrices);
    S = zeros(len,1);

    if len < n + 1
        return;
    end

    delta = diff(closePrices);
    gains = max(delta, 0);
    losses = max(-delta, 0);

    avgGain = movmean(gains, n);
    avgLoss = movmean(losses, n);

    RS = avgGain ./ (avgLoss + eps);  % use eps to avoid division by zero
    RSI = 100 - 100 ./ (1 + RS);

    % Adjust length due to diff
    RSI = [NaN; RSI];

    for i = 2:len
        if RSI(i-1) < oversold && RSI(i) >= oversold
            S(i) = 1;   % Buy
        elseif RSI(i-1) > overbought && RSI(i) <= overbought
            S(i) = -1;  % Sell
        end
    end
end