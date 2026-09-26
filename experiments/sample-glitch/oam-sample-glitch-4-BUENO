s.boot;
s.quit;
s.meter;
s.volume.gui;
Server.freeAll();

~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs"

~click1Sound = Buffer.read(s, ~soundDir +/+ "hat.wav");
~pad1 = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav")


TempoClock.default.tempo = 140/60;

// SynthDefs:
(
SynthDef(\play, { |buf, amp = 1.0, pan = 0.0, atk = 0.001, rel = 0.12, curve = -4, startPos = 0, rate = 1.0|
    var sig = PlayBuf.ar(2, buf, rate: rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
    sig = sig * env;
    Out.ar(0, Pan2.ar(sig, pan) * amp);
}).add;
)

(
Pdef(\clickcut, Pbind(
    \instrument, \play,
    \buf, ~pad1,
    \dur, Pwrand([1/16, 1/4, 1/2, Rest(1/4)], [0.4, 0.3, 0.15, 0.15], inf),
    \semi, Pdup(8, Pseq([5, -7, 0, -14], inf)),
    \rate, Pkey(\semi).midiratio,
    \amp, 1.0,
    \start, Pwhite(0.0, 0.9),
    \cut, Pwhite(0.05, 1.0)
)).play;
)

Pdef(\clickcut).stop;


(
~step = 1/4;  
~burst = Plazy({
    var span   = [1, 2, 3 ].choose;         
    var window = span * ~step; 
    var n      = rrand(span * 2, span * 5); 
    var ratio  = exprand(0.45, 0.85); 
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cell = Pwrand([
    Pseq([~step], 1), 
    ~burst              
], [0.8, 0.2], inf); 
)


(
~pos = 0;
~seq = Pbind(
    \amp, Pwhite(0.8, 1.0, inf),
    \instrument, \play,
    \buf, ~pad1,
    \startPos, Pwhite(0, ~pad1.numFrames),
    \dur, ~cell,
    \rate, 1.0,
    \pan, Pwhite(-0.5, 0.5, inf),
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
).play;
)

(
~pos = 0;
~seq = Pbind(
    \amp, Pwhite(0.1, 1.0, inf),
    \instrument, \play,
    \buf, ~click1Sound,
    \startPos, 0,
    \dur, ~cell,
    \rate, Pwhite(0.5, 1.0),
    \pan, Pwhite(-0.5, 0.5, inf),
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
).play;
)

s.record;
s.stopRecording;
