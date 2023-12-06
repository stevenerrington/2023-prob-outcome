 

function interploatePDSdata(allDataMat,c)
millisecondResolution=0.001;
cellwrapper = c.j;
%         regularTimeVectorForPdsInterval = [c.stepSizeOfResampledPDS: c.stepSizeOfResampledPDS  : (allDataMat{cellwrapper}(end,4))- ...
%             allDataMat{cellwrapper}(1,4) ];
     regularTimeVectorForPdsInterval = [-1: millisecondResolution  : (allDataMat{cellwrapper}(end,4))- ...
            allDataMat{cellwrapper}(1,4) ];
               max(PDS.definedCSdur) ;
        clear regularPdsData;
        relatveTimePDS = (allDataMat{cellwrapper}(:,4))- allDataMat{cellwrapper}(1,4) ;
        
        if useLinearInterp ==1
            regularPdsData(1,:) = interp1(  relatveTimePDS , ...
                allDataMat{cellwrapper}(:,1) , regularTimeVectorForPdsInterval  );
%             disp('regularPdsData made successfully');
            % regularizes the PDS data for Y eye positionby linearly
            %     interpolating between all recorded times
            regularPdsData(2,:) = interp1(  relatveTimePDS, ...
                allDataMat{cellwrapper}(:,2) ,   regularTimeVectorForPdsInterval  );
%             disp('interpolated successfully');

        else
            regularPdsDataTimeseries1 = timeseries(allDataMat{cellwrapper}(:,1)    ...
                ,(allDataMat{cellwrapper}(:,4) -allDataMat{cellwrapper}(1,4) )- allCsonTImes(cellwrapper) );
            
            % regularizes the PDS data for Y eye position by using timeseries
            % objects
            regularPdsDataTimeseries2 = timeseries(allDataMat{cellwrapper}(:,2)    ...
                ,(allDataMat{cellwrapper}(:,4) -allDataMat{cellwrapper}(1,4) )- allCsonTImes(cellwrapper) );
            
            test1 = resample(regularPdsDataTimeseries1 ,regularTimeVectorForPdsInterval );
            test2 =resample(regularPdsDataTimeseries2 , regularTimeVectorForPdsInterval);
           regularPdsData(1,:)= test1.Data;
            regularPdsData(2,:)= test2.Data;
        end
end
