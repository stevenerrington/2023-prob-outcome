[bb,aa]=butter(8,10/500,'low');
savestruct(x_file).brokenanalog=0;
close all;

% note that I did notcheck the code that is for Plex Converted files for
% this project.

try
    
    if PDS.plexonconv(1)==1
        
        millisecondResolution=0.001;
        Pupil=[];
        Xeye=[];
        Yeye=[];
        Lick=[];
        Blnksdetect=[];
        Lickbase=[];
        
        temp=[];
        for x=1:length(PDS.fractals);
            t=  PDS.AIvariables{3,x}./10000;
            temp=[temp;t(:,1)];
        end
        BlinkT=min(temp+.4); clear t temp
        
        for x=1:length(PDS.fractals)
            
            targon_=fix(PDS.timetargeton(x)*1000);
            targrange=[targon_' : targon_'+3250];
            
            badtrialfiller(1:length(targrange))=NaN;
            
            Xeye_ = PDS.AIvariables{1,x};
            Yeye_ = PDS.AIvariables{2,x};
            Pupil_ = PDS.AIvariables{3,x}./10000;
            Lick_ = PDS.AIvariables{4,x};
            Lick_(:,1)=filtfilt(bb,aa,Lick_(:,1));
            Lick=[Lick; Lick_(targrange,1)'];
            
            temp1(1:length(Pupil_(:,1)))=0;
            temp1(find(Pupil_(:,1)<BlinkT))=1;                  %ARBITRARY NUMBER BASED ON EYE LINK SETTINGS; derived above; always check by eye
            Blnksdetect=[Blnksdetect; temp1(targrange)]; clear temp1
            
            
            try
                Xeye=[Xeye; Xeye_(targrange,1)'];
                Yeye=[Yeye; Yeye_(targrange,1)'];
                Pupil=[Pupil; Pupil_(targrange,1)'];
                Lick=[Lick; Lick_(targrange,1)'];
            catch
                Xeye=[Xeye; badtrialfiller];
                Yeye=[Yeye; badtrialfiller];
                Pupil=[Pupil; badtrialfiller];
                Lick=[Lick; badtrialfiller];
            end
            
            
            lickbaserange=[targon_'-1000 : targon_'];
            Lickbase=[Lickbase; Lick_(lickbaserange,1)'];
            
            clear Xeye_ Yeye_ Pupil_ Lick_
            
        end
        
        Lickdetect=[];
        numberofstd=2;
        baseline=Lickbase;
        baseline=baseline(:);
        baseline=baseline(find(isnan(baseline)==0));
        baselinemean=mean(baseline(:));
        rangemin=baselinemean-(std(baseline)*numberofstd);
        rangemax=baselinemean+(std(baseline)*numberofstd);
        for x=1:length(PDS.fractals)
            x=Lick(x,:);
            x(find(x<rangemin | x>rangemax))=999999;
            x(find(x~=999999))=0;
            x(find(x==999999))=1;
            Lickdetect=[Lickdetect; x]; clear x;
        end
        
           SaveTarget=[]; %iem
        SaveGazeDegX=[]; %iem
        SaveGazeDegY=[]; %iem
        
        
        LookingTargArray=[];
        windowwidth=5;
        for x=1:length(PDS.fractals)
            try
                clear tempx tempy temp xx c
                tempx=Xeye(x,:)./1000;
                tempy=Yeye(x,:)./1000;
                
                c.viewdist                      = 410;      % viewing distance (mm)
                c.screenhpix                    = 1080;     % screen height (pixels)
                c.screenh                       = 293.22;
                
                V=tempx;
                for xx=1:length(tempx)
                    EyeX(xx)    = V(xx); % sign(V(xx))*deg2pix(8*abs(V(xx)),c);
                end
                
                V=tempy;
                for xx=1:length(tempy)
                    EyeY(xx)    = V(xx); % sign(V(xx))*deg2pix(8*abs(V(xx)),c);
                end
                
                
         
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                angs=PDS.angeofCS(x);
                amp=12;                     %SET BECAUSE NOT IN PLEXON. CHECK CODE ON RIG
                amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
                location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
                timelook=find(tempx>location(1)-windowwidth & tempx<location(1)+windowwidth & tempy>location(2)-windowwidth & tempy<location(2)+windowwidth);
                
                temp(1:length(tempx))=0;
                temp(timelook)=1;
                
                %%%
                SaveTarget=[SaveTarget;location]; %iem
                SaveGazeDegX=[SaveGazeDegX;EyeX]; %iem
                SaveGazeDegY=[SaveGazeDegY;EyeY]; %iem
                %%%
                clear EyeX EyeY
                
                LookingTargArray=[LookingTargArray; temp];
            catch
                
                temp(1:3251)=NaN;
                LookingTargArray=[LookingTargArray; temp];
                
                %%%
                SaveTarget=[SaveTarget;NaN NaN]; %iem
                SaveGazeDegX=[SaveGazeDegX;temp]; %iem
                SaveGazeDegY=[SaveGazeDegY;temp]; %iem
                %%%
                clear EyeX EyeY
                
            end
            
            clear temp timelook amp angs tempy tempx x V tempx tempy
            
        end
        
        
        savestruct(x_file).BlinkThreshold=  BlinkT;
        
        Blnk_detect=Blnksdetect;
        
        %%%%Find first time animal looks at Cue starting with 100ms before info
        %%%%cue to the outcome
        try
            TH_stayoncue=100; %threshold for how long an animmal has to stay on cue to count as an eyemovement towards cue (to get rid of scans)
            saveSingTrGaze=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,900:end); temp=findseq(temp);
                    temp=temp(find(temp(:,4)>TH_stayoncue),:);
                    Suatime=temp(1,2)+900;
                catch
                    Suatime=NaN;
                end
                saveSingTrGaze=[saveSingTrGaze; Suatime];
            end
        catch
            saveSingTrGaze(1:length(PDS.fractals))=NaN;
        end
        
        try
            saveSingLook=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,900:1000);
                    if length(find(temp==1)) >70
                        Suatime=1;
                    elseif length(find(temp==1)) <30
                        Suatime=-1;
                    else
                        Suatime=0;
                    end
                catch
                    Suatime=NaN;
                end
                saveSingLook=[saveSingLook; Suatime];
            end
        catch
            saveSingLook(1:length(PDS.fractals))=NaN;
        end
        
        try
            saveSingLook1=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,100:3251);
                    if length(find(temp==1)) >300
                        Suatime=1;
                    elseif length(find(temp==1)) <300
                        Suatime=-1;
                    else
                        Suatime=0;
                    end
                catch
                    Suatime=NaN;
                end
                saveSingLook1=[saveSingLook1; Suatime];
            end
        catch
            saveSingLook1(1:length(PDS.fractals))=NaN;
        end
        
    else
        
        millisecondResolution=0.001;
        Pupil=[];
        Xeye=[];
        Yeye=[];
        Lick=[];
        Blnksdetect=[];
        %onlineLickForce
        for x=1:length(PDS.timefpon)
            trialanalog=PDS.onlineEye{x};
            %
            temp=trialanalog(:,3:4);
            relatveTimePDS = temp(:,2)-temp(1,2);
            regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
            regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
            regularPdsData(length(regularPdsData)+1:12000)=NaN; %i do this because they may be different sizes
            
            BlinkT=-4.75;
            
            temp1(1:12000)=0;
            temp1(find(regularPdsData<BlinkT))=1;
            Blnksdetect=[Blnksdetect; temp1(1:12000)];
            clear regularPdsData regularTimeVectorForPdsInterval temp temp1 relatveTimePDS
            
            temp=trialanalog(:,[1 4]);
            relatveTimePDS = temp(:,2)-temp(1,2);
            regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
            regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
            regularPdsData(length(regularPdsData)+1:12000)=NaN;
            Xeye=[Xeye; regularPdsData(1:12000)];
            clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS
            %
            temp=trialanalog(:,[2 4]);
            relatveTimePDS = temp(:,2)-temp(1,2);
            regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
            regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
            regularPdsData(length(regularPdsData)+1:12000)=NaN;
            Yeye=[Yeye; regularPdsData(1:12000)];
            clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS
            %
            temp = PDS.onlineLickForce{x};
            relatveTimePDS = temp(:,2)-temp(1,2);
            regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
            regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
            %
            [bb,aa]=butter(8,10/500,'low');
            regularPdsData=filtfilt(bb,aa,regularPdsData);
            %
            regularPdsData(length(regularPdsData)+1:12000)=NaN;
            Lick=[Lick; regularPdsData(1:12000)];
            clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS   %
        end
        %
        
        Blnk_detect=[];
        targon_=fix(PDS.TimeofPunish*1000);
        targrange=[targon_'-1000 targon_'+3000];
        for b=1:length(PDS.TimeofPunish)
            try
                t= Blnksdetect(b,[targrange(b,1):targrange(b,2)]);
            catch
                t(1:4001)=NaN;
            end
            Blnk_detect=[Blnk_detect; t]; clear t
        end
        Blnksdetect=Blnk_detect;
        %
        Lick_=[];
        for b=1:length(PDS.TimeofPunish)
            try
                t=Lick(b,[targrange(b,1):targrange(b,2)]);
            catch
                t(1:4001)=NaN;
            end
            Lick_=[Lick_; t]; clear t
        end
        
        
        
% % %         Lick_=Lick_-mean(Lick_(:,1:1000)')';
% % %         %
% % %         %
        

        Lickdetect=[];
        numberofstd=2;
        baseline=Lick_(:,1:1000);
        baseline=baseline(:);
        baseline=baseline(find(isnan(baseline)==0));
        baselinemean=mean(baseline(:));
        rangemin=baselinemean-(std(baseline)*numberofstd);
        rangemax=baselinemean+(std(baseline)*numberofstd);
        
        for x=1:length(PDS.TimeofPunish)
            x=Lick_(x,:);
            x(find(x<rangemin | x>rangemax))=999999;
            x(find(x~=999999))=0;
            x(find(x==999999))=1;
            Lickdetect=[Lickdetect; x]; clear x;
        end
        
        
        
        
        
        
        
        
        Lickdetect=Lickdetect(:,1001:end);
        %
        %
     
               SaveTarget=[]; %iem
            SaveGazeDegX=[]; %iem
            SaveGazeDegY=[]; %iem
        LookingTargArray=[];
        
        windowwidth=5;
        for x=1:length(PDS.fractals)
            tempx=Xeye(x,:);
            tempy=Yeye(x,:);
            temp=(fix(PDS.timetargeton(x)*1000):fix(PDS.timetargeton(x)*1000)+3250);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            angs=PDS.targAngle(x);
            amp=PDS.targAmp(x);
            amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
            location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
            timelook=find(tempx>location(1)-windowwidth & tempx<location(1)+windowwidth & tempy>location(2)-windowwidth & tempy<location(2)+windowwidth);
            
            temp(1:length(tempx))=0;
            temp(timelook)=1;
            try
                temp=temp(fix(PDS.timetargeton(x)*1000):fix(PDS.timetargeton(x)*1000)+3250);
                   tempx=tempx(fix(PDS.timetargeton(x)*1000):fix(PDS.timetargeton(x)*1000)+3250);
                tempy=tempy(fix(PDS.timetargeton(x)*1000):fix(PDS.timetargeton(x)*1000)+3250);
               SaveTarget=[SaveTarget;location]; 
               SaveGazeDegX=[SaveGazeDegX;tempx]; 
               SaveGazeDegY=[SaveGazeDegY;tempy;]; 
            catch
            clear temp;
            temp(1:3250)=NaN;
            SaveTarget=[SaveTarget;NaN NaN]; %iem
            SaveGazeDegX=[SaveGazeDegX;temp]; %iem
            SaveGazeDegY=[SaveGazeDegY;temp]; %iem
            
            
            end
            LookingTargArray=[LookingTargArray; temp];
            clear temp timelook amp angs tempy tempx x c
        end
        LookingTargArray(find(PDS.targAngle==-1),:)=NaN;
        
        
        
        savestruct(x_file).BlinkThreshold=  BlinkT;
        
        %Blnk_detect=Blnksdetect;
        
        %%%%Find first time animal looks at Cue starting with 100ms before info
        %%%%cue to the outcome
        try
            TH_stayoncue=100; %threshold for how long an animmal has to stay on cue to count as an eyemovement towards cue (to get rid of scans)
            saveSingTrGaze=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,900:end); temp=findseq(temp);
                    temp=temp(find(temp(:,4)>TH_stayoncue),:);
                    Suatime=temp(1,2)+900;
                catch
                    Suatime=NaN;
                end
                saveSingTrGaze=[saveSingTrGaze; Suatime];
            end
        catch
            saveSingTrGaze(1:length(PDS.fractals))=NaN;
        end
        
        try
            saveSingLook=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,900:1000);
                    if length(find(temp==1)) >70
                        Suatime=1;
                    elseif length(find(temp==1)) <30
                        Suatime=-1;
                    else
                        Suatime=0;
                    end
                catch
                    Suatime=NaN;
                end
                saveSingLook=[saveSingLook; Suatime];
            end
        catch
            saveSingLook(1:length(PDS.fractals))=NaN;
        end
        
        try
            saveSingLook1=[];
            for NB=1:size(LookingTargArray,1)
                try
                    temp=LookingTargArray(NB,100:3251);
                    if length(find(temp==1)) >300
                        Suatime=1;
                    elseif length(find(temp==1)) <300
                        Suatime=-1;
                    else
                        Suatime=0;
                    end
                catch
                    Suatime=NaN;
                end
                saveSingLook1=[saveSingLook1; Suatime];
            end
        catch
            saveSingLook1(1:length(PDS.fractals))=NaN;
        end
        
        
    end
    
    clear x
    
catch
    savestruct(x_file).BlinkThreshold=NaN;
    savestruct(x_file).brokenanalog=1;
    LookingTargArray(1:length(PDS.fractals),1:3251)=NaN;
    Lickdetect(1:length(PDS.fractals),1:3251)=NaN;
    Blnk_detect(1:length(PDS.fractals),1:3251)=NaN;
    saveSingTrGaze(1:length(PDS.fractals))=NaN;
    saveSingLook(1:length(PDS.fractals))=NaN;
    saveSingLook1(1:length(PDS.fractals))=NaN;
    
end


%size(Rasters)
%         213       12000; with 6000 as center (CS PRES)

%size(Xeye)
%213        3251


%SaveGazeDegX=SaveGazeDegX ; %./1000;
%SaveGazeDegY=SaveGazeDegY ; %./1000;
%SaveTarget;





clear EyeX EyeY

function pixels             =   deg2pix(degrees,c) % PPD pixels/degree
% deg2pix convert degrees of visual angle into pixels

pixels = round(tand(degrees)*c.viewdist*c.screenhpix/c.screenh);

end
