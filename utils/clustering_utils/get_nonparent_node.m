% function to get the indexes of non-parent node
function idxes = get_nonparent_node(t)
    count = 1;
    
    for i = 1:size(t.Parent)
        if ~ismember(i, t.Parent)
            idxes(count) = i;
            count = count + 1;
        end
    end
end