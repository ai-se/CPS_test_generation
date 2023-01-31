% this function gets tree structure and non-parent nodes, selects one
% representative data point from each node, and simulates it to get
% anti-pattern values
function record = simulate_node(t, idxes, model, sim_opt, opt, input_ranges)
    record = {};
    
    for i = 1:size(idxes, 2)
        cur_dps = t.Node{idxes(i),1}{1,1};
        
        % random select one data point
        rand_int = randi([1, size(cur_dps, 1)], 1, 1);
        representative = cur_dps(rand_int:rand_int, :);
        
        % simulate the current data point and compute the anti-pattern
        % values.
        cur_val = compute_anti_pattern(model, representative, sim_opt, opt, input_ranges);
        
        record{i,1} = idxes(i);
        record{i,2} = cur_val;
    end
end