% the main script to run the experiment
disp(' Starting to run experiment ');

close all;
clear;
cur_path = fileparts(which('experiment_runner.m'));
addpath(genpath(cur_path));

%%% define some experiment parameters (adjust based on design)
repeat = 20;
cp_number = 3;
n_samples = 256;
n_tests = 16;

%%% define parameters for different case studies

% tiny parameters
% M = 'Tiny';
% input_names = {'In1_', 'In2_', 'In3_'};
% n_outputs = 1;
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
n_outputs = 41
categorical = [];
input_ranges = [0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 4.999; 0 1; 0 1; 0 1; 0 1; 0 1; 0 1];
sim_time = 5;
step_time = 0.001;
CW_Init

% CC parameters
% M = 'CC';
% input_names = {'In1_', 'In2_', 'In3_', 'In4_', 'In5_', 'In6_'};
% n_outputs = 2;
% categorical = [];
% input_ranges = [0 1; 0 1; 0 1; 0 200; 0 1; 0 1];
% sim_time = 40;
% step_time = 0.001;

% CLC parameters
% M = 'clc_sldv';
% input_names = {'In1_', 'In2_'};
% n_outputs = 7;
% categorical = [];
% input_ranges = [0 2; 0 2];
% sim_time = 10;
% step_time = 0.01;

[t, experiment_result] = experiment_runner(...
    M,...
    n_outputs,...
    input_names,...
    categorical,...
    input_ranges,...
    sim_time,...
    step_time,...
    repeat,...
    cp_number,...
    n_samples,...
    n_tests...
);

disp(experiment_result)
disp(t)
    