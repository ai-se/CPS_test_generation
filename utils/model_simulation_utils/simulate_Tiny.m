function [sig, t, cov] = simulate_Tiny(M, inp_signal, step_time, sim_time)
    load_system(M)
    simin1 = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'simin1', simin1);
    simin2 = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'simin2', simin2);
    simin3 = timeseries(inp_signal(:, 3), step_time);
    assignin('base', 'simin3', simin3);
    assignin('base', 'simTime', sim_time);
    
    open M;
    cov = cvsim(cvtest(strrep(M, '.mdl', '')));
    
    sig(:, 1) = yout(:, 1);
    t = tout;
end