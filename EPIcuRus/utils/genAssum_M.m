% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

%   genAssum learns assumptions from all the previously generated test cases.
%   it takes the data, builds a regression tree then extracts the conditions on the nodes 
%   from each branch of the tree to build the assumptions and returns the assumptions.
%
% INPUTS
%   tv: the newly generated test cases
%
%   Oldt: the prviously generated test cases. tv and Oldt will be merged and used for assumption generation
%
%   inputnames: a string array of the input control points names. 
%               it serves as the parameter predictors names during the decision tree building 
% 
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%
%   - assume_options : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
% OUTPUTS
%   assumptionArray: a cell array that contains the selected assumptions + information:
%                       C | probability estimate | leaf size | Parent node index | the Mean fitness at the leaf | importantFeature(if exists)
%                       Each row contains the information of one constraint C={c1 ^ c2 ^.. cn} where ci is a condition on one input
%                       Example of constraint C: ‘(input1 < 1) and (input2>= 10)’
%
%   parent_constraints: The parent constraints of the leaves associated with the selected assumptions assumptionArray.
%                       It can serve as a parameter in the function getRanges (genSuite) to get the next candidate input ranges
%                       on which the next test generation will be based. 
%
%   interAssum: a cell array of the intemediate assumptions generated + information
%               It serves as history
%
% modified by
% Xiao Ling, xling4@ncsu.edu, North Carolina State University

function [informativeA] = genAssum_M(tv,Olt,inputnames,categorical,assume_options)
    assume_opt = assume_options();
    data = [Olt;tv];
    X = data(:, 1:end-1);
    if ~isempty(categorical) % if the categorical is set , make sure the inputs are booleans
        for i = 1:size(categorical, 2)
            X(:,categorical(i)) = double(X(:,categorical(i))>=0.5);
        end
%         X(:,categorical)=double(X>=0.5);
    end
    Y=data(:,end);       % Y contains the fitness values
    
    selectedV=[];
    selectedminus=[];
    selectedplus=[];
    minLeafSize = round(size(Y,1)/10);
    selectedplus=[];
    selectedminus=[];
    regressionTree =  fitrtree(X,Y,...
                    'minleaf',minLeafSize,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical);
    if (regressionTree.NumNodes<=1)
        regressionTree =  fitrtree(X,Y,...
                     'minleaf',minLeafSize,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical);
    end
    view(regressionTree);
    r_as=getNodes(regressionTree); % as: a cell array of all ci
    disp('r_as:');
    disp(r_as);
    interInformativeAssum=getAssumption(regressionTree,r_as);
    disp('interInformativeAssum:')
    disp(interInformativeAssum);
    disp('assume_opt.desiredFitness-assume_opt.exploit:');
    disp(assume_opt.desiredFitness);
    disp(assume_opt.exploit);
    [~,informativeAplus]=selectA(interInformativeAssum,'>',assume_opt.desiredFitness,assume_opt.exploit,0);
    plusRow=find( arrayfun(@(RIDX) informativeAplus{RIDX,5}==max([informativeAplus{:,5}]) , 1:size(informativeAplus,1)) );
    if ~isempty(plusRow)
        selectedplus=informativeAplus(plusRow,:); % selected assumptions + information
    end
%     [~,informative]=selectA(interInformativeAssum,'==',assume_opt.desiredFitness,assume_opt.exploit,0);
%     vRow=find( arrayfun(@(RIDX) informative{RIDX,5}==min([informative{:,5}]) , 1:size(informative,1)) );
%     if ~isempty(vRow)
%         selectedV=informative(vRow,:); % selected assumptions + information
%     end
%     [~,informativeAminus]=selectA(interInformativeAssum,'<',assume_opt.desiredFitness,assume_opt.exploit,0);
%     minusRow=find( arrayfun(@(RIDX) informativeAminus{RIDX,5}==max([informativeAminus{:,5}]) , 1:size(informativeAminus,1)) );
%     if ~isempty(minusRow)
%         selectedminus=informativeAminus(minusRow,:); % selected assumptions + information
%     end
    informativeA=[selectedplus];
end
     