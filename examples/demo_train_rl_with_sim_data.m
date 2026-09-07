%DEMO_TRAIN_RL_WITH_SIM_DATA Train the execution RL agent on simulated data.
%
% This example is intended for portfolio review and local smoke testing. It
% does not connect to Interactive Brokers and does not submit orders.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
srcRoot = fullfile(repoRoot, 'src');
addpath(genpath(srcRoot));

rng(7);
symbol = 'SIM_DEMO';
numBars = 1200;
startPrice = 100;

fprintf('Generating simulated OHLCV data...\n');
simData = generateRealisticSimData(numBars, startPrice);
data = struct2table(simData);
data = rmmissing(data);

fprintf('Building technical signals...\n');
maSignal = generateMASignal(data, 5, 20);
bollingerSignal = Signal_Bollinger(data.Close, 20, 2);
volumeSignal = Signal_VolumeSpike(data.Volume, 20, 1.5);

[combinedSignal, signalUsed] = combineSignals( ...
    {maSignal, bollingerSignal, volumeSignal}, ...
    {'MA', 'Bollinger', 'VolumeSpike'});

fprintf('Non-zero combined signal count: %d\n', nnz(combinedSignal));

fprintf('Creating RL environment and DQN agent...\n');
env = tradingEnvExecution(data, combinedSignal, symbol);
obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);
agent = createExecutionAgent(obsInfo, actInfo);

maxDemoSteps = min(250, env.MaxSteps);
trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 15, ...
    'MaxStepsPerEpisode', maxDemoSteps, ...
    'ScoreAveragingWindowLength', 5, ...
    'Verbose', true, ...
    'Plots', 'none', ...
    'StopTrainingCriteria', 'EpisodeCount', ...
    'StopTrainingValue', 15);

fprintf('Training a short demo agent...\n');
trainingStats = train(agent, env, trainOpts);

agentFile = fullfile(repoRoot, sprintf('trainedAgent_%s.mat', symbol));
save(agentFile, 'agent', 'trainingStats', 'combinedSignal', 'signalUsed');
fprintf('Saved demo agent to %s\n', agentFile);

fprintf('Running a short simulation with the trained demo agent...\n');
reset(env);
simOpts = rlSimulationOptions('MaxSteps', maxDemoSteps);
experience = sim(env, agent, simOpts);
disp(experience);

