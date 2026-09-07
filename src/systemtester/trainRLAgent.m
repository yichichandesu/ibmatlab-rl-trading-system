function trainRLAgent(data, signal, symbol)
    % Train a DQN RL agent to optimize execution for a given symbol

    fprintf('Training DQN agent for %s...\n', symbol);


    % Create RL environment
    env = tradingEnvExecution(data, signal,symbol);

    % Get observation and action space
    obsInfo = getObservationInfo(env);
    actInfo = getActionInfo(env);

    % Create agent
    agent = createExecutionAgent(obsInfo, actInfo);

    % Training options
    trainOpts = rlTrainingOptions(...
        'MaxEpisodes', 200, ...
        'MaxStepsPerEpisode', env.MaxSteps, ...
        'ScoreAveragingWindowLength', 10, ...
        'Verbose', false, ...
        'Plots', 'training-progress', ...
        'StopTrainingCriteria','AverageReward',...
        'StopTrainingValue', 100);

    % Train agent
    trainingStats = train(agent, env, trainOpts);

    % Save agent
    save(sprintf('trainedAgent_%s.mat', symbol), 'agent', 'trainingStats');

    fprintf('Training complete. Agent saved as trainedAgent_%s.mat\n', symbol);
end
