% this function implements the continues domination on the objective space
% to rank all candidates
function pivot = better(record)
    pivot = {record{1, 1}, record{1, 2}};
    
    for i = 2:size(record, 1)
        if continues_domination(record{i, 2}, pivot{1, 2})
            pivot = {record{i, 1}, record{i, 2}};
        end
    end
end