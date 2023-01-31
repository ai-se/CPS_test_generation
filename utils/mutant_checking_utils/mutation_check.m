% mutation testing
function percentage = mutation_check(selected_data, M, sim_opt, opt, input_ranges)
    if strcmp(M, 'Tiny')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/Tiny/Tiny_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'Twotanks')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/Twotanks/Twotanks_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'EMB')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/EMB/EMB_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'CW')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CW/CW_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'CC')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CC/CC_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'clc_sldv')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CLC/CLC_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'RHB2')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/RHB2/RHB2_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    elseif strcmp(M, 'AFC')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/AFC/AFC_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    end
    
    % mutation result record
    mutation_testing_result = zeros(size(selected_data, 1), size(mutants_list, 2));
    
    for i = 1:size(selected_data, 1)
        disp(['checking row ', num2str(i)]);
        
        if strcmp(M, 'Tiny')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';

            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

            % report error if inp_signal is impty
            assert(~isempty(inp_signal));

            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};

                [hs_c, ~, ~] = simulate_Tiny(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_Tiny(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);

                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'Twotanks')
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~, ~] = simulate_Twotanks(M, selected_data(i:i, :)', sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_Twotanks(cur_mutant, selected_data(i:i, :)', sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'EMB')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';

            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
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
            
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~, ~] = simulate_EMB(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_EMB(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'CW')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';

            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);
            
            % report error if inp_signal is impty
            assert(~isempty(inp_signal));
            
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~, ~] = simulate_CW(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_CW(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'CC')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';

            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

            % report error if inp_signal is impty
            assert(~isempty(inp_signal));

            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~, ~] = simulate_CC(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_CC(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'clc_sldv')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
            
            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

            % report error if inp_signal is impty
            assert(~isempty(inp_signal));
            
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~, ~] = simulate_CLC(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~, ~] = simulate_CLC(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'RHB2')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
            
            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

            % report error if inp_signal is impty
            assert(~isempty(inp_signal));
            
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~] = simulate_RHB2(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~] = simulate_RHB2(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        elseif strcmp(M, 'AFC')
            u_point = selected_data(i:i, :)';
            step_time = (0:sim_opt.samp_time:sim_opt.simulation_time)';
            
            % create control point vector for signals generation
            for k = 1:size(input_ranges, 1)
                cp_array(k) = opt.cp_number*k;
            end

            inp_signal = ComputeInputSignals(step_time, u_point, sim_opt.interpolation_type, cp_array, input_ranges, sim_opt.simulation_time, 0);

            % report error if inp_signal is impty
            assert(~isempty(inp_signal));
            
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};
                
                [hs_c, ~] = simulate_AFC(M, inp_signal, step_time, sim_opt.simulation_time);
                [hs_m, ~] = simulate_AFC(cur_mutant, inp_signal, step_time, sim_opt.simulation_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(i, j) = 1;
                else
                    mutation_testing_result(i, j) = 0;
                end
            end
        end
    end
    
    
    cur_score = zeros(size(mutation_testing_result, 2), 1);
    for j = 1:size(mutation_testing_result, 2)
        if any( mutation_testing_result(:, j) == 1 )
            cur_score(j) = 1;
        end
    end
    
    percentage = sum(cur_score) / size(mutation_testing_result, 2);
end