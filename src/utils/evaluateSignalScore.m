function score = evaluateSignalScore(bardata, signal)

    if isempty(signal) || length(signal) ~= length(bardata.Close)
        score = -Inf;
        return;
    end

    closePrices = bardata.Close;
    PnL = zeros(size(closePrices));
    position = 0;
    entry = 0;

    for i = 2:length(signal)
        if signal(i) == 1
            position = 1;
            entry = closePrices(i);
        elseif signal(i) == -1 && position == 1
            PnL(i) = closePrices(i) - entry;
            position = 0;
        end
        PnL(i) = PnL(i) + PnL(i-1);
    end

    score = mean(diff(PnL)) / std(diff(PnL));  % Sharpe-like
end