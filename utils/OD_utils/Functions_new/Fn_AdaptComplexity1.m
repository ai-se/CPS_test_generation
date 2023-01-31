function [TestSuiteComplexity]=Fn_AdaptComplexity1(ModelName,NoOutputs,MutOutputs,acctscovLoop,LoopCnt,PlatueaLoops,TestSuiteComplexity) 
  persistent LastCheckLoop
  for ocnt=1:NoOutputs,
    if(LoopCnt==1)
      LastCheckLoop(ocnt)=1;
    end
    if(MutOutputs(ocnt)==0)
      continue;
    end
    if((LoopCnt-LastCheckLoop(ocnt))<PlatueaLoops)
      continue;
    end
    LastCheckLoop(ocnt)=LoopCnt;
    deltacov=decisioninfo(acctscovLoop{ocnt}{LoopCnt}-acctscovLoop{ocnt}{LoopCnt-PlatueaLoops}, strrep(ModelName,'.mdl',''));
    if(deltacov(1)==0)
      if(LoopCnt>=2*PlatueaLoops)
        delta2cov=decisioninfo(acctscovLoop{ocnt}{LoopCnt}-acctscovLoop{ocnt}{LoopCnt-2*PlatueaLoops}, strrep(ModelName,'.mdl',''));
        if(delta2cov(1)>0)
          TestSuiteComplexity(ocnt,:,:)=TestSuiteComplexity(ocnt,:,:)+1;
        end
      else
        TestSuiteComplexity(ocnt,:,:)=TestSuiteComplexity(ocnt,:,:)+1;
      end
    end
  end
end