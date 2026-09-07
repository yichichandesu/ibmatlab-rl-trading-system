function obs = getExecutionState(env, idx)
    price = env.Data.Close(idx);
    signal = env.Signal(idx);
    pos = env.Position;
    obs = [price; signal; pos];
end
