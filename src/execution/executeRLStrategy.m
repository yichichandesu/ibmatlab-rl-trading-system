function executeRLStrategy(agent, symbols, quantity)
    for k = 1:numel(symbols)
        symbol = symbols{k};
        try
            % 1. Get real-time data (past 20 bars)
            bardata = fetchFromIBMatlab(symbol, '1 D', '30 secs');  % 30 seconds data
            if isempty(bardata) || numel(bardata.Close) < 12
                fprintf('[%s] Not enough data\n', symbol);
                continue;
            end

            % 2. Constructing RL observation
            obs = buildRLObservation(bardata);

            % 3. Making decisions with agents
            action = agent.getAction(obs);

            if iscell(action)
                action = action{1};  % Unpacking
            end
            
            if action == 1
                action = 'BUY';
            elseif action == 3
                action = 'SELL';
            elseif action == 2
                fprintf('[%s] No trade action (HOLD)\n', symbol);
                return;
            else
                warning('[%s] Invalid action code: %d\n', symbol, action);
                return;
            end

            % Get the latest price 
            price = bardata.Close(end);  % The latest closing price, used as the simulated transaction price

            % 4. Execute the transaction
            placeOrderIB(symbol, action, quantity, price, 'MKT')
         catch ME
            fprintf('[%s] RL ERROR TRACE: %s\n', symbol, getReport(ME, 'extended'));
        end
    end
end