function [PDS, c, s] = playnoise(PDS, c, s)
Datapixx('SetAudioSchedule', 0, c.freq, c.nTF, c.lrMode, c.noisebuffadd, c.nTF);
Datapixx('StartAudioSchedule');
Datapixx('RegWrRd');
end