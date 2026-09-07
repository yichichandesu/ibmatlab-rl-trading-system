function evaluateExecutionAgent(data, signal, symbol)
    % Evaluate trained agent on signal and visualize performance

    fprintf('Evaluating trained agent for %s...\n', symbol);

    % Load agent
    agentFile = sprintf('trainedAgent_%s.mat', symbol);
    if ~isfile(agentFile)
        error('Agent file not found: %s', agentFile);
    end
    load(agentFile, 'agent');

    % Create environment
    capital = 100000;
    env = tradingEnvExecution(data, signal,symbol);

    % Run simulation
    simOpts = rlSimulationOptions('MaxSteps', env.MaxSteps);
    experience = sim(env, agent, simOpts);

    % Extract positions & reward
    prices = data.Close;
    obs = experience.Observation;

    % Handle various data formats
    if istable(obs)
        obsMat = obs.Variables';  % [obs_dim x T]
    elseif isnumeric(obs)
        obsMat = obs;
    elseif iscell(obs)
        obsMat = cell2mat(obs);
    elseif isstruct(obs)
        % If observation is a struct array and each .State is a timeseries
        tmp = arrayfun(@(s) s.State.Data, obs, 'UniformOutput', false);
        obsMat = cell2mat(tmp);  % result: [obs_dim x T]
    else
        error("Unsupported Observation type: %s", class(obs));
    end

    % Position is the last element of observation vector
    positions = obsMat(end, :)';  % column vector

    % Calculate cumulative PnL
    returns = [0; diff(prices)] ./ prices;

    % Align dimensions
    minLen = min(length(returns), length(positions));
    returns = returns(1:minLen);
    positions = positions(1:minLen);
    
    pnl = cumsum(returns .* positions);

    % Plot position and PnL
    figure;
    subplot(2,1,1);
    plot(positions, 'LineWidth', 1.2);
    title(sprintf('Agent Position - %s', symbol));
    ylabel('Position'); xlabel('Time');

    subplot(2,1,2);
    plot(pnl, 'LineWidth', 1.2);
    title('Cumulative PnL');
    xlabel('Time'); ylabel('PnL');
end
