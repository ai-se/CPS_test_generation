function [n_outputs, outputs_name, outputs_type, outputs_min, outputs_max] = Fn_process_outputs(output_info)
    field_name = fieldnames(output_info{1,1});
    n_outputs = numel(field_name);
    
    outputs_name = cell(1, n_outputs);
    outputs_type = cell(1, n_outputs);
    outputs_min = zeros(n_outputs, 1);
    outputs_max = zeros(n_outputs, 1);
    
    for k = 1:numel(field_name)
        cur_field = output_info{1,1}.(field_name{k});
        outputs_name{k} = cur_field.name;
        outputs_type{k} = cur_field.type;
        outputs_min(k, 1) = cur_field.min_val;
        outputs_max(k, 1) = cur_field.max_val;
    end