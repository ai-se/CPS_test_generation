% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

% Modified by Xiao Ling, xling4@ncsu.edu North Carolina State University.

% EPICURUS iteratively performs the test case generation and the assumption generation for one model, one property and one policy. 
% It stops when the number of iterations reaches the maximum number of
% iterations set. Then it writes the results of each assume run into the
% results folder. the results contain a .qct file containing the assumption
% and a .txt file containing the total time required to generate the assumption.
%
% INPUTs
%   - M: the simulink model name. 
%   - P: the property name.
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see staliro_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       staliro_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%       In case of parameter mining:
%           If staliro is run for specification parameter mining, then set the 
%           staliro option parameterEstimation to 1 (the default value is 0):
%               opt.parameterEstimation = 1;
%           and read the instructions under staliro_options.parameterEstimation 
%           on how to define the mapping of the atomic propositions.	
%
%   - sim_time : The simulation time.
%
%   - input_names: An array with the input names
%
%   - categorical: the index of the categorical inputs in input_name. if none write []
%
%   - input_range : 
%       The constraints for the parameterization of the input signal space.
%       The following options are supported:
%
%          * an empty array : no input signals.
%              % Example when no input signals are present
%              input_range = [];
%
%          * a hyper-rectangle that holds the range of possible values for 
%            the input signals. This is a Matlab m x 2 array, where m is the  
%            number of inputs to the model. Format:
%               [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_m UpperBound_m];
%            Examples: 
%              % Example for two input signals (for example for a Simulink model 
%              % with two input ports)
%              input_range = [5.6 7.8; 8 12]; 
%
%          * a cell vector. This is a more advanced option. Each input signal is 
%            parameterized using a number of parameters. Each parameter can 
%            range within a specific interval. The cell vector contains the
%            ranges of the parameters for each input signal. That is,
%                { [p_11_min p_11_max; ...; p_1n1_min p_1n1_max];
%                                    ...
%                  [p_m1_min p_m1_max; ...; p_1nm_min p_1nm_max]}
%            where m is the number of input signals and n1 ... nm is the number
%                  of parameters (control points) for each input signal.
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%       Additional constraints on the input signal search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%   - assume_opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.

function score = epicurus(...
    M,...
    P,...
    init_cond,...
    phi,...
    preds,...
    sim_time,...
    input_names,...
    categorical,...
    input_range,...
    assume_opt...
)
global hFeatures;
    if (assume_opt.nbrControlPoints==1) % interpolation function is either const or pconst
        interpolation_type='const';
    else
        interpolation_type='pconst';
    end
    numberOfInputs=size(input_names,2); 
    cp_array=assume_opt.nbrControlPoints*ones(1,numberOfInputs);
    % categorical and cp_names in terms of control points
    [categorical,cp_names]=getListOfFeatures(categorical,assume_opt.nbrControlPoints,input_names,cp_array);
    
    for run=1:assume_opt.assumeRuns
        disp('-------------------------------');
        disp(['Run: ',num2str(run),'/',num2str(assume_opt.assumeRuns)])      
        Oldt=[];   % previously generated test cases
        A={}; % last assumptions
        count=1; % iteration counter
        valid=0; % valid assumption is initialized to false
        hFeatures=[];
        
        kmax=(sim_time/assume_opt.SampTime);
        while  ((valid==0) || (valid==2))&& (count<=assume_opt.assumeIterations)
            if count==1
                assume_opt.first=1;
            else
                assume_opt.first=0;
            end
            
            disp(['Assume iteration: ',num2str(count)]);

            tv = genSuite(...
                M,...
                init_cond,...
                phi,...
                preds,...
                sim_time,...
                Oldt,...
                input_range,...
                interpolation_type,...
                cp_array,...
                cp_names,...
                categorical,...
                count,...
                assume_opt...
            );
        
            [A] = genAssum_M(tv,Oldt,cp_names,categorical,assume_opt);
            if ~isempty(A) && ~strcmp(A{1}, '(NaN)') && count == assume_opt.assumeIterations
                [percentage, ~] = mutationCheck(...
                    A,...
                    M,...
                    cp_names,...
                    cp_array,...
                    input_range,...
                    assume_opt,...
                    sim_time,...
                    kmax,...
                    categorical...
                );
                
                score(run) = percentage;
            end
            
            Oldt=cat(1,Oldt,tv); 
            count=count+1;
        end
    end
end
