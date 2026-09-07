function pos = getCurrentPosition(symbol)
    try
        data = IBMatlab('action', 'portfolio');  % Use portfolio rather than account.

        if ~isstruct(data)
            warning('Portfolio data is not a struct.');
            pos = 0;
            return;
        end

        match = find(strcmpi({data.symbol}, symbol), 1);
        if isempty(match)
            pos = 0;
        else
            pos = data(match).position;
        end
    catch ME
        warning('Error retrieving position: %s', ME.message);
        pos = 0;
    end
end
