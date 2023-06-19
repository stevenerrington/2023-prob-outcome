function [PDS ,c ,s] = ProbAmtIso_init(PDS ,c ,s)
% initialization function
% this is executed only 1 time, after the settings file is read in,
% as part of the 'Initialize' action from the GUI
% This is where values are defined for the entire experiment

choicearray=[]; save choicearray.mat choicearray;
choicearray=[]; save choicearray2.mat choicearray;


% Settings
c.intrareveal_interval = 1;
c.reveal_outcome_interval = 1.5;
c.intraoutcome_interval = 0;
c.reveal_change_flag = 0;


display('Init')
%c.startBlock = 1;%randi([1 2]);
%disp(c.startBlock)

%% Reposition GUI window
allobj = findall(0);

for i = 1:length(allobj)
    if isfield(get(allobj(i)),'Name')
        if strfind(get(allobj(i),'Name'),'pldaps')
            %set(allobj(i),'Position',[280 7.58 133.8333   43.4167]);
            break;
        end
    end
end

%% close old windows
oldWins = findobj('Type','figure','-not','Name','pldaps_gui2_beta (05nov2012)');
if ~isempty(oldWins)
    close(oldWins)
end

%% Geometry
%this is viewpixx geometry. i updated below to our screen
% c.viewdist                      = 410;      % viewing distance (mm)
% c.screenhpix                    = 1200;     % screen height (pixels)
% c.screenh                       = 302.40;   % screen height (mm)

c.viewdist                      = 410;      % viewing distance (mm)
c.screenhpix                    = 1080;     % screen height (pixels)
c.screenh                       = 293.22;   % screen height (mm)
% %0.2715 per pixel
% %1920 x 1080
c.preTrialIti =0.750;

c.repeatflag=0;
c.previousTrialRepeated =0;
c.goodtrial =0;
% grab stimcodes & trialtype codes from files
c.codes         = stimcodes;
%c.trialstructures = trialstructure;
c.fixreq = 1;

% %% Initalize audio
% % must be done prior to initalizing datapix, where the waveforms are loaded
% % into memory
% % audio stuff
c                               = audioinit(c);
% %% Initialize LUT
c                               = lutinit(c);
% %% Initialize DataPixx
c                               = init_DataPixx(c);
% %% do other one-time initialization steps as desired

% setup the plot-window for fast online plotting.
%[c, PDS]                        = plotwindowsetup(c, PDS);
%c= plotinit(c);


end

%% Helper functions

function c                      = init_DataPixx(c)
% INITDATAPIXX is a function that intializes the DATAPIXX, preparing it for
% experiments. Critically, the PSYCHIMAGING calls sets up the dual CLUTS
% (Color Look Up Table) for two screens.  These two CLUTS are in the
% condition file "c".
% Modified from initDataPixx, getting rid of global variables: window,
% screenRect, refreshrate, overlay

%c.useDataPixxBool=0;

