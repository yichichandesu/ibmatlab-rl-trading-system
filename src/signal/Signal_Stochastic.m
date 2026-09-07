function S = Signal_Stochastic(bardata, n, overbought, oversold)
% Generate Buy/Sell signals based on the Stochastic Oscillator
% Inputs: bardata = struct with .High, .Low, .Close
%         n = window size
%         overbought = e.g., 90
%         oversold   = e.g., 10
% Output: S = -1 (Sell), 0 (Hold), 1 (Buy)

    % Check that required fields exist
    if ~isfield(bardata, 'High') || ~isfield(bardata, 'Low') || ~isfield(bardata, 'Close')
        error('bardata must have High, Low, and Close fields');
    end

    high = bardata.High;
    low = bardata.Low;
    close = bardata.Close;

    len = length(close);
    S = zeros(len, 1);
    K = zeros(len, 1);

    if len < n
        return;
    end

    for i = n:len
        highestHigh = max(high(i-n+1:i));
        lowestLow = min(low(i-n+1:i));
        K(i) = 100 * (close(i) - lowestLow) / (highestHigh - lowestLow + eps);
    end

    % Signal logic: cross above oversold -> Buy; cross below overbought -> Sell.
    for i = 2:len
        if K(i-1) < oversold && K(i) >= oversold
            S(i) = 1;
        elseif K(i-1) > overbought && K(i) <= overbought
            S(i) = -1;
        end
    end
end
