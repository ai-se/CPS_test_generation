% function anti_pattern_taliro - Computing the anti-pattern value
%
% USAGE
%
%         rob = anti_pattern_taliro(seqS,seqT,seqL,customCostAuxData)
%
% INPUTS
%
%   seqS - The sequence of states from a Euclidean space X. Each row must  
%          be a different sampling instance and each column a different 
%	       dimension in the state space.
%
%	       For example, a 2D signal sampled at 3 time instances is:
%
%               seqS = [0.1  0.2;
%                       0.15 0.19;
%                       0.14 0.18];
%
%   seqT - The time-stamps of the trace. It must be a column vector.
%          For example:
%               seqT = [0 0.1 0.2]';
%          It should be a monotonically increasing sequence.
%          Enter [] or ignore if you are interested only about LTL 
%          properties.
%
% OUTPUTS
%
%   rob - the robustness estimate. This is a HyDis object for hybrid system
%	      trajectory robustness. To get the continuous state robustness 
%	      type get(rob,2).
%
% See also: dp_t_taliro, fw_taliro, polarity, 

% Copyright (c) 2011  Georgios Fainekos	- ASU							  
% Copyright (c) 2013  Hengyi Yang - ASU							  
% Copyright (c) 2013  Adel Dokhanchi - ASU							  
% modified by:
% Copyright by North Carolina State University
% Developed by Xiao Ling, xling4@ncsu.edu North Carolina State University.

% This program is free software; you can redistribute it and/or modify   
% it under the terms of the GNU General Public License as published by   
% the Free Software Foundation; either version 2 of the License, or      
% (at your option) any later version.                                    
%                                                                        
% This program is distributed in the hope that it will be useful,        
% but WITHOUT ANY WARRANTY; without even the implied warranty of         
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          
% GNU General Public License for more details.                           
%                                                                        
% You should have received a copy of the GNU General Public License      
% along with this program; if not, write to the Free Software            
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function varargout = anti_pattern_taliro(seqS, seqT, customCostAuxData)

seqS = double(seqS);
deltaT = seqT(2) - seqT(1);

if isempty(seqS) || isempty(seqT)
    error('anti_pattern_taliro: The output signal or time stamp is empty.')
else  
    [r, c] = size(seqS);
    score = zeros(1, c*4);
    
    % calculate Instability by using following equation
    %
    % instability(sig) = \sum_{i=1}^{k} | sig(i * Delta(T)) - sig((i-1) * Delta(T)) |
    %   k: number of simulation steps
    %   Delta(T): simulation time step

    for i = 1:c
        sig_instability = 0;
        
        for j = 2:r            
            dif_instability = abs(seqS(j,i) - seqS(j-1,i));
            sig_instability = sig_instability + dif_instability;
        end
        
        score(i+c*0) = sig_instability;
    end
    
    % calculate Discontinuity by using following equation
    %
    % discontinuity(sig) = \max_{dt=1}^{3} (\max_{i=dt}^{k-dt} (\min(lc_i,rc_i)))
    %   k: number of simulation steps
    %   lc_i = |sig(i * Delta(T)) - sig((i-dt) * Delta(T))| / Delta(T)
    %   rc_i = |sig((i+dt) * Delta(T)) - sig(i * Delta(T))| / Delta(T)
    %   Delta(T): simulation time step

    for i = 1:c
        res1 = zeros(1,3);
        
        for dt = 1:3
            cur_max = log(0);
            
            for j = (dt+1):(r-dt)
                lc_i = abs(seqS(j,i) - seqS(j-1,i)) / deltaT;
                lc_r = abs(seqS(j+1,i) - seqS(j,i)) / deltaT;
                
                if min([lc_i, lc_r]) > cur_max
                    cur_max = min([lc_i, lc_r]);
                end
            end
            
            res1(dt) = cur_max;
        end
        
        score(i+c*1) = max(res1);
    end
    
    % calculate Infinity by using following equation
    %
    % infinity(sig) = \max |sig(i *Delta(T))|
    %   Delta(T): simulation time step
    
    for i = 1:c
        cur_max = log(0);
        
        for j = 1:r
            if abs(seqS(j,i)) > cur_max
                cur_max = abs(seqS(j,i));
            end
        end
        
        score(i+c*2) = cur_max;
    end
    
    % calculate Infinity by using following equation
    %
    % infinity(sig) = \max |sig(i *Delta(T))|
    %   Delta(T): simulation time step
    
    for i = 1:c
        cur_max = log(0);
        
        for j = 1:r
            if abs(seqS(j,i)) > cur_max
                cur_max = abs(seqS(j,i));
            end
        end
        
        score(i+c*2) = cur_max;
    end
    
    % calculate Minmax by using following equation
    %
    % minmax(sig) = \max |sig(i *Delta(T))|
    %   Delta(T): simulation time step
    
    for i= 1:c
        score(i+c*3) = abs(max(seqS(:, i)) - min(seqS(:, i)));
    end
end

if nargout == 1
    varargout{1} = score;
else
    error(' anti_pattern_taliro: The maximum number of outputs is one.')
end

end
