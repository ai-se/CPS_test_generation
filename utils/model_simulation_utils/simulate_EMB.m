function [sig, t] = simulate_EMB(M, inp_array, step_time, sim_time)
    Brake = timeseries(inp_array, step_time);
    assignin('base', 'Brake', Brake)
    assignin('base', 'SimTime', sim_time)
    
    EMB_Initialize;
    open M;
    sim(M)
    
    sig(:, 1) = Tank1Height;
    t = tout;
end