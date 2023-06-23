clear all; close all;
addpath('C:\Users\Ilya Monosov\Dropbox\HELPER\HELPER_GENERAL');


pathname = 'Y:\MONKEYDATA\Slayer2\Laser test\'; addpath(pathname);
pathname1 = 'Y:\MONKEYDATA\Sabbath\LaserTest\'; addpath(pathname1);
DDD = dir([pathname 'V*.mat']);
DDD1 = dir([pathname1 'V*.mat']);
DDD=[DDD; DDD1];
monk='combined'


for xyz = 1:length(DDD)
    
    filename = DDD(xyz).name(1:end-4);
    load([filename '.mat'],'PDS'); %load session
    
    savestruct(xyz).filename=filename;
    
    millisecondResolution=0.001;
    Xeye=[];
    Yeye=[];
    
    for x=1:length(PDS.timefpon)
        trialanalog=PDS.onlineEye{x};
        %
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
    end
    

    
    whichtoshowfirst=PDS.whichtoshowfirst'
    Angs=[PDS.targAngle1' PDS.targAngle2']
    Angs=Angs(1,:)
    
    LookingTargOf1Rew=[];
    LookingTargOf1Pun=[];
    LookingTargOf2Rew=[];
    LookingTargOf2Pun=[];
    
    RTs= (PDS.timeChoice-(PDS.timetargeton+0.5)+1.1)*1000
    
    
    for x=1:length(PDS.timetargeton)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
        angforoffer1=Angs(whichtoshowfirst(x));
        angforoffer2=360-angforoffer1;
        A=[angforoffer1 angforoffer2];
        RewBar=[-2:1];
        PunBar=[2:5];
        
        templookrewOF1(1:3502)=0;
        templookpunOF1(1:3502)=0;
        templookrewOF2(1:3502)=0;
        templookpunOF2(1:3502)=0;
        
        
        %     tempx=Xeye(x,temp);
        %     tempy=Yeye(x,temp);
        
        %     try
        %         figuren;
        %         tempx=Xeye(x,:);
        %         tempy=Yeye(x,:);
        %
        %         line([(PDS.timeChoice(x)*1000) (PDS.timeChoice(x)*1000)],[-40 40],'Color',[1 0 0],'LineWidth',3);
        %         line([(PDS.TimeofPunish(x)*1000) (PDS.TimeofPunish(x)*1000)],[-40 40],'Color',[1 1 0],'LineWidth',3);
        %
        %         plot(tempy,'r');
        %         plot(tempx,'k')
        %         xlabel('black is x posi;tion; red is y position')
        %
        %         line([100 100],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         line([600 600],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         line([1100 1100],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         line([RTs(x) RTs(x)],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %
        %
        %
        %         %         line([PDS.timefpon(x)*1000 PDS.timefpon(x)*1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         %         line([PDS.timetargeton(x)*1000 PDS.timetargeton(x)*1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         %         line([(PDS.timetargeton(x)*1000)+500 (PDS.timetargeton(x)*1000)+500],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         %    line([(PDS.timetargeton(x)*1000)+1000 (PDS.timetargeton(x)*1000)+1000],[-40 40],'Color',[0 0 1],'LineWidth',2);
        %         %  line([(PDS.timetargeton(x)*1000)+1000+(1000*PDS.targFixDurReq(x)) (PDS.timetargeton(x)*1000)+1000+(1000*PDS.targFixDurReq(x))],[-40 40],'Color',[0 0 1],'LineWidth',2)
        %
        %
        %         chosenWind=Angs(PDS.chosenwindow(x))
        %         angs=chosenWind;
        %         amp=PDS.targAmp(x);
        %         amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
        %         location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
        %         line([1 9000],[location(2) location(2)],'Color',[1 0 0],'LineWidth',2)
        %         xlim([1 4000])
        %         title([mat2str(angs) ' ' mat2str(whichtoshowfirst(x))])
        %         close all
        %     end
        
        
        tempx=Xeye(x,600:4101);
        tempy=Yeye(x,600:4101);
        
        angs=angforoffer1;
        amp=PDS.targAmp(x);
        amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
        location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
        windowwidthy=5;
        windowwidthrewmin=-1;
        windowwidthrewmax=1;
        windowwidthpunmin=2;
        windowwidthpunmax=3;
        timelookrew=find(tempx>location(1)+windowwidthrewmin & tempx<location(1)+windowwidthrewmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
        timelookpun=find(tempx>location(1)+windowwidthpunmin & tempx<location(1)+windowwidthpunmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
        templookrewOF1(timelookrew)=1;
        templookpunOF1(timelookpun)=1;
        
        %        figuren;
        %     nsubplot(1, 2, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
        %     plot(tempy,'LineWidth',2)
        %     plot(tempx,'g')
        %   line([1 501],[location(1) location(1)],'Color',[0 1 0])
        %    line([1 501],[location(2) location(2)],'Color',[0 0 1])
        %     xlabel('green is x position')
        %     ylim([-40 40])
        %
        %     nsubplot(1, 2, 1, 2); set(gca,'ticklength',2*get(gca,'ticklength'))
        %     plot(templookrewOF1,'r','LineWidth',2)
        %     xlabel('red is reward')
        %     plot(templookpunOF1,'b')
        %     title(mat2str(angs))
        %
        %     close all
        
        clear temp tempx tempy
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
   tempx=Xeye(x,600:4101);
        tempy=Yeye(x,600:4101);
        
        
        angs=angforoffer2;
        amp=PDS.targAmp(x);
        amp              = round(amp-0.5); %we do this in the code in tasks, do it here too
        location               = amp*[cosd(360-angs(1)), sind(360-angs(1))];
        windowwidthy=5;
        windowwidthrewmin=-1;
        windowwidthrewmax=1;
        windowwidthpunmin=2;
        windowwidthpunmax=3;
        
        timelookrew=find(tempx>location(1)+windowwidthrewmin & tempx<location(1)+windowwidthrewmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
        timelookpun=find(tempx>location(1)+windowwidthpunmin & tempx<location(1)+windowwidthpunmax & tempy>location(2)-windowwidthy & tempy<location(2)+windowwidthy);
        templookrewOF2(timelookrew)=1;
        templookpunOF2(timelookpun)=1;
        
        %        figuren;
        %     nsubplot(1, 2, 1, 1); set(gca,'ticklength',2*get(gca,'ticklength'))
        %     plot(tempy,'LineWidth',2)
        %     plot(tempx,'g')
        %   line([1 501],[location(1) location(1)],'Color',[0 1 0])
        %    line([1 501],[location(2) location(2)],'Color',[0 0 1])
        %     xlabel('green is x position')
        %     nsubplot(1, 2, 1, 2); set(gca,'ticklength',2*get(gca,'ticklength'))
        %     plot(templookrewOF2,'r','LineWidth',2)
        %     xlabel('red is reward')
        %     plot(templookpunOF2,'b')
        %     title(mat2str(angs))
        %     close all
        
        
        clear temp tempx tempy
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        if PDS.chosenwindow(x)>0
        LookingTargOf1Rew=[LookingTargOf1Rew;templookrewOF1];
        LookingTargOf1Pun=[LookingTargOf1Pun;templookpunOF1];
        LookingTargOf2Rew=[LookingTargOf2Rew;templookrewOF2];
        LookingTargOf2Pun=[LookingTargOf2Pun;templookpunOF2];
        end
     
    
    end
        clear temp timelook amp angs tempy tempx x c templookrewOF1 templookrewOF2 templookpunOF1 templookpunOF2 
        
    end
    
    savestruct(xyz).LookingTargOf1Pun=LookingTargOf1Pun;
    savestruct(xyz).LookingTargOf1Rew=LookingTargOf1Rew;
    savestruct(xyz).LookingTargOf2Pun=LookingTargOf2Pun;
    savestruct(xyz).LookingTargOf2Rew=LookingTargOf2Rew;
    clear LookingTargOf1Pun LookingTargOf2Rew LookingTargOf2Pun LookingTargOf1Rew
    
    
end


filename='gaze.mat'
save(filename, 'savestruct', '-v7.3')


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
addpath('/Users/Ilya/Dropbox/HELPER/HELPER_GENERAL/');
close all;

load('gaze.mat')

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

figuren
bar(1, nanmean(Of1PunProp), 'FaceColor', 'w')
errorbar(1,nanmean(Of1PunProp),nanstd(Of1PunProp)./sqrt(length(Of1PunProp)),'k','LineWidth',1.5); hold on
bar(2, nanmean(Of2PunProp), 'FaceColor', 'w')
errorbar(2,nanmean(Of2PunProp),nanstd(Of2PunProp)./sqrt(length(Of2PunProp)),'k','LineWidth',1.5); hold on
xlim([0 3])
%ranksum(Of1PunProp,Of2PunProp)
title(mat2str(signrank(Of1PunProp,Of2PunProp)))

   set(gcf,'Position',[1 41 2560 1484],'Paperposition',[0 0 26.6667 15.4583], 'Paperpositionmode','auto','Papersize',[26.6667 15.4583]);  % sets the size of the figure and orientation
print('-dpdf', 'gaze' ); 



