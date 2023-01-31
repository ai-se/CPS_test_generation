function [percentage, assumption] = mutationCheck(...
    A,...
    model,...
    cp_names,...
    cp_array,...
    input_ranges,...
    assume_opt,...
    sim_time,...
    kmax,...
    categorical...
)
    global staliro_SimulationTime;
    global staliro_InputBounds;
    global temp_ControlPoints;
    global staliro_dimX;
    global staliro_opt;

    if strcmp(model, 'Tiny')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/Tiny/Tiny_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name,2)
            [p,f,~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p,f);
        end
    elseif strcmp(model, 'CC')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CC/CC_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name,2)
            [p,f,~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p,f);
        end
    elseif strcmp(model, 'CW')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CW/CW_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name,2)
            [p,f,~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p,f);
        end
    elseif strcmp(model, 'clc_sldv')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/CLC/CLC_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name,2)
            [p,f,~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p,f);
        end
    elseif strcmp(model, 'Twotanks')
        dinfo = dir(fullfile('E:/Research/CPS_testing/TestCaseGeneration/project/Twotanks/Twotanks_filtered_mutants', '*.slx'));
        file_name = {dinfo.name};
        mutants_list = {};
        for i = 1:size(file_name, 2)
            [p, f, ~] = fileparts(file_name{i});
            mutants_list{i} = fullfile(p, f);
        end
    end
        
    assumeToCheck = A(:,1);
    nTestsToCheck = assume_opt.testSuiteSize;
    
    % initial inpranges
    inpranges = [];
    count = 1;
    for ips = 1:size(input_ranges,1)
        for cps = 1:cp_array(ips)
            inpranges(count, :) = input_ranges(ips, :);
            count = count + 1;
        end
    end
    
    % extract ranges
    for assume = 1:size(assumeToCheck, 1)
        assumptionsRanges{assume} = getRange(assumeToCheck{assume,1}, cp_names, inpranges);
    end
    
    ranges = assumptionsRanges{1,1};
    [nInputs,~] = size(ranges);
    
    disp(strcat('Current test suite size', ':', num2str(nTestsToCheck)));
        
    cur_percentage_array = zeros(5, 1);
        
    for iter = 1:5
        disp(strcat('Current iteration', ':', num2str(iter)));
        %initialize curSample vector
        curSample = repmat({0}, 1, 1);

        % initialize storage
        tested_sample = zeros(nTestsToCheck, nInputs);

        % uniformly random generate n samples in ranges and run on mutants
        mutation_testing_result = zeros(nTestsToCheck, size(mutants_list,2));
        for i = 1:nTestsToCheck
            rng('shuffle');
            curSample{1} = (ranges(:,1)-ranges(:,2)).*rand(nInputs,1)+ranges(:,2);

            tested_sample(i:i, :) = cell2mat(curSample)';

            inpArray = cell2mat(curSample);
            XPoint = inpArray(1:staliro_dimX);
            UPoint = inpArray(staliro_dimX+1:end);

            for j = 1:size(mutants_list,2)
                curMutant = mutants_list{j};

                if strcmp(model, 'Tiny')
                    step_time = (0:staliro_opt.SampTime:staliro_SimulationTime)';
                    
                    for kk = 1:size(input_ranges, 1)
                        cpArray(kk) = cp_array(1)*kk;
                    end
                    
                    inp_signal = ComputeInputSignals(step_time, UPoint, staliro_opt.interpolationtype, cpArray, input_ranges, staliro_SimulationTime, 0);
                    % report error if inp_signal is impty
                    assert(~isempty(inp_signal));

                    [hs_c, ~] = simulate_Tiny(model, inp_signal, step_time, staliro_SimulationTime);
                    [hs_m, ~] = simulate_Tiny(curMutant, inp_signal, step_time, staliro_SimulationTime);

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
                elseif strcmp(model, 'Twotanks')
                    [hs_c, ~] = simulate_Twotanks(model, UPoint, staliro_SimulationTime);
                    [hs_m, ~] = simulate_Twotanks(curMutant, UPoint, staliro_SimulationTime);

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
                elseif strcmp(model, 'CW')
                    step_time = (0:staliro_opt.SampTime:staliro_SimulationTime)';

                    for kk = 1:size(input_ranges, 1)
                        cpArray(kk) = cp_array(1)*kk;
                    end

                    inp_signal = ComputeInputSignals(step_time, UPoint, staliro_opt.interpolationtype, cpArray, input_ranges, staliro_SimulationTime, 0);
                    % report error if inp_signal is impty
                    assert(~isempty(inp_signal));

                    [hs_c, ~] = simulate_CW(model, inp_signal, step_time, staliro_SimulationTime);
                    [hs_m, ~] = simulate_CW(curMutant, inp_signal, step_time, staliro_SimulationTime);

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
                elseif strcmp(model, 'clc_sldv')
                    step_time = (0:staliro_opt.SampTime:staliro_SimulationTime)';

                    for kk = 1:size(input_ranges, 1)
                        cpArray(kk) = cp_array(1)*kk;
                    end

                    inp_signal = ComputeInputSignals(step_time, UPoint, staliro_opt.interpolationtype, cpArray, input_ranges, staliro_SimulationTime, 0);
                    % report error if inp_signal is impty
                    assert(~isempty(inp_signal));

                    [hs_c, ~] = simulate_CLC(model, inp_signal, step_time, staliro_SimulationTime);
                    [hs_m, ~] = simulate_CLC(curMutant, inp_signal, step_time, staliro_SimulationTime);

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
                elseif strcmp(model, 'CC')
                    step_time = (0:staliro_opt.SampTime:staliro_SimulationTime)';

                    for kk = 1:size(input_ranges, 1)
                        cpArray(kk) = cp_array(1)*kk;
                    end

                    inp_signal = ComputeInputSignals(step_time, UPoint, staliro_opt.interpolationtype, cpArray, input_ranges, staliro_SimulationTime, 0);
                    % report error if inp_signal is impty
                    assert(~isempty(inp_signal));

                    [hs_c, ~] = simulate_CC(model, inp_signal, step_time, staliro_SimulationTime);
                    [hs_m, ~] = simulate_CC(curMutant, inp_signal, step_time, staliro_SimulationTime);

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

        cur_percentage_array(iter) = sum(cur_score) / size(mutation_testing_result, 2);
    end

    percentage = median(cur_percentage_array);
    
    assumption = assumeToCheck;
end