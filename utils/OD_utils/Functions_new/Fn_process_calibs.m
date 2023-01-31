function [n_calibs, calibs_name, calibs_type, calibs_min, calibs_max] = Fn_process_calibs(calib_info)
    field_name = fieldnames(calib_info{1,1});
    n_calibs = numel(field_name);
    
    calibs_name = cell(1, n_calibs);
    calibs_type = cell(1, n_calibs);
    calibs_min = zeros(n_calibs, 1);
    calibs_max = zeros(n_calibs, 1);
    
    for k = 1:numel(field_name)
        cur_field = calib_info{1,1}.(field_name{k});
        calibs_name{k} = cur_field.name;
        calibs_type{k} = cur_field.type;
        calibs_min(k, 1) = cur_field.min_val;
        calibs_max(k, 1) = cur_field.max_val;
    end