if c.useDataPixxBool
    AssertOpenGL;
    PsychImaging('PrepareConfiguration');
    
    PsychImaging('AddTask', 'General', 'EnableDataPixxL48Output');
    
    c.combinedClut = [c.monkeyCLUT;c.humanCLUT];
    
    
    
    [c.window, c.screenRect] = PsychImaging('OpenWindow', 1, [0 0 0]);
    c.middleXY = [c.screenRect(3)/2 c.screenRect(4)/2];
    
    Screen('LoadNormalizedGammaTable', c.window, linspace(0, 1, 256)' * [1, 1, 1], 0);
    
    Datapixx('SetVideoMode', 5);
    Datapixx('SetVideoClut', c.combinedClut);
    Datapixx('RegWrRd');
    
        
    % Fill the window with the background color.
    %Screen('FillRect', c.window, c.backcolor)
    Screen('FillRect', c.window, convertColorToL48D(c.backcolor))
    Screen('Flip', c.window);
    
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    
    %     Datapixx('EnableDoutDinLoopback'); % This will cause all strobe
    %     outputs to be delivered on the Datapixx's own Digital input!!!
    
    Datapixx('DisableDoutDinLoopback');%     % This will  turn off the automatic strobe
    %     outputs delivered on the Datapixx's own Digital input!!!
    
    
    Datapixx('DisableDinDebounce');
    
    
    Datapixx('DisableDinDebounce');
    Datapixx('SetDinLog');
    Datapixx('StartDinLog');
    Datapixx('SetDoutValues',0);
    Datapixx('RegWrRd');
    
    %     Datapixx('EnableAdcFreeRunning');
    Datapixx('DisableDacAdcLoopback');
    Datapixx('DisableAdcFreeRunning');          % For microsecond-precise sample windows
    %Datapixx('EnableVideoScanningBacklight');
    
    % Load the audio waveforms into the ViewPixx's buffer.
    c.rightbuffadd = Datapixx('WriteAudioBuffer', c.wrongtone, c.wrongbuffadd);
    c.noisebuffadd = Datapixx('WriteAudioBuffer', c.righttone, c.rightbuffadd);
    Datapixx('WriteAudioBuffer', c.noisetone, c.noisebuffadd);
    
    Datapixx('InitAudio');
    Datapixx('SetAudioVolume', 0.25);       % Not too loud
    Datapixx('RegWrRd');                    % Synchronize Datapixx registers to local register cache
else
end
end

function [c, PDS]               = plotwindowsetup(c, PDS)

% Create behaviour plotting windows
if isempty(findobj('Name','OnlinePlotWindow'))
    scrsz = get(0,'ScreenSize');
    c.onplotwin         = figure('Position', [scrsz(1)+scrsz(3)/2 scrsz(2) scrsz(3)/2 scrsz(4)/2.5],...
        'Name','OnlinePlotWindow',...
        'NumberTitle','off',...
        'Color',[0.8 0.8 0.8],...
        'Visible','on',...
        'NextPlot','add');
else
    c.onplotwin         = findobj('Name','OnlinePlotWindow');
    set(0, 'CurrentFigure', c.onplotwin);
    
    
end
% Raster window
if isempty(findobj('Name','OnlineRasterWindow'))
    scrsz = get(0,'ScreenSize');
    c.onRastwin         = figure('Position', [scrsz(1)+scrsz(3)/2 scrsz(4) scrsz(3)/2 scrsz(4)/2.5],...
        'Name','OnlineRasterWindow',...
        'NumberTitle','off',...
        'Color',[0.8 0.8 0.8],...
        'Visible','on',...
        'NextPlot','add');
else
    c.onRastwin         = findobj('Name','OnlineRasterWindow');
    set(0, 'CurrentFigure', c.onRastwin);
    
    
end
% % pupil and lick window
% if isempty(findobj('Name','OnlinepupilLick'))
%     scrsz = get(0,'ScreenSize');
%     c.OnlinepupilLick         = figure('Position', [scrsz(1)+scrsz(3)/2 scrsz(2) scrsz(3)/2 scrsz(4)/2],...
%         'Name','OnlinepupilLick',...
%         'NumberTitle','off',...
%         'Color',[0.8 0.8 0.8],...
%         'Visible','on',...
%         'NextPlot','add');
% else
%     c.onRastwin         = findobj('Name','OnlinepupilLick');
%     set(0, 'CurrentFigure', c.onRastwin);
%     
%     
% end

set(0, 'CurrentFigure', c.onplotwin);
% make all axes for probability of looking plots
c.uniquefractallist = [8800 8801 8802 8803 8804 8805 8806 8807 8808 8809 9800 9801 9802 9803 9804 9805 9806 9807 9808 9809];
PlotsWanted=size(c.uniquefractallist,2);

xposition = [1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 ];
yposition = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 ];

RowsNeeded = 4;%ceil(sqrt(PlotsWanted));
 ColsNeeded= 5;%floor(sqrt(PlotsWanted));
if (RowsNeeded* ColsNeeded)<PlotsWanted
   ColsNeeded =ColsNeeded+1
end


