% this function simulates the model
function hs = system_simulator(M, sim_opt, sig_data)
    % simulate the model
    simopt = simget(M);
    
    try
        load_system(M);
        timetic = tic;
        [~, MSGID] = lastwarn();
        warning('off', MSGID);
        
        [T, XT, YT] = sim(M, [0 sim_opt.simulation_time], simopt, sig_data);
        one_simulation_time = toc(timetic);
    catch ME
        if (strcmp(ME.identifier,'Simulink:Engine:ReturnWkspOutputNotSupported'))
            msg = sprintf('STaLiRo : Simulink model "%s" outputs to a single variable in the workspace. \nSet the staliro option SimulinkSingleOutput to 1 or modify the Simulink model single object \noutput option at Simulation > Model Configuration > Data Import/Export.',inputModel);
            causeException = MException('MATLAB:myCode:dimensions',msg);
            ME = addCause(ME,causeException);
            rethrow(ME);
        elseif (strcmp(ME.identifier,'Simulink:Engine:DerivNotFinite')|| strcmp(ME.identifier,'Simulink:modelReference:NormalModeSimulationError'))
            YT = NaN;
            XT = NaN;
            T = NaN;
        end
    end
    
    T = sig_data(:,1);
    if isstruct(XT)
        XT = double([XT.signals.values]);
    end

    if isstruct(YT)
        YT = double([YT.signals.values]);
    end
    
    hs = struct('T', T, 'XT', XT, 'YT', YT);
end