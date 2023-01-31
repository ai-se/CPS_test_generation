% function find_minmax finds the min/max for each column
function [min_v, max_v] = find_minmax(tv, cat)
    min_v = zeros(1, size(tv, 2));
    max_v = zeros(1, size(tv, 2));
    
    % initialize
    for i = 1:size(tv,2)
        if ~ismember(i, cat)
            min_v(i) = 1/0;
            max_v(i) = log(0);
        else
            min_v(i) = 0;
            max_v(i) = 1;
        end
    end
    
    % loop through tv to find min/max for each column
    for c = 1:size(tv,2)
        if ~ismember(c, cat)
            min_v(c) = min(tv(:,c:c));
            max_v(c) = max(tv(:,c:c));
        end
    end
end
    