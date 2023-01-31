function [sig, t, cov] = simulate_CC(M, inp_signal, step_time, sim_time)
    step_time = step_time(1:size(inp_signal,1));
    load_system(M)
    Enable = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'Enable', Enable);
    Brake = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'Brake', Brake);
    Set = timeseries(inp_signal(:, 3), step_time);
    assignin('base', 'Set', Set);
    Speed = timeseries(inp_signal(:, 4), step_time);
    assignin('base', 'Speed', Speed);
    Inc = timeseries(inp_signal(:, 5), step_time);
    assignin('base', 'Inc', Inc);
    Dec = timeseries(inp_signal(:, 6), step_time);
    assignin('base', 'Dec', Dec);
    assignin('base', 'simTime', sim_time);
    
    Configurations;
    assignin('base', 'KInc', KInc);
    assignin('base', 'Kdec', Kdec);
    assignin('base', 'Kp', Kp);
    assignin('base', 'Kp1', Kp1);
    assignin('base', 'Ki', Ki);
    
    open M;
%     sim(M)
    cov = cvsim(cvtest(strrep(M, '.mdl', '')));
    
    sig(:, 1) = yout(:, 1);
    sig(:, 2) = yout(:, 2);
    t = tout;
end