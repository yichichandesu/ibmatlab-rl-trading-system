function simData = generateRealisticSimData(numBars, startPrice)
%GENERATEREALISTICSIMDATA Generate realistic intraday bar data
%
% Usage:
%   simData = generateRealisticSimData(6240, 100)
%
% Output structure:
%   simData.Time
%   simData.Open
%   simData.High
%   simData.Low
%   simData.Close
%   simData.Volume

    % Defaults
    if nargin < 1, numBars = 6240; end   % 1 trading day at 15-sec bars
    if nargin < 2, startPrice = 100; end
    
    % Time vector (30 sec intervals)
    dt = seconds(30);
    timeVec = datetime('today') + (0:numBars-1)' * dt;
    dt_sec = seconds(dt);

    %% --- Heston-like stochastic volatility ---
    mu = 0.00002;             % small positive drift
    v0 = 0.0005^2;            % initial variance
    kappa = 3; theta = v0; eta = 0.1;  % mean-reversion parameters
    v = zeros(numBars,1); v(1) = v0;
    for t = 2:numBars
        v(t) = abs(v(t-1) + kappa * (theta - v(t-1)) * dt_sec + eta * sqrt(v(t-1)) * randn);
    end

    %% --- Jump Diffusion ---
    lambda = 0.002;              % jump probability
    jump_mu = -0.015;            % jump size mean
    jump_sigma = 0.03;           % jump size std
    jump_mask = rand(numBars,1) < lambda;
    jump_component = jump_mask .* (jump_mu + jump_sigma * randn(numBars,1));

    %% --- Intraday volatility profile (U-shaped) ---
    hourVec = hour(timeVec);
    minuteVec = minute(timeVec);
    in_opening = (hourVec == 9 & minuteVec >= 30) | hourVec == 10;
    in_closing = hourVec == 15;
    intraday_vol = 0.0005 + 0.0015 * (in_opening | in_closing);  % U-shape

    %% --- Returns: combine all components ---
    returns = mu * dt_sec + sqrt(v) .* randn(numBars,1) + jump_component + intraday_vol .* randn(numBars,1);
    prices = startPrice * cumprod(1 + returns);

    %% --- OHLC construction with microstructure noise ---
    spread = 0.001 * randn(numBars,1);
    Close = prices + spread;
    Open  = Close .* (1 + 0.0003 * randn(numBars,1));
    High  = max(Open, Close) .* (1 + abs(0.0005 * randn(numBars,1)));
    Low   = min(Open, Close) .* (1 - abs(0.0005 * randn(numBars,1)));

    %% --- Volume generation correlated with volatility/price move ---
    vol_proxy = abs([0; diff(log(Close))]);
    Volume = 1e4 * (0.5 + 3 * vol_proxy + 0.05 * randn(numBars,1));
    Volume = max(Volume, 10);  % avoid negative or too small

    %% --- Randomly drop 1% bars to simulate missing data ---
    drop_ratio = 0.01;
    drop_idx = randperm(numBars, round(drop_ratio * numBars));
    Open(drop_idx) = NaN;
    High(drop_idx) = NaN;
    Low(drop_idx)  = NaN;
    Close(drop_idx)= NaN;
    Volume(drop_idx) = NaN;

    %% --- Output struct ---
    simData = struct();
    simData.Time   = timeVec;
    simData.Open   = Open;
    simData.High   = High;
    simData.Low    = Low;
    simData.Close  = Close;
    simData.Volume = Volume;
end
