function [sig, t, cov] = simulate_Twotanks(M, inp_array, sim_time)
    assignin('base', 'tank1_sensor_hi_height_m_in', inp_array(1))
    assignin('base', 'tank1_sensor_lo_height_m_in', inp_array(2))
    assignin('base', 'tank1_pump_flow_rate_m3s_in', inp_array(3))
    assignin('base', 'tank1_valve_flow_rate_m3s_in', inp_array(4))
    assignin('base', 'tank1_cross_section_area_m2_in', inp_array(5))
    assignin('base', 'tank2_sensor_hi_height_m_in', inp_array(6))
    assignin('base', 'tank2_sensor_md_height_m_in', inp_array(7))
    assignin('base', 'tank2_sensor_lo_height_m_in', inp_array(8))
    assignin('base', 'tank2_p_valve_flow_rate_m3s_in', inp_array(9))
    assignin('base', 'tank2_e_valve_flow_rate_m3s_in', inp_array(10))
    assignin('base', 'tank2_cross_section_area_m2_in', inp_array(11))
%     tank1_sensor_hi_height_m_in = inp_array(1);
%     tank1_sensor_lo_height_m_in = inp_array(2);
%     tank1_pump_flow_rate_m3s_in =  inp_array(3);
%     tank1_valve_flow_rate_m3s_in = inp_array(4);
%     tank1_cross_section_area_m2_in = inp_array(5);
%     tank2_sensor_hi_height_m_in = inp_array(6);
%     tank2_sensor_md_height_m_in = inp_array(7);
%     tank2_sensor_lo_height_m_in = inp_array(8);
%     tank2_p_valve_flow_rate_m3s_in = inp_array(9);
%     tank2_e_valve_flow_rate_m3s_in = inp_array(10);
%     tank2_cross_section_area_m2_in = inp_array(11);
    
    open M;
    cov = cvsim(cvtest(strrep(M, '.mdl', '')));
    
    sig(:, 1) = Tank1Height;
    sig(:, 2) = Tank2Height;
    sig(:, 3) = Tank1SensorHValue;
    sig(:, 4) = Tank2SensorHValue;
    sig(:, 5) = Tank2SensorMValue;
    sig(:, 6) = Tank2SensorLValue;
    t = tout;
end