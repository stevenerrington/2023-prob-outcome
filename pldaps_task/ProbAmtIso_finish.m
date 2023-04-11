function [PDS ,c ,s] = ProbAmtIso_finish(PDS ,c ,s)
%% Cleanup
Screen('Close')
%Screen('Close', imTex); % Close texture
%Screen('Close', img); % Close texture
warning on;

%% Update Online Plots
if c.repeatflag ~=1
% try
%         [c, s, PDS]         = plotupdate_v03(c, s, PDS);
%         [c, s, PDS]         = plotupdate_ProportionLooking(c, s, PDS);
% 
  %      [c, s, PDS]         = plotRasterUpdate(c, s, PDS);
% catch
%     disp('ERROR - Plot update failed!');
% end
end

end

%% Helper functions

function [c, s, PDS]    = plotupdate_v03(c, s, PDS)
useLinearInterp=1;
%  PDS.samplesInTargetZone{c.j}=[];
currentTrial = PDS.trialnumber(end); %c.j?

%PDS.fractals2=0

if 0==0 %PDS.fractals2(currentTrial) ==0  % if a normal trial that completed
    % per run Init
    % update fractal list with unique fractals delv=ivered.
    fractalList = c.uniquefractallist;
    %           disp('fractalList made'); % debug code
    
      relatveTimePDS = (PDS.onlineEye{currentTrial}(:,4))- PDS.onlineEye{currentTrial}(1,4) ;
    disp('relatveTimePDS made')
    
    %     regularizes the PDS data for X eye position  by linearly
    %     interpolating between all recorded times 
    millisecondResolution=0.001;
    regularTimeVectorForPdsInterval = [0: millisecondResolution  : (PDS.onlineEye{currentTrial}(end,4))- ...
        PDS.onlineEye{currentTrial}(1,4) ];
    c.regularTimeVectorForPdsInterval =regularTimeVectorForPdsInterval
    %         %old code
    %         regularTimeVectorForPdsInterval = [c.stepSizeOfResampledPDS: c.stepSizeOfResampledPDS  : (PDS.onlineEye{currentTrial}(end,4))- ...
    %             PDS.onlineEye{currentTrial}(1,4) ];
    %     disp('regularTimeVectorForPdsInterval made');% debug code
    clear regularPdsData;
    tic
    if useLinearInterp ==1
                
        regularPdsData(1,:) = interp1(  relatveTimePDS , ...
            PDS.onlineEye{currentTrial}(:,1) , regularTimeVectorForPdsInterval  );
        disp('regularPdsData made successfully');
        % regularizes the PDS data for Y eye positionby linearly
        %     interpolating between all recorded times
        regularPdsData(2,:) = interp1(  relatveTimePDS, ...
            PDS.onlineEye{currentTrial}(:,2) ,   regularTimeVectorForPdsInterval  );
        disp('interpolated successfully (regular)');
    else
        
        %uses timescales for stricter interpolation
        regularPdsDataTimeseries(1,:) = timeseries(PDS.onlineEye{currentTrial}(:,1)    ...
            ,(PDS.onlineEye{currentTrial}(:,4) -PDS.onlineEye{currentTrial}(1,4) ) );
%                                                                               - PDS.timetargeton(currentTrial)        
        % regularizes the PDS data for Y eye position by using timeseries
        % objects
        regularPdsDataTimeseries(2,:) = timeseries(PDS.onlineEye{currentTrial}(:,2)    ...
            ,(PDS.onlineEye{currentTrial}(:,4) -PDS.onlineEye{currentTrial}(1,4) )  );
