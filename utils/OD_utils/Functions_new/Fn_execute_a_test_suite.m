function [test_suite_dist, test_suite_output, ts_cov] = Fn_execute_a_test_suite(model, test_suite, report_cov, inputs_type, n_step, n_outputs, sim_time, sim_step, max_dist, output_idx)
    n_test_cases = size(test_suite.TestCases, 2);
    
    if(exist('output_idx', 'var'))
        test_suite_dist = 0;
        test_suite_output = zeros(n_test_cases, n_step+1);
    else
        test_suite_dist = zeros(n_outputs, 1);
        test_suite_output = zeros(n_test_cases, n_outputs, n_step+1);
    end
    
    for tc = 1:n_test_cases
        output = Fn_execute_a_test_case(model, test_suite.TestCases(tc), false, inputs_type, 'externalinputdata', 'yout', sim_time, sim_step);
        
        if (report_cov)
            [m_output, tc_cov] = Fn_execute_a_test_case(model, test_suite.TestCases(tc), true, inputs_type, 'externalinputdata', 'yout', sim_time, sim_step);
            
            if (tc == 1)
                ts_cov = tc_cov;
            else
                ts_cov = ts_cov + tc_cov;
            end
        else
            m_output = Fn_execute_a_test_case(model, test_suite.TestCases(tc), false, inputs_type, 'externalinputdata', 'yout', sim_time, sim_step);
        end
        
        if(exist('output_idx', 'var'))
            test_suite_output(tc, :) = m_output(output_idx, :);
            test_case_dist = norm(m_output(output_idx, :) - output(output_idx, :))/max_dist(output_idx);
            
            if (test_case_dist > test_suite_dist)
                test_suite_dist = test_case_dist;
            end
        else
            test_suite_output(tc,:,:) = m_output(:,:);
            
            for ocnt = 1:n_outputs
                test_case_dist = norm(m_output(ocnt, :) - output(ocnt, :))/max_dist(ocnt);
                
                if (test_case_dist > test_suite_dist(ocnt))
                    
                    test_suite_dist(ocnt) = test_case_dist;
                end
            end
        end
    end
end