for jj=1:PlotsWanted
    c.plotax(jj) = nsubplot(RowsNeeded,ColsNeeded, yposition(jj),xposition(jj));
    
     c.plotdata(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdata2ndCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdata3rdCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     c.plotdata4thCondition(jj) = plot(c.plotax(jj), NaN, NaN);
     
    c.plotaxTitle(jj) = title(['ProbOfLooking ' num2str(c.uniquefractallist(jj))]);  

end


% add some axes
set(0, 'CurrentFigure', c.onRastwin);

plotTitles = {'100Rni' '75Rni' '50Rni' '25Rni' '0ni' '100Pni' '75Pni' '50Pni' '25Pni' '5050ni' '100Ri' '75Ri' '50Ri' '25Ri' '0i' '100Pi' '75Pi' '50Pi' '25Pi' '5050i'};

% RowsNeeded = ceil(sqrt(PlotsWanted));
%  ColsNeeded= floor(sqrt(PlotsWanted));
% if (RowsNeeded* ColsNeeded)<PlotsWanted
%    ColsNeeded =ColsNeeded+1
% end
c.globalMaxForRasters =0;
c.globalMaxForMeanRateData =0;
for j=1:PlotsWanted
    % add axes for raster and sums
    c.plotax_raster(j) =       nsubplot_raster(RowsNeeded,ColsNeeded,yposition(j),xposition(j));
    c.plotax_rasterSum(j) = nsubplot_rasterSum(RowsNeeded,ColsNeeded,yposition(j),xposition(j));
  
    % add a dummy plot object
    c.plotobj_raster(j) = plot(c.plotax_raster(j), NaN, NaN, 'r', 'LineWidth', 0.5);
    
    c.plot_rasterSum(j)= plot(c.plotax_rasterSum(j), NaN, NaN, 'k', 'LineWidth', 1);
    c.plot_rasterSum2ndConditon(j)= plot(c.plotax_rasterSum(j), NaN, NaN, 'k', 'LineWidth', 1);
    c.plot_rasterSum3rdCondition(j)= plot(c.plotax_rasterSum(j), NaN, NaN, 'k', 'LineWidth', 1);
    c.plot_rasterSum4thCondition(j)= plot(c.plotax_rasterSum(j), NaN, NaN, 'k', 'LineWidth', 1);
    

    
    c.CsOnPlotLine(j) = line([0 0], [ylim ],'Color' ,'c' );
    
    c.CsOffPlotLine(j) = line([1 1 ], [ylim ],'Color' ,'y' );

        c.plotaxrasterTitle(j) = title([num2str(c.uniquefractallist(j)) '-' plotTitles{j}]);

        c.rasterLineCount(j)=0;
                c.plotMax(j)=0;
        c.plotMin(j)=0;
end

% 
% set(0, 'CurrentFigure', c.OnlinepupilLick);
% % make all axes for pupil and lick
% c.uniquefractallist = [6300 6301 6302 6303 6304 6305 6306 6307 6308 6309 6310 6311  ];
% PlotsWanted=size(c.uniquefractallist,2);
% 
% xposition = [1 2 3 1 2 3 1 2 3 1 2 3];
% yposition = [1 1 1 2 2 2 3 3 3 4 4 4];
% 
% RowsNeeded = ceil(sqrt(PlotsWanted));
%  ColsNeeded= floor(sqrt(PlotsWanted));
% if (RowsNeeded* ColsNeeded)<PlotsWanted
%    ColsNeeded =ColsNeeded+1
% end
% 
% 
% for jj=1:PlotsWanted
% 
%     c.plotaxpupil(jj) = nsubplot(RowsNeeded,ColsNeeded, yposition(jj),xposition(jj));
%     
%      c.plotdatapupil(jj) = plot(c.plotaxpupil(jj), NaN, NaN);
%      c.plotdatapupil2ndCondition(jj) = plot( c.plotaxpupil(jj), NaN, NaN);
%      c.plotdatapupil3rdCondition(jj) = plot( c.plotaxpupil(jj), NaN, NaN);
%      c.plotdatapupil4thCondition(jj) = plot( c.plotaxpupil(jj), NaN, NaN);
%      
%     c.plotaxpupilTitle(jj) = title(['Pupildialation ' num2str(c.uniquefractallist(jj))]);  
% end




% make a cell-array of x-axis text-labels and colors for plotting.
myColors                = [0 1 0; 1 0 0; 0 0 1];
myLabels                = {'Hit','Fixation-Break','Non-Start'};

% Show the online plot window.
set(c.onplotwin,'Visible','on');
set(c.onRastwin,'Visible','on');
end

function c = plotinit(c)
%init
% trialNumber =1; % comment out for actual iteration

c.stepSizeOfResampledPDS = 1/2750;
c.targetWindowPdsVals.xPos = 0 ; % placeholder vals, calc  from PDS.targAngle in switch
c.targetWindowPdsVals.yPos =  0;   % always mid screen for now...

c.targetWindowPdsVals.xSize = c.tp1WindW ; %2 ;  % in degrees,, settable?
c.targetWindowPdsVals.ySize =  c.tp1WindH ; % 2;  % in degrees,, settable?
c.targetDispacementFromCenter =c.TargAmp ;%2;

end

function c                      = audioinit(c)
%% Audio Stuff
% Variables.
c.freq          = 48000;                % Sampling rate.
c.rightFreq     = 300;                  % A low-frequency tone to signal "WRONG"
c.wrongFreq     = 150;                  % A high-frequency tone to signal "RIGHT"
c.nTF           = round(c.freq/10);     % The tone-duration.
c.lrMode        = 0;                    % Mono sound on both channels.
c.wrongbuffadd  = 0;                    % Start-address of the first sound's buffer.

% Make a plateau-ed window with gaussian rise and fall at the beginning and
% end. Start by making the gaussian rise at the beginning. Use somewhat
% arbitrary values of MU and SIGMA to position the rise/fall in a place that
% you like.
risefallProp                    = 1/4;                              % proportion of sound for rise/fall
plateauProp                     = 1-2*risefallProp;                 % proportion of sound for plateau
mu1                             = round(risefallProp*c.nTF);        % Gaussian mean expressed in samples
sigma1                          = round(c.nTF/12);                  % Gaussian SD in samples, effectively the rate of rise/fall.

tempWindow                      = [normpdf(1:mu1,mu1,sigma1),...                                % RISE
    ones(1,round(plateauProp*c.nTF))*normpdf(mu1,mu1,sigma1),...    % PLATEAU (scaled to meet the rise/fall)
    fliplr(normpdf(1:mu1,mu1,sigma1))];                             % FALL

% Additively scale the window to ensure that it starts and ends at zero.
tempWindow                      = tempWindow - min(tempWindow);

% Multiplicatively scale the window to put the plateau at one.
tempWindow                      = tempWindow/max(tempWindow);

% Make the two sounds, one at 150hz ("righttone"), one at 300hz ("wrongtone").
c.wrongtone     = tempWindow.*sin((1:c.nTF)*2*pi*c.wrongFreq/c.freq);
c.righttone     = tempWindow.*sin((1:c.nTF)*2*pi*c.rightFreq/c.freq);
c.noisetone     = tempWindow.*((rand(1,c.nTF)-0.5)*2);

% Normalize the windowed sounds (keep them between -1 and 1.
c.wrongtone     = c.wrongtone/max(abs(c.wrongtone));
c.righttone     = c.righttone/max(abs(c.righttone));
c.noisetone     = c.noisetone/max(abs(c.noisetone));
end

function c                      = lutinit(c)
% initialize color lookup tables
% CLUTs may be customized as needed
% CLUTS also need to be defined before initializing DataPixx

% initialize DKL conversion stuff
initmon('LUTvpixx');

% bgRGB                                           = dkl2rgb([0 0 0]')'; %
% original line
bgRGB                                           = dkl2rgb( [0 0 0]')';

c.bgRGB=bgRGB;
%mutedGreen                                      = dkl2rgb([-0.2 -0.6 0.5]')';

mutedGreen                                      = dkl2rgb([0 -0.6 0.5]')';
c.mutedGreen=mutedGreen;
% c.colorone                                      = dkl2rgb([0.2 0.5 0.8]')';
% c.colortwo                                      = dkl2rgb([0.2 0.3 0]')';

c.colorone                                      = dkl2rgb([0.2 0.5 0.8]')';
c.colortwo                                      = dkl2rgb([0.5 0.3 0.5]')';

c.backcolor         = 2;

% colors for EXPERIMENTER's display
% black                     0
% grey-1 (grid-lines)       1
% grey-2 (background)       2
% grey-3 (fix-window)       3
% white  (fix-point)        4
% red                       5
% green                     6
% blue                      7
% cuering                   8
% muted green (fixation)    9

c.humanColors       = [ 0, 0, 0;                        % 0
    0.25, 0.25, 0.25;               % 1
    bgRGB;                          % 2
    0.8, 0.8, 0.8;                  % 3
    1, 1, 1;                        % 4
    1, 0.2, 0.2;                    % 5
    0, 1, 0;                        % 6
    0.4, 0.698, 1;                  % 7
    0.9,0.9,0.9;                    % 8
    mutedGreen];                    % 9

% colors for MONKEY's display
% black                     0
% grey-2 (grid-lines)       2
% grey-2 (background)       2
% grey-2 (fix-window)       3
% white  (fix-point)        4
% grey-2 (red)              2
% grey-2 (green)            2
% grey-2 (blue)             2
% cuering                   8
% muted green (fixation)    9

%ilya's add to make the monkey's screen black
% 
% backgr=[0, 0, 0];
% c.monkeyColors       = [ 0, 0, 0;                       % 0
%     backgr;                          % 1
%     backgr;                          % 2
%     bgRGB;                          % 3
%     1, 1, 1;                        % 4
%     bgRGB;                          % 5
%     bgRGB;                          % 6
%     backgr;                          % 7
%     0.9,0.9,0.9;                    % 8
%     mutedGreen];                    % 9 %this was


%use this for gray background .. the above one is for black monkey
%background
c.monkeyColors       = [ 0, 0, 0;                       % 0
    bgRGB;                          % 1
    bgRGB;                          % 2
    bgRGB;                          % 3
    1, 1, 1;                        % 4
    1, 0.2, 0.2;                    % 5
    bgRGB;                          % 6
    0.4, 0.698, 1;                  % 7
    0.9,0.9,0.9;                    % 8
    mutedGreen];                    % 9


c.humanColors(10,:)=c.colortwo;
c.monkeyColors(10,:)=c.colortwo;

c.humanColors(9,:)=c.colorone;
c.monkeyColors(9,:)=c.colorone;





%ilya commented out ffc line
c.ffc                                           = size(c.humanColors,1)+1;
c.humanCLUT                                     = c.humanColors;
c.monkeyCLUT                                    = c.monkeyColors;

c.humanCLUT(length(c.humanColors)+1:256,:)      = hsv2rgb(hsv(256-length(c.humanColors)));
c.monkeyCLUT(length(c.monkeyColors)+1:256,:)    = hsv2rgb(hsv(256-length(c.monkeyColors)));




%c.humanCLUT=[hsv2rgb(hsv(256-length(c.humanColors))); c.humanCLUT];
%c.monkeyCLUT=[hsv2rgb(hsv(256-length(c.monkeyColors))); c.monkeyCLUT ];


%xtemp=([[0:1/255:1]', zeros(256,1), zeros(256,1)]); %this is just the red channel
% xtemp=([[0:.5/255:.5]', [0:.5/255:.5]', zeros(256,1)]);
% xtemp(1:size(c.monkeyColors,1),:)=c.monkeyColors;
% c.monkeyCLUT=xtemp; clear xtremp;


%ilya add
%  templeng=(256-length(c.monkeyColors));
% linear_lut_=repmat(linspace(0,1,templeng)',1,3);
% %linear_lut_=repmat(linspace(1,1,246)',1,3);
%  c.monkeyCLUT(length(c.monkeyColors)+1:256,:)    = linear_lut_;

end

function initmon(initfile)
%INITMON  Initializes DKL<-->RGB conversion matrices
%   INITMON(INITFILE) initializes DKL<-->RGB conversion matrices for the
%   CIE xyY coordinates of monitor phosphors given in INITFILE.
%
%   INITMON without arguments uses default xyY values to initialize the
%   conversion matrices.
%
%   Function INITMON must be called once prior to subsequent calls of
%   conversion routines DKL2RGB or RGB2DKL.
%
%   See also DKL2RGB, RGB2DKL.
%
%Thorsten Hansen 2003-06-23


% file format of xyY monitor coordinates
% xyY coordinates of (r,g,b) monitor phospors and neutral gray point n
% file format:
%
%   rx ry rY
%   gx gy gY
%   bx by bY

% read CIE information
moncie = textread([initfile '.xyY']);

% read gamma tables
global Rg Gg Bg
Rg = importdata([initfile '.r'])'/255;
Gg = importdata([initfile '.g'])'/255;
Bg = importdata([initfile '.b'])'/255;

global global_moncie
global_moncie = moncie;

% initialize conversion matrices M_dkl2rgb and M_rgb2dkl
% from monitor coordinates moncie
global M_dkl2rgb M_rgb2dkl

M_dkl2rgb = getdkl(moncie(1:3,:)); % fourth line not needed
M_rgb2dkl = inv(M_dkl2rgb);

%
% initialize conversion matrices M_rgb2lms and M_lms2rgb
%
global M_rgb2lms M_lms2rgb

% TEST: new vectorized implementation
monxyY = moncie;
x = monxyY(:,1);
y = monxyY(:,2);
Y = monxyY(:,3);

if prod(y) == 0, error('y column contains zero value.'), end
z = 1-x-y;
monxyz = [x y z];

white = Y/2;

X = x./y.*Y;
Z = z./y.*Y;
monXYZ = [X Y Z]; % this should be monCIE
% end TEST

monCIE = zeros(3,3);
monCIE(:,2) = moncie(1:3,3);

for i=1:3
    moncie(i,3) = 1.0 - moncie(i,1) - moncie(i,2);
    monCIE(i,1) = (moncie(i,1)/moncie(i,2))*monCIE(i,2);
    monCIE(i,3) = (moncie(i,3)/moncie(i,2))*monCIE(i,2);
    monRGB(i,1) = 0.15514 * monCIE(i,1) + ...
        0.54313 * monCIE(i,2) - 0.03386 * monCIE(i,3);
    monRGB(i,2) = -0.15514 * monCIE(i,1) + ...
        0.45684 * monCIE(i,2) + 0.03386 * monCIE(i,3);
    monRGB(i,3) = 0.01608 * monCIE(i,3);
    tsum = monRGB(i,1) + monRGB(i,2);
    monrgb(i,1) = monRGB(i,1) / tsum;
    monrgb(i,2) = monRGB(i,2) / tsum;
    monrgb(i,3) = monRGB(i,3) / tsum;
end

M_rgb2lms = monRGB; % M_rgb2lms used in mon2cones
% why not directly compute on M_rgb2lms ?

M_lms2rgb = inv(M_rgb2lms);
end

function M_dkl2rgb              = getdkl(monxyY)
%------------------------------------------------------------------------------
% compute dkl2rgb conversion matrix from moncie coordinates
% (compare function "getdkl" in color.c)

x = monxyY(:,1); y = monxyY(:,2); Y = monxyY(:,3);
if prod(y) == 0, error('y column contains zero value.'), end
xyz = [x y 1-x-y];
white = Y/2;

% Smith & Pokorny cone fundamentals
% V. C. Smith & J. Pokorny (1975), Vision Res. 15, 161-172.
M = [ 0.15514  0.54312  -0.03286
    -0.15514  0.45684   0.03286
    0.0      0.0       0.01608];

RGB = xyz*M'; % R, G  and B cones (i.e, long, middle and short wavelength)

RG_sum = RGB(:,1) + RGB(:,2); % R G sum
R = RGB(:,1)./RG_sum;%similar to MacLeod-Boynton?
B = RGB(:,3)./RG_sum;
G = 1 - R;

% alternative implementation of last 4 lines
%RGB = RGB./repmat(RGB(:,1) + RGB(:,2), 1, 3);
%R = RGB(:,1); G = RGB(:,2); B = RGB(:, 3);

% constant blue axis
a = white(1)*B(1);
b = white(1)*(R(1)+G(1));
c = B(2);
d = B(3);
e = R(2)+G(2);
f = R(3)+G(3);
dGcb = (a*f/d - b)/(c*f/d - e); % solve x
dBcb = (a*e/c - b)/(d*e/c - f); % solve y

% tritanopic confusion axis
a = white(3)*R(3);
b = white(3)*G(3);
c = R(1);
d = R(2);
e = G(1);
f = G(2);
dRtc = (a*f/d - b)/(c*f/d - e); % solve x
dGtc = (a*e/c - b)/(d*e/c - f); % solve y

IMAX = 1;
M_dkl2rgb = IMAX * [1        1         dRtc/white(1)
    1  -dGcb/white(2)  dGtc/white(2)
    1  -dBcb/white(3)     -1];
end

function rgb                    = dkl2rgb(x,varargin)

% rgb = dkl2rgb(x,bgRGB)

if(nargin>1)
    bgRGB = round(varargin{1}*255);
else
    bgRGB = round([0.5 0.5 0.5]*255);
end

% Load the rotation matrix
global M_dkl2rgb

% Load the gamma correction LUTs
global Rg Gg Bg

% Convert from DKL to RGB
rgb         = round((0.5 + M_dkl2rgb*x/2)*255);

% Find "bad" values (out of RGB range).
bad         = sum(rgb>255 |rgb<0)>0;

% Replace "bad" values with the background color.
rgb(:,bad)    = bgRGB(ones(nnz(bad),1),:)';

% Gamma correct
rgb         = [Rg(rgb(1,:)+1), Gg(rgb(2,:)+1), Bg(rgb(3,:)+1)]';
end