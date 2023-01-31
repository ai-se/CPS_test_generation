function [sig, t, cov] = simulate_CW(M, inp_signal, step_time, sim_time)
    load_system(M)
    dw1 = timeseries(inp_signal(:, 1), step_time);
    assignin('base', 'DW1', dw1);
    dw2 = timeseries(inp_signal(:, 2), step_time);
    assignin('base', 'DW2', dw2);
    dw3 = timeseries(inp_signal(:, 3), step_time);
    assignin('base', 'DW3', dw3);
    dw4 = timeseries(inp_signal(:, 4), step_time);
    assignin('base', 'DW4', dw4);
    p1w2 = timeseries(inp_signal(:, 5), step_time);
    assignin('base', 'P1W2', p1w2);
    p2w3 = timeseries(inp_signal(:, 6), step_time);
    assignin('base', 'P2W3', p2w3);
    p1w3 = timeseries(inp_signal(:, 7), step_time);
    assignin('base', 'P1W3', p1w3);
    p3w4 = timeseries(inp_signal(:, 8), step_time);
    assignin('base', 'P3W4', p3w4);
    p1w4 = timeseries(inp_signal(:, 9), step_time);
    assignin('base', 'P1W4', p1w4);
    o1 = timeseries(inp_signal(:, 10), step_time);
    assignin('base', 'O1', o1);
    o2 = timeseries(inp_signal(:, 11), step_time);
    assignin('base', 'O2', o2);
    o3 = timeseries(inp_signal(:, 12), step_time);
    assignin('base', 'O3', o3);
    o4 = timeseries(inp_signal(:, 13), step_time);
    assignin('base', 'O4', o4);
    ld = timeseries(inp_signal(:, 14), step_time);
    assignin('base', 'LD', ld);
    lp = timeseries(inp_signal(:, 15), step_time);
    assignin('base', 'LP', lp);
    assignin('base', 'simTime', sim_time);

    CW_Init;
    
    assignin('base', 'J', J);
    assignin('base', 'b', b);
    assignin('base', 'K', K);
    assignin('base', 'R', R);
    assignin('base', 'L', L);
    
    open M;
    cov = cvsim(cvtest(strrep(M, '.mdl', '')));
    
    sig(:, 1) = yout(:, 1);
    sig(:, 2) = yout(:, 2);
    sig(:, 3) = yout(:, 3);
    sig(:, 4) = yout(:, 4);
    t = tout;
end