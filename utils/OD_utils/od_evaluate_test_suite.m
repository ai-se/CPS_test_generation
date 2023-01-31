function [output, ts_cov] = od_evaluate_test_suite(...
    model,...
    test_suite,...
    input_types,...
    n_step,...
    n_outputs,...
    sim_time,...
    samp_time,...
    output_idx...
)
    
    n_test_cases = size(test_suite.TestCases, 2);
    
    if(exist('output_idx', 'var'))
        output = zeros(n_test_cases, n_step+1);
    else
        output = zeros(n_test_cases, n_outputs, n_step+1);
    end
    
    for tc = 1:n_test_cases
        [m_output, tc_cov] = od_evaluate_test_case(...
            model,...
            test_suite.TestCases(tc),...
            input_types,...
            sim_time,...
            samp_time...
        );
        
        if tc == 1
            ts_cov = tc_cov;
        else
            ts_cov = ts_cov + tc_cov;
        end
        
        if(exist('output_idx', 'var'))
            output(tc,:) = m_output(:,output_idx);
        else
            output(tc,:,:) = m_output(:,:);
        end
    end
end