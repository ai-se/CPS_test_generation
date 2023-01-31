function [n_inputs, inputs_name, inputs_type, inputs_min, inputs_max] = Fn_process_inputs(input_info)
    field_name = fieldnames(input_info{1,1});
    n_inputs = numel(field_name);
    
    inputs_name = cell(1, n_inputs);
    inputs_type = cell(1, n_inputs);
    inputs_min = zeros(n_inputs, 1);
    inputs_max = zeros(n_inputs, 1);
    
    for k = 1:numel(field_name)
        cur_field = input_info{1,1}.(field_name{k});
        inputs_name{k} = cur_field.name;
        inputs_type{k} = cur_field.type;
        inputs_min(k, 1) = cur_field.min_val;
        inputs_max(k, 1) = cur_field.max_val;
    end
  