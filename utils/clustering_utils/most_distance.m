% function most_distance find the farest distance point to the input data
% point by using the Euclidean distance.
function [p_idx, point] = most_distance(tv, x)
    dd = log(0);
    
    for i = 1:size(tv,1)
        d = distance(tv(i:i, :), x);
        
        if d > dd
            dd = d;
            p_idx = i;
            point = tv(p_idx:p_idx, :);
        end
    end
end