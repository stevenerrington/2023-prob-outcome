% in init
% pupil and lick window
if isempty(findobj('Name','OnlinepupilLick'))
    scrsz = get(0,'ScreenSize');
    c.OnlinepupilLick         = figure('Position', [scrsz(1)+scrsz(3)/2 scrsz(2) scrsz(3)/2 scrsz(4)/2],...
        'Name','OnlineRasterWindow',...
        'NumberTitle','off',...
        'Color',[0.8 0.8 0.8],...
        'Visible','on',...
        'NextPlot','add');
else
    c.onRastwin         = findobj('Name','OnlinepupilLick');
    set(0, 'CurrentFigure', c.onRastwin);
    
    
end


set(0, 'CurrentFigure', c.OnlinepupilLick);
% make all axes for probability of looking plots
c.uniquefractallist = [6300 6301 6302 6303 6304 6305 6306 6307 6308 6309 6310 6311  ];
PlotsWanted=size(c.uniquefractallist,2);

xposition = [1 2 3 1 2 3 1 2 3 1 2 3];
yposition = [1 1 1 2 2 2 3 3 3 4 4 4];

RowsNeeded = ceil(sqrt(PlotsWanted));
 ColsNeeded= floor(sqrt(PlotsWanted));
if (RowsNeeded* ColsNeeded)<PlotsWanted
   ColsNeeded =ColsNeeded+1
end


for jj=1:PlotsWanted

    c.plotaxpupil(jj) = nsubplot(RowsNeeded,ColsNeeded, yposition(jj),xposition(jj));
    
     c.plotdatapupil(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdatapupil2ndCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdatapupil3rdCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdatapupil4thCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     
    c.plotaxpupilTitle(jj) = title(['Pupildialation ' num2str(c.uniquefractallist(jj))]);  
end


% in finish


    finalBlinkThreshold = -4.5 %PDS.blinkthreshold{c.j};

    % remove blinks by setting them to NaN values
      indexofblinkvalues=find(stableWindow(fractalIndex,fractalPresentationCount,: )<finalBlinkThreshold);
minindex=indexofblinkvalues-35;
maxindex=indexofblinkvalues+35;

stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
        stableWindow(fractalIndex,fractalPresentationCount,: )< finalBlinkThreshold ) = NaN;
stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
    minindex)=NaN;
stableWindow( fractalIndex , ...
        fractalPresentationCount  ,...
    maxindex)=NaN;


    
    %where stableWindow is less than the c.blinkThreshold Value, set it to NaN
    disp('blinks set to NaN');
    % Calculate preStimulus dialation value to put values in % change
    prestimulusDialation = PDS.onlineEye{c.j}( indexOfBegStableWindow:indexOfCsOn,3);
    prestimulusDialation(prestimulusDialation <finalBlinkThreshold) = NaN;
    PDS.meanPrestimulusDialation{c.j} = nanmean(prestimulusDialation);
    disp('mean blinks set');
    
    % normalize to mean prestimulus value before meaning across trials
    proportionalstableWindow ( fractalIndex , fractalPresentationCount  ,:) = ...
        stableWindow( fractalIndex , fractalPresentationCount  ,:)/PDS.meanPrestimulusDialation{c.j};
    
    meanStableWindow = squeeze(nanmean(100*(proportionalstableWindow) ,2));
    

    set(c.plotdatapupil(fractalIndex) ,  {'XData'}, {[1:size(squeeze(meanStableWindow),2) ]} , ...
        {'YData'}, {squeeze(meanStableWindow(fractalIndex,:)) } );

    set(c.plotaxpupil(fractalIndex), 'YLim', [-150 150]);
    
    disp('ylimset');