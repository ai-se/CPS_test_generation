% the mutation check function for OD algorithm

function percentage = od_mutation_check(...
    M,...
    test_suite,...
    input_types,...
    n_step,...
    n_outputs,...
    sim_time,...
    samp_time...
)
    
    n_test_cases = size(test_suite.TestCases, 2);
    
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
    mutation_testing_result = zeros(n_test_cases, size(mutants_list,2));
    
    for cnt = 1:n_test_cases
        disp(['checking row ', num2str(cnt)]);
        n_input_vars = size(test_suite.TestCases(cnt).dataValues, 1);
        step_time = (0:samp_time:sim_time)';
        
        for i = 1:n_input_vars
            signal(i) = Fn_MiLTester_CreateCustomStepSignal_SLDV(...
                test_suite.TestCases(cnt).dataValues{i},...
                test_suite.TestCases(cnt).timeValues,...
                sim_time,...
                samp_time...
            );
        
            inp_signal(:,i) = signal(i).values;
        end
        
        % report error if inp_signal is impty
        assert(~isempty(inp_signal));
        
        if strcmp(M, 'Tiny')
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};

                [hs_c, ~, ~] = simulate_Tiny(M, inp_signal, step_time, sim_time);
                [hs_m, ~, ~] = simulate_Tiny(cur_mutant, inp_signal, step_time, sim_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(cnt, j) = 1;
                else
                    mutation_testing_result(cnt, j) = 0;
                end
            end
        elseif strcmp(M, 'CW')
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};

                [hs_c, ~, ~] = simulate_CW(M, inp_signal, step_time, sim_time);
                [hs_m, ~, ~] = simulate_CW(cur_mutant, inp_signal, step_time, sim_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(cnt, j) = 1;
                else
                    mutation_testing_result(cnt, j) = 0;
                end
            end
        elseif strcmp(M, 'CC')
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};

                [hs_c, ~, ~] = simulate_CC(M, inp_signal, step_time, sim_time);
                [hs_m, ~, ~] = simulate_CC(cur_mutant, inp_signal, step_time, sim_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(cnt, j) = 1;
                else
                    mutation_testing_result(cnt, j) = 0;
                end
            end
        elseif strcmp(M, 'clc_sldv')
            for j = 1:size(mutants_list, 2)
                cur_mutant = mutants_list{j};

                [hs_c, ~, ~] = simulate_CLC(M, inp_signal, step_time, sim_time);
                [hs_m, ~, ~] = simulate_CLC(cur_mutant, inp_signal, step_time, sim_time);
                
                dif = zeros(1, size(hs_c, 2));
                for cc = 1:size(hs_c, 2)
                    for rr = 1:size(hs_c, 1)
                        dif(cc) = dif(cc) + abs(hs_c(rr, cc) - hs_m(rr, cc));
                    end
                end
                
                if any(dif > 0)
                    mutation_testing_result(cnt, j) = 1;
                else
                    mutation_testing_result(cnt, j) = 0;
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