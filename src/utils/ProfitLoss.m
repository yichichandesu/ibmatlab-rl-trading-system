function PnL = ProfitLoss(bardata, signals, signalUsed)
% signals: +1/-1 trading signals
% signalUsed: which signal triggered the trade

    closePrices = bardata.Close;
    PnL = zeros(size(closePrices));
    position = 0;
    entryPrice = 0;
    entryIndex = 0;
    maxBarsHold = 30;

    buyIdx = [];
    sellIdx = [];
    buyLabels = {};
    sellLabels = {};
    tradeReturns = [];  % for performance metrics

    for i = 2:length(signals)
        if signals(i) == 1 && position == 0
            position = 1; entryPrice = closePrices(i); entryIndex = i;
            buyIdx(end+1) = i;
            buyLabels{end+1} = signalUsed(i);  % record signal used for entry

        elseif signals(i) == -1 && position == 1
            ret = closePrices(i) - entryPrice;
            PnL(i) = ret;
            tradeReturns(end+1) = ret;
            position = 0;
            sellIdx(end+1) = i;
            sellLabels{end+1} = signalUsed(i);

        elseif position == 1 && (i - entryIndex >= maxBarsHold)
            ret = closePrices(i) - entryPrice;
            PnL(i) = ret;
            tradeReturns(end+1) = ret;
            position = 0;
            sellIdx(end+1) = i;
            sellLabels{end+1} = "[timeout]";
        end
        PnL(i) = PnL(i) + PnL(i-1);
    end

    % ===== Visualization =====
    plot(PnL, 'Color', [0 0.4 0.8], 'LineWidth', 1.5); hold on;
    
    % --- Buy/Sell markers ---
    plot(buyIdx, PnL(buyIdx), '^', 'MarkerSize', 7, ...
         'MarkerEdgeColor', [0 0.6 0], 'MarkerFaceColor', [0.7 1 0.7], ...
         'LineWidth', 1.2);
    plot(sellIdx, PnL(sellIdx), 'v', 'MarkerSize', 7, ...
         'MarkerEdgeColor', [0.8 0 0], 'MarkerFaceColor', [1 0.6 0.6], ...
         'LineWidth', 1.2);
    
    % --- Text labels for Buy points ---
    for j = 1:length(buyIdx)
        text(buyIdx(j), PnL(buyIdx(j)) + 0.2, buyLabels{j}, ...
            'Color', [0 0.5 0], 'FontSize', 8, ...
            'FontWeight','bold', 'HorizontalAlignment','center');
    end
    
    % --- Text labels for Sell/Timeout points ---
    for j = 1:length(sellIdx)
        if contains(sellLabels{j}, 'timeout', 'IgnoreCase', true)
            text(sellIdx(j), PnL(sellIdx(j)) - 0.3, '[timeout]', ...
                'Color', [0.4 0.4 0.4], 'FontSize', 8, ...
                'FontAngle','italic', 'HorizontalAlignment','center');
        else
            text(sellIdx(j), PnL(sellIdx(j)) - 0.3, sellLabels{j}, ...
                'Color', [0.6 0 0], 'FontSize', 8, ...
                'FontWeight','bold', 'HorizontalAlignment','center');
        end
    end
    
    % --- Graph settings ---
    title('PnL with Buy/Sell Markers and Signal Labels');
    xlabel('Bar Index'); ylabel('Cumulative PnL');
    legend({'PnL','Buy','Sell'}, 'Location','best');
    grid on; hold off;

    % ===== Performance Metrics =====
    totalReturn = PnL(end);
    avgTrade = mean(tradeReturns);
    stdTrade = std(tradeReturns);
    sharpe = avgTrade / stdTrade * sqrt(252);  % daily to annualized
    drawdown = PnL - cummax(PnL);
    maxDrawdown = min(drawdown);

    % --- Console Output ---
    fprintf('\n[Performance Metrics]\n');
    fprintf('Total Return       : %.2f\n', totalReturn);
    fprintf('Avg Trade Return   : %.4f\n', avgTrade);
    fprintf('Std Trade Return   : %.4f\n', stdTrade);
    fprintf('Sharpe Ratio       : %.4f\n', sharpe);
    fprintf('Max Drawdown       : %.2f\n', maxDrawdown);
end