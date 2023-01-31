function [Output, tccov] = Fn_execute_a_test_case(model, test_case, report_cov, input_types, externalinputname, externaloutputname, sim_time, sim_step)
    n_input_vars = size(test_case.dataValues, 1);
    
    for i = 1:n_input_vars
        externalinputdata.signals(i) = Fn_MiLTester_CreateCustomStepSignal_SLDV(test_case.dataValues{i}, test_case.timeValues, sim_time, sim_step);
        
        if(strcmp(input_types{i}, 'tbBOOLEAN') || strcmp(input_types{i}, 'tbBOOLEANF') || strcmp(input_types{i}, 'tbBOOLEANT'))
            externalinputdata.signals(i).values = boolean(externalinputdata.signals(i).values);
        end
    end
    
    n_params = size(test_case.paramValues, 2);
    
    for parcnt = 1:n_params
        eval(sprintf('assignin(''base'',''%s'',%d);',test_case.paramNames{parcnt},test_case.paramValues(parcnt)));
    end
    
    externalinputdata.time = externalinputdata.signals(1).time;
    eval(sprintf('assignin(''base'',''%s'',%s);',externalinputname,'externalinputdata'));
    
    if(report_cov)
        tccov = cvsim(cvtest(strrep(model, '.mdl', '')));
    else
        sim(model)
    end
    
    eval(sprintf('NoOutputs=size(%s.signals,2);', externaloutputname));
    eval(sprintf('Output=zeros(NoOutputs,size(%s.time,1));', externaloutputname));
    
    for i=1:NoOutputs
        eval(sprintf('Output(i,:)=%s.signals(i).values;', externaloutputname));
    end
    
    eval(sprintf('clear %s;', externaloutputname));
end
    