clear all; close all;
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL');

% 
% pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\'; addpath(pathname);
% pathname1 = 'Y:\MONKEYDATA\Sabbath\LaserTest\'; addpath(pathname1);
% DDD = dir([pathname 'V*.mat']);
% DDD1 = dir([pathname1 'V*.mat']);
% DDD=[DDD; DDD1];
% monk='combined'
% [bb,aa]=butter(8,10/500,'low');
% 
% for xyz = 1:length(DDD)
%     
%     filename = DDD(xyz).name(1:end-4);
%     load([filename '.mat'],'PDS'); %load session
%     
%     savestruct(xyz).filename=filename;
%     
%     millisecondResolution=0.001;
%     Xeye=[];
%     Yeye=[];
%     Blnksdetect=[];
%     Pupil=[];
%     Lick=[];
%     
%     for x=1:length(PDS.timefpon)
%         trialanalog=PDS.onlineEye{x};
%         %
%         temp=trialanalog(:,[1 4]);
%         relatveTimePDS = temp(:,2)-temp(1,2);
%         regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
%         regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
%         regularPdsData(length(regularPdsData)+1:12000)=NaN;
%         Xeye=[Xeye; regularPdsData(1:12000)];
%         clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS
%         %
%         temp=trialanalog(:,[2 4]);
%         relatveTimePDS = temp(:,2)-temp(1,2);
%         regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
%         regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
%         regularPdsData(length(regularPdsData)+1:12000)=NaN;
%         Yeye=[Yeye; regularPdsData(1:12000)];
%         clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS
%         %
%         
%         %%%%%%%%%%%%%%%%%%%%%%
%         temp=trialanalog(:,3:4);
%         relatveTimePDS = temp(:,2)-temp(1,2);
%         regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
%         regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
%         regularPdsData(length(regularPdsData)+1:12000)=NaN; %i do this because they may be different sizes
%         BlinkT=-4.75;
%         temp1(1:12000)=0;
%         temp1(find(regularPdsData<BlinkT))=1;
%         Blnksdetect=[Blnksdetect; temp1(1:12000)];
%         
%         %         figuren;
%         %         nsubplot(5, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%         %         plot(regularPdsData)
%         %         xlim([0 12000])
%         %         nsubplot(5, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%         %         plot( Blnksdetect)
%         %         xlim([0 12000])
%         
%         %remove blinks (very crude)
%         regularPdsData(1:40)=-2;
%         findblinks=find(regularPdsData<-4.2); %%% VOLTAGE THRESHOLD; SOME -4.9 some -9.9 depending on eyelink voltage output settings
%         
%         %get rid of blinks out of pupil dillation
%         if ~isempty(findblinks)==1
%             for zz=1:length(findblinks)
%                 regularPdsData(fix(findblinks(zz))-20:fix(findblinks(zz))+40)=NaN; %regularPdsData(fix(findblinks(zz)-50));
%             end
%         end
%         regularPdsData=regularPdsData(1:12000);
%         %
%         
%         %         vs=find(isnan(regularPdsData)==1)
%         %         regularPdsData(vs)=-2;
%         %         regularPdsData=filtfilt(bb,aa,regularPdsData);
%         %         regularPdsData(vs)=NaN;
%         
%         Pupil=[Pupil; regularPdsData];
%         
%         %         nsubplot(5, 1, 3, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%         %         plot( regularPdsData)
%         %         xlim([0 12000])
%         
%         clear regularPdsData regularTimeVectorForPdsInterval temp temp1 relatveTimePDS
%         
%         temp = PDS.onlineLickForce{x};
%         relatveTimePDS = temp(:,2)-temp(1,2);
%         regularTimeVectorForPdsInterval = [0: millisecondResolution  : temp(end,2)-temp(1,2)];
%         regularPdsData = interp1(  relatveTimePDS , temp(:,1) , regularTimeVectorForPdsInterval  );
%         
%         regularPdsData=filtfilt(bb,aa,regularPdsData);
%         %
%         regularPdsData(length(regularPdsData)+1:12000)=NaN;
%         Lick=[Lick; regularPdsData(1:12000)];
%         
%         %         nsubplot(5, 1, 4, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%         %         plot( regularPdsData)
%         %         xlim([0 12000])
%         clear regularPdsData regularTimeVectorForPdsInterval temp relatveTimePDS   %
%         
%         close all;
%         
%     end
%     
%     %     Lickdetect=[];
%     %     numberofstd=2;
%     %     baseline=Lick(:,1:400);
%     %     baseline=baseline(:);
%     %     baseline=baseline(isnan(baseline)==0);
%     %     baselinemean=mean(baseline(:));
%     %     rangemin=baselinemean-(std(baseline)*numberofstd);
%     %     rangemax=baselinemean+(std(baseline)*numberofstd);
%     %     for x=1:length(PDS.timefpon)
%     %         x=Lick(x,:);
%     %         x(x<rangemin | x>rangemax)=999999;
%     %         x(x~=999999)=0;
%     %         x(x==999999)=1;
%     %         Lickdetect=[Lickdetect; x]; clear x;
%     %     end
%     
%     %     for x=1:length(PDS.timefpon)
%     %         figuren;
%     %         nsubplot(5, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%     %         plot( Lick(x,:))
%     %         xlim([0 12000])
%     %         nsubplot(5, 1, 2, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
%     %         plot( Lickdetect(x,:))
%     %         xlim([0 12000])
%     %         close all;
%     %     end
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     timeChoice=fix(PDS.timeChoice*1000);
%     timeReward=fix(PDS.timereward*1000);
%     timePunish=fix(PDS.TimeofPunish*1000);
%     
%     chosen_=[];
%     choices_=[PDS.RewardRange1' PDS.PunishmentRange1' PDS.RewardRange2' PDS.PunishmentRange2' PDS.chosenwindow'];
%     for xC=1:length(PDS.RewardRange1)
%         c=choices_(xC,:);
%         if c(:,5)==1
%             chosen_=[chosen_; c(1:2)];
%         elseif c(:,5)==2
%             chosen_=[chosen_; c(3:4)];
%         else
%             chosen_=[chosen_; NaN NaN];
%         end
%     end
%     
%     matrix=[timeChoice' timePunish' timeReward' chosen_];
%     
%     temp=unique([find(isnan(matrix(:,1))==1)
%         find(isnan(matrix(:,2))==1)
%         find(isnan(matrix(:,3))==1)
%         find(isnan(matrix(:,4))==1)
%         find(isnan(matrix(:,5))==1)]);
%     matrix(temp,:)=NaN; clear temp
%     
%     savestruct(xyz).matrixchosen=matrix;
%     clear chosen_  choices_
%     
%     
%     LickChosenP=[];
%     BlinkChosenP=[];
%     PupilChosenP=[];
%     LickChosenR=[];
%     BlinkChosenR=[];
%     PupilChosenR=[];
%     for x=1:length(PDS.RewardRange1)
%         if ~isnan(matrix(x,3))==1
%             pt=([matrix(x,2)-3500:matrix(x,2)]);
%             rt=([matrix(x,3)-1500:matrix(x,3)]);
%             
%             try
%                 
%                 BlinkChosenP=[BlinkChosenP; Blnksdetect(x,pt)];
%                 PupilChosenP=[PupilChosenP; Pupil(x,pt)];
%                 
%                 BlinkChosenR=[BlinkChosenR; Blnksdetect(x,rt)];
%                 PupilChosenR=[PupilChosenR; Pupil(x,rt)];
%                 
%             catch
%                 
%                 temp(1:3501)=NaN;
%                 BlinkChosenP(x,:)=temp;
%                 PupilChosenP(x,:)=temp;
%                 clear temp
%                 temp(1:1501)=NaN;
%                 BlinkChosenR(x,:)=temp;
%                 PupilChosenR(x,:)=temp;
%                 clear temp;
%             end
%             
%         else
%             
%             
%             temp(1:3501)=NaN;
%             BlinkChosenP(x,:)=temp;
%             PupilChosenP(x,:)=temp;
%             clear temp
%             temp(1:1501)=NaN;
%             BlinkChosenR(x,:)=temp;
%             PupilChosenR(x,:)=temp;
%             clear temp;
%             
%         end
%         
%         clear pt rt
%         
%     end
%     
%     %%
%     %%%%
%     maxpun=find(matrix(:,5)==max(matrix(:,5)));
%     minpun=find(matrix(:,5)==min(matrix(:,5)));
%     %%
%     maxrew=find(matrix(:,4)==max(matrix(:,4)));
%     minrew=find(matrix(:,4)==min(matrix(:,4)));
%     %%
%     %%
%     
% 
%     maxrmaxp=PupilChosenP(intersect(maxrew,maxpun),:);
%     minrmaxp=PupilChosenP(intersect(minrew,maxpun),:);
%     maxrminp=PupilChosenP(intersect(maxrew,minpun),:);
%     minrminp=PupilChosenP(intersect(minrew,minpun),:);
%     
%     maxrmaxp=maxrmaxp(find(nanmean(maxrmaxp')>-999999),:);
%     minrmaxp=minrmaxp(find(nanmean(minrmaxp')>-999999),:);
%     maxrminp=maxrminp(find(nanmean(maxrminp')>-999999),:);
%     minrminp=minrminp(find(nanmean(minrminp')>-999999),:);
%     
% %     figuren;
% %     nsubplot(2, 1, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'));
% %     plot(nanmean(maxrmaxp),'r')
% %     plot(nanmean(minrmaxp),'k')
% %     plot(nanmean(maxrminp),'g')
% %     plot(nanmean(minrminp),'m')
%     
%     savestruct(xyz).maxrmaxpP=maxrmaxp;
%     savestruct(xyz).minrmaxpP=minrmaxp;
%     savestruct(xyz).maxrminpP=maxrminp;
%     savestruct(xyz).minrminpP=minrminp;
%     
%     maxrmaxp=BlinkChosenP(intersect(maxrew,maxpun),:);
%     minrmaxp=BlinkChosenP(intersect(minrew,maxpun),:);
%     maxrminp=BlinkChosenP(intersect(maxrew,minpun),:);
%     minrminp=BlinkChosenP(intersect(minrew,minpun),:);
%     
%         maxrmaxp=maxrmaxp(find(nanmean(maxrmaxp')>-999999),:);
%     minrmaxp=minrmaxp(find(nanmean(minrmaxp')>-999999),:);
%     maxrminp=maxrminp(find(nanmean(maxrminp')>-999999),:);
%     minrminp=minrminp(find(nanmean(minrminp')>-999999),:);
%     
% %     nsubplot(2, 1, 1, 2); set(gca,'ticklength',2*get(gca,'ticklength'));
% %     plot(nanmean(maxrmaxp),'r')
% %     plot(nanmean(minrmaxp),'k')
% %     plot(nanmean(maxrminp),'g')
% %     plot(nanmean(minrminp),'m')
%     
%     savestruct(xyz).maxrmaxpB=maxrmaxp;
%     savestruct(xyz).minrmaxpB=minrmaxp;
%     savestruct(xyz).maxrminpB=maxrminp;
%     savestruct(xyz).minrminpB=minrminp;
% 
%     clear maxrmaxp minrmaxp maxrminp minrminp
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     whichtoshowfirst=PDS.whichtoshowfirst'
%     Angs=[PDS.targAngle1' PDS.targAngle2']
%     Angs=Angs(1,:)
%     
%     LookingTargOf1Rew=[];
%     LookingTargOf1Pun=[];
%     LookingTargOf2Rew=[];
%     LookingTargOf2Pun=[];
%     
%     RTs= (PDS.timeChoice-(PDS.timetargeton+0.5)+1.1)*1000
%     
%     
%     for x=1:length(PDS.timetargeton)
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         try
%             angforoffer1=Angs(whichtoshowfirst(x));
%             angforoffer2=360-angforoffer1;
%             A=[angforoffer1 angforoffer2];
%             RewBar=[-2:1];
%             PunBar=[2:5];
%             
%             templookrewOF1(1:3502)=0;
%             templookpunOF1(1:3502)=0;
%             templookrewOF2(1:3502)=0;
%             templookpunOF2(1:3502)=0;
%             
%             
%             %     tempx=Xeye(x,temp);
%             %     tempy=Yeye(x,temp);
%             
%             %     try
%             %         figuren;
%             %         tempx=Xeye(x,:);
%             %         tempy=Yeye(x,:);
%             %
%             %         line([(PDS.timeChoice(x)*1000) (PDS.timeChoice(x)*1000)],[-40 40],'Color',[1 0 0],'LineWidth',3);
%             %         line([(PDS.TimeofPunish(x)*1000) (PDS.TimeofPunish(x)*1000)],[-40 40],'Color',[1 1 0],'LineWidth',3);
%             %
%             %         plot(tempy,'r');
%             %         plot(tempx,'k')
%             %         xlabel('black is x posi;tion; red is y position')
%             %
%             %         line([100 100],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         line([600 600],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         line([1100 1100],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         line([RTs(x) RTs(x)],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %
%             %
%             %
%             %         %         line([PDS.timefpon(x)*1000 PDS.timefpon(x)*1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         %         line([PDS.timetargeton(x)*1000 PDS.timetargeton(x)*1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         %         line([(PDS.timetargeton(x)*1000)+500 (PDS.timetargeton(x)*1000)+500],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         %    line([(PDS.timetargeton(x)*1000)+1000 (PDS.timetargeton(x)*1000)+1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
%             %         %  line([(PDS.timetargeton(x)*1000)+1000+(1000*PDS.targFixDurReq(x)) (PDS.timetargeton(x)*1000)+1000+(1000*PDS.targFixDurReq(x))],[-40 40],'Color',[0 0 1],'LineWidth',2)
%             %
%             %
%             %         chosenWind=Angs(PDS.chosenwindow(x))
%             %         angs=chosenWind;
%             %         amp=PDS.targAmp(x);
%             %         amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
%             %         location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
%             %         line([1 9000],[location(2) location(2)],'Color',[1 0 0],'LineWidth',2)
%             %         xlim([1 4000])
%             %         title([mat2str(angs) ' ' mat2str(whichtoshowfirst(x))])
%             %         close all
%             %     end
%             
%             
%             tempx=Xeye(x,600:4101);
%             tempy=Yeye(x,600:4101);
%             
%             angs=angforoffer1;
%             amp=PDS.targAmp(x);
%             amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
%             location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
%             windowwidthy=5;
%             windowwidthrewmin=-1;
%             windowwidthrewmax=1;
%             windowwidthpunmin=2;
%             windowwidthpunmax=3;
%             timelookrew=find(tempx>location(1)+windowwidthrewmin & tempx<location(1)+windowwidthrewmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
%             timelookpun=find(tempx>location(1)+windowwidthpunmin & tempx<location(1)+windowwidthpunmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
%             templookrewOF1(timelookrew)=1;
%             templookpunOF1(timelookpun)=1;
%             
%             %        figuren;
%             %     nsubplot(1, 2, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%             %     plot(tempy,'LineWidth',2)
%             %     plot(tempx,'g')
%             %   line([1 501],[location(1) location(1)],'Color',[0 1 0])
%             %    line([1 501],[location(2) location(2)],'Color',[0 0 1])
%             %     xlabel('green is x position')
%             %     ylim([-40 40])
%             %
%             %     nsubplot(1, 2, 1, 2); set(gca,'ticklength',2*get(gca,'ticklength'))
%             %     plot(templookrewOF1,'r','LineWidth',2)
%             %     xlabel('red is reward')
%             %     plot(templookpunOF1,'b')
%             %     title(mat2str(angs))
%             %
%             %     close all
%             
%             clear temp tempx tempy
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             tempx=Xeye(x,600:4101);
%             tempy=Yeye(x,600:4101);
%             
%             
%             angs=angforoffer2;
%             amp=PDS.targAmp(x);
%             amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
%             location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
%             windowwidthy=5;
%             windowwidthrewmin=-1;
%             windowwidthrewmax=1;
%             windowwidthpunmin=2;
%             windowwidthpunmax=3;
%             
%             timelookrew=find(tempx>location(1)+windowwidthrewmin & tempx<location(1)+windowwidthrewmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
%             timelookpun=find(tempx>location(1)+windowwidthpunmin & tempx<location(1)+windowwidthpunmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
%             templookrewOF2(timelookrew)=1;
%             templookpunOF2(timelookpun)=1;
%             
%             %        figuren;
%             %     nsubplot(1, 2, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
%             %     plot(tempy,'LineWidth',2)
%             %     plot(tempx,'g')
%             %   line([1 501],[location(1) location(1)],'Color',[0 1 0])
%             %    line([1 501],[location(2) location(2)],'Color',[0 0 1])
%             %     xlabel('green is x position')
%             %     nsubplot(1, 2, 1, 2); set(gca,'ticklength',2*get(gca,'ticklength'))
%             %     plot(templookrewOF2,'r','LineWidth',2)
%             %     xlabel('red is reward')
%             %     plot(templookpunOF2,'b')
%             %     title(mat2str(angs))
%             %     close all
%             
%             
%             clear temp tempx tempy
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             if PDS.chosenwindow(x)>0
%                 LookingTargOf1Rew=[LookingTargOf1Rew;templookrewOF1];
%                 LookingTargOf1Pun=[LookingTargOf1Pun;templookpunOF1];
%                 LookingTargOf2Rew=[LookingTargOf2Rew;templookrewOF2];
%                 LookingTargOf2Pun=[LookingTargOf2Pun;templookpunOF2];
%             end
%             
%             
%         end
%         clear temp timelook amp angs tempy tempx x c templookrewOF1 templookrewOF2 templookpunOF1 templookpunOF2
%         
%     end
%     
%     savestruct(xyz).LookingTargOf1Pun=LookingTargOf1Pun;
%     savestruct(xyz).LookingTargOf1Rew=LookingTargOf1Rew;
%     savestruct(xyz).LookingTargOf2Pun=LookingTargOf2Pun;
%     savestruct(xyz).LookingTargOf2Rew=LookingTargOf2Rew;
%     clear LookingTargOf1Pun LookingTargOf2Rew LookingTargOf2Pun LookingTargOf1Rew
%     
%     
% end
% 
% 
% filename='gaze.mat'
% save(filename, 'savestruct', '-v7.3')
% 
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');
close all;

load('gaze.mat')


close all

figuren;
maxrmaxpB=vertcat(savestruct(1,:).maxrmaxpB);
minrmaxpB=vertcat(savestruct(1,:).minrmaxpB);
maxrminpB=vertcat(savestruct(1,:).maxrminpB);
minrminpB=vertcat(savestruct(1,:).minrminpB);

plot(sum(maxrmaxpB)./size(maxrmaxpB,1),'b');
plot(sum(minrmaxpB)./size(minrmaxpB,1),'m');
plot(sum(maxrminpB)./size(maxrminpB,1),'g');
plot(sum(minrminpB)./size(minrminpB,1),'r');

figuren;
maxrmaxpP=vertcat(savestruct(1,:).maxrmaxpP);
minrmaxpP=vertcat(savestruct(1,:).minrmaxpP);
maxrminpP=vertcat(savestruct(1,:).maxrminpP);
minrminpP=vertcat(savestruct(1,:).minrminpP);
plot(nanmean(maxrmaxpP),'b');
plot(nanmean(minrmaxpP),'m');
plot(nanmean(maxrminpP),'g');
plot(nanmean(minrminpP),'r');



LookingTargOf1Pun=vertcat(savestruct(1,:).LookingTargOf1Pun);
LookingTargOf1Rew=vertcat(savestruct(1,:).LookingTargOf1Rew);
LookingTargOf2Rew=vertcat(savestruct(1,:).LookingTargOf2Rew);
LookingTargOf2Pun=vertcat(savestruct(1,:).LookingTargOf2Pun);

figuren;
plot(sum(LookingTargOf1Pun)./size(LookingTargOf1Pun,1)*100,'b','LineWidth',2)
plot(sum(LookingTargOf2Pun)./size(LookingTargOf1Pun,1)*100,'m','LineWidth',2)
plot(sum(LookingTargOf1Rew)./size(LookingTargOf1Pun,1)*100,'r','LineWidth',2)
plot(sum(LookingTargOf2Rew)./size(LookingTargOf1Pun,1)*100,'c','LineWidth',2)
xlim([0 1000])
line([500 500],[0 20],'Color',[0 0 0],'LineWidth',2)

LookingTargOf1Pun=sum(LookingTargOf1Pun(:,100:350)')';
LookingTargOf2Pun=sum(LookingTargOf2Pun(:,650:900)')';
LookingTargOf1Rew=sum(LookingTargOf1Rew(:,100:350)')';
LookingTargOf2Rew=sum(LookingTargOf2Rew(:,650:900)')';

sumOf1=LookingTargOf1Pun+LookingTargOf1Rew;
sumOf2=LookingTargOf2Pun+LookingTargOf2Rew;
Of1PunProp=LookingTargOf1Pun./sumOf1;
Of2PunProp=LookingTargOf2Pun./sumOf2;


% index=find(~isnan(Of1PunProp)==1 & ~isnan(Of2PunProp)==1);
% Of1PunProp=Of1PunProp(index)
% Of2PunProp=Of2PunProp(index)

 index=find(~isnan(Of1PunProp)==1);
Of1PunProp=Of1PunProp(index)
 index=find(~isnan(Of2PunProp)==1);
Of2PunProp=Of2PunProp(index)



figuren
bar(1, nanmean(Of1PunProp), 'FaceColor', 'w')
errorbar(1,nanmean(Of1PunProp),nanstd(Of1PunProp)./sqrt(length(Of1PunProp)),'k','LineWidth',1.5); hold on
bar(2, nanmean(Of2PunProp), 'FaceColor', 'w')
errorbar(2,nanmean(Of2PunProp),nanstd(Of2PunProp)./sqrt(length(Of2PunProp)),'k','LineWidth',1.5); hold on
xlim([0 3])
%ranksum(Of1PunProp,Of2PunProp)
%title(mat2str(signrank(Of1PunProp,Of2PunProp)))
title(mat2str(ranksum(Of1PunProp,Of2PunProp)))


set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'gaze' );



