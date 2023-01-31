% get_categorical expand the categorical indexes based on the control
% point.
%
% input:
%   opt: option of the algorithm defined by user
%   categorical: list of indexes of category data
%   input_names: the list of names of inputs
% output:
%   cat: list of expanded indexes of category data

function cat = get_categorical(opt, categorical, input_names)
    assert(size(categorical, 2) <= size(input_names, 2));
    
    cat = zeros(1, size(categorical, 2)*opt.cp_number);
    
    for i = 1:size(categorical, 2)
        for j = 0:opt.cp_number-1
            cat(i*opt.cp_number-j) = categorical(i) * opt.cp_number - j;
        end
    end
end