function [orderId, result] = placeOrderIB(symbol, action, quantity, price, orderType)
% Place a trade order using IB-Matlab (for paper trading)
%
% Inputs:
%   symbol     - e.g., 'AAPL'
%   action     - 'BUY' or 'SELL'
%   quantity   - number of shares
%   price      - limit price (used for LMT)
%   orderType  - 'MKT' or 'LMT'
%
% Outputs:
%   orderId    - IB order ID
%   result     - IBMatlab result struct

    if nargin < 5
        orderType = 'MKT';
    end

    params = struct();
    params.symbol    = symbol;
    params.quantity  = quantity;
    params.type      = upper(orderType);  % 'MKT' or 'LMT'
    params.action    = upper(action);     % 'BUY' or 'SELL'
    params.tif       = 'GTC';
    params.exchange  = 'SMART';
    params.currency  = 'USD';
    params.whatIf    = true;              % Test mode

    % ---- PLACE ORDER (Paper Trading Assumed) ----
    try
        fprintf('[Paper Order] Placing %s %d %s @ %s\n', ...
            action, quantity, symbol, orderType);
    
        result = IBMatlab(params);
    
        % Check result type returned by IBMatlab.
        if isstruct(result)
            if isfield(result, 'orderId')
                orderId = result.orderId;
                fprintf('[Paper Order Submitted] ID = %d | Status = %s\n', ...
                    orderId, result.status);
            else
                fprintf('[Paper Order Submitted] Struct result but missing orderId\n');
                disp(result);
                orderId = -1;
            end
        else
            % IBMatlab may return a numeric order identifier.
            fprintf('[Paper Order Submitted] Non-struct result: %s\n', class(result));
            disp(result);
            orderId = result;
        end
    
    catch ME
        warning('[Paper Order Failed] %s %d %s | Error: %s', ...
            action, quantity, symbol, ME.message);
        result = struct();
        orderId = -1;
    end
end
