function [sig, t] = simulate_RHB2(M, inp_signal, step_time, sim_time)
    simin1 = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'simin1', simin1);
    simin2 = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'simin2', simin2);
   
    assignin('base', 'simTime', sim_time);
    
%     load heat30;
%     assignin('base', 'Amat', Amat);
%     assignin('base', 'bvec', bvec);
%     assignin('base', 'cvec', cvec);
%     assignin('base', 'dif', dif);
%     assignin('base', 'get', get);
%     assignin('base', 'h', h);
%     assignin('base', 'lower', lower);
%     assignin('base', 'off', off);
%     assignin('base', 'on', on);
%     assignin('base', 'rooms', rooms);
%     assignin('base', 'u', u);
%     assignin('base', 'xinit', xinit);
    evalin('base', 'load(''heat30.mat'')');
    
    open M;
    sim(M)
    
    sig = yout;
    t = tout;
end