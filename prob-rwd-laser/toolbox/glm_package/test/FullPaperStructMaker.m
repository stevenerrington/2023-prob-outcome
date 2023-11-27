clear all;
close all;


fnames = arrayfun(@(z) z.filename,savedata,'uniform',0);
okf = find(startsWith(fnames,'LemmyKim-07292021-004_LaserTest_cl'));
okf
fnames(okf)' 

load('savedata_slayer__2.mat');
savedata1=savedata;
clear savedata

load('savedata_sabbath__1.mat');
savedata=[savedata savedata1]
clear savedata1


drift=[];
for x=1:length(savedata)
    drift=[drift;savedata(x).drift];
end
id=find(abs(drift(:,1))<0.6)
savedata=savedata(id);

 drift=[];
for x=1:length(savedata)
    drift=[drift;savedata(x).driftFP];
end
id=find(abs(drift(:,1))<0.5)
savedata=savedata(id);

% id=(find([savedata(:).exclude]==0 & [savedata(:).seq]<6))
% savedata=savedata(id);

id=(find([savedata(:).goodtrialslength]>180))
savedata=savedata(id);

t=[];
for neuron=1:length(savedata)
    try
        savedata(neuron).sva_bigbehavvalues.model.analysis{ 2 }.neural_corr_with_sv.rho
        savedata(neuron).sva_bigbehavvalues.model.analysis{ 1 }.neural_corr_with_sv.rho
        t=[t;neuron];
    end
end
savedata=savedata(t);



id=(find([savedata(:).variance]<0.001))
savedata=savedata(id);

clc;
length(savedata)

filename ='combinedneuronsOFC.mat'
save(filename, 'savedata', '-v7.3')
% 
