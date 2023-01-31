% this function simulate the inputs and calculate the anti-pattern values.
function anti_pattern_value = compute_anti_pattern(M, inp_array, sim_opt, opt, input_ranges)
    if strcmp(M, 'Tiny')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end

        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

        % report error if inp_signal is impty
        assert(~isempty(inp_signal));

        [YT, T] = simulate_Tiny(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'Twotanks')
        [YT, T] = simulate_Twotanks(M, inp_array', sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'EMB')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end
        
        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
        for k = 1:size(inp_signal, 1)
            if inp_signal(k) >= 0.5
                inp_signal(k) = 1;
            else
                inp_signal(k) = 0;
            end
        end
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        [YT, T] = simulate_EMB(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'CW')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end
        
        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        [YT, T] = simulate_CW(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'CC')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end
        
        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        [YT, T] = simulate_CC(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'clc_sldv')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end
        
        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        [YT, T] = simulate_CLC(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    elseif strcmp(M, 'RHB2')
        u_point = inp_array';
        step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
        
        % create control point vector for signals generation
        for i = 1:size(input_ranges, 1)
            cp_array(i) = opt.cp_number*i;
        end
        
        inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        [YT, T] = simulate_RHB2(M, inp_signal, step_time, sim_opt.simulation_time);
        anti_pattern_value = anti_pattern(YT, T);
    end
end