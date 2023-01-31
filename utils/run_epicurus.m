% the script to run epicurus

% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% Modified by Xiao Ling, xling4@ncsu.edu North Carolina State University.

function score = run_epicurus(...
    model,...
    input_names,...
    input_ranges,...
    categorical,...
    opt,...
    sim_opt...
)

    % Defines a variable that contains the name of the requirement of interest
    property='R';
    
    % The test case generation policy
    policy='IFBT_UR_M';
    
    % Considers the default initial conditions of the model
    init_cond = [];
    
    % defines of the requirement of interest
    phi = [];
    preds(1).str='p1';
    preds(1).A=[1 0];
    preds(1).b=50;
    
    % Creates the options of EPIcuRus. Further details are described under
    % epicurus_options.m
    epicurus_opt=epicurus_options();
    epicurus_opt.SampTime=sim_opt.samp_time; 
    epicurus_opt.assumeIterations = 30;
    epicurus_opt.assumeRuns=20;
    epicurus_opt.writeInternalAssumptions=0;
    epicurus_opt.testSuiteSize=opt.n_tests;
    epicurus_opt.iteration1Size=30;
    epicurus_opt.nbrControlPoints=opt.cp_number;
    epicurus_opt.policy=policy;
    epicurus_opt.desiredFitness=0;
    % epicurus_opt.desiredFitness=2;
    epicurus_opt.exploit=0; 
    epicurus_opt.qvtraceenabled=false;
    
    score = epicurus(...
        model,...
        property,...
        init_cond,...
        phi,...
        preds,...
        sim_opt.simulation_time,...
        input_names,...
        categorical,...
        input_ranges,...
        epicurus_opt...
    );
