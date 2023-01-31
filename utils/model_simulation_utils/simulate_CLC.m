function [sig, t, cov] = simulate_CLC(M, inp_signal, step_time, sim_time)
    load_system(M)
    simin = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'simin', simin);
    simin1 = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'simin1', simin1);
    
    assignin('base', 'simTime', sim_time);
    
    open M;
%     sim(M)
    cov = cvsim(cvtest(strrep(M, '.mdl', '')));
    
    sig = yout;
    t = tout;
end