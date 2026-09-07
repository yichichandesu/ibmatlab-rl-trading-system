function S = Signal_MACD(closePrices)
    [macdLine, signalLine] = macd(closePrices);
    S = zeros(size(macdLine));
    for i = 2:length(macdLine)
        if macdLine(i) > signalLine(i) && macdLine(i-1) <= signalLine(i-1)
            S(i) = 1;
        elseif macdLine(i) < signalLine(i) && macdLine(i-1) >= signalLine(i-1)
            S(i) = -1;
        end
    end
end