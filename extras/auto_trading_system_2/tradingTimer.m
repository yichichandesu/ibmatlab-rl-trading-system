function tradingTimer(symbols, barSize, duration, intervalSec)
% Execute trading strategies periodically with signal scoring + live orders

    t = timer( ...
        'ExecutionMode','fixedRate', ...
        'Period',intervalSec, ...
        'TimerFcn',@(~,~)executeStrategy );

    fprintf('Starting auto-trader | Interval: %d sec\n', intervalSec);
    start(t);

    function executeStrategy()
        fprintf('[%s] Executing strategy...\n', datestr(now,'HH:MM:SS'));

        for k = 1:numel(symbols)
            data = fetchFromIBMatlab(symbols{k}, duration, barSize);

            if isempty(data.Close) || length(data.Close) < 30
                fprintf('[%s] %s: Not enough data.\n', datestr(now,'HH:MM:SS'), symbols{k});
                continue;
            end

            % === Signal generation ===
            sigs = {
                generateMASignal(data, 3, 10);
                Signal_Stochastic(data, 14, 90, 10);
                Signal_RSI(data, 14, 70, 30);
                Signal_MACD(data.Close);
                Signal_Bollinger(data.Close, 20, 2);
                Signal_VolumeSpike(data.Volume, 20, 2.0)
            };
            sigNames = {'MA','Stoch','RSI','MACD','Boll','Vol'};

            % === Signal scoring ===
            scores = cellfun(@(s) evaluateSignalScore(data, s), sigs);
            [~, idxTop] = maxk(scores, 2);
            topSignals = sigs(idxTop);
            topNames   = sigNames(idxTop);

            % === Combine signals ===
            [finalSignal, signalUsed] = combineSignals(topSignals, topNames);

            % === Place order for the last signal ===
            recentSig = finalSignal(end);
            price     = data.Close(end);

            if recentSig == 1
                fprintf('[%s] [%s] BUY @ %.2f | Signals: %s\n', ...
                        datestr(now,'HH:MM:SS'), symbols{k}, price, signalUsed(end));
                placeOrderIB(symbols{k}, 'BUY', 10, price, 'MKT');

            elseif recentSig == -1
                fprintf('[%s] [%s] SELL @ %.2f | Signals: %s\n', ...
                        datestr(now,'HH:MM:SS'), symbols{k}, price, signalUsed(end));
                placeOrderIB(symbols{k}, 'SELL', 10, price, 'MKT');

            else
                fprintf('[%s] [%s] Hold | No trade signal.\n', ...
                        datestr(now,'HH:MM:SS'), symbols{k});
            end
        end
    end
end