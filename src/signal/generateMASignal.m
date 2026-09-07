function S = generateMASignal(bardata, m, n)
% Moving Average Crossover Signal Calculation
    closePrices = bardata.Close;
    if isempty(closePrices)
        S = zeros(0,1); return;
    end
    shortMA = movmean(closePrices, m);
    longMA  = movmean(closePrices, n);
    S = zeros(length(closePrices), 1);
    for i = 2:length(S)
        if shortMA(i) > longMA(i) && shortMA(i-1) <= longMA(i-1)
            S(i) = 1;
        elseif shortMA(i) < longMA(i) && shortMA(i-1) >= longMA(i-1)
            S(i) = -1;
        end
    end
end