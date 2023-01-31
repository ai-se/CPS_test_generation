function [TestSuite]=Fn_TweakATestSuite1(TestSuite,TweakSigma,NoInputVars,InputTypesVar,InputMinVals,InputMaxVals,TestSuiteComplexity,TestSuiteSize,SimTime,SimStep)

  
  [AdpInputMinVals,AdpInputMaxVals]=Fn_AdaptMinMaxValues(NoInputVars,InputTypesVar,InputMinVals,InputMaxVals);
  for tccnt=1:TestSuiteSize,
    curTimeValues=repmat(SimTime,NoInputVars,max(TestSuiteComplexity(tccnt,:)));
    for icnt=1:NoInputVars,
      timePoints=TestSuiteComplexity(tccnt,icnt)-1;
      if(timePoints>0)
        for tpcnt=1:timePoints,
          if(~isfield(TestSuite.TestCases(tccnt),'timeRawValues'))
            TestSuite.TestCases(tccnt).timeRawValues{icnt,1}=rand(1,1)*SimTime;
          elseif(length(TestSuite.TestCases(tccnt).timeRawValues)<icnt)
            TestSuite.TestCases(tccnt).timeRawValues{icnt,1}=rand(1,1)*SimTime;
          elseif(length(TestSuite.TestCases(tccnt).timeRawValues{icnt,1})<tpcnt)
            TestSuite.TestCases(tccnt).timeRawValues{icnt,1}=[TestSuite.TestCases(tccnt).timeRawValues{icnt,1},(rand(1,1)*SimTime)];
          else
            CurValue=TestSuite.TestCases(tccnt).timeRawValues{icnt,1}(tpcnt);
            NewValueIsInMinMaxRange=false;
            while(~NewValueIsInMinMaxRange)
              NewValue=CurValue+Fn_MiLTester_My_Normal_Rnd(0,TweakSigma*SimTime);
              NewValueIsInMinMaxRange=true;
              if(NewValue>SimTime || NewValue<0)
                display('Tweak out of boundary!');
                NewValueIsInMinMaxRange=false;
              end
            end
            TestSuite.TestCases(tccnt).timeRawValues{icnt,1}(tpcnt)=NewValue;
          end
        end
        TestSuite.TestCases(tccnt).timeRawValues{icnt,1}=sort(TestSuite.TestCases(tccnt).timeRawValues{icnt,1});
        curTimeValues(icnt,1:timePoints)=round(TestSuite.TestCases(tccnt).timeRawValues{icnt,1}/SimStep)*SimStep;
      end
      dataPoints=TestSuiteComplexity(tccnt,icnt);
      for dpcnt=1:dataPoints,
        if(length(TestSuite.TestCases(tccnt).dataRawValues{icnt,1})<dpcnt)
          RawValue=AdpInputMinVals(icnt)+(AdpInputMaxVals(icnt)-AdpInputMinVals(icnt))*rand(1);
          TestSuite.TestCases(tccnt).dataRawValues{icnt,1}=[TestSuite.TestCases(tccnt).dataRawValues{icnt,1},RawValue];
          TestSuite.TestCases(tccnt).dataValues{icnt,1}=[TestSuite.TestCases(tccnt).dataRawValues{icnt,1},...
            Fn_RawToAppropriateValue(NewValue,InputTypesVar{icnt},InputMinVals(icnt),InputMaxVals(icnt))];
        else
          CurValue=TestSuite.TestCases(tccnt).dataRawValues{icnt,1}(dpcnt);
          NewValueIsInMinMaxRange=false;
          while(~NewValueIsInMinMaxRange)
            NewValue=CurValue+Fn_MiLTester_My_Normal_Rnd(0,TweakSigma*(AdpInputMaxVals(icnt)-AdpInputMinVals(icnt)));
            NewValueIsInMinMaxRange=true;
            if(NewValue>AdpInputMaxVals(icnt) || NewValue<AdpInputMinVals(icnt))
              NewValueIsInMinMaxRange=false;
            end
          end
          TestSuite.TestCases(tccnt).dataRawValues{icnt,1}(dpcnt)=NewValue;
          TestSuite.TestCases(tccnt).dataValues{icnt,1}(dpcnt)=Fn_RawToAppropriateValue(NewValue,InputTypesVar{icnt},InputMinVals(icnt),InputMaxVals(icnt));
        end
      end
    end

    TestSuite.TestCases(tccnt).timeValues=sort(unique([curTimeValues(:)',0,SimTime]));
    for icnt=1:NoInputVars,
      curDataValues=TestSuite.TestCases(tccnt).dataValues{icnt,1};
      clear TestSuite.TestCases(tccnt).dataValues;
      l=1;
      for k=1:size(TestSuite.TestCases(tccnt).timeValues,2),
        if(TestSuite.TestCases(tccnt).timeValues(k)>=curTimeValues(icnt,l) && ...
            TestSuite.TestCases(tccnt).timeValues(k)~=SimTime)
          l=l+1;
        end
        if(k==1)
          TestSuite.TestCases(tccnt).dataValues{icnt,1}=curDataValues(l);
        else
          TestSuite.TestCases(tccnt).dataValues{icnt,1}=[TestSuite.TestCases(tccnt).dataValues{icnt,1}, curDataValues(l)];
        end
      end
    end
  end
end