s.boot;
s.plotTree;
s.freeAll;

t = TempoClock(130/60).permanent_(true);

~toMax = NetAddr.new("127.0.0.1", 7374);

~toMax.sendMsg('/test', 'bang')

s.options.blockSize;

(
SynthDef(\bleepFm, {
  | atk = 0.01, 
    rel = 0.01, 
    amp = 1.0, 
    pan = 0.0, 
    freq = 440 |
  var sig, env, mod, modHz;
  modHz = XLine.kr(1, 150, 10);
  mod = SinOsc.ar(modHz, mul: 300);
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel), doneAction: 2);
  sig = SinOsc.ar(freq: freq + mod);
  sig = sig * env * amp;
  Out.ar(0, Pan2.ar(sig, pan));
}).add;
)

(
SynthDef(\constantNoise, {
  var sig;
  sig = WhiteNoise.ar();
  sig = sig * (SinOsc.kr(0.2).range(0.01, 0.1) * 0.1);
  Out.ar(0, Pan2.ar(sig, SinOsc.kr(0.1).range(-0.5, 0.5)));
}).add;
)

Synth(\constantNoise);

(
SynthDef(\bleep, {
  | atk = 0.01, 
    rel = 0.01, 
    amp = 1.0, 
    pan = 0.0, 
    freq = 440,
    ampMod = 1.0,
    panRate = 1.0,
    panDepth = 1.0|
  var sig, env, harm, blipSig, ampLfo, panLfo;
  ampLfo = SinOsc.kr(ampMod).range(0.1, 1.0);
  panLfo = SinOsc.kr(ampMod) * panDepth;
  harm = LFPulse.kr(1.0, 1).range(0.1, 10.0);
  env = EnvGen.ar(Env.perc(attackTime: atk, releaseTime: rel), doneAction: 2);
  sig = SinOsc.ar(freq: freq);
  blipSig = Saw.ar(freq: freq, mul: 1.0);
  sig = sig + SinOsc.ar(freq: freq * 0.5, mul: 0.4) + blipSig;
  sig = sig * ampLfo;
  sig = sig * env * amp;
  Out.ar(0, Pan2.ar(sig, panLfo));
}).add;
)

(
Synth(\bleep, 
  [atk: rrand(0.01, 1.0),
  rel: rrand(0.05, 8.0), 
  freq: [261.63, 311.13, 349.23, 392.00, 466.16, 587.33].choose,
  amp: rrand(0.1, 0.8),
  ampMod: rrand(0.1, 5.0),
  panRate: rrand(0.1, 5.0)]
);
)

(
~bleepPattern1 = Pbind(
  \instrument, \bleep,
  \dur, Pdefn(\bleepPattern1Dur, 1/4),
  \rel, Pwhite(0.01, 0.2),
  \freq, Prand([440, 220, 110], inf),
  \pan, Pdefn(\bleepPattern1Pan, 0.0),
  \amp, Pwhite(0.5, 1.0),
  \finish, {
    var freq = ~freq;
    SystemClock.sched(s.latency ? 0, {
      ~toMax.sendMsg('/bang', 'bang', freq);
      nil
    });
  }
);
)


(
~bleepFmPattern1 = Pbind(
  \instrument, \bleepFm,
  \dur, Pdefn(\bleepFmPatternDur, 1/2),
  \rel, Pwhite(0.01, 0.2),
  \freq, Prand([440, 220, 110], inf),
  \pan, Pdefn(\bleepFmPattern1Pan, 0.0),
  \amp, Pwhite(0.5, 1.0),
);
)

(
~bleepPattern1.play(t, quant: 1);
)

(
Pdefn(\bleepFmPattern1Pan, Pfunc({sin(thisThread.beats * 2pi / 4)})).quant(4);
Pdefn(\bleepPattern1Pan, Pwhite(-1.0, 1.0)).quant_(4);
)
Pdefn(\bleepFmPattern1Pan, 0.0).quant(4);
Pdefn(\bleepFmPatternDur, 1/2).quant_(4);
Pdefn(\bleepPattern1Dur, 1/4).quant_(4);
Pdefn(\bleepPattern1Dur, 1/1).quant_(4);
