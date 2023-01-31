% this function randomly generates test suite for random algorithm
% PARAMS:
%     Inputs:
%     - input_names: the names of inputs
%     - input_ranges: the ranges of inputs
%     - categorical: the indexes of categorical inputs
%     - opt: algorithm options
%
%     Outputs:
%     - tv: the generated test suite
%     - cat: expanded indexes of categorical inputs (with control points)

function [tv, cat] = gen_suite_random_algo(...
    input_names,...
    input_ranges,...
    categorical,...
    opt...
)
    % initialize test suite storage
    tv = zeros(opt.n_tests, size(input_ranges, 1)*opt.cp_number);
    
    % based on number of control point, expand categorical indexes
    cat = get_categorical(opt, categorical, input_names);
    
    % based on number of control point, expand ranges and names
    [new_ranges, ~] = get_ranges(opt, input_ranges, input_names);
    
    for i = 1:opt.n_tests
        rng('shuffle')
        cur_sample{1} = (new_ranges(:,2) - new_ranges(:,1)).*rand(size(new_ranges,1),1)+new_ranges(:,1);
        
        tv(i:i, :) = cell2mat(cur_sample)';
    end
end