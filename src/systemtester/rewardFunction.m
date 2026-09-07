function r = rewardFunction(action, position, priceNow, priceNext, holdDuration, maxPosition)
    
    % Calculate profit or loss from holding position between two time steps
    pnl = (priceNext - priceNow) * position;
    
    % Scale the PnL to amplify reward signal (e.g., 200 basis points)
    scaled_pnl = 200 * pnl / priceNow;  
    
    % Penalize switching direction unless already at max long/short
    if (action == 1 && position ~= maxPosition) || (action == 3 && position ~= -maxPosition)
        switchCost = 0.01;
    else
        switchCost = 0;
    end
    
    % Bonus for correct directional positioning (aligned with price change)
    direction_score = sign(priceNext - priceNow) * position;   % Measures if position aligns with movement
    direction_bonus = 0.1 * direction_score;  % Scaled direction bonus
    
    % Penalize holding a position for too long
    holding_penalty = 0.005 * holdDuration; % Cost increases linearly with time


    % Penalize staying idle (no position + hold action)
    if action == 2 && position == 0
        idle_penalty = 0.05;
    else
        idle_penalty = 0;
    end
    
    % Final reward combines scaled PnL, penalties, and directional bonus
    r = scaled_pnl - switchCost + direction_bonus - holding_penalty - idle_penalty;
end