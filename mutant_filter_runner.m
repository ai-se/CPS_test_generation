% This script is used to filtered the manually generated mutants which
% cannot be killed by any of the 100 randomly generated test cases or 
% killed by all those test cases

disp(' Starting to run mutant filtering script ');

close all;
clear;
cur_path = fileparts(which('mutant_filter_runner.m'));
addpath(genpath(cur_path));

% tiny parameters
% M = 'Tiny';
% input_names = {'In1_', 'In2_', 'In3_'};
% categorical = [];
% input_ranges = [-100 100; -100 100; -100 100];
% sim_time = 10;
% step_time = 0.1;

% two tanks parameters
% M = 'Twotanks';
% input_names = {'In1_', 'In2_', 'In3_', 'In4_', 'In5_', 'In6_', 'In7_', 'In8_', 'In9_', 'In10_', 'In11_'};
% categorical = [];
% input_ranges = [3.5 8; 1 3.5; -0.4 0.4; -0.3 0.3; 0 1.3; 2.5 4.3; 1 1.5; 1.5 3.0; -0.3 0.3; -0.4 0.4; 0.5 3];
% sim_time = 300;
% step_time = 0.1;

% EMB parameters
% M = 'EMB';
% input_names = {'In1_'};
% categorical = 1;
% input_ranges = [0 1];
% sim_time = 6;
% step_time = 0.000005;

% CW parameters
M = 'CW';
input_names = {'In1_', 'In2_', 'In3_', 'In4_', 'In5_', 'In6_', 'In7_', 'In8_', 'In9_', 'In10_', 'In11_', 'In12_', 'In13_', 'In14_', 'In15_'};
categorical = [10 11 12 13 14 15];
input_ranges = [0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1];
sim_time = 5;
step_time = 0.001;

% CC parameters
% M = 'CC';
% input_names = {'In1_', 'In2_', 'In3_', 'In4_', 'In5_', 'In6_'};
% categorical = [1 2 3 5 6];
% input_ranges = [0 1; 0 1; 0 1; 0 200; 0 1; 0 1];
% sim_time = 40;
% step_time = 0.001;

% CLC parameters
% M = 'clc_sldv';
% input_names = {'In1_', 'In2_'};
% categorical = [];
% input_ranges = [0 2; 0 2];
% sim_time = 10;
% step_time = 0.01;

% RHB2 parameters
% M = 'RHB2';
% input_names = {'In1_', 'In2_'};
% categorical = [];
% input_ranges = [1 2; 0.8 1.2];
% sim_time = 24;
% step_time = 0.05;

% AFC parameters
% M = 'AFC';
% input_names = {'In1_', 'In2_'};
% categorical = [];
% input_ranges = [900 1100; 0 61.1];
% sim_time = 50;
% step_time = 0.05;

opt.repeat = 1;
opt.cp_number = 5;
opt.n_samples = 200;
opt.n_tests = 200;

sim_opt.samp_time = step_time;
sim_opt.simulation_time = sim_time;
interpolation = 'pconst';
for i = 1:size(input_names, 2)
    sim_opt.interpolation_type(i,:) = {interpolation};
end

[tv, cat] = gen_suite(input_names, input_ranges, categorical, opt);

[result, mutants_list] = mutant_filter_check(...
    tv,...
    M,...
    sim_opt,...
    opt,...
    input_ranges...
);