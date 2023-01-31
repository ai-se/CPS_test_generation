% ALGORITHM: clustering procedure test case generation
% use SWAY continuely cluster on variable space, and select the best
% leaf 
%
% PARAMS:
%     Input:
%     - model: the model will be run in this experiment
%     - input_names: the name of inputs
%     - input_ranges: the range of inputs
%     - categorical: the indexes of categorical inputs
%     - opt: algorithm options
%     - sim_opt: simulation options 
%
%     Output:
%     - score: the mutation score of this run

function score = clustering(...
    model,...
    input_names,...
    input_ranges,...
    categorical,...
    opt,...
    sim_opt...
)
    % first randomly generate n samples
    [tv, cat] = gen_suite(input_names, input_ranges, categorical, opt);
    
    % initialize tree structure
    t = tree({tv, 0});
    
    % build the whole tree
    t = cluster(tv, cat, opt.n_tests, t, 1);
    
    % get indexes of non-parent nodes
    idxes = get_nonparent_node(t);
    
    % for each non-parent node, randomly select one representative
    % data point and simulate it
    record = simulate_node(t, idxes, model, sim_opt, opt, input_ranges);
    
    % after we get anti-pattern values for each representative data
    % point, we use continues domination to rank them.
    rank = better(record);

    % get all data points from that node
    selected_data = t.Node{rank{1,1}, 1}{1, 1};

    % for all the test cases in that node, perform mutation testing
    % and get mutation score
    score = mutation_check(selected_data, model, sim_opt, opt, input_ranges);
    
    
    