%                                                                               - PDS.timetargeton(currentTrial)        
        test1 = resample(regularPdsDataTimeseries(1,:) ,[c.stepSizeOfResampledPDS: c.stepSizeOfResampledPDS  : (PDS.onlineEye{currentTrial}(end,4)-PDS.onlineEye{currentTrial}(1,4))] );
        test2 =resample(regularPdsDataTimeseries(2,:) , regularTimeVectorForPdsInterval);
        regularPdsData(1,:) = test1.Data;
        regularPdsData(2,:) = test2.Data;
        clear test1 test2 regularPdsDataTimeseries
        
        disp('interpolated successfully (timeseries)');
    end
    toc
    
    %     Sets target position from angle measurements
    if PDS.targAngle(currentTrial)==-1
        %center target
        c.targetWindowPdsVals.xPos = 0;
        centerTrialflag=1;
    else
        % non ceterTarget
        c.targetWindowPdsVals.xPos = pol2cart( deg2radNML(PDS.targAngle(currentTrial)), c.targetDispacementFromCenter);
        centerTrialflag=0;
    end
    NmlMagicNumber =00;
    %check samples in target zone starting from target onscreen time
    startTargetIndex = find(regularTimeVectorForPdsInterval > PDS.timetargeton(currentTrial),1,'first')-NmlMagicNumber;
    
    %NML magicNumber
    if isfield(c, 'initializedStableWindow')
        % add if statement here with windows for different
        % lengths...
        
        endTargetIndex= (startTargetIndex )+ c.stableWindowLength ;
    else
        c.initializedStableWindow = 1;
        endTargetIndex = find(regularTimeVectorForPdsInterval > PDS.timetargetoff(currentTrial),1,'first');
        % add if statement here with windows for different lengths...
        c.stableWindowLength = endTargetIndex-startTargetIndex;
    end
    
    % NML 3/31/2015
    useOnlineMethod=0;
    if useOnlineMethod==0
        scaleFactor=1;
        samplesInTargetZone =   regularPdsData(1,startTargetIndex:endTargetIndex)>( c.targetWindowPdsVals.xPos - c.targetWindowPdsVals.xSize/scaleFactor) & ...
            regularPdsData(1,startTargetIndex:endTargetIndex) < (c.targetWindowPdsVals.xPos + c.targetWindowPdsVals.xSize/scaleFactor) & ...
            regularPdsData(2,startTargetIndex:endTargetIndex)>( c.targetWindowPdsVals.yPos - c.targetWindowPdsVals.ySize/scaleFactor) & ...
            regularPdsData(2,startTargetIndex:endTargetIndex) < (c.targetWindowPdsVals.yPos + c.targetWindowPdsVals.ySize/scaleFactor);
        disp(['detected '  num2str(sum(samplesInTargetZone)) ' samples in target zone successfully']);
    elseif useOnlineMethod==1
        
        PDS.loopCountOfTargetOn;
        PDS.loopCountOfTargetOff;
        samplesInTargetZone = PDS.samplesInTargetZone{c.j}(PDS.loopCountOfTargetOn(c.j):PDS.loopCountOfTargetOff(c.j));
        disp(['detected '  num2str(sum(samplesInTargetZone)) ' samples in target zone successfully']);
    end
    
    
    % save samplesInTargetZone in c
    
    %    PDS.samplesInTargetZone{c.j} =zeros(1,size());
    PDS.samplesInTargetZonefinish(c.j,:) = logical(samplesInTargetZone);
    %Check this for size stability...grabs only between Targon and
    %targoff
    
    % records time focused per trial
    PDS.timeFocused(currentTrial) =  sum(samplesInTargetZone )*c.stepSizeOfResampledPDS ;
    disp('time focused calculated successfully');
    %sets acquisition time to zero if a center trial
    % otherwise, takes first timepoint on a fractal as defined in the
    % run code
    if centerTrialflag~=1
        %                 PDS.acquisitionTimesPerFractal(1,PDS.fractal1Presentations) =  firstTargetLocationInd * c.stepSizeOfResampledPDS;
        
        PDS.acquisitionTime(currentTrial) = ...
            ((PDS.targetAcquisitionFirst(currentTrial) - PDS.onlineEye{currentTrial}(1,4)) - PDS.timetargeton(currentTrial));
    else
        PDS.acquisitionTime(currentTrial)  = NaN;
    end
    disp('center trial detection ran successfully');
    
    %             meantimeFocusedPerFractal = nanmean( PDS.timeFocusedPerFractal(1,:));
    for i=1:size(c.uniquefractallist,2)
        meantimeFocusedPerFractal(i) = nanmean( PDS.timeFocused(PDS.fractals==c.uniquefractallist(i) & ...
            PDS.repeatflag~=1 ));  % mean(PDS.timeFocusedPerFractal(1,~isnan(PDS.timeFocusedPerFractal(1,:))));
        meanAcquisitionTimePerFractal(i) = nanmean ( PDS.acquisitionTime(PDS.fractals==c.uniquefractallist(i) & ...
            PDS.repeatflag~=1));
    end
    disp('means calculated');
    
    % Plotting update
    %depricated
    %     plotTrialDatav2 (meantimeFocusedPerFractal, meanAcquisitionTimePerFractal, [1 2],c, PDS);
    
