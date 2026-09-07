%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% enhanced_IBMatlab_system.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

%% Add subfolders to path
addpath(genpath('signal'));
addpath(genpath('data'));
addpath(genpath('execution'));
addpath(genpath('scheduler'));
addpath(genpath('systemtester'));
addpath(genpath('utils'));  % ProfitLoss.m 


%symbols = {'AAPL', 'MSFT', 'GOOG', 'NVDA', 'AMZN'};
symbols = {'AAPL'};
barSize = '30 secs';
duration = '1 D';

if isempty(gcp('nocreate')); parpool; end

%% 1. Synchronous data collection (for loop)
fprintf('\n--- [1] Synchronous Fetch ---\n');
bardataSync = cell(size(symbols));
for k = 1:numel(symbols)
     bardataSync{k} = fetchFromIBMatlab(symbols{k}, duration, barSize);
 end

%% 2. Asynchronous data collection (parfeval)
fprintf('\n--- [2] Asynchronous Fetch ---\n');
futures = parallel.FevalFuture.empty;
for k = 1:numel(symbols)
    futures(k) = parfeval(@fetchFromIBMatlab, 1, symbols{k}, duration, barSize);
end

bardataAsync = cell(size(symbols));
for i = 1:numel(futures)
    [idx, result] = fetchNext(futures);
    bardataAsync{idx} = result;
end

%% 3. Automatic selection & combination of top signals
fprintf('\n--- [3] Signal Ranking & Combination ---\n');

combinedSignals = cell(size(symbols));
signalUsedAll = cell(size(symbols));  

parfor k = 1:numel(symbols)
    data = bardataSync{k};

    if isempty(data.Close) || length(data.Close) < 30
        combinedSignals{k} = zeros(0,1);
        continue;
    end

    % Individual signal generation
    sigs = {
        generateMASignal(data, 3, 10);
        Signal_Stochastic(data, 14, 90, 10);
        Signal_RSI(data, 14, 70, 30);
        Signal_MACD(data.Close);
        Signal_Bollinger(data.Close, 20, 2);
        Signal_VolumeSpike(data.Volume, 20, 2.0)
    };


    sigNames = {'MA', 'Stoch', 'RSI', 'MACD', 'Boll', 'Vol'};
    
    % Score-based top signal selection
    scores = cellfun(@(s) evaluateSignalScore(data, s), sigs);
    N = 2;
    [~, idxTop] = maxk(scores, N);
    topSignals = sigs(idxTop);
    topNames   = sigNames(idxTop);
    
    [combinedSignals{k}, signalUsedAll{k}] = combineSignals(topSignals, topNames);
end

%% 4. PnL visualization based on combined signals
fprintf('\n--- [4] PnL Visualization: Combined Signal ---\n');
for k = 1:numel(symbols)
    figure;
    ProfitLoss(bardataSync{k}, combinedSignals{k}, signalUsedAll{k});
    title(sprintf('[%s] Combined Signal PnL', symbols{k}));
end

%% 5. RL-based Execution Based on Retrieved Data
fprintf('\n--- [5] RL-based Execution ---\n');

for k = 1:numel(symbols)
    rawStruct = bardataSync{k};
    signal = combinedSignals{k};
    symbol = symbols{k};

    % === Convert struct to table JUST for RL ===
    data = table();
    data.Time   = rawStruct.Timestamp(:);
    data.Open   = rawStruct.Open(:);
    data.High   = rawStruct.High(:);
    data.Low    = rawStruct.Low(:);
    data.Close  = rawStruct.Close(:);
    data.Volume = rawStruct.Volume(:);

    % Optional: remove NaN rows if needed
    nanRows = any(ismissing(data), 2);
    data(nanRows, :) = [];

    fprintf('[RL DATA] %s | Clean bars = %d\n', symbol, height(data));

    % === RL steps ===
    trainRLAgent(data, signal, symbol);
    evaluateExecutionAgent(data, signal, symbol);
    simulateExecutionRL(data, signal, symbol);
end
%% 6. Order Submission to TWS
symbols = {'AAPL'};
agentFile = 'trainedAgent_AAPL.mat';
intervalSec = 30;
quantity = 1;

tradingTimerRL(agentFile, symbols, intervalSec, quantity);

stop(timerfindall); delete(timerfindall);



