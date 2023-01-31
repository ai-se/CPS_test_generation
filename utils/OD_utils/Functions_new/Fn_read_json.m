function [sim_time, input_info, calib_info, output_info] = Fn_read_json(project_name)
    fname = append(project_name, '_para.json');
    fid = fopen(fname);
    raw = fread(fid, inf);
    str = char(raw');
    fclose(fid);
    val = jsondecode(str);
    
    sim_time = extractfield(val, 'sim_time');
    input_info = extractfield(val, 'inputs');
    calib_info = extractfield(val, 'calibs');
    output_info = extractfield(val, 'outputs');