end


end


function [c,  PDS]  = plotPupilDialation(PDS, c,plotPositions)
% pupilOutout=NaN;

% PDS.onlineEye{c.j}(:,4) % this is the time vector from PDS eye data


% Plots mean dialation across fractals
% in a multi-plot axis (must be set up appropriately in VisSac_init)
if(PDS.goodtrial(c.j) && PDS.fractals2(c.j)==0)
    
    fractalIndex =find(c.uniquefractallist ==PDS.fractals(c.j),1) ; % identify fractal
    fractalPresentationCount = size(PDS.fractals(PDS.fractals==PDS.fractals(c.j) & PDS.goodtrial==1 & PDS.fractals2==0 ) ,2 );
    
    minITI_dur =2;
    
          relatveTimePDS = (PDS.onlineEye{c.j}(:,4))- PDS.onlineEye{c.j}(1,4) ;
    disp('relatveTimePDS made')
    
    millisecondResolution=0.001;
    regularTimeVectorForPdsInterval = [0: millisecondResolution  : PDS.onlineEye{c.j}(end,4)- ...
      PDS.onlineEye{c.j}(1,4) ];
    %         %old code
    %         regularTimeVectorForPdsInterval = [c.stepSizeOfResampledPDS: c.stepSizeOfResampledPDS  : (PDS.onlineEye{currentTrial}(end,4))- ...
    %             PDS.onlineEye{currentTrial}(1,4) ];
    %     disp('regularTimeVectorForPdsInterval made');% debug code
    clear regularPdsData;
    tic
    
                
        regularPdsData(1,:) = interp1(  relatveTimePDS , ...
            PDS.onlineEye{c.j}(:,3) , regularTimeVectorForPdsInterval  );
        disp('regularPdsData made successfully');
        % regularizes the PDS pupil data for Y eye positionby linearly
        %     interpolating between all recorded times
 
   toc
    
    
    %TODO WARNING THIS MAY NOT BE STABLE! This value could be changed
    %during a run...
    beginingOfStableWindow = (PDS.timetargeton(c.j) - c.minFixDur ) +PDS.onlineEye{c.j}(1,4) ;
    endOfStableWindow = (PDS.timetargetoff(c.j) + minITI_dur) + PDS.onlineEye{c.j}(1,4) ;
    beginingOfCsOn = (PDS.timetargeton(c.j)) +PDS.onlineEye{c.j}(1,4)
    
    % convert to index space
    indexOfBegStableWindow = find ( PDS.onlineEye{c.j}(:,4)>beginingOfStableWindow,1 );
    
      
    if  ~isfield(c, 'proportionalstableWindow')  % (c.proportionalstableWindow,3)<2
        indexOfEndStableWindow = find ( PDS.onlineEye{c.j}(:,4) > endOfStableWindow,1 );
    else
        indexOfEndStableWindow= indexOfBegStableWindow + size(c.proportionalstableWindow,3)-1;
    end
    
%     indexOfEndStableWindow = find ( PDS.onlineEye{c.j}(:,4) > endOfStableWindow,1 );
    indexOfCsOn =  find ( PDS.onlineEye{c.j}(:,4) > beginingOfCsOn,1 );
    % TODO double check length against previous data?
    
    
    
    % meanable array of (fratal, presentation num, data)
    stableWindow( fractalIndex , fractalPresentationCount  ,:) = ...
        regularPdsData(indexOfBegStableWindow:indexOfEndStableWindow);
    PDS.stableWindowByTrial{c.j} =   regularPdsData(indexOfBegStableWindow:indexOfEndStableWindow);
    %     meanStableWindow = squeeze(mean(stableWindow,2)); % no NaN handling
    
    finalBlinkThreshold = -4.5 %PDS.blinkthreshold{c.j};
    
    % remove blinks by setting them to NaN values
    indexofblinkvalues=find(stableWindow(fractalIndex,fractalPresentationCount,: )<finalBlinkThreshold);
