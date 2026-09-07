function agent = createExecutionAgent(obsInfo, actInfo)
% CREATEEXECUTIONAGENT Creates a DQN agent for RL-based execution.
%   Inputs:
%       obsInfo - Observation specification (from environment)
%       actInfo - Action specification (from environment)
%
%   Output:
%       agent   - Configured rlDQNAgent

    % === 1. Define Neural Network for Q-value function ===
    statePath = [
        featureInputLayer(obsInfo.Dimension(1), 'Normalization', 'none', 'Name', 'state')
        fullyConnectedLayer(24, 'Name', 'fc1')
        reluLayer('Name', 'relu1')
        fullyConnectedLayer(24, 'Name', 'fc2')
        reluLayer('Name', 'relu2')
        fullyConnectedLayer(length(actInfo.Elements), 'Name', 'fcFinal')];

    criticNet = layerGraph(statePath);
    dlnet = dlnetwork(criticNet);

    % === 2. Create Q-value representation ===
    criticOptions = rlRepresentationOptions(...
        'LearnRate', 1e-3, ...
        'GradientThreshold', 1);

    critic = rlQValueRepresentation(dlnet, obsInfo, actInfo, ...
        'Observation', {'state'}, ...
        criticOptions);

    % === 3. Define Epsilon-greedy exploration strategy ===
    exploration = rl.option.EpsilonGreedyExploration();
    exploration.Epsilon = 1.0;
    exploration.EpsilonDecay = 1e-4;
    exploration.EpsilonMin = 0.01;

    % === 4. Set DQN agent options ===
    agentOptions = rlDQNAgentOptions(...
        'SampleTime', 1, ...
        'DiscountFactor', 0.99, ...
        'MiniBatchSize', 64, ...
        'ExperienceBufferLength', 1e4, ...
        'TargetUpdateFrequency', 4, ...
        'EpsilonGreedyExploration', exploration, ...
        'ResetExperienceBufferBeforeTraining', false ...
    );

    % === 5. Create the agent ===
    agent = rlDQNAgent(critic, agentOptions);
end
