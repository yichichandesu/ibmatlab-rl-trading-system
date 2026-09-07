function [newPosition, entryPrice] = applyExecutionAction(currentPosition, currentEntry, action, px)
    % Convert RL action into new position and update entry price if needed
    if action == 0
        newPosition = currentPosition;
        entryPrice = currentEntry;
    elseif action ~= currentPosition
        % Close old position and open new one
        newPosition = action;
        entryPrice = px;
    else
        % Keep current position
        newPosition = currentPosition;
        entryPrice = currentEntry;
    end
end
