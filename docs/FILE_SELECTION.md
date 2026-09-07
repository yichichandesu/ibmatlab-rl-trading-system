# File Selection Notes

This folder is a cleaned public-ready selection from the local auto trading project.

## Included From Main Source

Main source:

- `/Users/zhangyichi/Documents/MATLAB/AutoTradingSystem`

Included:

- `enhanced_IB_system.m`
- `getCurrentPosition.m`
- `data/*.m`
- `signal/*.m`
- `execution/*.m`
- `scheduler/*.m`
- `systemtester/*.m`
- `utils/*.m`

These files are source code and do not contain API keys, account numbers, or local credentials based on a keyword scan.

## Included As Optional Extras

Alternate source:

- `/Users/zhangyichi/Documents/MATLAB/AutoTradingSystem 2`

Included under `extras/auto_trading_system_2/`:

- `executeTWAP.m`
- `computeTradeQuantity.m`
- `tradingTimer.m`

These are not part of the main cleaned source tree yet. They are useful reference files that can be reviewed and merged later.

## Excluded

The following were intentionally excluded:

- `IB_tradeslog_*.csv`
- `IB_tradeslog_*.mat`
- `trainedAgent_*.mat`
- `.DS_Store`
- `*.asv`
- `__MACOSX/`
- third-party IBMatlab binaries such as `IBMatlab.jar` and `IBMatlab.p`
- homework PDFs and generated MATLAB publish outputs
- downloaded duplicate project archives

## Public GitHub Caution

The code includes functions that can connect to TWS and submit orders through IBMatlab. Keep the project framed as coursework/research, use paper trading only, and review all execution wrappers before any live broker connection.

