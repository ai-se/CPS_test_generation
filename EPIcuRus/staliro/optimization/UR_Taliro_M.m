function [run, history] = UR_Taliro_M(model,inpRanges,opt,Oldt,controlPointNames,categorical,count)
% UR_Taliro_M - Performs random sampling in the state and input spaces.
% Gradient descent can be applied to samples optionally
% The code is similar to UR_Taliro, but modified to runnable with
% anti_pattern.
%
% USAGE:
%   [run, history] = UR_Taliro_M(inpRanges,opt)
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
% modified by:
% Copyright by North Carolina State University
% Developed by Xiao Ling, xling4@ncsu.edu North Carolina State University.

global staliro_SimulationTime

tmc = tic;
opt.dispinfo = 0;
params = opt.optim_params;
GD_params = opt.optim_params.GD_params;
max_T = opt.optim_params.max_time;
no_dec_TH = GD_params.no_dec_TH;

if params.apply_GD 
    if strcmp('',GD_params.model)
        error('The Simulink model name is not specified, see help GD_parameters')
    else
        assert(~isempty(getlinio(GD_params.model)), 'Linearization I/O are not specified correctly in the Simulink model')
    end
end

nSamples = params.n_tests;
StopCond = opt.falsification;

[nInputs, ~] = size(inpRanges); 

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
% iteratly generate samples and simulate them.
for i = 1:nSamples/opt.n_workers
    % random generation of cursample
    for jj = 1:opt.n_workers
        rng('shuffle');
        curSample{jj} = (inpRanges(:,1)-inpRanges(:,2)).*rand(nInputs,1)+inpRanges(:,2);
        
%         if ~isempty(categorical)
%             for idx = 1:size(categorical, 2)
%                 if curSample{jj}(categorical(idx)) >= 0.5
%                     curSample{jj}(categorical(idx)) = 1;
%                 else
%                     curSample{jj}(categorical(idx)) = 0;
%                 end
%             end
%         end
    end
    
    % simulate cursample and compute rob
    disp('Iteration number :');
    disp(strcat(num2str(run.nTests+1),'/',num2str(nSamples)));
    test_suite_samples(i:i,:) = cell2mat(curSample)';
    
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
    
    run.nTests = run.nTests + 1;
    [~, a] = size(curVal{1,1});
    
    for j = 1: a
        all_samples{1,i}{1,j} = curVal{1,1}(j);
    end
    
    if toc(tmc) > max_T
        break
    end
end

[~, c] = size(all_samples);
[~, cc] = size(all_samples{1, 1});
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
        new_best_sample = 1;
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
            new_best_sample = 1;
        else
            no_success = no_success + 1;
        end
        
        if no_success > no_dec_TH && new_best_sample && params.apply_GD
            no_success = 0;
            new_best_sample = 0;
            
            try
                [minmax_val, Inp,  GD_iter] = feval(GD_params.GD_func, run.bestSample, run.bestRob, tmc, max_T, opt); %%%%%%%%%
            catch
                error('Unable to evaluate the GD function')
            end
            
            if (fcn_cmp(minmax_val,bestCost))
                bestCost = minmax_val;
                run.bestCost = minmax_val;
                run.bestRob = minmax_val;
                run.bestSample = Inp;
                run.nTests = run.nTests+GD_iter;
                
                if opt.dispinfo>0
                    disp(['Best ==> ' num2str(minmax_val)]);
                end
            end
        end
    end
    
    run.falsified = fcn_cmp(minmax_val, 0) | run.falsified;
end

end
