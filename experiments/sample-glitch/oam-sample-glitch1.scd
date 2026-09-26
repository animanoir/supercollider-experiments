s.boot;
s.quit;
s.meter;
Server.freeAll();

~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs"

~click1Sound = Buffer.read(s, ~soundDir +/+ "hat.wav");

(
SynthDef(\soundFile, { |buf, rate=1, amp=1, pan=0, cut=0.04, start=0|
    var env = EnvGen.ar(Env.perc(LFNoise0.kr(0.1).range(0.005, 0.2), cut), doneAction: 2);
    var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, startPos: start * BufFrames.kr(buf));
    Out.ar(0, Pan2.ar(sig * amp * env, pan));
}).add;
)

TempoClock.default.tempo = 100/60;

(
Pdef(\clickcut, Pbind(
    \instrument, \soundFile,
    \buf, ~click1Sound,
    \dur, Pwrand([1/16, 1/4, 1/2, Rest(1/4)], [0.4, 0.3, 0.15, 0.15], inf),
    \semi, Pdup(4, Pseq([5, -7, 0, -14], inf)),
    \rate, Pkey(\semi).midiratio,
    \amp, Pwhite(0.8, 1.0),
    \start, Pwhite(0.0, 0.9),
    \cut, Pwhite(0.05, 1.0)
)).play;
)

Pdef(\clickcut).stop;

// -----


// 1) SynthDef de reproducción (evalúa una vez)
(
SynthDef(\play, { |buf, amp = 1.0, pan = 0.0, atk = 0.001, rel = 0.12, curve = -4, startPos = 0|
    var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf), startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: 2);
    sig = sig * env;
    Out.ar(0, Pan2.ar(sig, pan) * amp);
}).add;
)

// 2) Algoritmo de ráfaga (evalúa una vez)
(
~step = 1/8;  
~burst = Plazy({
    var span   = [1, 2, 3].choose;         
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

TempoClock.default.tempo = 100 / 60;

(
~pos = 0;
~seq = Pbind(
    \instrument, \play,
    \buf, ~click1Sound,
    \dur, ~cell,
    \pan, Pwhite(-0.9, 0.9, inf),
    \rel, Pkey(\dur) * Pwhite(0.1, 1.0);
).play;
)

s.record;
s.stopRecording;
