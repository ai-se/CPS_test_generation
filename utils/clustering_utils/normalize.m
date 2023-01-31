% function normalize the values by using the following formula:
% (x-lo)/(hi-lo)
function tv_n = normalize(tv, min_v, max_v)
    tv_n = zeros(size(tv,1), size(tv,2));
    
    for i = 1:size(tv,1)
        for j = 1:size(tv,2)
            tv_n(i,j) = (tv(i,j)-min_v(j))/(max_v(j)-min_v(j));
        end
    end
end