%     minindexofblinkvalues=find(stableWindow(fractalIndex,fractalPresentationCount,: )<finalBlinkThreshold);

    minindex=indexofblinkvalues -ceil(0.050/millisecondResolution);
    maxindex=indexofblinkvalues +ceil(0.050/millisecondResolution);
    
    stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
        stableWindow(fractalIndex,fractalPresentationCount,: )< finalBlinkThreshold ) = NaN;
    stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
        minindex)=NaN;
    stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
        maxindex)=NaN;
    % NML check against offline data???
    
    %where stableWindow is less than the c.blinkThreshold Value, set it to NaN
    disp('blinks set to NaN');
    % Calculate preStimulus dialation value to put values in % change
    prestimulusDialation = regularPdsData( indexOfBegStableWindow:indexOfCsOn);
    prestimulusDialation(prestimulusDialation <finalBlinkThreshold) = NaN;
    PDS.meanPrestimulusDialation{c.j} = nanmean(prestimulusDialation);
    disp('mean blinks set');
    
    % normalize to mean prestimulus value before meaning across trials
    %     proportionalstableWindow ( fractalIndex , fractalPresentationCount  ,:) = ...
    %         stableWindow( fractalIndex , fractalPresentationCount  ,:)/PDS.meanPrestimulusDialation{c.j};
    %
    %     meanStableWindow = squeeze(nanmean(100*(proportionalstableWindow) ,2));
    %
    % if isfield(PDS , 'proportionalstableWindow')
    % proportionalstableWindow =PDS.proportionalstableWindow;%NM testing...
    % end
    
    PDS.meanPrestimulusDialation{c.j}=1;% set to one to kill proportional plotting
    
    c.proportionalstableWindow ( fractalIndex , fractalPresentationCount  ,:) = ...
        squeeze(stableWindow( fractalIndex , fractalPresentationCount  ,:)/PDS.meanPrestimulusDialation{c.j});
    
    %     Is this being saved propperly for meaning? Seems incorrect...
    
