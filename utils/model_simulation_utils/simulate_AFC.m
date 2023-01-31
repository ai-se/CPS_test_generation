function [sig, t] = simulate_AFC(M, inp_signal, step_time, sim_time)
    simin1 = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'simin1', simin1);
    simin2 = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'simin2', simin2);
    
    assignin('base', 'simTime', sim_time);
    
    measureTime=1;
    fault_time=60;
    spec_num=1;
    fuel_inj_tol=1;
    MAF_sensor_tol=1;
    AF_sensor_tol=1;
    
    assignin('base', 'measureTime', measureTime);
    assignin('base', 'fault_time', fault_time);
    assignin('base', 'spec_num', spec_num);
    assignin('base', 'fuel_inj_tol', fuel_inj_tol);
    assignin('base', 'MAF_sensor_tol', MAF_sensor_tol);
    assignin('base', 'AF_sensor_tol', AF_sensor_tol);
    
    open M;
    sim(M)
    
    t = tout;
    sig = yout;
end