function obs = buildRLObservation(bardata)
    try
        close = bardata.Close(:);
        signal = 0;  % Replace with a live signal pipeline if needed.

        idx = numel(close);
        if idx <= 10
            rets = zeros(10,1);
        else
            px = close(end-10:end);
            rets = diff(px) ./ px(1:end-1);
        end
        position = 0;  % Default to flat; connect account state if needed.
        
        obs = [rets; signal; position];
    catch
        obs = zeros(12,1);  % fallback
    end
end
