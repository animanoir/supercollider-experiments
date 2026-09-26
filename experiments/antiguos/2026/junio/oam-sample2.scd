s.boot;
s.freeAll;

~pad1 = Buffer.read(s, "pad1.wav");

(
SynthDef(\pad1, { |buf, rate=1, amp=1, pan=0, cut=0.04, start=0|
    var env = EnvGen.ar(Env.perc(LFNoise0.kr(0.1).range(0.005, 0.2), cut), doneAction: 2);
    var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, startPos: start * BufFrames.kr(buf));
    Out.ar(0, Pan2.ar(sig * amp * env, pan));
}).add;
)

(
TempoClock.default.tempo = 100/60;
Pdef(\clickcut, Pbind(
    \instrument, \pad1,
    \buf, ~pad1,
    \dur, Pwrand([1/16, 1/4, 1/2, Rest(1/4)], [0.4, 0.3, 0.15, 0.15], inf),
    \semi, Pdup(4, Pseq([5, -7, 0, -14], inf)),
    \rate, Pkey(\semi).midiratio,
    \amp, Pwhite(0.8, 1.0),
    \start, Pwhite(0.0, 0.9),
    \cut, Pwhite(0.05, 1.0)
)).play;
)

Pdef(\clickcut).stop;

s.record;
s.stopRecording;
