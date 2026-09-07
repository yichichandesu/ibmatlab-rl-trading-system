function simulateExecutionRL(data, signal, symbol)
    fprintf('Simulating RL execution for %s...\n', symbol);
    % Create environment instance
    env = tradingEnvExecution(data, signal,symbol);
    % Load or create RL agent (assume already trained)
    agentFile = sprintf('trainedAgent_%s.mat', symbol);
    if exist(agentFile, 'file')
        load(agentFile, 'agent');
    else
        error('Trained agent for %s not found. Please run trainRLAgent.m first.', symbol);
    end
    % Simulate agent execution in environment
    % === Start Simulation ===
    maxSteps = env.MaxSteps;
    positionHistory = zeros(maxSteps, 1);
    stepIndex = zeros(maxSteps, 1);
    actionHistory = zeros(maxSteps, 1);  % keep each action
    lastAction = NaN;  % initial actioin
    for t = 1:maxSteps
        obs = getObservation(env);
        action = agent.getAction(obs);
        if iscell(action)
            action = action{1};  
        end
        [~, ~, isDone, ~] = step(env, action);
        
        %  Avoid repeated acquisition of account positions (save calls)
        if t == 1 || action ~= lastAction
            pos = getCurrentPosition(symbol);
        else
            pos = positionHistory(t - 1);
        end
        lastAction = action;
        % Get real-time account positions from IB.
        positionHistory(t) = pos;
        stepIndex(t) = env.CurrentIndex;
        actionHistory(t) = action;
        if isDone
            break;
        end
    end
    % Clean unused slots
    positionHistory = positionHistory(1:t);
    stepIndex = stepIndex(1:t);
    actionHistory = actionHistory(1:t);  % Clean up redundant action records
    % Plot real position path
    figure;
    plot(stepIndex, positionHistory, '-o');
    title(sprintf('Real Account Position for %s (Live)', symbol));
    xlabel('Time Index'); ylabel('Shares Held');
end
