s.boot;
s.quit;
s.meter;
s.plotTree;
s.volume.gui;
Server.freeAll();

(
~maindDir = thisProcess.nowExecutingPath; 
~soundDir = "/Users/oscarmontiel/documents/GitHub/scoll/wavs";
~click1Sound = Buffer.read(s, ~soundDir +/+ "hat.wav");
~pad1 = Buffer.read(s, ~soundDir +/+ "noeresespecial.wav");
~tamb1 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb1.wav");
~tamb2 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb2.wav");
~tamb3 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb3.wav");
~tamb4 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb4.wav");
~tamb5 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb5.wav");
~tamb6 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb6.wav");
~tamb7 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb7.wav");
~tamb8 = Buffer.read(s, ~soundDir +/+ "tamborcito/tamb8.wav");
)

TempoClock.default.tempo = 130/60;

// SynthDefs:
(
SynthDef(\play, { 
  |buf, 
  amp = 1.0, 
  pan = 0.0, 
  atk = 0.001, 
  rel = 0.12, 
  curve = -4, 
  startPos = 0, 
  rate = 1.0|
    var sig = PlayBuf.ar(2, buf, rate: rate, startPos: startPos);
    var env = EnvGen.kr(Env.perc(atk, rel, 1, curve), doneAction: Done.freeSelf);
    sig = sig * env;
    Out.ar(0, Balance2.ar(sig[0], sig[1], pan) * amp);
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
~step = 1/2;  
~burst = Plazy({
    var span   = [1, 2, 3].choose;         
    var window = span * ~step; 
    var n      = rrand(span * 2, span * 5); 
    var ratio  = exprand(0.42, 0.82); 
    var durs   = Array.geom(n, 1, ratio);
    Pseq(durs / durs.sum * window, 1);
});
~cell = Pwrand([
    Pseq([~step], 1), 
    ~burst              
], [0.8, 0.5], inf); 
)


(
~pos = 0;
~seq = Pbind(
    \amp, Pwhite(0.8, 1.0, inf),
    \instrument, \play,
    //\buf, Prand([~tamb1,~tamb2,~tamb3,~tamb4,~tamb5,~tamb6,~tamb7,~tamb8], inf),
    \buf, ~tamb1,
    \startPos, Pdefn(\padStartPos, 10000),
    \dur, ~cell,
    \rate, Pdefn(\seqTambRate, 1.0),
    \pan, 0.0,
    \rel, Pkey(\dur) * Pwhite(0.5, 1.0);
).play;
)

Pdefn(\seqTambRate, 1.0).quant_(2);
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
