function [new_ranges, new_names] = get_ranges(opt, input_ranges, input_names)
    % iterate through input_ranges
    for i = 1:size(input_ranges, 1)
        for j = 1:opt.cp_number
            new_ranges(opt.cp_number*(i-1)+j,:) = input_ranges(i, :);
            new_names(opt.cp_number*(i-1)+j) = strcat(input_names(i), num2str(j));
        end
    end
end