%     c.PDS.proportionalstableWindow = proportionalstableWindow;
    meanStableWindow = squeeze(nanmean((c.proportionalstableWindow(fractalIndex ,:,:)) ,2));
    
    
    set(c.plotdatapupil(fractalIndex) ,  {'XData'}, {relatveTimePDS(1:size(meanStableWindow ,1))} , ...
        {'YData'}, {(meanStableWindow)' } );
    
    set(c.plotaxpupil(fractalIndex), 'YLim', [-5 1]);
    set(c.plotaxpupil(fractalIndex), 'XLim', [0 c.CS_dur+minITI_dur]);
    
    disp('ylimset');
end
end

function [c, s, PDS]    = plotupdate_ProportionLooking(c, s, PDS)
PDS.goodtrial(c.j) = ~logical(PDS.repeatflag(c.j));
if (PDS.repeatflag(c.j)==0  )
    %     sizeOflookingDataWindow =
    regularTimeVectorForPdsInterval=c.regularTimeVectorForPdsInterval;
    logicalIndexForFractal = (PDS.fractals == PDS.fractals(c.j) & ...
        PDS.goodtrial == 1);
    
    proportionLookingData =sum( PDS.samplesInTargetZonefinish(logicalIndexForFractal,:)  ,1 )/ ...
        sum( logicalIndexForFractal); %Sum down columns over sum across rows of index
    
    
    plotIdentifier = find(c.uniquefractallist==PDS.fractals(c.j));
    
    %     PDS.proportionLookingData(c.j,:) = proportionLookingData;
    set (c.plotdata(plotIdentifier), ...
        {'XData'}, {regularTimeVectorForPdsInterval(1:size(proportionLookingData,2))} , ...
        {'YData'}, {[proportionLookingData ]} );
    
    set(c.plotax(plotIdentifier), 'XLim', [-0.1 2.5]);
    set(c.plotax(plotIdentifier), 'YLim', [0 1]);
    
%     if c.j >10
%         set (c.plotdata2ndCondition(plotIdentifier), ...
%         {'XData'}, {regularTimeVectorForPdsInterval(1:size(proportionLookingData,2))} , ...
%         {'YData'}, {[proportionLookingData ]} );
%         
%     end
%     
    
end

end


function radians = deg2radNML(degreesIn)
radians =degreesIn *pi/180;
end

function output1 = plotTrialDatav2(meansOfFocusTime,meansOfAcquisitionTime, plotPositions,c , PDS)

% fractalPresentationInfo = [PDS.fractal1Presentations PDS.fractal2Presentations PDS.fractal3Presentations ...
%     PDS.fractal4Presentations PDS.fractal5Presentations PDS.fractal6Presentations];
fractallist = c.uniquefractallist;

% subplot(6,2,plotPositions(1)); %hold on;
% set(c.plotax(plotPositions(1)) )
set (c.plotdata(plotPositions(1)),{'XData'}, {[1:(size(meansOfFocusTime,2)+2)]} , ...
    {'YData'}, {[(meansOfFocusTime/c.CS_dur) ,0, (PDS.timeFocused(c.j)/c.CS_dur)  ]} );

%             bar([PDS.timeFocusedPerFractal(3,PDS.fractal3Presentations) , meantimeFocusedPerFractal ]);
% bar(c.plotax(plotPositions(1)), [fractalBehaveData(1) , fractalBehaveData(2) ]);

set(c.plotaxTitle(plotPositions(1))   , 'String' ,['Focused Time per fractal '  ]);
set(c.plotax(plotPositions(1)),'XTick',[1:(size(meansOfFocusTime,2)+2)]);
set(c.plotax(plotPositions(1)),'XTickLabel',{fractallist,' ', ['LastTrial-' num2str(PDS.fractals(c.j))]  });
set(c.plotax(plotPositions(1)), 'YLim', [0 1]);
% subplot(6,2,plotPositions(2));% hold on;
% set(c.plotax(plotPositions(1)) )
%             bar ([PDS.acquisitionTimesPerFractal(3,PDS.fractal3Presentations)  , meanAcquisitionTimePerFractal  ]) ;

set (c.plotdata(plotPositions(2)),{'XData'}, {[1:(size(meansOfFocusTime,2)+2)]}, ...
    {'YData'},{[meansOfAcquisitionTime ,0, PDS.acquisitionTime(c.j) ]});

% bar(c.plotax(plotPositions(2)), [fractalBehaveData(3) , fractalBehaveData(4) ]);

set(c.plotaxTitle(plotPositions(2))   , 'String' ,['Acquisition speed per fractal '  ]);
set(c.plotax(plotPositions(2)),'XTick',[1:(size(meansOfFocusTime,2)+2)]);
set(c.plotax(plotPositions(2)),'XTickLabel',{fractallist, ' ', ['LastTrial-' num2str(PDS.fractals(c.j))] });
set(c.plotax(plotPositions(2)), 'YLim', [0 max([meansOfAcquisitionTime ,0.1, PDS.acquisitionTime(c.j) ])]);

output1=1;

end
%% Helper functions

function [c, s, PDS]    = plotRasterUpdate(c, s, PDS)
currentTrial = PDS.trialnumber(end);
if 0==0; %isnan(PDS.fractals2(currentTrial))
    flatten = @(x)x(:);
    magicNumberForLogicals=  65534; % this is the code used for spike events
    % delivered to the Datapixx from Alpha Omega
    % determine fractal id
    
    
    if ~all(cellfun(@isempty, PDS.sptimes))
        
        % what do we want the half-length of the raster-lines to be?
        lineRad         = 0.4;
        % FractaltoplotlookupTable = [1 2 3 4 5 6];
        plotIdentifier = find(c.uniquefractallist==PDS.fractals(c.j));
        
        % make new raster lines for each of the new spikes
        if PDS.goodtrial(c.j)
            
            newRasters = copyobj(c.plotobj_raster(plotIdentifier), repmat(c.plotax_raster(plotIdentifier), nnz(PDS.spikes{c.j}-magicNumberForLogicals), 1));
            c.rasterLineCount(plotIdentifier) = c.rasterLineCount(plotIdentifier) + 1;
            
        end
        
        %%% update spike-plot
        fixRasters =  .750;
        origSpTimes = PDS.sptimes{c.j}(logical(PDS.spikes{c.j}-magicNumberForLogicals));
        spTimes= origSpTimes - PDS.timetargeton(c.j)+fixRasters;
        
        % assign x/y data to new raster objects.
        set(newRasters, {'XData'}, mat2cell(repmat(spTimes(:),1,2) - repmat(flatten(repmat(PDS.timefpon(c.j), length(spTimes), 1)),1,2), ones(1,length(spTimes),1),2),...
            {'YData'}, mat2cell(repmat(c.rasterLineCount(plotIdentifier),length(spTimes),2) + repmat([-1 1]*lineRad,length(spTimes),1), ones(1,length(spTimes),1),2));
        
        set(c.plotax_raster(plotIdentifier), 'Color', 'None', 'XLim', get(c.plotax_rasterSum(plotIdentifier), 'XLim'), 'TickDir', 'out', 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'Box', 'off')
        set(c.plotax_rasterSum(plotIdentifier), 'TickDir', 'out',  'YAxisLocation', 'Right' ,'Color', [0 0 0], 'XColor', [0.7 0.7 0.7], 'YColor', [0.7 0.7 0.7], 'Box', 'off');
        %         set(c.plotax_rasterSum(plotIdentifier), 'LineWidth' , 1);
        
        % combine spikes into one vector across trials
        logicalForSpikesByCondition = logical(PDS.goodtrial & PDS.fractals ==PDS.fractals(c.j));
        
        allSpTimes          = cell2mat(cellfun(@(x,y,z)x(logical(y-magicNumberForLogicals))' - z, ...
            PDS.sptimes(logical(logicalForSpikesByCondition)), ...
            PDS.spikes(logical(logicalForSpikesByCondition)), ...
            num2cell(PDS.timetargeton(logical(logicalForSpikesByCondition))), 'UniformOutput', false)');
        
        %     bin spikes
        xlimits=[-1 , c.CS_dur+4];
        [spBin, binC] = spikeBin(allSpTimes, 0.05, xlimits); %timescale variable in settings?
        % assign bin counts and bin center values to plot object
        try
            set(c.plot_rasterSum(plotIdentifier), 'XData', (binC'    ), ... - PDS.timetargeton(c.j)+fixRasters
                'YData', spBin'/sum(logicalForSpikesByCondition)/0.05, 'LineWidth', 1, 'Color', [0.5 0.5 0.5]);
        catch me
            %             keyboard
        end
        
        uistack(c.plot_rasterSum(plotIdentifier),'top');
       
        
        localMaxValuePlot = max( spBin)/sum(logicalForSpikesByCondition)/0.05;
        c.globalMinForMeanRateData = min( spBin  )/sum(logicalForSpikesByCondition)/0.05;
try
        ylim(c.plotax_rasterSum(plotIdentifier),[0 localMaxValuePlot] );
end
        c.plotMax(plotIdentifier)=localMaxValuePlot;

        rasterMinMax(1)= 0.5
        rasterMinMax(2)= max((c.rasterLineCount(plotIdentifier) ))+1.5
        
        if rasterMinMax(2) <  localMaxValuePlot
            % sets plot max to summary plot value
            c.plotMax(plotIdentifier)=localMaxValuePlot;

        else
            % sets plot max to raster plot value
             c.plotMax(plotIdentifier)=rasterMinMax(2);
        end
        
        xlim( c.plotax_rasterSum(plotIdentifier), [-1 2.5+2]);
        xlim(    c.plotax_raster(plotIdentifier), [-1 2.5+2]);
        
        %         
        for k = 1:size(c.uniquefractallist,2)
            
            ylim(c.plotax_raster(k), [0 max(c.plotMax)])
        end
        
        
        plotMin= -1;
        plotMax = max(c.plotMax) ;
        
        set(c.CsOnPlotLine(plotIdentifier), 'XData', [0 0 ]  );
        set(c.CsOnPlotLine(plotIdentifier), 'YData', [plotMin plotMax]  );
        %
        set(c.CsOffPlotLine(plotIdentifier), 'XData', [c.CS_dur  c.CS_dur]  );
        set(c.CsOffPlotLine(plotIdentifier), 'YData', [plotMin plotMax]  );
        
        
    end
end
try
c.plotMax(plotIdentifier) = localMaxValuePlot;
catch
end

end

function [n, binCenters] = spikeBin(spikeTimes, binWidth, xlimits)


[n,binCenters]= hist(spikeTimes,[xlimits(1):binWidth:xlimits(2)]);
n=n(2:end-1);
binCenters = binCenters(2:end-1);


end

