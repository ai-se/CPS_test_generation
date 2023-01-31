% function to start the experiment
% params:
%     Input:
%     - model: the model will be run in this experiment
%     - input_names: the name of simulator inputs
%     - categorical: the list of indexes of categorical input(s)
%     - input_ranges: the range of inputs
%     - sim_time: simulation time
%     - step_time: time stamp during the simulation
%     - repeat: number of repeats for the experiment
%     - cp_number: number of control points
%     - n_samples: number of initial random samples
%     - n_test: number of test cases in the test suite
%
%     Output:
%     - storage: the m*n array where n is number of repeat, m means
%                number of running mode
%     - execution_time: the algorithm + simulation execution time

function [execution_time, storage] = experiment_runner(...
    model,...
    n_outputs,...
    input_names,...
    categorical,...
    input_ranges,...
    sim_time,...
    step_time,...
    repeat,...
    cp_number,...
    n_samples,...
    n_tests...
)
    % define running mode
%     running_mode = ["random", "epicurus", "sway", "od"];
    running_mode = ["od"];
    
    % define opt and sim_opt
    opt.repeat = repeat;
    opt.cp_number = cp_number;
    opt.n_samples = n_samples;
    opt.n_tests = n_tests;
    
    sim_opt.samp_time = step_time;
    sim_opt.simulation_time = sim_time;
    interpolation = 'pconst';
    for i = 1:size(input_names, 2)
        sim_opt.interpolation_type(i,:) = {interpolation};
    end
    
    % initialize return storage
    storage = zeros(size(running_mode, 2), repeat);
    execution_time = zeros(size(running_mode, 2), 1);
    
    % loop through running mode, and run experiment
    for i = 1:size(running_mode, 2)
        start_time = tic;
        cur_mode = running_mode(i);
        
        score = main_script(...
            model,...
            n_outputs,...
            input_names,...
            input_ranges,...
            categorical,...
            cur_mode,...
            opt,...
            sim_opt...
        );
        
        storage(i, :) = score;
        execution_time(i, 1) = toc(start_time);
    end
    
    delete *.slxc
    
    
    