function S = Signal_Bollinger(closePrices, window, numStd)
    m = movmean(closePrices, window);
    s = movstd(closePrices, window);
    upper = m + numStd * s;
    lower = m - numStd * s;
    S = zeros(length(closePrices),1);
    for i = 2:length(closePrices)
        if closePrices(i-1) > lower(i-1) && closePrices(i) <= lower(i)
            S(i) = 1;
        elseif closePrices(i-1) < upper(i-1) && closePrices(i) >= upper(i)
            S(i) = -1;
        end
    end
end