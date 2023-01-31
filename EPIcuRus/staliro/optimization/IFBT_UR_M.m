function [run, history] = IFBT_UR_M(model,inpRanges,opt,Oldt,controlPointNames,categorical,count)
% IFBT_UR_M(UR based Important Features Boundary Test) - generates test cases by focusing mainly on the important features that have the highest impact on the fitness
%           values given the previously generated test cases and the
%           previously generated assumptions with modified details
% USAGE:
%   [run, history] = IFBT_UR(inpRanges,opt,Oldt,controlPointNames,categorical,co
%
% INPUTS:
%
%   inpRanges: n-by-2 lower and upper bounds on initial conditions and
%       input ranges, e.g.,
%           inpRanges(i,1) <= x(i) <= inpRanges(i,2)
%       where n = dimension of the initial conditions vector +
%           the dimension of the input signal vector * # of control points
%
%   opt : staliro options object
%
%   Oldt: previously generated test cases
%
%   controlPointNames: the control points labels
%
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%   count: iteration counter
%
% OUTPUTS:
%   run: a structure array that contains the results of each run of
%       the stochastic optimization algorithm. The structure has the
%       following fields:
%
%           bestRob : The best (min or max) robustness value found
%
%           bestSample : The sample in the search space that generated
%               the trace with the best robustness value.
%
%           nTests: number of tests performed (this is needed if
%               falsification rather than optimization is performed)
%
%           bestCost: Best cost value. bestCost and bestRob are the
%               same for falsification problems. bestCost and bestRob
%               are different for parameter estimation problems. The
%               best robustness found is always stored in bestRob.
%
%           paramVal: Best parameter value. This is used only in
%               parameter query problems. This is valid if only if
%               bestRob is negative.
%
%           falsified: Indicates whether a falsification occurred. This
%               is used if a stochastic optimization algorithm does not
%               return the minimum robustness value found.
%
%           time: The total running time of each run. This value is set by
%               the calling function.
%
%   history: array of structures containing the following fields
%
%       rob: all the robustness values computed for each test
%
%       samples: all the samples generated for each test
%
%       cost: all the cost function values computed for each test.
%           This is the same with robustness values only in the case
%           of falsification.
%
% See also: staliro, staliro_options, UR_Taliro_parameters

% (C) 2010, Sriram Sankaranarayanan, University of Colorado
% (C) 2010, Georgios Fainekos, Arizona State University
% (C) 2019, Shakiba Yaghoubi, Arizona State University
%modified by:
% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 
%
% additional modified by:
% Developed by Xiao Ling, xling4@ncsu.edu, North Carolina State University.

global staliro_SimulationTime

ranges = {};
assumeRanges = {};
tc = 0;
tmc = tic;
max_T = opt.optim_params.max_time;

X = Oldt(:, 1:end-1);  % X contains the input predictors

% if ~isempty(categorical)
% %     X(:, categorical) = double(X>=0.5);
%     for i = 1: size(categorical, 2)
%         X(:, categorical(i)) = double(X(:, categorical(i)) >= 0.5);
% end
Y=Oldt(:,end);       % Y contains the fitness values

[feature, informativeA] = computeAssumption_M(X, Y, controlPointNames, categorical, count, opt);

for assume = 1:size(informativeA,1)
    assumtionsRanges{assume}=getRange(informativeA{assume,1},controlPointNames,inpRanges);
end
perc=2+0.1*count;
for assumeR=1:size(assumtionsRanges,2)
    assumeRanges=assumtionsRanges{assumeR};
    for in=1:size(assumeRanges,1)
        ranges{assumeR}{in}=[];
            for inputBound=1:size(assumeRanges,2)
                if assumeRanges(in,inputBound)~=inpRanges(in,inputBound)
                lowB=assumeRanges(in,inputBound)-assumeRanges(in,inputBound)/perc;
                upB=assumeRanges(in,inputBound)+assumeRanges(in,inputBound)/perc;
                ranges{assumeR}{in}=cat(1,ranges{assumeR}{in},[lowB upB]);
                end
            end
        if isempty(ranges{assumeR}{in})
        ranges{assumeR}{in}=inpRanges(in,:);
        end
    end
end

cellOfFOldTC=getTests(Oldt,informativeA,controlPointNames,opt.testSuiteSize);
nSamples=opt.testSuiteSize;

[nInputs,~] = size(inpRanges);
% Initialize outputs
run = struct('bestRob',[],'bestSample',[],'nTests',[],'bestCost',[],'paramVal',[],'falsified',[],'time',[]);
history = struct('rob',[],'samples',[],'cost',[]);

%initialize curSample vector
curSample = repmat({0}, 1, opt.n_workers);

% get polarity and set the fcn_cmp
if isequal(opt.parameterEstimation,1)
    if isequal(opt.optimization,'min')
        fcn_cmp = @le;
        minmax = @min;
    elseif isequal(opt.optimization,'max')
        fcn_cmp = @ge;
        minmax = @max;
    end
else
    fcn_cmp = @le;
    minmax = @min;
end

if rem(nSamples/opt.n_workers,1) ~= 0
    error('The number of tests (opt.ur_params.n_tests) should be divisible by the number of workers.')
end

% create storage to store the samples for normalization
all_samples = {};

% create stroage to store the generated test suite
test_suite_samples = zeros(nSamples, nInputs);

run.nTests = 0;
% iterate through all assumptions and generate new samples and simulate
% them
for oneAssum=1: size(ranges,2)
    fOldTCs=cellOfFOldTC{1,oneAssum};
    if size(feature,2)>1
        max_nbrOfRangesPerInput = 0;
        index_max = 0;
        
        for f=1:size(feature,2)
            if size(ranges{oneAssum}{feature(f)}, 1) > max_nbrOfRangesPerInput
                max_nbrOfRangesPerInput = size(ranges{oneAssum}{feature(f)}, 1);
                index_max = feature(f);
            end
        end

        for f=1:size(feature,2)
            nbrOfRangesF=size(ranges{oneAssum}{feature(f)},1);
            if nbrOfRangesF < max_nbrOfRangesPerInput
                ct=1;
                for x =nbrOfRangesF+1:max_nbrOfRangesPerInput
                    ranges{oneAssum}{feature(f)}=cat(1,ranges{oneAssum}{feature(f)},ranges{oneAssum}{feature(f)}(ct,:));
                    ct=ct+1;
                end
            end
        end
    else 
        index_max=feature;
    end
    
    tcsize=round(size(fOldTCs,1)/(size(ranges{oneAssum}{index_max},1)))-1;
    for oneinputrange=1:size(ranges{oneAssum}{index_max},1)
        start=(oneinputrange-1)*tcsize;
        endd=oneinputrange*tcsize;
        
        for rangetc = start+1 : endd+1
            tc = tc + 1;
            fOldTC=fOldTCs(rangetc,:); % one test case in FOld
            rng('shuffle');
            for f=1:size(feature,2)
                fOldTC(feature(f))=(ranges{oneAssum}{feature(f)}(oneinputrange,2)-ranges{oneAssum}{feature(f)}(oneinputrange,1)).*rand(size(feature(f),1),1)+ranges{oneAssum}{feature(f)}(oneinputrange,1);
            end
            curSample{1} =fOldTC;
            run.nTests = run.nTests + 1;
            
            % simulate cursample and compute rob
            disp('Iteration number :');
            disp(strcat(num2str(run.nTests),'/',num2str(nSamples)));
            test_suite_samples(run.nTests:run.nTests, :) = cell2mat(curSample)';
            
            if strcmp(model, 'Tiny')
                u_point = cell2mat(curSample);
                step_time = (0:opt.SampTime:staliro_SimulationTime)';

                % create control point vector for signals generation
                for kk = 1:(nInputs/opt.nbrControlPoints)
                    cp_array(kk) = opt.nbrControlPoints*kk;
                end

                inp_signal = ComputeInputSignals(step_time, u_point, opt.interpolationtype, cp_array, inpRanges, staliro_SimulationTime, 0);

                % report error if inp_signal is impty
                assert(~isempty(inp_signal));

                [YT, T] = simulate_Tiny(model, inp_signal, step_time, staliro_SimulationTime);
                curVal = {anti_pattern(YT, T)};
            elseif strcmp(model, 'CW')
                u_point = cell2mat(curSample);
                step_time = (0:opt.SampTime:staliro_SimulationTime)';

                % create control point vector for signals generation
                for kk = 1:(nInputs/opt.nbrControlPoints)
                    cp_array(kk) = opt.nbrControlPoints*kk;
                end

                inp_signal = ComputeInputSignals(step_time, u_point, opt.interpolationtype, cp_array, inpRanges, staliro_SimulationTime, 0);

                % report error if inp_signal is impty
                assert(~isempty(inp_signal));

                [YT, T] = simulate_CW(model, inp_signal, step_time, staliro_SimulationTime);
                curVal = {anti_pattern(YT, T)};
            elseif strcmp(model, 'clc_sldv')
                u_point = cell2mat(curSample);
                step_time = (0:opt.SampTime:staliro_SimulationTime)';
                
                for kk = 1:(nInputs/opt.nbrControlPoints)
                    cp_array(kk) = opt.nbrControlPoints*kk;
                end
                
                inp_signal = ComputeInputSignals(step_time, u_point, opt.interpolationtype, cp_array, inpRanges, staliro_SimulationTime, 0);

                % report error if inp_signal is impty
                assert(~isempty(inp_signal));

                [YT, T] = simulate_CLC(model, inp_signal, step_time, staliro_SimulationTime);
                curVal = {anti_pattern(YT, T)};
            elseif strcmp(model, 'CC')
                u_point = cell2mat(curSample);
                step_time = (0:opt.SampTime:staliro_SimulationTime)';
                
                for kk = 1:(nInputs/opt.nbrControlPoints)
                    cp_array(kk) = opt.nbrControlPoints*kk;
                end
                
                inp_signal = ComputeInputSignals(step_time, u_point, opt.interpolationtype, cp_array, inpRanges, staliro_SimulationTime, 0);
                
                % report error if inp_signal is impty
                assert(~isempty(inp_signal));

                [YT, T] = simulate_CC(model, inp_signal, step_time, staliro_SimulationTime);
                curVal = {anti_pattern(YT, T)};
            elseif strcmp(model, 'Twotanks')
                u_point = cell2mat(curSample);
                
                [YT, T] = simulate_Twotanks(model, u_point, staliro_SimulationTime);
                curVal = {anti_pattern(YT, T)};
            end
            
            [~,a] = size(curVal{1,1});
            
            for j = 1: a
                all_samples{1,run.nTests}{1,j} = curVal{1,1}(j);
            end
            
            if toc(tmc) > max_T
                break
            end
        end
    end
end

[~, c] = size(all_samples);
[~, cc] = size(all_samples{1,1});
run.falsified = 0;

new_samples = zeros(c, cc);
% iterate through all_samples and normalize them
for i = 1: cc
    cur_c = [];
    
    for j = 1: c
        cur_c(j) = cell2mat(all_samples{1, j}(1, i));
    end
    
    cur_max = max(cur_c);
    
    for j = 1: c
        if cur_c(j) == 0
            new_samples(j, i) = 0;
        else
            new_samples(j, i) = cur_c(j) / cur_max;
        end
    end
end

% now we can add all anti-pattern values to calculate the final single
% score
[r, c] = size(new_samples);

for i = 1: r
    cur_sum = 0;
    
    for j = 1: c
        cur_sum = cur_sum + new_samples(i, j);
    end
    
    if i == 1
        history.cost = zeros(nSamples, 1);
        history.rob = zeros(nSamples, 1);
        history.cost(1:opt.n_workers) = cur_sum;
        history.rob(1:opt.n_workers) = cur_sum;
        history.samples = zeros(nSamples, nInputs);
        history.samples(1:opt.n_workers, :) = test_suite_samples(1:opt.n_workers, :);
        
        minmax_val = cur_sum;
        
        bestCost = minmax_val;
        
        run.bestCost = minmax_val;
        run.bestSample = all_samples{1,i};
        run.bestRob = minmax_val;
        run.falsified = minmax_val <= 0;
        no_success = 0;
    else
        history.cost((i-1)*opt.n_workers+1 : i*opt.n_workers) = cur_sum;
        history.rob((i-1)*opt.n_workers+1 : i*opt.n_workers) = cur_sum;
        history.samples((i-1)*opt.n_workers+1 : i*opt.n_workers, :) = test_suite_samples((i-1)*opt.n_workers+1 : i*opt.n_workers, :);
        
        minmax_val = cur_sum;
        
        if (fcn_cmp(minmax_val, bestCost))
            bestCost = minmax_val;
            run.bestCost = minmax_val;
            run.bestRob = minmax_val;
            run.bestSample = all_samples{1,i};
            
            if opt.dispinfo>0
                disp(['Best ==> ', num2str(minmax_val)]);
            end
        
            no_success = 0;
        else
            no_success = no_success + 1;
        end
    end
    
    run.falsified = fcn_cmp(minmax_val, 0) | run.falsified;
end
end