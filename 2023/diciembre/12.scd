Server.default.options.inDevice_("Analogue 1 + 2");
Server.default.options.outDevice_("Analogue 1 + 2 (fniusbwc4800)");
s.volume(0.1);
s.options.sampleRate = 48000;
s.reboot();

thisProcess.nowExecutingPath;

s.waitForBoot {
    var buffer1 = Buffer.read(s, "C:/Users/momom/OneDrive/Documentos/GitHub/SuperColliders/2023/diciembre/amigo.wav");
    var buffer2 = Buffer.read(s, "C:/Users/momom/OneDrive/Documentos/GitHub/SuperColliders/2023/diciembre/amigo.wav");

    var modSignal1 = LFNoise1.kr(0.2).range(0.5, 2.0);
    var modSignal2 = LFNoise1.kr(0.2).range(2.0, 0.5);

	{PlayBuf.ar(1, buffer1, rate: modSignal1)}.play;

    (
        {Pan2.ar(SinOsc.ar(LFNoise1.kr(10).range(500,1500), mul: 0.1), -1)}.play;
        {Pan2.ar(SinOsc.ar(LFNoise1.kr(10).range(500,1500), mul: 0.1), 1)}.play;
    )


    {PlayBuf.ar(1, buffer2, rate: modSignal2)}.play;

    {Dust.ar([12, 15])}.play;
};