function tradingTimerRL(agentFile, symbols, intervalSec, quantity)
% Periodically fetch data, compute RL action, and send orders to TWS
%
% agentFile : e.g., 'trainedAgent_AAPL.mat'
% symbols   : e.g., {'AAPL'}
% intervalSec : interval in seconds
% quantity  : trade size (e.g., 100)

    fprintf('[TIMER] RL-based trading loop starting...\n');

    % Load RL agent
    load(agentFile, 'agent');

    % Create and start timer
    t = timer( ...
        'ExecutionMode','fixedRate', ...
        'Period',intervalSec, ...
        'TimerFcn',@(~,~) executeRLStrategy(agent, symbols, quantity), ...
        'BusyMode','drop' ...
    );

    start(t);

    persistent keepRunning
    if isempty(keepRunning)
        keepRunning = true;
    end
    
    if ~keepRunning
        stop(t);
        delete(t);
        return;
    end
end