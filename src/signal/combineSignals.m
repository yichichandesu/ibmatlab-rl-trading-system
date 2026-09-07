function [finalSignal, signalUsed] = combineSignals(signals, signalNames)
% Combine multiple signals and record which one triggered the trade by name
% signals: cell array of vectors (each signal)
% signalNames: cell array of corresponding signal names (e.g. {'MA', 'RSI', 'MACD'})

    numSignals = length(signals);
    signalMatrix = zeros(length(signals{1}), numSignals);

    for i = 1:numSignals
        signalMatrix(:, i) = signals{i};
    end

    score = sum(signalMatrix, 2);  % Simple voting.
    finalSignal = zeros(size(score));
    signalUsed = strings(length(score), 1);

    for t = 1:length(score)
        if score(t) >= 2
            finalSignal(t) = 1;
            active = find(signalMatrix(t,:) == 1);
            signalUsed(t) = join(string(signalNames(active)), '+');
        elseif score(t) <= -2
            finalSignal(t) = -1;
            active = find(signalMatrix(t,:) == -1);
            signalUsed(t) = join(string(signalNames(active)), '+');
        end
    end
end
