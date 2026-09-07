function quantity = computeTradeQuantity(symbol, price, capitalLimit)
% Compute tradable share quantity under an account/capital limit.
% symbol        - ticker, e.g. 'AAPL'
% price         - current market price, preferably mid or last
% capitalLimit  - maximum usable capital

    % Default to a fixed per-trade capital limit.
    if nargin < 3
        capitalLimit = 100000;
    end

    % Try to read account funds; fall back to the configured limit.
    try
        acct = IBMatlab('action', 'account');
        availableUSD = acct.AvailableFunds_S.value;
    catch
        warning('[%s] Could not retrieve account funds; using capitalLimit.', symbol);
        availableUSD = capitalLimit;
    end

    % Use the smaller of account funds and the configured limit.
    usableCapital = min(availableUSD, capitalLimit);

    % Compute maximum whole-share quantity.
    quantity = floor(usableCapital / price);

    % Avoid returning zero.
    if quantity <= 0
        quantity = 1;
    end
end
