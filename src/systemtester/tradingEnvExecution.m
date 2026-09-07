classdef tradingEnvExecution < rl.env.MATLABEnvironment
    % RL environment where the agent optimizes execution decisions
    % based on signal and market state (e.g., recent returns)

    properties
        Data            % Table with OHLCV data (from fetchFromIBMatlab)
        Signal          % Combined signal vector (same length as Data)
        CurrentIndex    % Current time index
        Position        % Current position: -1 (short), 0 (flat), 1 (long)
        MaxPosition = 1 % Position magnitude limit
        InitialIndex = 100 % Index from which simulation starts
        MaxSteps = 200  % maximum steps per episode
        HoldDuration = 1  % Used to punish long-term holding of positions in the same direction
        Symbol  % ticker string
    end

    properties(Access = protected)
        Observation     % Current observation vector
    end

    methods
        function this = tradingEnvExecution(data, signal, symbol)
            obsInfo = rlNumericSpec([12 1]);
            obsInfo.Name = 'State';

            actInfo = rlFiniteSetSpec([1 2 3]);
            actInfo.Name = 'Action';

            % Explicitly call the parent class constructor.
            this = this@rl.env.MATLABEnvironment(obsInfo, actInfo);

            % Custom environment properties
            this.Data = data;
            this.Signal = signal;
            this.Symbol = symbol;
            this.CurrentIndex = this.InitialIndex;

             try
                this.Position = getCurrentPosition(symbol);
             catch
                this.Position = 0;
             end

           
            % Keep the episode length within the available sample.
            this.MaxSteps = max(1, height(data) - this.InitialIndex - 1);

            % Output debugging information.
            fprintf('[ENV INIT] Data height = %d | InitialIndex = %d | MaxSteps = %d\n', ...
                height(data), this.InitialIndex, this.MaxSteps);

            this.Observation = getObservation(this);
        end

        function [obs, reward, isDone, log] = step(this, action)
            log = [];
        
            priceNow = this.Data.Close(this.CurrentIndex);
            priceNext = this.Data.Close(this.CurrentIndex + 1);
        
        
            switch action
                case 1
                    newPos = this.MaxPosition;  % BUY
                case 2
                    newPos = this.Position;     % HOLD
                case 3
                    newPos = -this.MaxPosition; % SELL
            end
        
            % Update holding duration.
            if newPos == this.Position
                this.HoldDuration = this.HoldDuration + 1;
            else
                this.HoldDuration = 1;  % Reset counter
            end
        
        
            % total reward
            reward = rewardFunction(action, this.Position, priceNow, priceNext, this.HoldDuration, this.MaxPosition);
        
            this.Position = newPos;
            this.CurrentIndex = this.CurrentIndex + 1;
        
            isDone = this.CurrentIndex >= height(this.Data) - 1;
        
            obs = getObservation(this);
        
            if mod(this.CurrentIndex, 100) == 0
                fprintf("t=%d | action=%d | reward=%.4f | position=%d | hold=%d\n", ...
                    this.CurrentIndex, action, reward, this.Position, this.HoldDuration);
            end
        end

        function obs = reset(this)
            this.CurrentIndex = this.InitialIndex;
            try
                this.Position = getCurrentPosition(this.Symbol);  
            catch
                this.Position = 0;
            end
            this.HoldDuration = 1;  % Initialized to 1
            obs = getObservation(this);
        end

        function obs = getObservation(this)
            close = this.Data.Close;
        
            try
                % Return vector
                if this.CurrentIndex <= 10 || this.CurrentIndex > length(close)
                    rets = zeros(10, 1);
                else
                    % Extract price returns safely
                    pxWindow = close(this.CurrentIndex - 10:this.CurrentIndex);
                    if any(~isfinite(pxWindow)) || length(pxWindow) ~= 11
                        rets = zeros(10, 1);
                    else
                        rets = diff(pxWindow) ./ pxWindow(1:end-1);
                    end
                end
            catch
                rets = zeros(10,1);  % fallback
            end
        
            % Signal safe check
            if this.CurrentIndex > length(this.Signal)
                sig = 0;
            else
                sig = this.Signal(this.CurrentIndex);
            end
        
            obs = [rets; sig; this.Position];
        end

    end
end
